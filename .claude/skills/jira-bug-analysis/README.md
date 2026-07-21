# jira-bug-analysis skill

A Claude skill that turns a **Jira ticket key** into a **First Analysis Report**
for the reported bug, and — when the fix is clear and contained — implements it
and opens a **draft pull request**.

## What it does

1. Fetches the ticket from Jira (Atlassian Rovo MCP).
2. Ensures the target repos are cloned locally (two groups: `core`, `apps`).
3. Infers which repo the bug lives in (and confirms with you).
4. Reads the code, root-causes the bug, and writes a structured report.
5. Optionally implements a minimal fix on a branch and opens a draft PR.
6. Optionally posts the report back to the Jira ticket as a comment.

Every write action (push, PR, Jira comment) is gated on your confirmation.

## Layout

```
jira-bug-analysis/
  SKILL.md                     # the skill instructions (entry point)
  README.md                    # this file
  references/
    repos.json                 # repo registry + mapping hints (extend to add repos)
    report-template.md         # First Analysis Report structure
  scripts/
    setup-repos.sh             # add/init the core & apps repos as submodules
```

The analysis repos are **git submodules** of this repo, under `core/` and
`apps/` at the repo root. Populate them with `git submodule update --init
--recursive` or the setup script.

## Usage

```
/jira-bug-analysis DX-1234
```

or just: "Analyze the bug in DX-1234 and propose a fix."

## Requirements & notes

- The Atlassian (Rovo) MCP must be connected for Jira access.
- **Private repos only initialize in an environment with access to them.** In a
  session scoped to a different owner, `setup-repos.sh` adds/inits the public
  submodule and reports the private ones as out-of-scope. Run it locally or in a
  session scoped to those repos to complete the private submodules, then commit
  the `.gitmodules` change.
- Add more repos by appending to `references/repos.json` and the `REPOS` array in
  `scripts/setup-repos.sh`.
