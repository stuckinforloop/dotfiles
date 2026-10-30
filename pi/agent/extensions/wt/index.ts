/**
 * wt: parallel agent tasks in git worktrees, one rex tab per task.
 *
 * The `wt` CLI (dotfiles bin/wt) owns worktrees, branches, stacks and rex
 * tabs. This extension adds, inside pi:
 *   /wt            navigator over every task in every wt repo
 *   /wt <task>     open or focus a task's tab
 *   wt_list, wt_start tools, so an agent can start tasks for the user
 *   status reporting: a pi running in a task worktree writes its state to
 *   <root>/.bare/wt/status/<task>.json, which `wt ls` and the navigator show
 */
import { existsSync, mkdirSync, readFileSync, renameSync, writeFileSync } from "node:fs";
import { basename, join } from "node:path";
import { Type } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionCommandContext, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { Key, matchesKey, truncateToWidth, type TUI, visibleWidth } from "@earendil-works/pi-tui";

type Task = {
  task: string;
  repo: string;
  root: string;
  branch: string;
  path: string;
  base: string;
  trunk: string;
  parent: string;
  prompt: string;
  created: string;
  state: "working" | "waiting" | "idle" | "open" | "closed";
  changes: number | null;
  open: boolean;
  summary: string;
  updated: string;
};

type CurrentTask = { task: string; branch: string; parent: string; path: string; statusFile: string };

