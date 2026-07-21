#!/usr/bin/env bash
#
# list-repos.sh [keyword ...]
#
# Runtime discovery helper for the jira-bug-analysis skill: list the
# contentstack org's repos (NOT a hardcoded snapshot) so the skill can match a
# ticket to the right repo. Prints one repo per line as:
#
#   <name>\t<clone-url>\t<description>
#
# Optional keywords filter to repos whose name or description contains ANY of
# them (case-insensitive). Override the org with REPO_ORG.
#
# Access: uses the `gh` CLI if present; otherwise the GitHub REST API with a
# token in $GH_TOKEN or $GITHUB_TOKEN. If neither is available, the skill should
# fall back to its GitHub MCP tools (search_repositories with
# `org:contentstack <keywords>`) or ask the user for the repo URL.

set -uo pipefail
ORG="${REPO_ORG:-contentstack}"

emit() {  # reads TSV "name\turl\tdesc" on stdin, filters by keywords ($@)
  if [ "$#" -eq 0 ]; then cat; return; fi
  local pat; pat="$(printf '%s\n' "$@" | paste -sd'|' -)"
  grep -iE "$pat" || true
}

if command -v gh >/dev/null 2>&1; then
  gh repo list "$ORG" --limit 1000 --no-archived \
    --json name,url,description \
    -q '.[] | [.name, .url, (.description // "")] | @tsv' \
    | emit "$@"
  exit $?
fi

TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
if [ -n "$TOKEN" ] && command -v jq >/dev/null 2>&1; then
  {
    page=1
    while :; do
      resp="$(curl -fsSL -H "Authorization: Bearer $TOKEN" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/orgs/$ORG/repos?per_page=100&page=$page")" || {
          if [ "$page" -eq 1 ]; then
            echo "!! GitHub API request failed (token lacks access, or blocked here)." >&2
            echo "   Use the GitHub MCP (search_repositories: 'org:$ORG <keywords>') or ask for the repo URL." >&2
            exit 3
          fi
          break
        }
      [ "$(printf '%s' "$resp" | jq 'length')" -eq 0 ] && break
      printf '%s' "$resp" | jq -r '.[] | select(.archived|not) | [.name, .clone_url, (.description // "")] | @tsv'
      page=$((page+1))
    done
  } | emit "$@"
  exit "${PIPESTATUS[0]}"
fi

echo "!! no 'gh' CLI and no \$GH_TOKEN/\$GITHUB_TOKEN (+jq) available." >&2
echo "   Use the GitHub MCP (search_repositories: 'org:$ORG <keywords>') instead," >&2
echo "   or ask the user for the repo URL." >&2
exit 3
