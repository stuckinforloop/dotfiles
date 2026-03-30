#!/usr/bin/env bash

# 1. Select the path
# If an argument is provided, use it.
if [[ $# -eq 1 ]]; then
    selected=$1
else
    # If no argument, use fzf to select a directory.
    # ADJUST THE SEARCH PATHS BELOW (e.g., ~/Projects, ~/work, etc.)
    selected=$(find ~/dev ~/.config -mindepth 1 -maxdepth 2 -type d | fzf)
fi

# 2. Exit if no selection was made
if [[ -z $selected ]]; then
    exit 0
fi

# Helper: true if dir is a bare repo container created by worktree.sh
is_bare_repo() {
    [[ -d "$1/.bare" ]]
}

# 2b. If the selected dir is a bare repo container, create/resolve a worktree
if is_bare_repo "$selected"; then
    # fzf #1 — pick an existing remote branch or type a new name
    # --print-query: always prints the query on line 1, the selected item (if any) on line 2
    fzf_output=$(
        git -C "$selected" branch -r \
            | sed 's|[[:space:]]*origin/||' \
            | grep -v 'HEAD' \
            | sort \
            | fzf --print-query --prompt="Branch> "
    )
    fzf1_exit=$?

    query=$(echo "$fzf_output" | head -1)
    selection=$(echo "$fzf_output" | sed -n '2p')

    # fzf exits 0 when item selected, 1 when no match (typed new name), 130 on Ctrl-C/Escape
    # Abort on Ctrl-C (130) or Escape with nothing typed (1 + empty query)
    if [[ $fzf1_exit -eq 130 ]] || [[ $fzf1_exit -eq 1 && -z "$query" ]]; then
        exit 0
    fi

    if [[ -n "$selection" ]]; then
        # Existing remote branch chosen
        remote_ref="$selection"               # preserve original for git reference (may contain slashes)
        branch="${selection//\//-}"           # sanitize for local branch name and filesystem path

        # Prompt for worktree name (default: branch name)
        worktree_name=$(echo "$branch" | fzf --print-query --prompt="Worktree name> " | tail -1)
        if [[ -z "$worktree_name" ]]; then
            worktree_name="$branch"
        fi
        worktree_path="$selected/$worktree_name"

        if [[ ! -d "$worktree_path" ]]; then
            git -C "$selected" worktree add --track -b "$branch" "$worktree_path" "origin/$remote_ref" || exit 1
        fi
    else
        # New branch name typed — ask for base branch via fzf #2
        branch="$query"
        branch="${branch//\//-}"   # replace / with - for safe path/session naming

        base_branch=$(
            git -C "$selected" branch -r \
                | sed 's|[[:space:]]*origin/||' \
                | grep -v 'HEAD' \
                | sort \
                | fzf --prompt="Base branch for '$branch'> "
        )

        if [[ -z "$base_branch" ]]; then
            exit 0
        fi

        # Prompt for worktree name (default: branch name)
        worktree_name=$(echo "$branch" | fzf --print-query --prompt="Worktree name> " | tail -1)
        if [[ -z "$worktree_name" ]]; then
            worktree_name="$branch"
        fi
        worktree_path="$selected/$worktree_name"

        if [[ ! -d "$worktree_path" ]]; then
            git -C "$selected" worktree add -b "$branch" "$worktree_path" "origin/$base_branch" || exit 1
        fi
    fi

    # Update selected so the rest of the script opens a session in the worktree
    selected="$worktree_path"
fi

# 3. Create a clean session name
# extracts the folder name and replaces '.' with '_'
selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# 4. Create the session if it doesn't exist (detached)
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

# 5. Switch to the session
# If we are inside tmux, switch client. If outside, attach.
if [[ -z $TMUX ]]; then
    tmux attach-session -t $selected_name
else
    tmux switch-client -t $selected_name
fi
