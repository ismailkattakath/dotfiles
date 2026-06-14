# Dotfiles Design Invariants

These rules are non-negotiable. Violating any of them breaks the container/Codespaces workflow.

## Never add

- `.tmpl` files — no chezmoi templates, no `{{ if darwin }}` blocks, ever
- `.zshrc`, `.zprofile`, or any shell config — devcontainer features own the shell
- `Brewfile` — macOS only, not applicable to containers
- `run_once_*` scripts — features handle installation
- Secrets or tokens of any kind — not even as examples
- Absolute macOS paths (e.g. `/opt/homebrew/`, `/Users/USER/`, `/Applications/`)
- `UseKeychain yes` in SSH config — macOS keychain is not available in containers

## Always ensure

- `dot_gitconfig` credential helper uses `!gh auth git-credential` — never the Homebrew full path
- `dot_gitconfig` uses `gpg.format = ssh` and `user.signingkey` set to the ed25519 public key
- `install.sh` is listed in `.chezmoiignore` — it must not be applied to `~/`
- All files are plain — chezmoi copies them as-is, no processing
- `dot_ssh/config` begins with `Include ~/.ssh/config.local` for machine-specific hosts

## Credential helper rule

```
# CORRECT — resolves gh from PATH, works everywhere
helper = !gh auth git-credential

# WRONG — Homebrew path, breaks inside Linux containers
helper = !/opt/homebrew/bin/gh auth git-credential
```

## What this repo is NOT

- Not a host machine dotfiles manager (the host's gitconfig has extra macOS content — that is intentional)
- Not a shell customisation repo (no prompt, no aliases, no functions)
- Not a secret store (no tokens, no keys, no credentials)

## File naming

- `dot_X` → `~/.X`
- `dot_config/Y/Z` → `~/.config/Y/Z`
- `dot_ssh/config` → `~/.ssh/config`
