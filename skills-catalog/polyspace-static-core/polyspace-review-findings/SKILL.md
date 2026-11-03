---
name: polyspace-review-findings
description: Reads, explains, and prioritizes Polyspace findings — defects and coding-standard violations — from a results database (.psbf for Bug Finder, .payc for Polyspace as You Code). Use when the user asks "what did Bug Finder find", "what did the analysis find", "explain this defect/violation", "which findings are serious", "prioritize my findings", or wants the root cause of a defect. For Code Prover red/orange/green/gray checks use review-polyspace-code-prover-results instead.
license: MathWorks BSD-3-Clause
metadata:
  author: MathWorks
  version: "1.1"
---
# How to Review Polyspace Findings (Bug Finder / Polyspace as You Code)

Read a Polyspace **findings** database — `.psbf` (Bug Finder) or `.payc`
(Polyspace as You Code) — then explain and prioritize what matters. A *finding* is
one of two things, and the whole job is telling them apart and ranking them:

- **A defect** (`Defect:*`) — a detected bug pattern (division by zero, use after
  free, tainted data reaching a sink, …). Each carries an **impact**:
  High / Medium / Low.
- **A coding-standard violation** — MISRA (C:2025, C:2023, C++:2023), CERT C/C++,
  CWE, AUTOSAR C++14, … A compliance deviation, not necessarily a bug.

Bug Finder is a **bug-*finder***, not a sound prover: it can miss issues and can
report false positives. Treat each finding as a lead to confirm, not a proof.
(For proof-backed red/orange/green/gray run-time checks detected using Code Prover,
use `review-polyspace-code-prover-results`.)

## When to Use
- Understanding what a Bug Finder or Polyspace as You Code run found and how serious it is.
- Explaining a specific defect or coding-standard violation and its root cause.
- Prioritizing findings so the user knows what to fix first.

## When NOT to Use
- Running the analysis — use `run-polyspace-bug-finder-analysis` or `run-polyspace-as-you-code-analysis`.
- Reviewing **Code Prover** results (red/orange/green/gray, orange triage) — use
  `review-polyspace-code-prover-results` and `triage-orange-checks`.
- Applying a code fix — use `polyspace-fix-findings`.
- Recording a review status / justifying — use `polyspace-justify-in-code` or
  `polyspace-justify-in-database`.
- Understanding what a checker *rule* means in general — use
  `polyspace-find-checker-documentation`.

## Bug Finder vs Polyspace as You Code — same findings, different scope

The finding model is identical; the **scope** differs, and it changes what you can
say about a finding:

- **Polyspace as You Code (`.payc`)** analyzes **one file**. Defects that need
  data flow from other translation units are out of its reach.
- **Bug Finder (`.psbf`)** analyzes **several files / a whole component**, so it
  finds **interprocedural, cross-file** defects that Polyspace as You Code cannot: a
  tainted-data source in one function reaching a sink in another, a use-after-free
  across call boundaries, a data race between tasks, cross-TU concurrency issues.

When a Bug Finder defect's cause is not on the finding line, **trace it** rather
than explaining the symptom (see the workflow below).

## Workflow

### Using the MCP tools

**If the Polyspace MCP Server is available**, all tools take `results_file` (the
`.psbf` / `.payc` path from the run skill).

**On an as-you-code-only install these tools are absent.** Every tool named below
belongs to the Bug Finder / Code Prover toolsets, so an install with neither
product registers none of them — the server starts and serves its generic tools,
but no tool named here exists to call. That is a property of the install, not a
failure: fall back to the CLI section below, which does read a `.payc` file. Note
what the fallback cannot give you: the exported SARIF carries no event trace, so
the source→sink path in step 3 and the tracing in step 4 are unavailable from it.

1. **Summary** — `get_polyspace_results_summary`: the total (`results_count`), the
   list of family *names* present (`families` — names only, no counts), and the
   analysis metrics (`analysis.num_files`, `analysis.num_lines`). It carries no
   per-family and no per-impact counts: for those, call
   `get_polyspace_results_list` filtered by `family`/`impact` and count its
   `results` entries. Establish the shape of the run before drilling in.
2. **List** — `get_polyspace_results_list`. Filter by `family`/`rule_id`,
   `impact`, or `status`. Lead with **High-impact defects**, then Medium, then
   coding-standard violations. Each entry carries its finding number in `id` —
   pass that value as the `result_id` argument of the tools below.
3. **Explain one finding** — `get_polyspace_result_details` with the `result_id`:
   the message, location, and the event/flow trace (for a dataflow defect, the
   source→sink path). When the cause is not on the finding's own line, continue to
   step 4 to trace it (cross-file / interprocedural). For what the *rule* means in
   general, delegate to `polyspace-find-checker-documentation`.
4. **Trace a cross-file / interprocedural cause** — when the reason is not on the
   finding's own line:
   - `get_call_graph` (`direction: "callers"`) to see who supplies the offending
     value or reaches the sink.
   - `get_variable_accesses` for a variable's read/write sites (and its
     shared/protected status for concurrency defects).
   - `get_symbol_navigation` to jump to a definition/declaration.
   - `get_macro_expansion` if the finding sits on a macro — it shows the code
     actually analyzed.
5. **Concurrency defects** — `get_variable_accesses` for the racing accesses, plus the
   defect's own `get_polyspace_result_details` for the tasks it names. There is no
   concurrency-model tool on this path: `get_concurrency_model` is Code Prover only, so
   it rejects a `.psbf`/`.payc` file and is not even registered on a Bug Finder install.
   Detection depends on the concurrency model being configured or detected; if none is
   modeled, no concurrency findings are produced.

### Otherwise using the binary directly

**If the tools above are not available to you** — either no Polyspace MCP Server at
all, or an as-you-code-only install where the server runs but registers none of them
(see the note above) — read `references/cli-usage.md` in this folder. Do not gate this
on the server being absent: in the as-you-code-only case the server is present and
answering, and the tools are still missing.

## Prioritization

Report findings in this order, and route the follow-up work:
1. **High-impact defects** — most likely real bugs → confirm, then `polyspace-fix-findings`.
2. **Medium / Low-impact defects** — confirm; fix or justify.
3. **Coding-standard violations** — whether each must be fixed, justified, or
   formally deviated is set by the project's coding standard and deviation policy.
   The agent will not know that unless told, so confirm it with the user rather
   than assume, then fix or justify (`polyspace-justify-in-code` /
   `polyspace-justify-in-database`).
4. **Confirmed false positives** — record with a rationale via `polyspace-justify-in-code`
   or `polyspace-justify-in-database`; do not edit correct code to silence them.

## Review is complete when
- Every defect is confirmed and either fixed (`polyspace-fix-findings`) or has an
  owner/decision.
- Coding-standard violations are triaged: fixed, or justified with a rationale.
- False positives are recorded with a reason, not silenced by contorting the code.

## Conventions
- Always establish the summary (total, families present, size of the run) before
  reporting individual findings; get impact/family *counts* from
  `get_polyspace_results_list`.
- For a defect whose cause is elsewhere, trace it (call graph / variable
  accesses) before explaining it — the fix belongs at the root, not the symptom.
- Never present a Bug Finder finding as a proof of a bug or its absence; it is a
  detection, to be confirmed. (Soundness/proof is Code Prover's model.)

---

Copyright 2026 The MathWorks, Inc.

---
