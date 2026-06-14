---
description: Scan this repo for sensitive data — secrets, emails, tokens, PII — before pushing
---

Scan every tracked file in this dotfiles repo for sensitive data that shouldn't be in a public repository.

Run these checks in order:

**1. Gitleaks (secrets/tokens)**
```bash
ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks detect --source . --no-banner 2>&1
else
  echo "gitleaks not installed — skipping secret scan"
fi
```

**2. Email addresses**
```bash
ROOT=$(git rev-parse --show-toplevel)
git -C "$ROOT" grep -rn --word-regexp -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' \
  -- ':!*.yml' ':!*.md' 2>/dev/null || echo "none found"
```

**3. Absolute personal paths**
```bash
ROOT=$(git rev-parse --show-toplevel)
git -C "$ROOT" grep -rn -E '/Users/[a-zA-Z0-9_-]+|/home/[a-zA-Z0-9_-]+' 2>/dev/null || echo "none found"
```

**4. Homebrew absolute paths (design invariant)**
```bash
ROOT=$(git rev-parse --show-toplevel)
git -C "$ROOT" grep -rn '/opt/homebrew' 2>/dev/null || echo "none found"
```

**5. Private key material**
```bash
ROOT=$(git rev-parse --show-toplevel)
git -C "$ROOT" grep -rn 'PRIVATE KEY\|BEGIN RSA\|BEGIN EC' 2>/dev/null || echo "none found"
```

After running all checks, report:
- Each finding with file path, line number, and what was found
- Whether each finding is a real problem or expected/intentional (e.g. GitHub noreply emails are fine, `${{ secrets.GITHUB_TOKEN }}` is fine)
- A clear verdict: **clean** or **action required**
