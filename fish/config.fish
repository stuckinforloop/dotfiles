# aliases
source ~/.config/fish/alias.fish

# bindings
bind \cf tmux-sessionizer

# env vars
# source ~/.config/fish/env_vars.fish

zoxide init fish | source

# brew
set -gx HOMEBREW_NO_ENV_HINTS true

# rust configuration
# source "$HOME/.cargo/env.fish"

# go
set -gx GOPATH (go env GOPATH)
set -gx PATH $PATH (go env GOPATH)/bin

# 1pass
set -gx SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# scripts
set -gx PATH $PATH ~/.config/scripts
