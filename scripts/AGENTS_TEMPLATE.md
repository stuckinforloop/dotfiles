# Repository Structure

This repository uses a **bare clone + git worktrees** setup.

```
<repo-name>/
  .bare/          # bare git objects — do not modify directly
  .git            # file: "gitdir: ./.bare" — do not modify
  main/           # worktree for main branch (all code lives here)
  <branch>/       # additional worktrees, one per branch
  AGENTS.md       # this file
  CLAUDE.md       # symlink → AGENTS.md
```

**All source code lives inside worktree directories.** The repo root only contains git internals and these docs.

---

# Rules for AI Agents

- **Always work inside a worktree directory** (e.g. `main/`, `feature-xyz/`). Never edit source files in the repo root.
- **Never touch `.bare/` or `.git`** directly.
- When asked to work on a branch, check if its worktree exists before creating one.
- Each worktree is an independent checkout — changes in one do not affect others.

---

# Worktree Commands

**List all worktrees**
```bash
git worktree list
```

**Create a worktree for an existing remote branch**
```bash
git worktree add <branch> <branch>
# e.g. git worktree add feature-xyz feature-xyz
```

**Create a worktree with a new branch**
```bash
git worktree add -b <new-branch> <new-branch>
```

**Remove a worktree** (after merging / no longer needed)
```bash
git worktree remove <branch>
```

---

# Branch Naming Conventions

Format: `<type>/<short-description>`

| Prefix | Use for |
|--------|---------|
| `feature/` | New functionality |
| `fix/` | Bug fixes |
| `hotfix/` | Urgent production fixes |
| `chore/` | Maintenance, dependencies, config |
| `refactor/` | Code restructuring without behavior change |
| `test/` | Adding or updating tests |
| `docs/` | Documentation only |

**Rules**
- Lowercase only
- Hyphens as word separators — no underscores, no spaces
- Keep descriptions short (3–5 words)
- No special characters except `/` and `-`

**Examples**
```
feature/add-upi-payment
fix/null-pointer-on-checkout
chore/update-go-dependencies
refactor/extract-payment-service
test/add-checkout-unit-tests
docs/update-api-reference
hotfix/token-expiry-crash
```

---

# Workflow

**Starting a new feature**
```bash
git worktree add -b feature-xyz feature-xyz
cd feature-xyz
```

**Reviewing a PR / switching context**
```bash
git fetch origin
git worktree add pr-123 origin/pr-branch
cd pr-123
```

**Cleaning up after merge**
```bash
git worktree remove feature-xyz
git branch -d feature-xyz
```
