#!/usr/bin/env python3
"""
Claude Sessions Popup
Interactive curses UI showing active Claude sessions in a tmux popup.
Navigate with ↑/↓, press Enter to switch to the selected session's pane.
"""
import curses
import json
import os
import subprocess
import sys
import time

STATE_FILE = "/tmp/claude-sessions.json"
REFRESH_INTERVAL = 2.0  # seconds
STALE_THRESHOLD = 30    # seconds; stale if updated_at is older than this

IDLE_STATUSES = {"waiting_for_input", "unknown"}

# Lower number = sorted first
ACTIVE_ORDER = {
    "waiting_for_approval": 0,
    "running_tool": 1,
    "processing": 2,
    "compacting": 3,
    "notification": 4,
    "waiting_for_input": 5,
    "unknown": 6,
}

STATUS_LABELS = {
    "processing":           "processing  ",
    "running_tool":         "running_tool",
    "waiting_for_input":    "waiting     ",
    "waiting_for_approval": "approval!   ",
    "compacting":           "compacting  ",
    "notification":         "notification",
    "unknown":              "unknown     ",
}

STATUS_DOTS = {
    "processing":           "●",
    "running_tool":         "●",
    "waiting_for_input":    "○",
    "waiting_for_approval": "●",
    "compacting":           "●",
    "notification":         "●",
    "unknown":              "○",
}

# Color pair IDs
PAIR_SELECTED   = 1
PAIR_PROCESSING = 2
PAIR_RUNNING    = 3
PAIR_WAITING    = 4
PAIR_APPROVAL   = 5
PAIR_COMPACTING = 6


def load_sessions():
    """Load sessions from state file, filtering out dead PIDs."""
    try:
        with open(STATE_FILE) as f:
            data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return []

    sessions = []
    for session_id, entry in data.items():
        pid = entry.get("pid")
        if pid:
            try:
                os.kill(pid, 0)
            except (OSError, ProcessLookupError):
                continue  # Dead process — skip

        sessions.append((session_id, entry))

    def sort_key(item):
        _, entry = item
        status = entry.get("status", "unknown")
        order = ACTIVE_ORDER.get(status, 99)
        updated = entry.get("updated_at", 0)
        return (order, -updated)

    sessions.sort(key=sort_key)
    return sessions


def get_tty_pane_map():
    """Return dict mapping tty path → 'session:window.pane' target string."""
    try:
        result = subprocess.run(
            [
                "tmux", "list-panes", "-a", "-F",
                "#{pane_tty} #{session_name}:#{window_index}.#{pane_index}",
            ],
            capture_output=True,
            text=True,
            timeout=3,
        )
        mapping = {}
        for line in result.stdout.strip().splitlines():
            parts = line.split(" ", 1)
            if len(parts) == 2:
                mapping[parts[0]] = parts[1]
        return mapping
    except Exception:
        return {}


def get_tty_session_map():
    """Return dict mapping tty path → tmux session name."""
    return {tty: target.split(":")[0] for tty, target in get_tty_pane_map().items()}


def switch_to_pane(tty):
    """Switch tmux client to the pane with the given tty."""
    tty_map = get_tty_pane_map()
    pane_id = tty_map.get(tty)
    if pane_id:
        subprocess.run(["tmux", "switch-client", "-t", pane_id])


def send_message_to_pane(tty, message):
    """Send a message to a tmux pane via send-keys."""
    tty_map = get_tty_pane_map()
    pane_id = tty_map.get(tty)
    if pane_id:
        subprocess.run(["tmux", "send-keys", "-t", pane_id, message, "Enter"])
        return True
    return False


def read_input(stdscr, prompt):
    """Read a line of text from the user, drawn over the last row. Returns None on ESC."""
    height, width = stdscr.getmaxyx()
    row = height - 1
    curses.curs_set(1)
    stdscr.timeout(-1)  # block while typing

    text = []
    while True:
        stdscr.move(row, 0)
        stdscr.clrtoeol()
        line = f" {prompt}: {''.join(text)}"
        try:
            stdscr.addstr(row, 0, line[:width - 1], curses.A_BOLD)
        except curses.error:
            pass
        stdscr.refresh()

        key = stdscr.getch()
        if key in (10, 13):  # Enter
            break
        elif key == 27:  # ESC — cancel
            text = []
            break
        elif key in (curses.KEY_BACKSPACE, 127, 8):
            if text:
                text.pop()
        elif 32 <= key <= 126:  # printable ASCII
            text.append(chr(key))

    curses.curs_set(0)
    stdscr.timeout(200)
    return "".join(text) if text else None


def format_cwd(cwd):
    """Shorten cwd to last two path components."""
    if not cwd:
        return "-"
    parts = cwd.rstrip("/").split("/")
    if len(parts) >= 2:
        return "/".join(parts[-2:])
    return parts[-1] if parts else cwd


