#!/usr/bin/env bash
# Bootstrap script for ismailkattakath/dotfiles.
# Called by the devcontainer dotfiles feature and usable on any new machine.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install chezmoi into ~/.local/bin if not already present
if ! command -v chezmoi >/dev/null 2>&1; then
  echo "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

CHEZMOI="$(command -v chezmoi 2>/dev/null || echo "$HOME/.local/bin/chezmoi")"
export PATH="$HOME/.local/bin:$PATH"

# In non-interactive environments (containers, CI, Codespaces) skip prompts
if [ -n "${DEVCONTAINER:-}" ] || [ -n "${CODESPACE_NAME:-}" ] || [ -n "${CI:-}" ] || [ ! -t 0 ]; then
  mkdir -p "$HOME/.config/chezmoi"
  if [ ! -f "$HOME/.config/chezmoi/chezmoi.toml" ]; then
    cat > "$HOME/.config/chezmoi/chezmoi.toml" << EOF
[data]
    name       = "${GIT_AUTHOR_NAME:-Ismail Kattakath}"
    email      = "${GIT_AUTHOR_EMAIL:-8927166+ismailkattakath@users.noreply.github.com}"
    signingKey = "${GIT_SIGNING_KEY:-}"
EOF
  fi
fi

echo "Applying dotfiles..."
"$CHEZMOI" apply --source "$DOTFILES_DIR"
echo "Dotfiles applied."
