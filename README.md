# dotfiles

Personal dotfiles managed with GNU Stow, Devbox, and fish shell.

## Bootstrap (new machine)

Run this one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/stuckinforloop/dotfiles/master/Makefile | make -f - remote-bootstrap
```

This will:

1. Install fish (latest GitHub `.pkg`)
2. Set fish as default shell
3. Install devbox
4. Pull and install global devbox packages from `DEVBOX_REPO`
5. Stow dotfiles into `~/.config`

## Local usage

From the repo root:

```bash
make                     # full bootstrap
make devbox-global-pull  # sync global devbox config from DEVBOX_REPO
make devbox-global-push  # push current global devbox config to DEVBOX_REPO
make stow                # apply symlinks
make stow-dry-run
make help
```

## Layout

- `fish/` → `~/.config/fish`
- `git/` → `~/.config/git`
- `tmux/` → `~/.config/tmux`
- `pi/agent/` → `~/.config/pi/agent`
- `templates/` → reusable templates (e.g. `AGENTS_WORKTREE.md` used by `fish/functions/worktree.fish`)
- Global devbox package set is synced via `DEVBOX_REPO` (outside this repo)

## Notes

- Stow target is `~/.config`.
- Stow is executed directly (`stow ...`), so `stow` must be available in your `PATH`.
- Override global config remote via `DEVBOX_REPO` when needed.
- `pi` runtime credentials/sessions should stay untracked (`auth.json`, `sessions/`, caches).