def draw(stdscr, sessions, selected, tty_session_map):
    stdscr.erase()
    height, width = stdscr.getmaxyx()
    now = time.time()

    sep = "─" * min(width, 54)

    # Header
    header = "  CLAUDE SESSIONS  [auto-refresh: 2s]"
    try:
        stdscr.addstr(0, 0, header[:width - 1], curses.A_BOLD)
        stdscr.addstr(1, 0, sep)
    except curses.error:
        pass

    # Session rows
    for i, (session_id, entry) in enumerate(sessions):
        row = 2 + i
        if row >= height - 2:
            break

        status = entry.get("status", "unknown")
        tool = entry.get("tool") or None
        tty = entry.get("tty")
        display = tty_session_map.get(tty) if tty else None
        if not display:
            display = format_cwd(entry.get("cwd", ""))
        updated = entry.get("updated_at", 0)
        stale = (now - updated) > STALE_THRESHOLD and status not in IDLE_STATUSES

        dot = STATUS_DOTS.get(status, "○")
        label = STATUS_LABELS.get(status, status.ljust(12))
        indicator = "▶" if i == selected else " "
        tool_str = f"[{tool}]" if tool else "-"

        line = f" {indicator} {dot} {label}  {display:<22}  {tool_str}"
        line = line[:width - 1]

        # Color selection
        if i == selected:
            attr = curses.color_pair(PAIR_SELECTED)
            line = line.ljust(width - 1)
        else:
            if status in ("processing", "notification"):
                attr = curses.color_pair(PAIR_PROCESSING)
            elif status == "running_tool":
                attr = curses.color_pair(PAIR_RUNNING)
            elif status in ("waiting_for_input", "unknown"):
                attr = curses.color_pair(PAIR_WAITING) | curses.A_DIM
            elif status == "waiting_for_approval":
                attr = curses.color_pair(PAIR_APPROVAL) | curses.A_BOLD
            elif status == "compacting":
                attr = curses.color_pair(PAIR_COMPACTING)
            else:
                attr = curses.A_NORMAL

            if stale:
                attr |= curses.A_DIM

        try:
            stdscr.addstr(row, 0, line, attr)
        except curses.error:
            pass

    if not sessions:
        try:
            stdscr.addstr(3, 2, "No active Claude sessions.")
        except curses.error:
            pass

    # Footer
    footer_row = min(2 + len(sessions), height - 2)
    try:
        stdscr.addstr(footer_row, 0, sep)
        help_text = "  [↑/↓] navigate  [Enter] switch  [m] message  [q] quit"
        stdscr.addstr(footer_row + 1, 0, help_text[:width - 1])
    except curses.error:
        pass

    stdscr.refresh()


def main(stdscr):
    curses.curs_set(0)
    stdscr.timeout(200)  # 200ms poll — responsive keys, ~2s refresh

    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(PAIR_SELECTED,   curses.COLOR_BLACK,  curses.COLOR_WHITE)
    curses.init_pair(PAIR_PROCESSING, curses.COLOR_YELLOW, -1)
    curses.init_pair(PAIR_RUNNING,    curses.COLOR_GREEN,  -1)
    curses.init_pair(PAIR_WAITING,    -1,                  -1)
    curses.init_pair(PAIR_APPROVAL,   curses.COLOR_RED,    -1)
    curses.init_pair(PAIR_COMPACTING, curses.COLOR_CYAN,   -1)

    sessions = load_sessions()
    tty_session_map = get_tty_session_map()
    selected = 0
    last_refresh = time.monotonic()
    chosen_tty = None

    while True:
        draw(stdscr, sessions, selected, tty_session_map)
        key = stdscr.getch()

        if key in (ord("q"), ord("Q"), 27):  # q / Q / ESC
            break

        elif key == curses.KEY_UP:
            if sessions:
                selected = (selected - 1) % len(sessions)

        elif key == curses.KEY_DOWN:
            if sessions:
                selected = (selected + 1) % len(sessions)

        elif key in (curses.KEY_ENTER, 10, 13):
            if sessions and 0 <= selected < len(sessions):
                _, entry = sessions[selected]
                tty = entry.get("tty")
                if tty:
                    chosen_tty = tty
                    break

        elif key == ord("m"):
            if sessions and 0 <= selected < len(sessions):
                _, entry = sessions[selected]
                tty = entry.get("tty")
                if tty:
                    message = read_input(stdscr, "Message")
                    if message:
                        send_message_to_pane(tty, message)

        # Reload state every REFRESH_INTERVAL seconds
        now = time.monotonic()
        if now - last_refresh >= REFRESH_INTERVAL:
            sessions = load_sessions()
            tty_session_map = get_tty_session_map()
            if selected >= len(sessions):
                selected = max(0, len(sessions) - 1)
            last_refresh = now

    return chosen_tty


if __name__ == "__main__":
    # curses.wrapper restores the terminal before we call switch_to_pane
    chosen_tty = curses.wrapper(main)
    if chosen_tty:
        switch_to_pane(chosen_tty)
