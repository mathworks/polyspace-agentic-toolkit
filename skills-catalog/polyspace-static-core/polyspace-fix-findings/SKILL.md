---
name: polyspace-fix-findings
description: Fixes or justifies Polyspace findings after analysis. Use when the user asks to "fix this finding", "fix these defects", "fix violations", "address Polyspace results", or wants to resolve static analysis findings.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.3"
---
# How to Fix Polyspace Findings

After a Polyspace analysis (Polyspace as You Code, Bug Finder, or Code Prover), use this workflow to address each finding — a defect, a coding-standard violation, or a run-time-error check.

## When NOT to Use

- Reviewing, explaining, or prioritizing **Bug Finder / as-you-code** findings (defects and coding-standard violations) before deciding what to fix — use `polyspace-review-findings`. Come back here once you know a finding needs a code fix.
- Reviewing, explaining, or prioritizing **Code Prover** results (red/orange/green/gray checks) before deciding what to fix — use `review-polyspace-code-prover-results`, and `triage-orange-checks` for orange checks. Come back here once you know a check needs a code fix.

## Step 1 — Understand the finding

Read the finding's family and acronym from the analysis results (e.g., `Defect:INT_OVERFLOW`, `MISRA-C3:8.4`).

Invoke the `polyspace-find-checker-documentation` skill to get the documentation URL for the finding. Fetch the documentation page to understand what the checker detects and why.

That documentation explains the *rule* in general. To understand *this specific* finding — its message, location, and root-cause trace — invoke the matching review skill: `polyspace-review-findings` for Bug Finder / Polyspace as You Code findings, or `review-polyspace-code-prover-results` for Code Prover checks.

## Step 2 — Decide: fix or justify

**Fix the code** if the finding reveals a genuine issue:
- Apply the code fix.
- After a number of fixes, re-run the analysis with the run skill for your product (`run-polyspace-as-you-code-analysis`, `run-polyspace-bug-finder-analysis`, or `run-polyspace-code-prover-analysis`) to confirm the finding is resolved.

**Justify the finding** if it is a false positive, intentional behavior, or prevented by external constraints:
- To justify with a source-code annotation, invoke the `polyspace-justify-in-code` skill for the syntax and guidelines, then insert the annotation. On the next analysis run, Polyspace recognizes it and marks the finding as justified.
- To record a review status in the results database instead (Bug Finder `.psbf` or Code Prover `.pscp`), invoke the `polyspace-justify-in-database` skill.

## Step 3 — Repeat

Repeat steps 1-2 for each remaining finding.

---

Copyright 2026 The MathWorks, Inc.

---
