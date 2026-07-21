#!/usr/bin/env bash
#
# clone-repo.sh <git-url-or-owner/repo> [ref]
#
# Clone a repo at runtime for the jira-bug-analysis skill to analyze/fix.
# The repo is cloned into work/<name> (gitignored) at THIS repo's root. If it's
# already there, it's fetched instead. Optionally checks out <ref> (a branch,
# tag, or SHA); otherwise stays on the remote default branch.
#
# Accepts any git-cloneable form:
#   https://github.com/contentstack/marketplace-jsoneditor-app
#   git@github.com:contentstack/marketplace-jsoneditor-app.git
#   contentstack/marketplace-jsoneditor-app   (shorthand -> https://github.com/...)
#
# Prints the clone path (work/<name>) on success so the caller can cd into it.
# The environment must have git access to the repo (public, or org SSH/token).

set -uo pipefail

RAW="${1:?usage: clone-repo.sh <git-url-or-owner/repo> [ref]}"
REF="${2:-}"

# Normalize owner/repo shorthand to an https URL.
case "$RAW" in
  *://*|git@*) URL="$RAW" ;;
  */*)         URL="https://github.com/$RAW" ;;
  *)           echo "!! unrecognized repo reference: $RAW" >&2; exit 2 ;;
esac

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "!! run inside a git repo" >&2; exit 1; }
cd "$ROOT"

NAME="$(basename "${URL%.git}")"
DEST="work/$NAME"
mkdir -p work

if [ -d "$DEST/.git" ]; then
  echo ">> fetching existing $DEST" >&2
  GIT_TERMINAL_PROMPT=0 git -C "$DEST" fetch --all --prune || {
    echo "!! fetch failed for $DEST" >&2; exit 1; }
else
  echo ">> cloning $URL -> $DEST" >&2
  GIT_TERMINAL_PROMPT=0 git clone "$URL" "$DEST" || {
    echo "!! clone failed for $URL (no access from this environment?)" >&2
    rm -rf "$DEST"; exit 1; }
fi

if [ -n "$REF" ]; then
  git -C "$DEST" checkout "$REF" || { echo "!! could not checkout $REF" >&2; exit 1; }
fi

echo "$DEST"
