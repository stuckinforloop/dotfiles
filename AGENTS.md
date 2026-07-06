# AGENTS.md

Guidance for coding agents working in this dotfiles repository.

## Purpose

This repo stores user configuration under a dotfiles layout intended to be deployed mostly into `~/.config`, primarily via GNU Stow, with some non-`~/.config` state tracked separately when explicitly documented.

Agents should prefer small, safe changes and preserve the existing layout unless explicitly asked to restructure it.

## Repo layout

Top-level directories are treated as stow packages:

- `fish/`
- `git/`
- `gh/`
- `ghostty/`
- `kitty/`
- `tmux/`
- `nvim/`
- `devstack/` — local devstack config, flows, and helper binaries
- `devbox/`
- `pi/`

Additional directories:

- `scripts/` — helper scripts; not usually stowed directly into `~/.config`

## Deployment model

Expected local checkout:

```bash
~/.config/dotfiles
```

Primary deployment target:

```bash
~/.config
```

Typical stow command:

```bash
cd ~/.config/dotfiles
stow --target="$HOME/.config" fish git gh ghostty kitty tmux nvim devstack pi
```

To restow after edits:

```bash
stow --restow --target="$HOME/.config" fish git gh ghostty kitty tmux nvim devstack pi
```

`devbox/` is intentionally not part of the `~/.config` stow target. It tracks Devbox global package files that live under:

```bash
~/.local/share/devbox/global/default
```

To remove a package:

```bash
stow --delete --target="$HOME/.config" fish
```

## Editing guidance

- Keep changes localized to the relevant package.
- Preserve XDG-oriented paths when possible.
- Prefer portable config unless the file is clearly macOS-specific.
- Do not move files across packages without updating `README.md` and this file.
- If adding a new top-level config directory, document it in `README.md` and this file.

## Secrets and sensitive files

Never commit secrets or machine-local auth/session state.

Currently ignored via root `.gitignore`:

- `fish/secrets.fish`
- `fish/fish_variables`
- `gh/hosts.yml`
- `pi/agent/auth.json`
- `pi/agent/sessions/`
- `pi/agent/.extmgr-cache/`
- `pi/agent/models.json`
- `pi/agent/npm/`
- `pi/agent/trust.json`

If a new config introduces credentials, tokens, session files, or host-specific state, update the root `.gitignore`.

## Fish-specific notes

- Main file: `fish/config.fish`
- Local secrets should go in `fish/secrets.fish`
- `fish/config.fish` is expected to source `secrets.fish` only if it exists

When adding environment variables with sensitive values, place examples in docs but keep real values in `fish/secrets.fish`.

## Devbox notes

- `devbox/` tracks the contents of:

```bash
~/.local/share/devbox/global/default
```

- Track these files as normal files in the repo:
  - `devbox/global/default/devbox.json`
  - `devbox/global/default/devbox.lock`
- The live files under `~/.local/share/devbox/global/default/` should be symlinks pointing back to the repo copy.
- Do not commit `.devbox/` runtime state, caches, or generated ephemeral files.
- This repo’s global Git ignore ignores `devbox.json` and `devbox.lock` broadly, but explicitly re-includes the tracked files under `devbox/global/default/`.

## Scripts

`scripts/` contains helper utilities and may be symlinked separately, e.g.:

```bash
ln -sfn ~/.config/dotfiles/scripts ~/.config/scripts
```

Do not assume scripts are automatically on `PATH` unless the shell config adds that path.

## README sync

If you change setup instructions, stow usage, package layout, or ignored sensitive files, update `README.md` in the same change.
