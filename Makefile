SHELL := /bin/bash
.DEFAULT_GOAL := bootstrap

DOTFILES_DIR ?= $(HOME)/.config/dotfiles
STOW_TARGET ?= $(HOME)/.config
STOW_PACKAGES ?= .
STOW_FLAGS ?= --ignore='^Makefile$$' --ignore='^\.DS_Store$$' --ignore='^AGENTS.md'
DEVBOX_REPO ?= git@github.com:stuckinforloop/devbox-work.git
REPO_URL ?= https://github.com/stuckinforloop/dotfiles.git
BRANCH ?= work

help:
	@echo "Targets:"
	@echo "  make (or make bootstrap)   Run full setup in safe order"
	@echo "  make install-fish          Install fish from latest GitHub release pkg"
	@echo "  make set-default-shell     Set fish as login shell"
	@echo "  make install-devbox        Install devbox"
	@echo "  make install-devbox-deps   Pull and install global devbox packages from $(DEVBOX_REPO)"
	@echo "  make devbox-global-pull    Pull global devbox config from $(DEVBOX_REPO)"
	@echo "  make devbox-global-push    Push current global devbox config to $(DEVBOX_REPO)"
	@echo "  make stow                  Apply stow symlinks"
	@echo "  make stow-dry-run          Preview stow changes"
	@echo "  make remote-bootstrap      Clone/update repo and run local bootstrap"
	@echo "Environment overrides: DEVBOX_REPO"

remote-bootstrap:
	@mkdir -p "$$(dirname "$(DOTFILES_DIR)")"
	@if [ -d "$(DOTFILES_DIR)/.git" ]; then \
		echo "Updating dotfiles in $(DOTFILES_DIR) (branch: $(BRANCH))..."; \
		git -C "$(DOTFILES_DIR)" fetch origin "$(BRANCH)"; \
		git -C "$(DOTFILES_DIR)" checkout "$(BRANCH)"; \
		git -C "$(DOTFILES_DIR)" pull --ff-only origin "$(BRANCH)"; \
	else \
		echo "Cloning $(REPO_URL) into $(DOTFILES_DIR) (branch: $(BRANCH))..."; \
		git clone --branch "$(BRANCH)" "$(REPO_URL)" "$(DOTFILES_DIR)"; \
	fi
	@$(MAKE) -C "$(DOTFILES_DIR)" bootstrap

bootstrap: install-fish set-default-shell install-devbox install-devbox-deps stow
	@echo "✅ Bootstrap complete"

install-devbox:
	@if command -v devbox >/dev/null 2>&1; then \
		echo "devbox already installed"; \
	else \
		echo "Installing devbox..."; \
		curl -fsSL https://get.jetify.com/devbox | bash; \
	fi

install-devbox-deps: devbox-global-pull


devbox-global-pull:
	@if [ -z "$(DEVBOX_REPO)" ]; then \
		echo "Missing DEVBOX_REPO"; \
		exit 1; \
	fi
	@echo "Pulling global devbox config from $(DEVBOX_REPO)..."
	@devbox global pull "$(DEVBOX_REPO)" -f
	@echo "Installing global devbox packages..."
	@devbox global install

devbox-global-push:
	@if [ -z "$(DEVBOX_REPO)" ]; then \
		echo "Missing DEVBOX_REPO"; \
		exit 1; \
	fi
	@echo "Pushing global devbox config to $(DEVBOX_REPO)..."
	@devbox global push "$(DEVBOX_REPO)"

install-fish:
	@if command -v fish >/dev/null 2>&1; then \
		echo "fish already installed"; \
	else \
		echo "Installing fish from latest GitHub release (.pkg)..."; \
		FISH_PKG_URL="$$(curl -fsSL https://api.github.com/repos/fish-shell/fish-shell/releases/latest | grep -Eo '"browser_download_url":\s*"[^"]+\.pkg"' | head -n1 | sed -E 's/.*"(https:[^"]+)"/\1/')"; \
		if [ -z "$$FISH_PKG_URL" ]; then \
			echo "Could not resolve fish .pkg URL from GitHub releases."; \
			exit 1; \
		fi; \
		TMP_PKG="$$(mktemp /tmp/fish.XXXXXX.pkg)"; \
		echo "Downloading $$FISH_PKG_URL"; \
		curl -fL "$$FISH_PKG_URL" -o "$$TMP_PKG"; \
		echo "Installing fish package (sudo required)..."; \
		sudo installer -pkg "$$TMP_PKG" -target /; \
		rm -f "$$TMP_PKG"; \
		echo "fish installed"; \
	fi

stow:
	@echo "Stowing $(STOW_PACKAGES) from $(DOTFILES_DIR) -> $(STOW_TARGET)"
	@if ! command -v stow >/dev/null 2>&1; then \
		echo "stow not found in PATH. Install stow or expose it in your shell before running this target."; \
		exit 1; \
	fi
	@stow $(STOW_FLAGS) -d "$(DOTFILES_DIR)" -t "$(STOW_TARGET)" $(STOW_PACKAGES)

stow-dry-run:
	@echo "Dry-run stow $(STOW_PACKAGES) from $(DOTFILES_DIR) -> $(STOW_TARGET)"
	@if ! command -v stow >/dev/null 2>&1; then \
		echo "stow not found in PATH. Install stow or expose it in your shell before running this target."; \
		exit 1; \
	fi
	@stow -n -v $(STOW_FLAGS) -d "$(DOTFILES_DIR)" -t "$(STOW_TARGET)" $(STOW_PACKAGES)

set-default-shell:
	@FISH_PATH="$$(command -v fish)"; \
	if [ -z "$$FISH_PATH" ]; then \
		echo "fish not found. Run 'make install-fish' first."; \
		exit 1; \
	fi; \
	if ! grep -qx "$$FISH_PATH" /etc/shells; then \
		echo "Adding $$FISH_PATH to /etc/shells (sudo required)..."; \
		echo "$$FISH_PATH" | sudo tee -a /etc/shells >/dev/null; \
	fi; \
	if [ "$$SHELL" = "$$FISH_PATH" ]; then \
		echo "fish is already default shell"; \
	else \
		echo "Setting default shell to $$FISH_PATH..."; \
		chsh -s "$$FISH_PATH"; \
		echo "Default shell updated. Restart terminal to apply."; \
	fi

.PHONY: bootstrap help remote-bootstrap install-devbox install-devbox-deps devbox-global-pull devbox-global-push install-fish stow stow-dry-run set-default-shell
