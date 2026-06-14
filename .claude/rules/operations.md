# Dotfiles Operations Reference

## Adding a new dotfile

1. Confirm the file has no macOS-specific content
2. Confirm the file has no secrets
3. Confirm the file does not configure the shell
4. Copy it to the source: `cp ~/.<file> ~/dotfiles/dot_<file>`
5. Run `chezmoi status` — verify the new file appears as added
6. Run `chezmoi apply --force` — apply to home dir
7. Commit and push

## Editing a tracked dotfile

```bash
chezmoi edit ~/.<file>          # opens source file in $EDITOR
chezmoi apply --force           # applies the change
chezmoi status                  # verify clean
cd ~/dotfiles && git add -A && git commit -m "..." && git push
```

## Applying all changes

```bash
chezmoi apply --force
chezmoi status   # must be empty after apply
```

## Verifying dotfiles in a container

```bash
# Rebuild the base devcontainer
source ~/.secrets
docker stop $(docker ps -q --filter "label=devcontainer.local_folder=$HOME/USER-workspace/devcontainer") 2>/dev/null
devcontainer up --workspace-folder ~/USER-workspace/devcontainer --remove-existing-container

# Inspect synced files
devcontainer exec --workspace-folder ~/USER-workspace/devcontainer bash -c "
  echo '=== gitconfig ===' && cat ~/.gitconfig
  echo '=== ssh/config ===' && cat ~/.ssh/config
  echo '=== signing ===' && git config --global gpg.format
"
```

## Pushing changes

```bash
cd ~/dotfiles
git add -A
git status    # review before committing
git commit -m "feat: ..."
git push
```

## Checking source vs applied state

```bash
chezmoi diff      # shows what would change (source vs home)
chezmoi status    # shows which files differ
chezmoi source-path   # confirm source dir is ~/dotfiles
```
