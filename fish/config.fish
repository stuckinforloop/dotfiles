set fish_greeting ""

if status is-interactive
    bind \ck 'commandline -r "worktree"; commandline -f execute'
end

# aliases
alias ls "eza -l --git"
alias ll "ls"
alias ta "tmux at"
alias vim "nvim"
alias vi "nvim"
alias codex "codex --dangerously-bypass-approvals-and-sandbox"
alias helmfile "helmfile --enable-live-output -b werf"
alias ca "claude --dangerously-skip-permissions"

# env vars
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx EDITOR "nvim"
set -gx PI_CODING_AGENT_DIR "$HOME/.config/pi/agent"
set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"

set -gx SSL_CERT_FILE "$HOME/.local/share/ca-certs/combined_ca_bundle.pem"
set -gx CURL_CA_BUNDLE "$HOME/.local/share/ca-certs/combined_ca_bundle.pem"
set -gx REQUESTS_CA_BUNDLE "$HOME/.local/share/ca-certs/combined_ca_bundle.pem"
set -gx NODE_EXTRA_CA_CERTS "$HOME/.local/share/ca-certs/combined_ca_bundle.pem"


# sensitive env vars
if test -f "$HOME/.config/fish/secrets.fish"
    source "$HOME/.config/fish/secrets.fish"
end

# source apps
devbox global shellenv --init-hook | source
zoxide init fish | source
