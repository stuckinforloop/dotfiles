# aliases
source ~/.config/fish/alias.fish

# bindings
bind \cf tmux-sessionizer

# env vars
source ~/.config/fish/env_vars.fish

zoxide init fish | source

# brew
set -gx HOMEBREW_NO_ENV_HINTS true

# rust configuration
source "$HOME/.cargo/env.fish"

# go
source $HOME/.g/env
# set -gx GOBIN (go env GOPATH)/bin
# set -gx GOPATH (go env GOPATH)
# # set -gx PATH $PATH (go env GOPATH)/bin
# # set -gx GOPATH $HOME/go
set -gx PATH $PATH $GOPATH/bin

#php
set -gx PATH $PATH /opt/homebrew/opt/php@8.1/bin
set -gx PATH $PATH /opt/homebrew/opt/php@8.1/sbin

#python
set -gx PATH $PATH /Users/neel.modi/Library/Python/3.9/bin

#orbstack
set -gx PATH $PATH ~/.orbstack/bin

# 1pass
set -gx SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# scripts
set -gx PATH $PATH ~/.config/scripts

set -gx PATH $PATH ~/.devstack/bin

set -gx PATH $PATH ~/.volta/bin

set -gx PATH $PATH ~/.local/bin

fzf --fish | source
