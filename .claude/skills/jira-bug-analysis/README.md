# jira-bug-analysis skill

A Claude skill that turns a **Jira ticket key** into a **First Analysis Report**
for the reported bug, and — when the fix is clear and contained — implements it
and opens a **draft pull request**.

## What it does

1. Fetches the ticket from Jira (Atlassian Rovo MCP).
2. Determines the target GitHub repo — from a link in the ticket, or by
   **discovering it at runtime** (searching the `contentstack` org live and
   matching the ticket), or by **asking you for the repo URL** when unsure. No
   repo list is committed, so nothing goes stale.
3. **Clones that repo at runtime** into a gitignored `work/` dir.
4. Reads the code, root-causes the bug, and writes a structured report.
5. Optionally implements a minimal fix on a branch and opens a draft PR.
6. Optionally posts the report back to the Jira ticket as a comment.

Every write action (push, PR, Jira comment) is gated on your confirmation.

No repos are hardcoded — repositories change over time, so the skill resolves
and clones the right one per ticket instead of tracking a fixed list.

## Layout

```
jira-bug-analysis/
  SKILL.md                     # the skill instructions (entry point)
  README.md                    # this file
  references/
    report-template.md         # First Analysis Report structure
  scripts/
    list-repos.sh              # runtime discovery: list contentstack org repos to match a ticket
    clone-repo.sh              # runtime clone of a given repo into work/<name>
```

## Usage

```
/jira-bug-analysis DX-1234
```

or just: "Analyze the bug in DX-1234 and propose a fix."

If the skill can't tell which repo the bug is in, it will ask you for the GitHub
repo URL (a full URL or `owner/repo` shorthand), then clone it.

## Requirements & notes

- The Atlassian (Rovo) MCP must be connected for Jira access.
- The environment needs git access to the target repo (public, or an SSH
  key / token with org access for private repos). If a clone fails for lack of
  access, the skill reports it rather than guessing.
- Runtime repo discovery uses the org repo listing via the `gh` CLI, a
  `$GH_TOKEN`/`$GITHUB_TOKEN`, or the GitHub MCP `search_repositories`. If none
  is available, the skill asks you for the repo URL.
- **Version bump:** when the target repo is a marketplace *app* (detected by a
  `@contentstack/app-sdk` dependency), a fix also bumps `package.json` (patch by
  default). Platform/library repos are not bumped.
