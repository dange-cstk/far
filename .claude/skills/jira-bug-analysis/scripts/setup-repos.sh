#!/usr/bin/env bash
#
# setup-repos.sh — clone/refresh the repos used by the jira-bug-analysis skill
# into a two-group layout:
#
#   $WORKSPACE/core/<repo>   (developerhub-ui, marketplace-ui)
#   $WORKSPACE/apps/<repo>   (marketplace-jsoneditor-app, marketplace-brightcove-app)
#
# WORKSPACE defaults to $HOME; override with BUG_ANALYSIS_WORKSPACE.
# Repos already present are fetched (not re-cloned). The repo list mirrors
# references/repos.json — keep them in sync when adding repos.
#
# Clone URLs use https://github.com/... on purpose: the session's git proxy
# rewrites them (url.<proxy>.insteadOf=https://github.com/). Private repos only
# clone in a session that has them in scope.

set -uo pipefail

WORKSPACE="${BUG_ANALYSIS_WORKSPACE:-$HOME}"
CORE_DIR="$WORKSPACE/core"
APPS_DIR="$WORKSPACE/apps"
DEPTH="${CLONE_DEPTH:-1}"   # set CLONE_DEPTH=0 (or unset) for a full clone

# group  repo                          clone-url
REPOS=(
  "core|developerhub-ui|https://github.com/contentstack/developerhub-ui.git"
  "core|marketplace-ui|https://github.com/contentstack/marketplace-ui.git"
  "apps|marketplace-jsoneditor-app|https://github.com/contentstack/marketplace-jsoneditor-app.git"
  "apps|marketplace-brightcove-app|https://github.com/contentstack/marketplace-brightcove-app.git"
)

mkdir -p "$CORE_DIR" "$APPS_DIR"

ok=0; failed=0
for entry in "${REPOS[@]}"; do
  IFS='|' read -r group name url <<<"$entry"
  case "$group" in
    core) dest="$CORE_DIR/$name" ;;
    apps) dest="$APPS_DIR/$name" ;;
    *)    echo "!! unknown group '$group' for $name"; failed=$((failed+1)); continue ;;
  esac

  if [ -d "$dest/.git" ]; then
    echo ">> refreshing $group/$name"
    if GIT_TERMINAL_PROMPT=0 git -C "$dest" fetch --all --prune; then
      ok=$((ok+1))
    else
      echo "!! fetch failed for $group/$name"; failed=$((failed+1))
    fi
  else
    echo ">> cloning $group/$name"
    depth_args=()
    [ "$DEPTH" != "0" ] && depth_args=(--depth "$DEPTH")
    if GIT_TERMINAL_PROMPT=0 git clone "${depth_args[@]}" "$url" "$dest"; then
      ok=$((ok+1))
    else
      echo "!! clone failed for $group/$name (is it in this session's scope?)"
      rmdir "$dest" 2>/dev/null || true
      failed=$((failed+1))
    fi
  fi
done

echo
echo "=== setup-repos summary ==="
echo "workspace: $WORKSPACE"
echo "ok: $ok   failed: $failed"
echo "core: $(ls -1 "$CORE_DIR" 2>/dev/null | tr '\n' ' ')"
echo "apps: $(ls -1 "$APPS_DIR" 2>/dev/null | tr '\n' ' ')"
[ "$failed" -eq 0 ]
