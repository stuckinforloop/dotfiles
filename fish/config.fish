# aliases
source ~/.config/fish/alias.fish

# bindings
bind \cf tmux-sessionizer

# env vars
source ~/.config/fish/env_vars.fish

zoxide init fish | source

# brew
set -gx HOMEBREW_NO_ENV_HINTS true

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
set -gx GOPATH (go env GOPATH)
set -gx PATH $PATH (go env GOPATH)/bin

# 1pass
set -gx SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Setting PATH for Python 3.12
# The original version is saved in /Users/neel/.config/fish/config.fish.pysave
set -x PATH "/Library/Frameworks/Python.framework/Versions/3.12/bin" "$PATH"

pyenv init - | source
eval "$(pyenv virtualenv-init -)"
