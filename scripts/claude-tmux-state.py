#!/usr/bin/env python3
"""
Claude tmux State Hook
- Maintains /tmp/claude-sessions.json for the claude-popup.py UI
- Mirrors event→status logic from claude-island-state.py
"""
import fcntl
import json
import os
import sys
import time

STATE_FILE = "/tmp/claude-sessions.json"


def get_tty():
    """Get the TTY of the Claude process (parent)."""
    import subprocess

    ppid = os.getppid()

    try:
        result = subprocess.run(
            ["ps", "-p", str(ppid), "-o", "tty="],
            capture_output=True,
            text=True,
            timeout=2,
        )
        tty = result.stdout.strip()
        if tty and tty != "??" and tty != "-":
            if not tty.startswith("/dev/"):
                tty = "/dev/" + tty
            return tty
    except Exception:
        pass

    try:
        return os.ttyname(sys.stdin.fileno())
    except (OSError, AttributeError):
        pass
    try:
        return os.ttyname(sys.stdout.fileno())
    except (OSError, AttributeError):
        pass
    return None


def update_state(session_id, entry, remove=False):
    """Safely update the session state file using exclusive file locking."""
    with open(STATE_FILE, "a+") as fd:
        fcntl.flock(fd, fcntl.LOCK_EX)
        try:
            fd.seek(0)
            content = fd.read()
            try:
                sessions = json.loads(content) if content.strip() else {}
            except json.JSONDecodeError:
                sessions = {}

            if remove:
                sessions.pop(session_id, None)
            else:
                sessions[session_id] = entry

            fd.seek(0)
            fd.truncate()
            json.dump(sessions, fd, indent=2)
            fd.flush()
        finally:
            fcntl.flock(fd, fcntl.LOCK_UN)


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(1)

    session_id = data.get("session_id", "unknown")
    event = data.get("hook_event_name", "")
    cwd = data.get("cwd", "")

    # Skip PermissionRequest - Island app handles that flow
    if event == "PermissionRequest":
        sys.exit(0)

    # SessionEnd: remove the entry
    if event == "SessionEnd":
        update_state(session_id, None, remove=True)
        sys.exit(0)

    claude_pid = os.getppid()
    tty = get_tty()

    entry = {
        "cwd": cwd,
        "pid": claude_pid,
        "tty": tty,
        "updated_at": time.time(),
    }

    if event == "UserPromptSubmit":
        entry["status"] = "processing"

    elif event == "PreToolUse":
        entry["status"] = "running_tool"
        entry["tool"] = data.get("tool_name")

    elif event == "PostToolUse":
        entry["status"] = "processing"

    elif event == "Notification":
        notification_type = data.get("notification_type")
        # permission_prompt is handled by PermissionRequest hook
        if notification_type == "permission_prompt":
            sys.exit(0)
        elif notification_type == "idle_prompt":
            entry["status"] = "waiting_for_input"
        else:
            entry["status"] = "notification"

    elif event == "Stop":
        entry["status"] = "waiting_for_input"

    elif event == "SubagentStop":
        entry["status"] = "waiting_for_input"

    elif event == "SessionStart":
        entry["status"] = "waiting_for_input"

    elif event == "PreCompact":
        entry["status"] = "compacting"

    else:
        entry["status"] = "unknown"

    update_state(session_id, entry)


if __name__ == "__main__":
    main()
