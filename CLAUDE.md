# dotfiles

Chezmoi-managed dotfiles for devcontainers and Codespaces.
Applies git identity, SSH config, and editor consistency across all container environments.
Plain files only — except identity templates (`*.tmpl`) which inject `name`, `email`, `signingKey` from `chezmoi.toml [data]`.

## Commands

| Command | Purpose |
|---|---|
| `chezmoi status` | Show pending changes |
| `chezmoi diff` | Preview before applying |
| `chezmoi apply` | Apply source → home directory |
| `chezmoi apply --force` | Apply without interactive prompts |
| `chezmoi add <file>` | Start tracking a new dotfile |
| `chezmoi git -- push` | Push changes to GitHub |

## Architecture

```
~/dotfiles/
├── install.sh                  Bootstrap for devcontainer features / Codespaces
├── .chezmoiignore              Excludes install.sh from being applied to ~/
├── dot_gitconfig.tmpl          Git identity, aliases, SSH signing, credential helper
├── dot_gitconfig-infin8it.tmpl Work identity override for ~/infin8it/ repos
├── dot_gitignore_global        Global gitignore (.DS_Store, .env, *.swp)
├── dot_editorconfig            Consistent indent/charset across all editors
├── dot_stCommitMsg             Commit message template
├── dot_ssh/
│   └── config                  SSH defaults: AddKeysToAgent, identity file
└── dot_config/
    └── gh/
        └── config.yml          gh CLI preferences and co alias
```

## Conventions

- **Templates for identity only** — `*.tmpl` files use `{{ .name }}`, `{{ .email }}`, `{{ .signingKey }}`; no `{{ if }}` blocks ever
- **Linux-only** — targets container/Codespaces environments; macOS config lives on the host outside this repo
- **No secrets** — tokens come from `~/.secrets` on host (never committed) or Codespaces secrets
- **No shell config** — `.zshrc`/`.zprofile` are absent by design; devcontainer features manage shell
- **Credential helper** — uses `!gh auth git-credential` (no Homebrew path) for cross-platform compatibility
- **SSH signing** — `user.signingkey` is the ed25519 public key; `gpg.format = ssh`
- File prefix: `dot_X` → `~/.X`, `dot_config/Y` → `~/.config/Y`

## Important notes

- `install.sh` is called by the devcontainer `dotfiles-sync` feature and Codespaces — NOT applied to `~/`
- `helpers4/dotfiles-sync` in local devcontainers syncs host's live files; for Codespaces, `install.sh` runs chezmoi
- Host chezmoi config: `~/.config/chezmoi/chezmoi.toml` → `sourceDir = "~/dotfiles"`
- `gpgsign = true` works in local devcontainers (`.gnupg/` synced from host) but is skipped in Codespaces
- GitHub signing key registered at github.com/settings/ssh (signing keys section)