export default function wtExtension(pi: ExtensionAPI): void {
  // --- CLI ------------------------------------------------------------------

  async function wt(args: string[], cwd: string): Promise<string> {
    const result = await pi.exec("wt", args, { cwd, timeout: 120_000 });
    if (result.code !== 0) {
      const reason = result.stderr.trim().split("\n").pop();
      if (reason) throw new Error(reason);
      throw new Error(
        result.code === 127
          ? "wt is not on PATH; link it with: ~/dotfiles/bootstrap.sh link bin"
          : `wt ${args[0]} failed (exit ${result.code})`,
      );
    }
    return result.stdout.trim();
  }

  async function listTasks(cwd: string): Promise<Task[]> {
    const tasks = JSON.parse(await wt(["ls", "--all", "--json"], cwd)) as Task[];
    // Tasks of the repo pi runs in come first, then by repo and age.
    const here = await wtRoot(cwd);
    tasks.sort(
      (a, b) =>
        Number(b.root === here) - Number(a.root === here) ||
        a.repo.localeCompare(b.repo) ||
        a.created.localeCompare(b.created),
    );
    // Each stacked layer goes right below its parent.
    const ordered: Task[] = [];
    const visit = (task: Task) => {
      ordered.push(task);
      for (const child of tasks) if (child.root === task.root && child.parent === task.task) visit(child);
    };
    for (const task of tasks) {
      if (!tasks.some((p) => p.root === task.root && p.task === task.parent)) visit(task);
    }
    return ordered;
  }

  /** The wt root containing cwd, if any. */
  async function wtRoot(cwd: string): Promise<string | undefined> {
    const result = await pi.exec("git", ["rev-parse", "--path-format=absolute", "--git-common-dir"], { cwd });
    const common = result.stdout.trim();
    return result.code === 0 && basename(common) === ".bare" ? common.slice(0, -"/.bare".length) : undefined;
  }

  // --- status reporting -------------------------------------------------------

  let current: CurrentTask | undefined;
  let summary = "";
  // Dialogs opened by the user's own commands (like /wt) are not the agent waiting.
  let running = false;

  async function detectTask(cwd: string): Promise<CurrentTask | undefined> {
    const result = await pi.exec(
      "git",
      ["rev-parse", "--path-format=absolute", "--git-common-dir", "--show-toplevel"],
      { cwd },
    );
    if (result.code !== 0) return undefined;
    const [common, top] = result.stdout.trim().split("\n");
    if (!common || !top || basename(common) !== ".bare") return undefined;
    const task = basename(top);
    const metaFile = join(common, "wt", "tasks", `${task}.json`);
    if (!existsSync(metaFile)) return undefined;
    const meta = JSON.parse(readFileSync(metaFile, "utf8"));
    return {
      task,
      branch: meta.branch,
      parent: meta.parent,
      path: top,
      statusFile: join(common, "wt", "status", `${task}.json`),
    };
  }

  function report(state: "working" | "waiting" | "idle" | "stopped"): void {
    if (!current) return;
    const file = current.statusFile;
    try {
      mkdirSync(join(file, ".."), { recursive: true });
      const body = {
        task: current.task,
        state,
        pid: state === "stopped" ? undefined : process.pid,
        summary,
        updated: new Date().toISOString(),
      };
      writeFileSync(`${file}.tmp`, JSON.stringify(body));
      renameSync(`${file}.tmp`, file);
    } catch {
      // Status is advisory; never fail the session over it.
    }
  }

  pi.on("session_start", async (_event, ctx) => {
    current = await detectTask(ctx.cwd);
    if (!current) return;
    try {
      summary = JSON.parse(readFileSync(current.statusFile, "utf8")).summary ?? "";
    } catch {
      summary = "";
    }
    ctx.ui.setStatus("wt", ctx.ui.theme.fg("accent", `task ${current.task}`));
    report("idle");
  });

  pi.on("before_agent_start", (event) => {
    if (!current) return;
    const stacked = current.parent
      ? ` It is a stacked layer on task "${current.parent}"; change lower layers in their own task, not here.`
      : "";
    event.systemPromptOptions.sections.wt_task = [
      `You are working on task "${current.task}" in the git worktree ${current.path}, on branch ${current.branch}.${stacked}`,
      "Other agents work in sibling worktrees at the same time. Keep every edit and command inside this worktree,",
      "and never check out or switch to another branch here. Load the worktrees skill for anything beyond committing.",
    ].join(" ");
  });

  pi.on("agent_start", () => {
    running = true;
    report("working");
  });
  pi.on("ui_prompt_start", () => {
    if (running) report("waiting");
  });
  pi.on("ui_prompt_end", () => {
    if (running) report("working");
  });
  pi.on("agent_settled", () => {
    running = false;
    report("idle");
  });
  pi.on("message_end", (event) => {
    const message = event.message as { role?: string; content?: Array<{ type: string; text?: string }> };
    if (message.role !== "assistant" || !Array.isArray(message.content)) return;
    const text = message.content.find((part) => part.type === "text" && part.text?.trim())?.text;
    if (text) summary = text.trim().split("\n")[0]!.slice(0, 200);
  });
  pi.on("session_shutdown", (event) => {
    if (event.reason === "quit") report("stopped");
  });

  // --- commands ---------------------------------------------------------------

  const completeTask = async (prefix: string) => {
    try {
      const tasks = await listTasks(process.cwd());
      return tasks
        .filter((t) => t.task.startsWith(prefix))
        .map((t) => ({ value: t.task, label: t.task, description: `${t.repo} · ${t.state}` }));
    } catch {
      return null;
    }
  };

  pi.registerCommand("wt", {
    description: "Navigate parallel agent tasks (wt worktrees); /wt <task> opens one",
    getArgumentCompletions: completeTask,
    handler: async (args, ctx) => {
      const name = args.trim();
      if (name) {
        await openTask(ctx, name);
        return;
      }
      if (ctx.mode !== "tui") {
        ctx.ui.notify("/wt needs the interactive TUI; use `wt ls` instead", "error");
        return;
      }
      await navigator(ctx);
    },
  });

  pi.registerCommand("wt-drop", {
    description: "Discard a task after confirming: tab, worktree, branch, stack layer, PR (default: this task)",
    getArgumentCompletions: completeTask,
    handler: async (args, ctx) => {
      try {
        const tasks = await listTasks(ctx.cwd);
        let name = args.trim() || current?.task;
        if (!name) {
          name = await ctx.ui.select(
            "Drop which task?",
            tasks.map((t) => t.task),
          );
          if (!name) return;
        }
        const here = await wtRoot(ctx.cwd);
        // The same task name can exist in two repos; prefer this repo's.
        const task = tasks.find((t) => t.task === name && t.root === here) ?? tasks.find((t) => t.task === name);
        if (!task) throw new Error(`no task named ${name}`);
        await dropTask(ctx, task);
      } catch (error) {
        ctx.ui.notify((error as Error).message, "error");
      }
    },
  });

  /** Show `wt drop --dry-run`'s plan, and drop only on confirmation. */
  async function dropTask(ctx: ExtensionCommandContext, task: Task): Promise<boolean> {
    const plan = await wt(["drop", task.task, "--dry-run"], task.root);
    const steps = plan
      .split("\n")
      .filter(Boolean)
      .map((line) => `• ${line}`);
    // A select, not confirm, so the highlighted default keeps the task.
    const drop = `Drop ${task.task}`;
    const choice = await ctx.ui.select(
      [`Drop task ${task.task}? This discards its work:`, ...steps].join("\n"),
      [`Keep ${task.task}`, drop],
    );
    if (choice !== drop) return false;
    ctx.ui.setStatus("wt-drop", ctx.ui.theme.fg("warning", `wt: dropping ${task.task}…`));
    try {
      // Dropping this pi's own task closes its tab, which ends this process.
      await wt(["drop", task.task, "--yes"], task.root);
    } finally {
      ctx.ui.setStatus("wt-drop", undefined);
    }
    ctx.ui.notify(`Dropped ${task.task}`, "info");
    return true;
  }

  async function openTask(ctx: ExtensionCommandContext, name: string): Promise<void> {
    try {
      const tasks = await listTasks(ctx.cwd);
      const matches = tasks.filter((t) => t.task === name);
      if (matches.length === 0) throw new Error(`no task named ${name}`);
      // The same task name can exist in two repos; prefer this repo's.
      await wt(["open", name], matches[0]!.root);
      ctx.ui.notify(`Opened ${name}`, "info");
    } catch (error) {
      ctx.ui.notify((error as Error).message, "error");
    }
  }

  async function navigator(ctx: ExtensionCommandContext): Promise<void> {
    let selected: string | undefined;
    while (true) {
      let tasks: Task[];
      try {
        tasks = await listTasks(ctx.cwd);
      } catch (error) {
        ctx.ui.notify((error as Error).message, "error");
        return;
      }
      const action = await ctx.ui.custom<Action>(
        (tui, theme, _keys, done) => new Navigator(tui, theme, tasks, selected, done, () => listTasks(ctx.cwd)),
        { overlay: true, overlayOptions: { anchor: "center", width: "90%", maxHeight: "85%", minWidth: 70 } },
      );
      if (action.kind === "close") return;
      selected = action.task ? `${action.task.root}/${action.task.task}` : selected;
      try {
        if (action.kind === "open" && action.task) {
          await wt(["open", action.task.task], action.task.root);
          ctx.ui.notify(`Opened ${action.task.task}`, "info");
          return;
        }
        if (action.kind === "new" || action.kind === "stack") {
          const root = action.kind === "stack" ? action.task?.root : ((await wtRoot(ctx.cwd)) ?? action.task?.root);
          if (!root) throw new Error("not in a wt repository; create one with: wt clone <url>");
          const on = action.kind === "stack" ? action.task?.task : undefined;
          const started = await startFromDialog(ctx, root, on);
          if (started) selected = `${root}/${started}`;
        }
        if (action.kind === "remove" && action.task) {
          const t = action.task;
          const ok = await ctx.ui.confirm(
            `Remove task ${t.task}?`,
            `Closes its tab, removes ${t.path}, and deletes branch ${t.branch} if it is merged.`,
          );
          if (ok) {
            try {
              await wt(["rm", t.task], t.root);
              ctx.ui.notify(`Removed ${t.task}`, "info");
            } catch (error) {
              // rm keeps work; when only discarding can remove the task, offer that.
              if (!(error as Error).message.includes("wt drop")) throw error;
              ctx.ui.notify((error as Error).message, "warning");
              await dropTask(ctx, t);
            }
          }
        }
        if (action.kind === "drop" && action.task) await dropTask(ctx, action.task);
      } catch (error) {
        ctx.ui.notify((error as Error).message, "error");
      }
    }
  }

  async function startFromDialog(ctx: ExtensionCommandContext, root: string, on?: string): Promise<string | undefined> {
    const title = on ? `New task stacked on ${on} (${basename(root)})` : `New task in ${basename(root)}`;
    const task = (await ctx.ui.input(title, "task-name"))?.trim();
    if (!task) return undefined;
    const prompt = (await ctx.ui.editor(`Prompt for ${task} (empty: start pi without one)`, ""))?.trim();
    if (prompt === undefined) return undefined;
    ctx.ui.setStatus("wt-start", ctx.ui.theme.fg("accent", `wt: starting ${task}…`));
    try {
      await wt(["start", task, ...(on ? ["--on", on] : []), ...(prompt ? [prompt] : [])], root);
    } finally {
      ctx.ui.setStatus("wt-start", undefined);
    }
    ctx.ui.notify(`Started ${task}`, "info");
    return task;
  }

  // --- tools ------------------------------------------------------------------

  pi.registerTool({
    name: "wt_list",
    label: "wt list",
    description:
      "List parallel agent tasks: each runs pi in its own git worktree and rex tab. Shows repo, branch, stack parent, agent state (working, waiting, idle, open, closed), uncommitted changes, and the task prompt.",
    parameters: Type.Object({}),
    async execute(_id, _params, _signal, _onUpdate, ctx) {
      const tasks = await listTasks(ctx.cwd);
      const lines = tasks.map(
        (t) =>
          `${t.repo}/${t.task} [${t.state}] branch=${t.branch}${t.parent ? ` on=${t.parent}` : ""} changes=${t.changes ?? "missing"}` +
          `${t.prompt ? `\n  prompt: ${t.prompt.split("\n")[0]}` : ""}${t.summary ? `\n  last: ${t.summary}` : ""}`,
      );
      return { content: [{ type: "text", text: lines.join("\n") || "No tasks." }], details: undefined };
    },
  });

  pi.registerTool({
    name: "wt_start",
    label: "wt start",
    description:
      "Start a task in a new git worktree with its own pi agent in a new rex tab. Use only when the user asks to start or delegate parallel tasks. Each task should be independent; use `on` only when it builds on another task's unmerged branch (it becomes the next layer of that task's stack).",
    parameters: Type.Object({
      task: Type.String({ description: "Task name: letters, digits, '.', '_', '-'; becomes the directory and branch name" }),
      prompt: Type.String({ description: "Complete instructions for the agent; it sees nothing else from this conversation" }),
      on: Type.Optional(Type.String({ description: "Parent task to stack on" })),
      base: Type.Optional(Type.String({ description: "Base ref for the new branch (default: origin's default branch)" })),
      repo: Type.Optional(Type.String({ description: "Path inside the wt repository (default: current directory)" })),
    }),
    async execute(_id, params, _signal, _onUpdate, ctx) {
      const cwd = params.repo ?? ctx.cwd;
      const args = ["start", params.task, params.prompt];
      if (params.on) args.push("--on", params.on);
      if (params.base) args.push("--base", params.base);
      await wt(args, cwd);
      const path = await wt(["path", params.task], cwd);
      return { content: [{ type: "text", text: `Started ${params.task} in ${path}` }], details: undefined };
    },
  });
}

