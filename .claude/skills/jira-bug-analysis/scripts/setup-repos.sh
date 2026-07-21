#!/usr/bin/env bash
#
# setup-repos.sh — ensure the analysis repos are present as git submodules of
# THIS repo, in a two-group layout:
#
#   core/developerhub-ui           core/marketplace-ui
#   apps/marketplace-jsoneditor-app  apps/marketplace-brightcove-app
#
# Behavior per repo:
#   - already registered in .gitmodules -> `git submodule update --init`
#   - not yet registered              -> `git submodule add <url> <path>`
#
# Adding the private repos requires a git environment that has access to them
# (org SSH key or token / an appropriately-scoped Claude Code session). If a
# repo can't be reached, it's reported and the script keeps going. After the
# script adds new submodules, commit the resulting .gitmodules + gitlink change.
#
# URLs use the git@github.com: (SSH) form; ensure your environment has an SSH
# key with access to the private repos.

set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "!! run inside the repo"; exit 1; }
cd "$ROOT"

# path|ssh-url
REPOS=(
  "core/developerhub-ui|git@github.com:contentstack/developerhub-ui.git"
  "core/marketplace-ui|git@github.com:contentstack/marketplace-ui.git"
  "apps/marketplace-jsoneditor-app|git@github.com:contentstack/marketplace-jsoneditor-app.git"
  "apps/marketplace-brightcove-app|git@github.com:contentstack/marketplace-brightcove-app.git"
  "apps/custom-asset-field|git@github.com:contentstack/custom-asset-field.git"
)

added=0; inited=0; failed=0
for entry in "${REPOS[@]}"; do
  IFS='|' read -r path url <<<"$entry"
  if git config -f .gitmodules --get "submodule.$path.url" >/dev/null 2>&1; then
    echo ">> init/update $path"
    if GIT_TERMINAL_PROMPT=0 git submodule update --init -- "$path"; then
      inited=$((inited+1))
    else
      echo "!! could not init $path (no access in this environment?)"; failed=$((failed+1))
    fi
  else
    echo ">> add $path"
    if GIT_TERMINAL_PROMPT=0 git submodule add "$url" "$path"; then
      added=$((added+1))
    else
      echo "!! could not add $path (no access in this environment?)"; failed=$((failed+1))
      # leave no half-written .gitmodules entry behind
      git submodule deinit -f -- "$path" >/dev/null 2>&1 || true
      git config -f .gitmodules --remove-section "submodule.$path" >/dev/null 2>&1 || true
    fi
  fi
done

echo
echo "=== setup-repos summary ==="
echo "added: $added   init/updated: $inited   failed: $failed"
echo "core: $(ls -1 core 2>/dev/null | tr '\n' ' ')"
echo "apps: $(ls -1 apps 2>/dev/null | tr '\n' ' ')"
if [ "$added" -gt 0 ]; then
  echo
  echo "New submodules were added. Commit them with:"
  echo "  git add .gitmodules core apps && git commit -m 'Add analysis repos as submodules'"
fi
[ "$failed" -eq 0 ]
