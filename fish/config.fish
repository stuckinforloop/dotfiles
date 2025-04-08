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
# source "$HOME/.cargo/env.fish"

# go
source $HOME/.g/env
set -gx GOBIN (go env GOPATH)/bin
set -gx GOPATH (go env GOPATH)
set -gx PATH $PATH (go env GOPATH)/bin

# 1pass
set -gx SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# scripts
set -gx PATH $PATH ~/.config/scripts

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/Users/stuckinforloop/.opam/opam-init/init.fish' && source '/Users/stuckinforloop/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

# pnpm
set -gx PNPM_HOME "/Users/stuckinforloop/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
