# dotfiles

Chezmoi-managed dotfiles for devcontainers, Codespaces, and the host.
Applies git identity, SSH config, editor consistency, gh prefs (everywhere), plus host macOS terminal preferences.
Mostly plain files; `*.tmpl` files are allowed only to inject identity vars (`name`, `email`, `signingKey` from `chezmoi.toml [data]`) or carry the macOS-prefs `sha256sum` change-guard — never `{{ if }}` platform switching.

> Security/design rules live in `.claude/rules/design-invariants.md` (non-negotiable) and `.claude/rules/operations.md`. Hooks in `.claude/settings.json` enforce them. Run `/audit` before pushing.

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
├── install.sh                       Bootstrap for devcontainer features / Codespaces
├── .chezmoiignore                   Excludes install.sh from being applied to ~/
├── dot_gitconfig.tmpl               Git identity, aliases, SSH signing, credential helper
├── dot_gitignore_global             Global gitignore (.DS_Store, .env, *.swp)
├── dot_editorconfig                 Consistent indent/charset across all editors
├── dot_stCommitMsg                  Commit message template
├── dot_ssh/config                   SSH defaults: AddKeysToAgent, identity file, Include config.local
├── dot_config/gh/config.yml         gh CLI preferences and co alias
├── macos/                           Host macOS prefs (Terminal + iTerm2) — scrubbed of PII
│   ├── com.apple.Terminal.plist
│   └── com.googlecode.iterm2.plist
├── run_onchange_macos-prefs.sh.tmpl Imports macos/*.plist on Darwin when they change (sha256sum guard)
├── .githooks/pre-commit             gitleaks secret scan (local guard)
├── .github/workflows/secret-scan.yml  gitleaks secret scan (CI guard)
└── .claude/                         rules, commands, settings, hooks for this repo
```

## Conventions

- **Templates for identity + the macOS guard only** — `*.tmpl` may inject `{{ .name }}`, `{{ .email }}`, `{{ .signingKey }}` or the macOS-prefs sha256sum guard; no `{{ if }}` platform blocks ever
- **Cross-platform** — container/Codespaces dotfiles apply everywhere; `macos/*.plist` apply on Darwin only (no-op on Linux)
- **No secrets / no hardcoded emails** — tokens come from `~/.secrets` (never committed); identity emails come from chezmoi data vars, never literals in tracked files
- **Privacy** — macOS plists must be scrubbed of usernames and security-scoped path bookmarks (`NSOSPLastRootDirectory`, `BackgroundImageBookmark`) before commit
- **No shell config** — `.zshrc`/`.zprofile` are absent by design; devcontainer features manage shell
- **Credential helper** — uses `!gh auth git-credential` (no Homebrew path) for cross-platform compatibility
- **SSH signing** — `user.signingkey` is the ed25519 public key; `gpg.format = ssh`
- File prefix: `dot_X` → `~/.X`, `dot_config/Y` → `~/.config/Y`

## Important notes

- `install.sh` is called by the devcontainer `dotfiles-sync` feature and Codespaces — NOT applied to `~/`
- `helpers4/dotfiles-sync` in local devcontainers syncs host's live files; for Codespaces, `install.sh` runs chezmoi
- Host chezmoi config: `~/.config/chezmoi/chezmoi.toml` → `sourceDir = "~/dotfiles"`
- `install.sh` must define **every** identity var the templates use (`name`/`email`/`signingKey`); chezmoi's `missingkey=error` aborts the whole apply on any undefined var (this is what would silently break Codespaces)
- Identity is never hardcoded to a person — resolved in order: explicit `GIT_AUTHOR_*`/`GIT_SIGNING_KEY` env vars → the authenticated GitHub account via `gh` (account name + `<id>+<login>@users.noreply.github.com`) → existing git config
- `gpgsign = true` is committed, but `install.sh` turns it off when no `GIT_SIGNING_KEY` is present; in Codespaces specifically it defers signing entirely to GitHub's own setup (their GPG-verification docs warn dotfiles git config may conflict with it)
- GitHub signing key registered at github.com/settings/ssh (signing keys section)
- Codespaces install order (GitHub-searched): `install.sh` → `install` → `bootstrap[.sh]` → `script/bootstrap` → `setup[.sh]` → `script/setup`; if none exist, dot-files are symlinked into `$HOME` instead
