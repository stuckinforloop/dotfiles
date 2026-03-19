set fish_greeting ""

# aliases
alias ls "eza -l --git"
alias ll "ls"
alias ta "tmux at"
alias vim "nvim"
alias vi "nvim"
alias codex "codex --dangerously-bypass-approvals-and-sandbox"

# env vars
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx EDITOR "nvim"
set -gx PI_CODING_AGENT_DIR "$HOME/.config/pi/agent"

# sensitive env vars
if test -f "$HOME/.config/fish/secrets.fish"
    source "$HOME/.config/fish/secrets.fish"
end

# source apps
devbox global shellenv --init-hook | source
zoxide init fish | source
