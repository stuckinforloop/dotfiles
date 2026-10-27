# dotfiles

Each top-level directory is an app's config, linked whole to `~/.config/<app>` by stow (`bin/*` goes to `~/.local/bin`), plus mise for every dev tool. Fish is the only shell this repo supports. `README.md` covers layout and everyday commands.

## Startup budget

Interactive fish startup is ~14ms. Every change to `config.fish` or the mise config stays within that **budget**. Measure before and after:

```sh
hyperfine -N --warmup 3 'fish -i -c exit'
```

The design follows from one number: anything that starts the `mise` binary costs ~15ms.

- **Real binaries on PATH.** `config.fish` caches `mise env` + `mise bin-paths` in `~/.cache/mise/env.fish` and rebuilds it when `config.toml` is newer. Shims sit behind it as a fallback only.
- **Hook-free shell init.** Keep PATH static and cache generated output. `mise activate` adds ~5ms per prompt; a `<tool> init | source` line adds its runtime to every start (zoxide's ~3ms is the one accepted).
- **Fast backends.** Use core, aqua, `go:` or `cargo:` backends. vfox plugins run Lua on every mise invocation (~10ms), which is why neovim and eza name their backend explicitly.

## Adding a tool

1. Add an exact version to `mise/config.toml`. This file is the single install path for dev tools, Go tools included (`"go:<module>" = "<version>"`). `go install`, `cargo install` and pnpm/bun globals are reserved for throwaway experiments.
2. `mise install`, open a new fish shell, and confirm `command -s <tool>` resolves under `~/.local/share/mise/installs/`.

`~/.cargo/bin` appears in `mise bin-paths` (rustup's proxies live there). The cache moves it to the end of PATH so leftover `cargo install` binaries never shadow mise tools.

**Rust:** mise drives rustup, and rustup's default is pinned to the same version so processes outside fish match. When bumping `rust`, also run `rustup default <version>` and `rustup toolchain uninstall <old>`.

## Adding a config file

Stow treats the repo itself as one package targeting `~/.config`, so `~/.config/<app>` is a symlink to `<app>/` and every file an app writes there lands in the working tree. Repo files that aren't app config (docs, `bootstrap.sh`, `bin/`) are listed in `.stow-local-ignore`; a new one needs an entry there, or it gets linked into `~/.config`. `.gitignore` is the **boundary** between config and state:

- `fish`, `git`, `nvim`, `mise`: tracked by default; state files (`fish_variables`, `secrets.fish`) are listed individually.
- `gh`, `pi`: allowlists (`dir/*` then `!config-file`), because those apps keep logins, sessions and caches next to config. New files there stay ignored automatically.
- `~/.config` and `~/.local/bin` stay real directories (`bootstrap.sh` creates them before stowing); `bin` scripts get file links.

**Existing package:** create the file under `~/.config/<app>/`; it is already in the repo.

**New app:**
1. Move `~/.config/<app>` to `<app>/` in the repo, then `./bootstrap.sh link <app>`.
2. Run `git status` and sort every new path into tracked config or `.gitignore`. Use an allowlist when the app stores logins, sessions or caches.

Done when `./bootstrap.sh status` shows the package fully linked and `git status` lists only hand-edited config.

## Scripts

`bootstrap.sh` follows `bin/coffee`'s CLI shape: a usage heredoc with examples, `-h`, `case` dispatch, usage plus exit 1 for an empty or unknown command. Options parse in any position. New subcommands and personal scripts keep that shape.
