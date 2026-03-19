function worktree
    echo ""
    echo "Enter repository (URL, org/repo, or git@github.com:org/repo)"
    echo "============================================================"
    echo ""

    read --prompt "" repo_input
    set repo_input (string trim -- $repo_input)
    if test -z "$repo_input"
        echo "Repository input is required."
        return 1
    end

    set org_user ""
    set repo_name ""

    if string match -rq '^[^/@:[:space:]]+/[^/@:[:space:]]+$' -- $repo_input
        set parts (string split / -- $repo_input)
        set org_user $parts[1]
        set repo_name $parts[2]
    else
        set ssh_parts (string match -r --groups-only '^git@github\.com:([^/[:space:]]+)/([^/[:space:]]+?)(?:\.git)?$' -- $repo_input)
        if test (count $ssh_parts) -eq 2
            set org_user $ssh_parts[1]
            set repo_name $ssh_parts[2]
        else
            set url_parts (string match -r --groups-only '^https?://github\.com/([^/[:space:]]+)/([^/[:space:]]+?)(?:\.git)?/?$' -- $repo_input)
            if test (count $url_parts) -eq 2
                set org_user $url_parts[1]
                set repo_name $url_parts[2]
            end
        end
    end

    if test -z "$org_user" -o -z "$repo_name"
        echo "Unsupported format. Use one of:"
        echo "  1) https://github.com/<org>/<repo>"
        echo "  2) <org>/<repo>"
        echo "  3) git@github.com:<org>/<repo>"
        return 1
    end

    set target_dir "$HOME/dev"
    set repo_root "$target_dir/$repo_name"

    mkdir -p $repo_root
    cd $repo_root

    # Always use SSH for clone/auth.
    set url "git@github.com:$org_user/$repo_name.git"

    # Bare clone with partial clone filter (blobs fetched on-demand at checkout)
    git clone --bare --filter=blob:none $url .bare
    or begin
        echo "Clone failed. Cleaning up..."
        cd $HOME && rm -rf $repo_root
        return 1
    end

    echo "gitdir: ./.bare" > .git

    # Explicitly set remote fetch refspec so remote branches are trackable
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

    # Fetch all remote refs (commits + trees only, no file content)
    git fetch origin
    or begin
        echo "Fetch failed. Cleaning up..."
        cd $HOME && rm -rf $repo_root
        return 1
    end

    # Detect default branch
    set default_branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | string replace "refs/remotes/origin/" "")
    set create_orphan_master 0

    if test -z "$default_branch"
        if git show-ref --verify --quiet refs/remotes/origin/main
            set default_branch main
        else if git show-ref --verify --quiet refs/remotes/origin/master
            set default_branch master
        else
            set default_branch master
            set create_orphan_master 1
        end
    end

    # Create worktree for the default branch
    if test $create_orphan_master -eq 1
        git worktree add --orphan $default_branch
        or begin
            echo "Orphan master worktree creation failed. Cleaning up..."
            cd $HOME && rm -rf $repo_root
            return 1
        end
    else
        git worktree add $default_branch $default_branch
        or begin
            echo "Worktree creation failed. Cleaning up..."
            cd $HOME && rm -rf $repo_root
            return 1
        end
    end

    # Add AGENTS.md and CLAUDE.md symlink to repo root
    cp "$HOME/.config/templates/AGENTS_WORKTREE.md" "$repo_root/AGENTS.md"
    ln -sf AGENTS.md "$repo_root/CLAUDE.md"

    echo ""
    echo "Repository cloned in $repo_root"
    echo "Default branch: $default_branch"

    cd "$repo_root/$default_branch"
end
