set fish_greeting ""

# aliases
alias ls "eza -l --git"
alias ll ls
alias vim nvim
alias vi nvim
alias ca "claude --dangerously-skip-permissions"
alias devstack devstackctl

# env vars
## xdg base variables (https://specifications.freedesktop.org/basedir/latest/)
set -gx XDG_BIN_HOME "$HOME/.local/bin"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"

set -gx EDITOR nvim
set -gx PI_CODING_AGENT_DIR "$XDG_CONFIG_HOME/pi/agent"

## tool homes (binaries come from mise; these are for globally installed packages)
set -gx GOPATH "$HOME/go"
set -gx GOBIN "$GOPATH/bin"
set -gx PNPM_HOME "$HOME/Library/pnpm"
set -gx BUN_INSTALL "$HOME/.bun"

# PATH
# ~/.local/bin comes from universal fish_user_paths.
# Global package bins (go install, pnpm/bun add -g, cargo install).
fish_add_path -g "$HOME/.cargo/bin" "$GOBIN" "$PNPM_HOME/bin" "$BUN_INSTALL/bin"
# mise shims: fallback for anything missing from the cache below.
fish_add_path -gm "$XDG_DATA_HOME/mise/shims"

## mise env cache
# Every shim call starts mise (~15ms), and so does `mise activate`'s per-prompt hook.
# Instead, cache the tool bin dirs + env (GOROOT, RUSTUP_TOOLCHAIN, ...) once and put
# the real binaries ahead of the shims. The cache is rebuilt when config.toml is newer;
# run `rm ~/.cache/mise/env.fish` to force a rebuild.
set -l mise_config "$XDG_CONFIG_HOME/mise/config.toml"
set -l mise_cache "$XDG_CACHE_HOME/mise/env.fish"
if not test -f $mise_cache; or test (path mtime $mise_config) -gt (path mtime $mise_cache)
    mkdir -p (path dirname $mise_cache)
    begin
        mise env -s fish | string match -rv '^set -gx PATH '
        # ~/.cargo/bin goes last so stale `cargo install`ed binaries don't shadow mise tools
        set -l bins (mise bin-paths)
        set -l cargo_bin (string match -- "$HOME/.cargo/bin" $bins)
        echo set -gx PATH (string escape -- (string match -v -- "$HOME/.cargo/bin" $bins) $cargo_bin) '$PATH'
    end >$mise_cache
end
source $mise_cache

# source secrets.fish if present (not tracked in git)
if test -f "$HOME/.config/fish/secrets.fish"
    source "$HOME/.config/fish/secrets.fish"
end

if status is-interactive
    zoxide init fish | source
end
