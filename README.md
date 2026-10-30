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

Each top-level directory is an app's config directory, linked whole: `fish/` becomes `~/.config/fish`, `bin/*` goes into `~/.local/bin`, and `skills/*` into `~/.agents/skills`.

| package | links | tracked |
|---|---|---|
| `fish` | `~/.config/fish` | everything except `fish_variables`, `secrets.fish` |
| `git`  | `~/.config/git`  | everything |
| `nvim` | `~/.config/nvim` | everything |
| `mise` | `~/.config/mise` | everything |
| `gh`   | `~/.config/gh`   | `config.yml` only |
| `pi`   | `~/.config/pi`   | `agent/settings.json`, `agent/extensions/` |
| `bin`  | `~/.local/bin/*` | personal scripts (file links; the directory holds other binaries) |
| `skills` | `~/.agents/skills/*` | agent skills (directory links; skill installers share the directory) |

Stow treats the repo itself as one package targeting `~/.config`; `.stow-local-ignore` keeps repo files (README, `bootstrap.sh`, `bin/`, `skills/`) out of it. App state and secrets written into linked directories live in the repo folder but are git-ignored (see `.gitignore`). `bootstrap.sh` creates `~/.config`, `~/.local/bin` and `~/.agents/skills` as real directories first, so stow never links them whole.

## Parallel agent tasks

`wt` runs one pi agent per task, each in its own git worktree and rex tab. Independent tasks get a rex session each; a task stacked with `--on` becomes the next [gh stack](https://github.com/github/gh-stack) layer and a tab in its stack's session.

```sh
wt clone git@github.com:acme/api.git   # api/.bare + api/main
cd api/main
wt start fix-login "Fix the login redirect loop"
wt start auth-ui --on auth-api "Build the login form"
wt ls --all                            # every task, with agent state
```

`wt rm` removes finished tasks and refuses to lose work; `wt drop` discards an abandoned task (worktree, branch, stack layer, and its PR and origin branch if wt created them) after showing what it will delete.

Inside pi, `/wt` opens a navigator over every task (enter opens a tab, `n` new, `s` stack, `d` remove, `x` drop), `/wt-drop [task]` drops a task (default: the current one) after a confirmation that defaults to keeping it, and the `wt_start` tool lets an agent start tasks for you. The pi extension (`pi/agent/extensions/wt`) also reports each task agent's state, and the `worktrees` skill tells task agents how to work in a worktree. Stacking needs `gh extension install github/gh-stack`; switching tabs needs Remote Control on in Rex.app (Settings > Rex Server).

## Common tasks

```sh
./bootstrap.sh status     # link state per package, missing tools
./bootstrap.sh link fish  # link a package (new packages, or bin/ scripts)
./bootstrap.sh unlink gh  # remove a package's links
mise install              # install tools after editing config.toml
mise outdated             # check for updates
mise upgrade --bump       # upgrade and rewrite pins
```