// --- navigator UI -------------------------------------------------------------

type Action = {
  kind: "close" | "open" | "new" | "stack" | "remove" | "drop";
  task?: Task;
};

const STATE_ICON: Record<Task["state"], string> = {
  working: "●",
  waiting: "?",
  idle: "○",
  open: "○",
  closed: "·",
};

class Navigator {
  private index = 0;
  private timer: ReturnType<typeof setInterval> | undefined;

  constructor(
    private readonly tui: TUI,
    private readonly theme: Theme,
    private tasks: Task[],
    selected: string | undefined,
    private readonly done: (action: Action) => void,
    reload: () => Promise<Task[]>,
  ) {
    const found = tasks.findIndex((t) => `${t.root}/${t.task}` === selected);
    this.index = Math.max(0, found);
    // Agent states change while the navigator is open.
    this.timer = setInterval(() => {
      reload()
        .then((tasks) => {
          const key = this.current && `${this.current.root}/${this.current.task}`;
          this.tasks = tasks;
          const keep = tasks.findIndex((t) => `${t.root}/${t.task}` === key);
          this.index = keep >= 0 ? keep : Math.min(this.index, Math.max(0, tasks.length - 1));
          this.tui.requestRender();
        })
        .catch(() => {});
    }, 3000);
  }

