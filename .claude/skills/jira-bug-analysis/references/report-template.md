# First Analysis Report — <TICKET-KEY>

> <one-line ticket summary> · Priority: <priority> · Status: <status>
> Jira: https://contentstack.atlassian.net/browse/<TICKET-KEY>

## 1. Ticket summary
What the ticket reports, in your own words: the observed (buggy) behavior vs the
expected behavior, and who/what it affects.

## 2. Environment & reproduction
- Environment / version / browser (if given).
- Steps to reproduce (numbered). Note if repro is confirmed, inferred, or unclear.
- Relevant error messages / stack traces (verbatim, in a code block).

## 3. Affected repo & files
- **Repo:** `<group>/<repo-name>` — why this repo (the evidence that mapped it here).
- **Key files / functions:** `path/to/file.ext:line` — `symbolName()` — role in the bug.

## 4. Root-cause analysis
The concrete mechanism of the bug — the code path from trigger to failure and the
exact point where behavior diverges from intent. Distinguish confirmed facts from
hypotheses. Include a short annotated code excerpt if it clarifies the cause.

## 5. Proposed fix
The recommended change and why it addresses the root cause (not just the symptom).
Note the files/functions to change and the shape of the change.

## 6. Alternatives considered
Other viable approaches and why they were not chosen (or when they'd be preferable).

## 7. Risk & impact
- Blast radius: what else touches this code.
- Backward-compatibility / data / API concerns.
- Suggested rollout or feature-flag considerations, if any.

## 8. Test plan
- Existing tests covering this area (paths).
- New/updated tests that would catch this bug.
- Manual verification steps.

## 9. Open questions / blockers
Anything that prevents a confident fix: missing repro, unclear expected behavior,
out-of-scope dependencies, needed access, or product decisions required.
