#!/usr/bin/env bash
# Bootstrap script for ismailkattakath/dotfiles.
# Entry point GitHub Codespaces and the devcontainer dotfiles feature run first
# (Codespaces searches install.sh → install → bootstrap → setup); also usable on any new machine.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install chezmoi into ~/.local/bin if not already present
if ! command -v chezmoi >/dev/null 2>&1; then
  echo "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

CHEZMOI="$(command -v chezmoi 2>/dev/null || echo "$HOME/.local/bin/chezmoi")"
export PATH="$HOME/.local/bin:$PATH"

# Resolve git identity — same logic on every platform (macOS host, devcontainers,
# Codespaces, CI). Nothing is hardcoded to a person. Each field is resolved in order:
#   1. explicit env vars      — GIT_AUTHOR_NAME / GIT_AUTHOR_EMAIL / GIT_SIGNING_KEY (override)
#        GIT_AUTHOR_NAME/EMAIL are git-native; GIT_SIGNING_KEY is read by THIS script only
#        (git has no signing-key env var — it reads user.signingkey from config), and is
#        a common dotfiles convention, not a git standard.
#   2. the authenticated GitHub account, via `gh` — name, the account's noreply email
#      (<id>+<login>@users.noreply.github.com), and the registered SSH signing key
#   3. any existing git config — whatever git already knows on this machine
#
# Every identity var referenced by a *.tmpl must end up defined in chezmoi.toml, or
# chezmoi (missingkey=error by default) aborts the whole apply — see dot_gitconfig.tmpl.
gh_name="" gh_login="" gh_id="" gh_sshkey=""
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  gh_name="$(gh api user --jq '.name // ""' 2>/dev/null || true)"
  gh_login="$(gh api user --jq '.login // ""' 2>/dev/null || true)"
  gh_id="$(gh api user --jq '.id // ""' 2>/dev/null || true)"
  # Requires the read:ssh_signing_key / admin:ssh_signing_key scope; empty if absent.
  gh_sshkey="$(gh api user/ssh_signing_keys --jq '.[0].key // ""' 2>/dev/null || true)"
fi

resolved_name="${GIT_AUTHOR_NAME:-}"
[ -z "$resolved_name" ] && resolved_name="$gh_name"
[ -z "$resolved_name" ] && resolved_name="$gh_login"
[ -z "$resolved_name" ] && resolved_name="$(git config --global user.name 2>/dev/null || true)"

resolved_email="${GIT_AUTHOR_EMAIL:-}"
if [ -z "$resolved_email" ] && [ -n "$gh_id" ] && [ -n "$gh_login" ]; then
  resolved_email="${gh_id}+${gh_login}@users.noreply.github.com"
fi
[ -z "$resolved_email" ] && resolved_email="$(git config --global user.email 2>/dev/null || true)"

resolved_signingkey="${GIT_SIGNING_KEY:-}"
[ -z "$resolved_signingkey" ] && resolved_signingkey="$gh_sshkey"
[ -z "$resolved_signingkey" ] && resolved_signingkey="$(git config --global user.signingkey 2>/dev/null || true)"

# Write the chezmoi data block from the resolved values on every run, so identity is
# always gh-derived (or env-overridden) and never a stale hardcoded value. Preserve an
# existing sourceDir line (host installs set it; containers pass --source explicitly).
mkdir -p "$HOME/.config/chezmoi"
CHEZMOI_CFG="$HOME/.config/chezmoi/chezmoi.toml"
src_line=""
[ -f "$CHEZMOI_CFG" ] && src_line="$(grep -E '^[[:space:]]*sourceDir[[:space:]]*=' "$CHEZMOI_CFG" 2>/dev/null | head -1 || true)"
{
  [ -n "$src_line" ] && printf '%s\n\n' "$src_line"
  printf '[data]\n'
  printf '    name       = "%s"\n' "$resolved_name"
  printf '    email      = "%s"\n' "$resolved_email"
  printf '    signingKey = "%s"\n' "$resolved_signingkey"
} > "$CHEZMOI_CFG"

echo "Applying dotfiles..."
# --force: never prompt for a TTY (Codespaces/CI have none) and re-apply cleanly on
# rebuilds even though the post-apply signing tweak below modifies ~/.gitconfig.
"$CHEZMOI" apply --force --source "$DOTFILES_DIR"
echo "Dotfiles applied."

# Signing: the committed gitconfig enables SSH commit signing. Three cases:
#
#  - Codespaces (CODESPACE_NAME set): GitHub auto-configures its own commit signing when
#    GPG verification is enabled, and the docs warn dotfiles git config "may conflict with
#    the configuration that GitHub Codespaces requires to sign commits." Step out of the
#    way — drop our gpg.format/signingkey override and let GitHub's setup win.
#
#  - Elsewhere with a signing key resolved (host/devcontainer/CI): keep SSH signing on.
#
#  - Elsewhere with no key: disable signing so gpgsign=true + empty key doesn't make every
#    commit fail ("user.signingKey needs to be set").
if [ -n "${CODESPACE_NAME:-}" ]; then
  echo "Codespaces detected — deferring commit signing to GitHub's configuration."
  git config --global --unset-all gpg.format 2>/dev/null || true
  git config --global --unset-all user.signingkey 2>/dev/null || true
  git config --global commit.gpgsign false
  git config --global tag.gpgsign false
elif [ -z "$resolved_signingkey" ]; then
  echo "No signing key resolved — disabling commit/tag signing for this environment."
  git config --global commit.gpgsign false
  git config --global tag.gpgsign false
fi