  private get current(): Task | undefined {
    return this.tasks[this.index];
  }

  private finish(action: Action): void {
    this.dispose();
    this.done(action);
  }

  dispose(): void {
    if (this.timer) clearInterval(this.timer);
    this.timer = undefined;
  }

  invalidate(): void {}

  handleInput(data: string): void {
    if (matchesKey(data, Key.escape) || matchesKey(data, Key.ctrl("c")) || data === "q") return this.finish({ kind: "close" });
    if (matchesKey(data, Key.up) || data === "k") return this.move(-1);
    if (matchesKey(data, Key.down) || data === "j") return this.move(1);
    if (matchesKey(data, Key.enter) && this.current) return this.finish({ kind: "open", task: this.current });
    if (data === "n") return this.finish({ kind: "new", task: this.current });
    if (data === "s" && this.current) return this.finish({ kind: "stack", task: this.current });
    if (data === "d" && this.current) return this.finish({ kind: "remove", task: this.current });
    if (data === "x" && this.current) return this.finish({ kind: "drop", task: this.current });
  }

  private move(delta: number): void {
    if (this.tasks.length === 0) return;
    this.index = Math.max(0, Math.min(this.tasks.length - 1, this.index + delta));
    this.tui.requestRender();
  }

  render(width: number): string[] {
    const t = this.theme;
    const inner = Math.max(30, width - 2);
    const height = Math.max(8, Math.min(30, Math.floor((this.tui.terminal.rows ?? 30) * 0.6)));
    const counts = ["working", "waiting", "idle"]
      .map((s) => [s, this.tasks.filter((x) => x.state === s).length] as const)
      .filter(([, n]) => n > 0)
      .map(([s, n]) => `${n} ${s}`)
      .join(" · ");
    const title = t.fg("accent", t.bold("Tasks"));
    const right = t.fg("muted", counts || `${this.tasks.length} tasks`);
    const header = `${title}${" ".repeat(Math.max(1, inner - visibleWidth(title) - visibleWidth(right)))}${right}`;

    let body: string[];
    if (inner >= 80) {
      const left = Math.floor(inner * 0.5);
      const rightW = inner - left - 1;
      const list = this.renderList(left, height);
      const detail = this.renderDetail(rightW, height);
      body = list.map((line, i) => `${fit(line, left)}${t.fg("borderMuted", "│")}${fit(detail[i] ?? "", rightW)}`);
    } else {
      body = this.renderList(inner, height);
    }

    const bar = (l: string, r: string, color: "borderAccent" | "borderMuted" = "borderAccent") =>
      t.fg(color, `${l}${"─".repeat(inner)}${r}`);
    const line = (s: string) => `${t.fg("borderAccent", "│")}${fit(s, inner)}${t.fg("borderAccent", "│")}`;
    return [
      bar("┌", "┐"),
      line(header),
      bar("├", "┤", "borderMuted"),
      ...body.map(line),
      bar("├", "┤", "borderMuted"),
      line(t.fg("dim", "↑↓ move · enter open · n new · s stack on · d remove · x drop · esc close")),
      bar("└", "┘"),
    ];
  }

