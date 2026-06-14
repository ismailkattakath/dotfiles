---
description: Apply dotfiles from source to home directory, then commit and push any source changes
---

1. Show what will change:

```bash
chezmoi diff
```

2. Apply:

```bash
chezmoi apply --force
```

3. Verify clean:

```bash
chezmoi status
```

4. If there are uncommitted changes in the source repo, commit and push:

```bash
ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"
git status
git add -A
git diff --staged
```

Ask the user to confirm the commit message before committing. Then:

```bash
git commit -m "<confirmed message>"
git push
```
