---
description: Rebuild the base devcontainer and verify dotfiles are correctly synced inside it
---

Derive paths dynamically — the devcontainer repo is expected as a sibling of this dotfiles repo:

```bash
DOTFILES_ROOT=$(git rev-parse --show-toplevel)
DEVCONTAINER_ROOT=$(dirname "$DOTFILES_ROOT")/devcontainer
echo "Dotfiles root: $DOTFILES_ROOT"
echo "Devcontainer root: $DEVCONTAINER_ROOT"
ls "$DEVCONTAINER_ROOT/.devcontainer/devcontainer.json" || echo "ERROR: devcontainer repo not found at expected path"
```

Rebuild the container:

```bash
source ~/.secrets
docker stop $(docker ps -q --filter "label=devcontainer.local_folder=$DEVCONTAINER_ROOT") 2>/dev/null || true
devcontainer up --workspace-folder "$DEVCONTAINER_ROOT" --remove-existing-container 2>&1 | tail -10
```

Inspect what was synced:

```bash
source ~/.secrets && devcontainer exec --workspace-folder "$DEVCONTAINER_ROOT" bash -c "
  echo '=== .gitconfig (key sections) ==='
  grep -E 'name|email|signingkey|format|helper|gpgsign' ~/.gitconfig

  echo ''
  echo '=== .ssh/config ==='
  cat ~/.ssh/config

  echo ''
  echo '=== credential helper ==='
  git config --global credential.https://github.com.helper

  echo ''
  echo '=== signing format ==='
  git config --global gpg.format

  echo ''
  echo '=== CLAUDE_CODE_OAUTH_TOKEN ==='
  [ -n \"\$CLAUDE_CODE_OAUTH_TOKEN\" ] && echo 'SET' || echo 'NOT SET'
"
```

Report any issues found. Common problems:
- Absolute path in credential helper → must be `!gh auth git-credential` (no path prefix)
- `UseKeychain yes` in SSH config → must not appear in container
- `CLAUDE_CODE_OAUTH_TOKEN` not set → user must source `~/.secrets` before starting container
