set fish_greeting ""

# aliases
## cli tools
alias ls "eza -l --git"
alias ll "ls"
alias vim "nvim"
alias vi "nvim"

## coding agents
alias ca "claude --dangerously-skip-permissions"
alias codex "codex --dangerously-bypass-approvals-and-sandbox"

# env vars
## xdg base variables (https://specifications.freedesktop.org/basedir/latest/)
set -gx XDG_BIN_HOME "$HOME/.local/bin"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"

## zscaler ca certs
set -gx SSL_CERT_FILE "$XDG_DATA_HOME/ca-certs/combined_ca_bundle.pem"
set -gx CURL_CA_BUNDLE "$XDG_DATA_HOME/ca-certs/combined_ca_bundle.pem"
set -gx REQUESTS_CA_BUNDLE "$XDG_DATA_HOME/ca-certs/combined_ca_bundle.pem"
set -gx NODE_EXTRA_CA_CERTS "$XDG_DATA_HOME/ca-certs/combined_ca_bundle.pem"

## apps
set -gx EDITOR "nvim"
set -gx PI_CODING_AGENT_DIR "$XDG_CONFIG_HOME/pi/agent"
set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"

# devstack v2
fish_add_path "$HOME/.config/devstack/bin"
function devstackctl
    command devstackctl --config $HOME/.config/devstack/config.yaml $argv
end

# source secrets.fish if present
if test -f "$HOME/.config/fish/secrets.fish"
    source "$HOME/.config/fish/secrets.fish"
end

# use global packages with host shell
devbox global shellenv --init-hook | source
zoxide init fish | source