  private stateText(task: Task): string {
    const t = this.theme;
    const icon = STATE_ICON[task.state];
    switch (task.state) {
      case "working":
        return t.fg("success", `${icon} working`);
      case "waiting":
        return t.fg("warning", `${icon} waiting`);
      case "idle":
        return t.fg("accent", `${icon} idle`);
      case "open":
        return t.fg("muted", `${icon} open`);
      default:
        return t.fg("dim", `${icon} closed`);
    }
  }

  private renderList(width: number, height: number): string[] {
    const t = this.theme;
    if (this.tasks.length === 0) {
      return pad([t.fg("dim", " No tasks. Press n to start one, or run: wt start <task> [prompt]")], height);
    }
    const rows: string[] = [];
    let repo = "";
    this.tasks.forEach((task, i) => {
      if (task.repo !== repo) {
        repo = task.repo;
        rows.push(t.fg("muted", ` ${repo}`));
      }
      const depth = depthOf(task, this.tasks);
      const name = `${"  ".repeat(depth)}${depth ? "└ " : ""}${task.task}`;
      const changes = task.changes ? t.fg("warning", ` ±${task.changes}`) : "";
      const row = `${i === this.index ? "›" : " "} ${name}${changes}`;
      const state = this.stateText(task);
      const gap = Math.max(1, width - visibleWidth(row) - visibleWidth(state) - 1);
      const text = `${row}${" ".repeat(gap)}${state}`;
      rows.push(i === this.index ? t.bold(text) : text);
    });
    // Keep the selection visible.
    const selectedRow = rows.findIndex((r) => r.includes("›"));
    const start = Math.max(0, Math.min(selectedRow - Math.floor(height / 2), rows.length - height));
    return pad(rows.slice(start, start + height), height);
  }

