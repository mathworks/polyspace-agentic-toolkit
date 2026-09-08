---
name: polyspace-justify-in-database
description: Records a review status and rationale on Polyspace findings directly in the results database (.psbf for Bug Finder, .pscp for Code Prover) and carries that review across re-runs. Use when the user asks to "set the status to Justified", "mark this as acceptable in the results", "record a rationale in the results database", or wants review decisions to survive re-running the analysis without editing the source. For justifying by annotating the source code instead, use polyspace-justify-in-code.
license: MathWorks BSD-3-Clause
metadata:
  author: MathWorks
  version: "1.3"
---
# How to Justify Findings in the Results Database

Record a **review status and rationale directly in the Polyspace results database** — `.psbf` for Bug Finder, `.pscp` for Code Prover — and preserve it when the code is re-analyzed. This is the database mechanism; for justifications written as comments in the source code, use `polyspace-justify-in-code` instead.

## When to Use
- Marking a triaged finding or check (a Bug Finder defect, or a Code Prover orange/intentional gray) as reviewed and acceptable, in the results.
- Recording the rationale for a decision without editing the source.
- Keeping review decisions from being lost when the analysis is re-run.

## When NOT to Use
- Writing the justification as an annotation in the source code — use `polyspace-justify-in-code`.
- Deciding *whether* a Bug Finder / as-you-code finding is a real defect or acceptable — review it first with `polyspace-review-findings`.
- Deciding *whether* a Code Prover check is acceptable — review it first with `review-polyspace-code-prover-results` (and `triage-orange-checks` for orange checks specifically).
- Fixing a real error in code — use `polyspace-fix-findings`.

## Workflow

### Using the MCP tools

1. **Get the `result_id`** — from `get_polyspace_results_list` on the results file.
2. **Set the status** — `add_review_information_to_result`:
   - `results_file`: the `.psbf` or `.pscp` path.
   - `result_id`: the finding to update.
   - `status`: one of `Justified`, `No action planned`, `Not a defect`, `To fix`, `To investigate`, `Unreviewed`, `Other`. Use `Justified` for an intentional/acceptable finding, `Not a defect` for a confirmed false alarm.
   - `comment`: the rationale (why it is acceptable). Always record one — a status without a reason is not a justification.
   - `severity` (optional): `High` / `Medium` / `Low` / `Unset`.
3. **Preserve across re-runs** — re-analysis produces a new results file. Run `transfer_polyspace_comments` from the old file (`from_results_file`) to the new one (`to_results_file`) so statuses and comments carry over. Both files must be the same product (`.psbf`→`.psbf` or `.pscp`→`.pscp`); `.payc` results are not supported.

### Code Prover: unreachable defensive code (gray `UNR`)

Justify an intentionally-unreachable gray check with `status: Justified` and a comment citing the evidence (e.g. the defensive guard is required by the coding standard), referencing the exact checker id (`UNR`, family `RTE Check`). If the gray is *unintended* dead code, it is not a justification case — remove or refactor it (route to `polyspace-fix-findings`).

### Without the MCP server

**Setting a new status** *directly in the results database* requires the MCP tool `add_review_information_to_result` — there is no command-line equivalent. To justify the finding in the source code instead, invoke `polyspace-justify-in-code`.

**Transferring existing database comments across a re-run** *does* have a CLI equivalent. When a previous database already holds review decisions — for example, statuses a user set earlier in the Polyspace user interface — and a new run has produced a fresh database, import them with `polyspace-comments-import`. See `references/cli-usage.md` in this folder.

## Conventions
- Always attach a comment explaining *why* the finding is acceptable; the status alone is not auditable.
- Never mark a finding `Justified` before it has been reviewed (for Code Prover orange, before `triage-orange-checks`) — justify decisions, not guesses.
- Re-running the analysis starts a fresh database; transfer comments every time, or review work is lost.

---

Copyright 2026 The MathWorks, Inc.

---
