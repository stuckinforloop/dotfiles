---
name: worktrees
description: Run work as parallel tasks, each in its own git worktree with its own pi agent in a rex tab, using the wt CLI. Use when starting, stacking, listing, opening or removing tasks, or when your working directory is a task worktree.
---

# Tasks in worktrees

A wt repository keeps one **task** per worktree:

```text
<root>/.bare/     shared repository; task state in .bare/wt/
<root>/main/      default branch
<root>/<task>/    one worktree, one branch, one agent
```

`wt --help` lists every command and flag. `wt ls --json` shows each task's branch, stack parent, agent state (`working`, `waiting`, `idle`, `open`, `closed`) and uncommitted changes.

## Working inside a task

Your task is your worktree's directory name; the system prompt names it, its branch, and its parent. Every edit, build and git command runs inside this worktree, on this branch. The repository's other worktrees belong to agents running right now, so treat them as read-only.

- **Commit** on the task branch. `git push` creates the upstream on first push.
- **A stacked task** is a **layer**: its branch builds on its parent task's branch. A change that belongs in a lower layer goes to that layer's agent, or to the user.
- **Stacks** use `gh stack` (load the gh-stack skill when it is installed). A rebase rewrites every layer's worktree, so it runs only when the user asks.

## Starting tasks for the user

Start a task only when the user asks for parallel work. Use the `wt_start` tool, or `wt start <task> "<prompt>"` from inside the repository.

- **The prompt is everything the new agent knows.** Write it complete: goal, relevant files, constraints, and how to verify the work.
- **Independent tasks** start from the default branch and run in parallel.
- **Dependent work** becomes a stack: `--on <parent>` makes the new task the next layer on the parent's branch. Only the top layer of a stack takes a new layer.

Done when `wt ls` lists each new task with its agent `working` or `idle`.

## Removing a task

- **Finished work** (merged, or committed and kept): `wt rm <task>`. It refuses while the worktree has uncommitted changes, while other tasks are stacked on it, or while it is an unmerged gh stack layer, and keeps an unmerged branch unless `--force` is given.
- **Abandoned work**: `wt drop <task>` discards everything the task made: worktree and changes, branch and commits, its gh stack layer, and the PR and origin branch when wt created the branch. Run `wt drop <task> --dry-run`, show the user that plan, and pass `--yes` only after they confirm it.

Tasks stacked on another go first: remove or drop from the top of a stack down.
