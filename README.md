# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

**Design principle:** Linux is the baseline. Every file works on Ubuntu,
containers, and Raspberry Pi as-is. macOS-specific config is clearly
marked and additive.

## Supported platforms

| Platform | Status |
|----------|--------|
| Ubuntu / Debian | Primary baseline |
| Raspberry Pi (ARM) | Supported |
| macOS | Additive layer |
| Devcontainers / Codespaces | Supported |

## Bootstrap

**Any machine:**
```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ismail-kattakath
```

This installs chezmoi, clones this repo, prompts once for your name/email/GPG key,
applies all dotfiles, and runs the platform-appropriate install script.

## What's tracked

| File | Purpose |
|------|---------|
| `~/.zshrc` | Shell config — history, completion, tools, aliases |
| `~/.zprofile` | Login shell — PATH, secrets, Homebrew (macOS) |
| `~/.gitconfig` | Git — sensible defaults, aliases, work context override |
| `~/.gitignore_global` | Ignored everywhere: `.DS_Store`, `*.swp`, `.env` |
| `~/.editorconfig` | Consistent indent/charset across all editors |
| `~/.stCommitMsg` | Commit message template |
| `~/.config/starship.toml` | Prompt |
| `~/.config/gh/config.yml` | GitHub CLI preferences and aliases |
| `~/.ssh/config` | Key-based auth defaults |
| `~/Brewfile` | macOS packages (ignored on Linux) |

## Machine-local overrides

These files are **never committed** — create them on each machine as needed:

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Machine-specific aliases, paths, env vars |
| `~/.ssh/config.local` | Machine-specific SSH hosts (DevPod, jump hosts, VMs) |
| `~/.secrets` | Tokens and credentials (`chmod 600`) |

## Daily workflow

```sh
chezmoi edit ~/.zshrc       # edit in source dir, applies on save
chezmoi add ~/.newfile      # start tracking a new dotfile
chezmoi diff                # preview before applying
chezmoi apply               # apply source → home
chezmoi update              # pull from git + apply
chezmoi cd                  # jump into source dir
chezmoi git -- push         # push changes to GitHub
```