  private renderDetail(width: number, height: number): string[] {
    const t = this.theme;
    const task = this.current;
    if (!task) return pad([], height);
    const field = (label: string, value: string) => `${t.fg("muted", label.padEnd(10))}${value}`;
    const lines = [
      t.fg("accent", t.bold(` ${task.task}`)),
      "",
      field(" branch", task.branch),
      ...(task.parent ? [field(" on", task.parent)] : []),
      field(" agent", this.stateText(task)),
      field(" changes", task.changes === null ? t.fg("error", "worktree missing") : String(task.changes)),
      field(" path", task.path.replace(process.env.HOME ?? "", "~")),
      "",
      t.fg("muted", " prompt"),
      ...wrap(task.prompt || t.fg("dim", "(none)"), width - 2).map((l) => `  ${l}`),
    ];
    if (task.summary) lines.push("", t.fg("muted", " last message"), ...wrap(task.summary, width - 2).map((l) => `  ${l}`));
    return pad(lines.map((l) => truncateToWidth(l, width)), height);
  }
}

function depthOf(task: Task, tasks: Task[]): number {
  let depth = 0;
  let parent = task.parent;
  while (parent && depth < 10) {
    const p = tasks.find((t) => t.root === task.root && t.task === parent);
    if (!p) break;
    depth++;
    parent = p.parent;
  }
  return depth;
}

function fit(text: string, width: number): string {
  const cut = truncateToWidth(text, Math.max(0, width));
  return cut + " ".repeat(Math.max(0, width - visibleWidth(cut)));
}

function pad(lines: string[], height: number): string[] {
  const out = lines.slice(0, height);
  while (out.length < height) out.push("");
  return out;
}

function wrap(text: string, width: number): string[] {
  const out: string[] = [];
  for (const para of text.split("\n")) {
    let line = "";
    for (const word of para.split(/\s+/)) {
      if (line && visibleWidth(line) + 1 + visibleWidth(word) > width) {
        out.push(line);
        line = word;
      } else {
        line = line ? `${line} ${word}` : word;
      }
    }
    out.push(line);
  }
  return out.slice(0, 12);
}
