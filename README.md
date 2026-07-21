# far

Claude skills and tooling for Contentstack engineering workflows.

## Skills

- **[jira-bug-analysis](.claude/skills/jira-bug-analysis/)** — Analyze a bug
  reported in a Jira ticket and produce a first-analysis report; optionally
  implement the fix and open a draft pull request. The target repo is inferred
  from the ticket (or provided by the user) and cloned at runtime.

Skills live under `.claude/skills/` and are discovered automatically by Claude
Code. See each skill's `README.md` for usage.
