# dotfiles

Personal dotfiles for a macOS development setup centered around Fish, Neovim, tmux, Ghostty, GitHub CLI, Devbox, devstack, and the pi coding agent.

## What’s in here

- `fish/` — shell config, aliases, environment variables, and local secret sourcing
- `git/` — Git config and global ignore file
- `gh/` — GitHub CLI configuration
- `ghostty/` — terminal configuration
- `tmux/` — terminal multiplexer config
- `nvim/` — Neovim configuration
- `devstack/` — local devstack config, flows, and helper binaries
- `devbox/` — tracked Devbox global package definitions
- `pi/agent/` — pi coding agent settings
- `scripts/` — small utility scripts

## Sensitive files

This repo intentionally keeps machine-local or secret-bearing files out of git via the root `.gitignore`.

Ignored files include:

- `fish/secrets.fish` — local Fish secrets such as API keys
- `fish/fish_variables` — machine-local Fish universal variables
- `gh/hosts.yml` — GitHub CLI authentication state
- `pi/agent/auth.json`
- `pi/agent/sessions/`
- `pi/agent/.extmgr-cache/`
- `pi/agent/models.json`

## Fish secrets

`fish/config.fish` will source `~/.config/fish/secrets.fish` only if it exists.

Example:

```fish
set -gx OPENAI_API_KEY "..."
set -gx ANTHROPIC_API_KEY "..."
```

## Setup

This repo is meant to be used under `~/.config`.

Example:

```bash
git clone <your-repo-url> ~/.config/dotfiles
cd ~/.config/dotfiles
```

## Using with GNU Stow

This repo is structured so each top-level directory can be stowed into `~/.config`.

Install stow if needed:

```bash
brew install stow
```

From the repo root:

```bash
cd ~/.config/dotfiles
stow --target="$HOME/.config" fish git gh ghostty tmux nvim devstack pi
```

This will create symlinks like:

- `~/.config/fish -> ~/.config/dotfiles/fish`
- `~/.config/nvim -> ~/.config/dotfiles/nvim`
- `~/.config/tmux -> ~/.config/dotfiles/tmux`

To stow only one package:

```bash
stow --target="$HOME/.config" fish
```

To restow after changes:

```bash
stow --restow --target="$HOME/.config" fish git gh ghostty tmux nvim devstack pi
```

To remove symlinks managed by stow:

```bash
stow --delete --target="$HOME/.config" fish
```

## Devbox global packages

`devbox/` contains tracked Devbox global files sourced from `~/.local/share/devbox/global/default`.

Tracked files:

- `devbox/global/default/devbox.json`
- `devbox/global/default/devbox.lock`

These repo files are intended to be the source of truth and are symlinked into the live Devbox location:

```bash
mkdir -p ~/.local/share/devbox/global/default
ln -sfn ~/.config/dotfiles/devbox/global/default/devbox.json ~/.local/share/devbox/global/default/devbox.json
ln -sfn ~/.config/dotfiles/devbox/global/default/devbox.lock ~/.local/share/devbox/global/default/devbox.lock
```

This keeps the file contents visible in GitHub while still allowing Devbox to read them from its expected location.

### Scripts

The `scripts/` directory is not under `~/.config` semantically. If you want these on your `PATH`, symlink them separately, for example:

```bash
ln -sfn ~/.config/dotfiles/scripts ~/.config/scripts
```

## Notes

- Paths are largely organized around the XDG base directory layout.
- Some configs are intentionally portable; others are macOS-specific.
- Secrets should live in ignored local files, not tracked config.
