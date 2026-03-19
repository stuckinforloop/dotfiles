# AGENTS.md

Guidance for AI coding agents working in this repository.

## Scope

This repo contains dotfiles intended to be symlinked into `~/.config` using GNU Stow.

## Goals

- Keep bootstrap reliable and minimal.
- Prefer deterministic, idempotent changes.
- Avoid introducing platform abstraction unless explicitly requested.

## Repo conventions

- Use `Makefile` as the source of truth for setup flow.
- Stow root: `$(HOME)/.config/dotfiles`
- Stow target: `$(HOME)/.config`
- Primary bootstrap target: `make` / `make bootstrap`
- Remote bootstrap target: `make remote-bootstrap`

## Safety rules

- Never commit secrets/tokens/session history.
- For pi config, keep sensitive files ignored (e.g. `auth.json`, `sessions/`, caches).
- Preserve existing user-facing behavior unless asked to change it.

## Change guidelines

1. Read files before editing.
2. Make small, surgical edits where possible.
3. Keep Make targets simple and explicit.
4. Validate with quick checks (e.g. `make help`, `make -n <target>`).
5. Summarize changed paths clearly.

## Bootstrap assumptions

Current setup order in `Makefile`:

1. install fish
2. set fish as default shell
3. install devbox
4. install devbox dependencies
5. run stow

Do not reorder unless explicitly requested.
