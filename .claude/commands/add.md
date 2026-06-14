---
description: Add a new file to chezmoi dotfiles tracking. Usage: /add <path-to-file>
---

The argument is the path to the file to track (e.g. `~/.config/something/config.yml`).

Before adding, verify the file passes all invariants:

1. Does it contain any macOS-specific content? (`/opt/homebrew`, `UseKeychain`, `/Applications`, `/Users/`)
2. Does it contain any secrets or tokens?
3. Does it configure the shell (`.zshrc`, `.zprofile`, aliases)?
4. Does it use Homebrew paths in credential helpers?

If any check fails, refuse and explain what needs to be fixed first.

If all checks pass:

```bash
chezmoi add $ARGUMENTS
chezmoi status
```

Then apply and push:

```bash
chezmoi apply --force
cd ~/dotfiles && git add -A && git status
```

Ask the user to confirm before committing.
