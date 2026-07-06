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
alias devin "devin --permission-mode dangerous"

# env vars
## xdg base variables (https://specifications.freedesktop.org/basedir/latest/)
set -gx XDG_BIN_HOME "$HOME/.local/bin"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"

## apps
set -gx EDITOR "nvim"
set -gx PI_CODING_AGENT_DIR "$XDG_CONFIG_HOME/pi/agent"
set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
set -gx CLAUDE_CODE_TMUX_TRUECOLOR "1"

# source secrets.fish if present
if test -f "$HOME/.config/fish/secrets.fish"
    source "$HOME/.config/fish/secrets.fish"
end

# add to path
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.config/scripts"
fish_add_path "$HOME/.cache/.bun/bin/"

# use global packages with host shell
devbox global shellenv --init-hook | source
zoxide init fish | source

# Added by Devin
fish_add_path /Users/stuckinforloop/.codeium/windsurf/bin
