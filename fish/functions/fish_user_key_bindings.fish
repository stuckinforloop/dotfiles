function fish_user_key_bindings --description "Custom fish key bindings"
    bind -M default ctrl-k worktree
    bind -M insert ctrl-k worktree
    bind -M visual ctrl-k worktree
end
