# aliases
source ~/.config/fish/alias.fish

# bindings
bind \cf tmux-sessionizer

#personal
source ~/.config/fish/personal.fish

# funnelstory
source ~/.config/fish/funnelstory.fish

zoxide init fish | source

# pnpm
set -gx PNPM_HOME "/Users/neel/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# opam configuration
source /Users/neel/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
