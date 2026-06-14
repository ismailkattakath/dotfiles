---
description: Rebuild the base devcontainer and verify dotfiles are correctly synced inside it
---

```bash
source ~/.secrets
docker stop $(docker ps -q --filter "label=devcontainer.local_folder=$HOME/USER-workspace/devcontainer") 2>/dev/null || true
devcontainer up --workspace-folder ~/USER-workspace/devcontainer --remove-existing-container 2>&1 | tail -10
```

Then inspect what was synced:

```bash
source ~/.secrets && devcontainer exec --workspace-folder ~/USER-workspace/devcontainer bash -c "
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
- `!/opt/homebrew/bin/gh` in credential helper → must be `!gh auth git-credential`
- `UseKeychain yes` in SSH config → must not appear in container
- `CLAUDE_CODE_OAUTH_TOKEN` not set → user must source `~/.secrets` before starting devcontainer
