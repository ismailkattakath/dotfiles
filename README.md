# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Supported platforms

- macOS (primary)
- Ubuntu / Debian Linux (VMs, containers, Codespaces)
- Raspberry Pi (ARM Linux)

## Bootstrap a new machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ismail-kattakath
```

This will:
1. Install chezmoi
2. Clone this repo
3. Prompt for personalization data (name, email, GPG key)
4. Apply all dotfiles
5. Run install scripts (Homebrew packages on macOS, apt packages on Linux)

## Secrets

Secrets are **never committed**. On each machine, create `~/.secrets` (chmod 600):

```sh
touch ~/.secrets && chmod 600 ~/.secrets
```

Then add your tokens:

```sh
# ~/.secrets
export ANTHROPIC_API_KEY="..."
export OPENAI_API_KEY="..."
# etc.
```

## Daily usage

| Command | What it does |
|---------|-------------|
| `chezmoi add ~/.zshrc` | Start tracking a new dotfile |
| `chezmoi edit ~/.zshrc` | Edit a tracked file in source dir |
| `chezmoi apply` | Apply source changes to home directory |
| `chezmoi diff` | Preview what would change |
| `chezmoi update` | Pull latest from git and apply |
| `chezmoi cd` | Jump into the source directory |
| `chezmoi git -- push` | Push changes to GitHub |

## Machine-local overrides

For machine-specific config that shouldn't be committed, use:

- `~/.zshrc.local` — sourced at end of `.zshrc`
- `~/.secrets` — environment variables and tokens

## Devcontainers / Codespaces

Set the `DOTFILES_REPO` to `ismail-kattakath/dotfiles` in your devcontainer settings, or add to `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotfiles:1": {
      "repository": "ismail-kattakath/dotfiles"
    }
  }
}
```
