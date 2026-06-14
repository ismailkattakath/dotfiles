---
description: Show chezmoi status and diff — what differs between source and home directory
---

Run the following and report what differs:

```bash
chezmoi source-path
chezmoi status
chezmoi diff
```

If status is empty, confirm everything is clean and in sync.
If there are differences, explain what changed and whether `chezmoi apply` is needed.
