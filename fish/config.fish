# aliases
source ~/.config/fish/alias.fish

# bindings
bind \cf tmux-sessionizer

# env vars
source ~/.config/fish/env_vars.fish

zoxide init fish | source

# pnpm
set -gx PNPM_HOME "/Users/neel/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# volta
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

# opam configuration
source /Users/neel/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

# rust configuration
source "$HOME/.cargo/env.fish"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# go
set -x GOPATH (go env GOPATH)
set -x PATH $PATH (go env GOPATH)/bin
