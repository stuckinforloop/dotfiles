#!/usr/bin/env bash
# bootstrap - set up this machine from the dotfiles repo
# Installs mise + stow, links app directories into ~/.config, installs tools with mise.

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
PREFIX="$HOME/.local"
STOW_VERSION="2.4.1"
export PATH="$PREFIX/bin:$PATH"

usage() {
    cat <<EOF
Usage: bootstrap.sh <command> [options] [packages...]

Commands:
  install             Full setup: deps, link, tools (safe to re-run)
  deps                Install mise and GNU stow into ~/.local/bin
  link [pkg...]       Link packages (default: all)
  unlink [pkg...]     Remove package links (default: all)
  tools               Install tools from mise/config.toml
  status              Show deps, link state per package, missing tools

Options:
  -n, --dry-run       Show what would change, change nothing
  -h, --help          Show this help

Packages: $(packages | tr '\n' ' ')
  <app> -> ~/.config/<app>, bin/* -> ~/.local/bin/*

Examples:
  bootstrap.sh install          # New machine
  bootstrap.sh status           # What's linked, what's missing
  bootstrap.sh link fish nvim   # Re-link after adding files
  bootstrap.sh unlink -n gh     # Preview removing gh links
  bootstrap.sh tools -n         # Preview tool installs
EOF
}

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { echo "bootstrap: $*" >&2; exit 1; }

# Each top-level directory is a package: an app directory, or bin.
packages() {
    local dir
    for dir in "$DOTFILES"/*/; do basename "$dir"; done
}

# Echo the requested packages, or all of them; reject unknown names.
resolve_packages() {
    if [[ $# -eq 0 ]]; then
        packages
        return
    fi
    local pkg
    for pkg in "$@"; do
        [[ -d "$DOTFILES/$pkg" ]] || die "unknown package: $pkg (have: $(packages | tr '\n' ' '))"
        echo "$pkg"
    done
}

install_deps() {
    if command -v mise >/dev/null; then
        echo "mise: $(mise --version)"
    elif [[ -n "$DRY_RUN" ]]; then
        echo "would install mise -> $PREFIX/bin/mise"
    else
        log "installing mise"
        curl -fsSL https://mise.run | MISE_INSTALL_PATH="$PREFIX/bin/mise" sh
    fi

    if command -v stow >/dev/null; then
        echo "stow: $(stow --version)"
    elif [[ -n "$DRY_RUN" ]]; then
        echo "would build GNU stow $STOW_VERSION -> $PREFIX/bin/stow"
    else
        # stow is not in mise's registry; build it from GNU source.
        log "installing GNU stow $STOW_VERSION"
        local tmp
        tmp="$(mktemp -d)"
        trap 'rm -rf "$tmp"' EXIT
        curl -fsSL "https://ftp.gnu.org/gnu/stow/stow-$STOW_VERSION.tar.gz" | tar -xz -C "$tmp"
        (cd "$tmp/stow-$STOW_VERSION" && ./configure --prefix="$PREFIX" >/dev/null && make install >/dev/null)
    fi
}

# Directories that must stay real. stow links a whole directory when the target
# doesn't exist yet; these are shared with other apps and installers.
SHARED_DIRS=("$HOME/.config" "$HOME/.local/bin")

# Where a package's files land.
target_of() {
    [[ "$1" == bin ]] && echo "$HOME/.local/bin" || echo "$HOME/.config/$1"
}

# Two stow invocations:
#   - the repo itself is one stow package targeting ~/.config, so each app
#     directory becomes ~/.config/<app> (.stow-local-ignore skips repo files);
#     a subset is selected by ignoring the other app directories.
#   - bin is a normal package targeting ~/.local/bin.
run_stow() {
    local action="$1"; shift
    command -v stow >/dev/null || die "stow not installed (run: bootstrap.sh deps)"
    local pkgs pkg p apps=() skip=() flags=() want_bin=""
    pkgs=($(resolve_packages "$@"))
    log "$action: ${pkgs[*]}"
    [[ -n "$DRY_RUN" ]] || mkdir -p "${SHARED_DIRS[@]}"

    case "$action" in
        link)   flags+=(--restow) ;;
        unlink) flags+=(--delete) ;;
    esac
    [[ -n "$DRY_RUN" ]] && flags+=(--simulate --verbose)

    for pkg in "${pkgs[@]}"; do
        [[ "$pkg" == bin ]] && want_bin=1 || apps+=("$pkg")
    done

    if [[ ${#apps[@]} -gt 0 ]]; then
        for p in $(packages); do
            [[ " ${apps[*]} " == *" $p "* ]] || skip+=(--ignore="^$p\$")  # stow matches names, not paths
        done
        stow --dir="$(dirname "$DOTFILES")" --target="$HOME/.config" \
            "${flags[@]}" ${skip[@]+"${skip[@]}"} "$(basename "$DOTFILES")"
    fi
    if [[ -n "$want_bin" ]]; then
        stow --dir="$DOTFILES" --target="$HOME/.local/bin" "${flags[@]}" bin
    fi
}

install_tools() {
    command -v mise >/dev/null || die "mise not installed (run: bootstrap.sh deps)"
    log "tools"
    mise install --yes ${DRY_RUN:+--dry-run}
}

show_status() {
    local pkg file target linked total missing
    echo "Deps:"
    printf '  %-6s %s\n' mise "$(command -v mise >/dev/null && mise --version || echo 'not installed')"
    printf '  %-6s %s\n' stow "$(command -v stow >/dev/null && stow --version || echo 'not installed')"

    echo "Packages:"
    for pkg in $(packages); do
        linked=0 total=0
        # Count files git would track; app state inside linked dirs is ignored.
        while IFS= read -r file; do
            target="$(target_of "$pkg")/${file#"$pkg/"}"
            total=$((total + 1))
            [[ "$(realpath "$target" 2>/dev/null)" == "$DOTFILES/$file" ]] && linked=$((linked + 1))
        done < <(git -C "$DOTFILES" ls-files --cached --others --exclude-standard -- "$pkg")
        printf '  %-6s %d/%d linked\n' "$pkg" "$linked" "$total"
    done

    echo "Tools:"
    if ! command -v mise >/dev/null; then
        echo "  mise not installed"
    else
        missing="$(mise ls --missing --no-header 2>/dev/null || true)"
        [[ -z "$missing" ]] && echo "  all installed" || sed 's/^/  missing: /' <<<"$missing"
    fi
}

# Parse options anywhere; everything else is the command and its arguments.
DRY_RUN=""
ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done
set -- ${ARGS[@]+"${ARGS[@]}"}

cmd="${1:-}"
shift || true

case "$cmd" in
    install)
        [[ $# -eq 0 ]] || die "install takes no packages (use: bootstrap.sh link <pkg...>)"
        install_deps
        run_stow link
        install_tools
        log "done; open a new fish shell"
        ;;
    deps)
        install_deps
        ;;
    link|unlink)
        run_stow "$cmd" "$@"
        ;;
    tools)
        install_tools
        ;;
    status)
        show_status
        ;;
    "")
        usage
        exit 1
        ;;
    *)
        echo "Unknown command: $cmd"
        usage
        exit 1
        ;;
esac
