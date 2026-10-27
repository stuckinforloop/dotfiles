# dotfiles

Dotfiles linked into place with [GNU Stow](https://www.gnu.org/software/stow/). Tools managed by [mise](https://mise.jdx.dev), with no shell hook.

Each call through a mise shim takes ~15ms, because mise has to start. So `config.fish` caches mise's bin dirs and env vars in `~/.cache/mise/env.fish` and puts the real binaries first on `PATH`. The shims stay as a fallback. The cache rebuilds automatically when `config.toml` is newer than it; `rm ~/.cache/mise/env.fish` forces a rebuild.

## Setup

```sh
git clone git@github.com:stuckinforloop/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh install
```

`bootstrap.sh --help` lists the other commands (`deps`, `link`, `unlink`, `tools`, `status`); `-n` previews any of them.

## Layout

Each top-level directory is an app's config directory, linked whole: `fish/` becomes `~/.config/fish`, and `bin/*` goes into `~/.local/bin`.

| package | links | tracked |
|---|---|---|
| `fish` | `~/.config/fish` | everything except `fish_variables`, `secrets.fish` |
| `git`  | `~/.config/git`  | everything |
| `nvim` | `~/.config/nvim` | everything |
| `mise` | `~/.config/mise` | everything |
| `gh`   | `~/.config/gh`   | `config.yml` only |
| `pi`   | `~/.config/pi`   | `agent/settings.json` only |
| `bin`  | `~/.local/bin/*` | personal scripts (file links; the directory holds other binaries) |

Stow treats the repo itself as one package targeting `~/.config`; `.stow-local-ignore` keeps repo files (README, `bootstrap.sh`, `bin/`) out of it. App state and secrets written into linked directories live in the repo folder but are git-ignored (see `.gitignore`). `bootstrap.sh` creates `~/.config` and `~/.local/bin` as real directories first, so stow never links them whole.

## Common tasks

```sh
./bootstrap.sh status     # link state per package, missing tools
./bootstrap.sh link fish  # link a package (new packages, or bin/ scripts)
./bootstrap.sh unlink gh  # remove a package's links
mise install              # install tools after editing config.toml
mise outdated             # check for updates
mise upgrade --bump       # upgrade and rewrite pins
```
