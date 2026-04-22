---
name: fix-findings
description: Fixes or justifies Polyspace findings after analysis. Use when the user asks to "fix this finding", "fix these defects", "fix violations", "address Polyspace results", or wants to resolve static analysis findings.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.0"
---
# How to Fix Polyspace Findings

After running Polyspace as You Code analysis, use this workflow to address each finding.

## Step 1 — Understand the finding

Read the finding's family and acronym from the analysis results (e.g., `Defect:INT_OVERFLOW`, `MISRA-C3:8.4`).

Read `find-checker-documentation/SKILL.md` in the parent folder to get the documentation URL for the finding. Fetch the documentation page to understand what the checker detects and why.

## Step 2 — Decide: fix or justify

**Fix the code** if the finding reveals a genuine issue:
- Apply the code fix.
- After a number of fixes, ensure to re-run the analysis (see `run-analysis/SKILL.md`) to confirm the finding is resolved.

**Justify the finding** if it is a false positive, intentional behavior, or prevented by external constraints:
- Read `justify-findings/SKILL.md` in the parent folder for annotation syntax and guidelines.
- Insert the annotation comment in the source code.
- On the next analysis run, Polyspace recognizes the annotation and marks the finding as justified.

## Step 3 — Repeat

Repeat steps 1-2 for each remaining finding.
