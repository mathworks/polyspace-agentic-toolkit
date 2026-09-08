---
name: triage-orange-checks
description: Triages Polyspace Code Prover orange (unproven) checks and decides what to do about them. Use when the user asks to "reduce orange", "which oranges are real bugs", "which oranges can I justify", "find defects hidden in orange", "what should I do about this orange", "is this orange in dead/unreachable code", or wants to separate genuine potential run-time errors from analysis imprecision. For merely explaining what a check's color means (without deciding what to do), use review-polyspace-code-prover-results.
license: MathWorks BSD-3-Clause
metadata:
  author: MathWorks
  version: "1.2"
---
# How to Triage Code Prover Orange Checks

An orange check is *unproven*: Code Prover could not show it safe or faulty on all executions. An orange is one of two things, and the whole task is telling them apart:

- **A real potential run-time error** — a subset of the possible values genuinely triggers overflow, out-of-bounds, division by zero, etc. → fix it.
- **Imprecision** — the check is safe in reality, but analysis lost precision (unbounded external input, complex aliasing, wide data flow). → justify it, or narrow inputs via configuration.

Because Code Prover is sound, an orange is reported rather than a possible error being silently missed — so an orange is never "nothing", but it is also not automatically a bug. Blindly "fixing" every orange wastes effort and adds dead defensive code; blindly justifying them hides real bugs. Triage first.

## When to Use
- Reducing the orange count on a Code Prover run.
- Deciding, for a specific orange, whether it is a real defect or imprecision.
- Locating the code constructs that generate the most orange.

## When NOT to Use
- Reading results in general or explaining red/green/gray — use `review-polyspace-code-prover-results`.
- Applying a status once you've decided an orange is acceptable — use `polyspace-justify-in-database`.
- Fixing a red (definite) error — that's `polyspace-fix-findings`.

## Workflow

### Using the MCP tools

All tools take `results_file` (the `.pscp` path).

1. **Rank the sources of imprecision** — `get_orange_sources` (optionally `min_impact` to focus on high-impact ones). Each source reports how many oranges it causes and whether **DRS applies**. A source where **DRS applies is an input/imprecision source** — the oranges it drives are prime justify-or-constrain candidates, not code bugs.
2. **Inspect one orange's ranges** — `get_static_ranges` at the check's line (get the `source_file_snapshot` id from `list_source_file_snapshots`, pass it verbatim). Read the computed range: is the faulty value produced by **local logic** right there, or is the range wide only because it traces back to an **unbounded external input**? Confirm the origin two ways:
   - **Cross-check `get_orange_sources`.** If this check is attributed to a source where **DRS applies**, its width comes from an input/stub, not from local code — that points to imprecision.
   - **Walk the callers with `get_call_graph` (`direction: "callers"`)** on the enclosing function. If the wide value arrives as a parameter or return from callers (or from a stubbed input), the origin is *upstream* → imprecision; if the faulty subset is produced by a computation on the line itself, the origin is *local* → likely a real defect.

   Use the decision heuristic below for the verdict.
Note: an orange is always on **reachable** code — Code Prover attempted a proof there and could not conclude. Genuinely unreachable/dead code is **gray** (checker `UNR`), never orange, so there is no such thing as "an orange in unreachable code" to triage here. If a check you expected to be orange shows up gray, it is dead code (often downstream of an upstream red) — handle it via `review-polyspace-code-prover-results`, not in orange triage.

Note: adding Data Range Specifications / constraint files to actually remove input-driven oranges is a **configuration** task and is out of scope for these skills — report that the oranges are input-driven and recommend constraining the inputs.

### Otherwise using the binary directly

**If the MCP server is NOT available**, read `references/cli-usage.md` in this folder.

## Decision heuristic

| Signal | Verdict | Route |
|--------|---------|-------|
| Orange source has DRS-applicable, traces to external input | Imprecision | `polyspace-justify-in-database` (or constrain via config) |
| Range shows a genuinely faulty subset from local computation | Potential defect | `polyspace-fix-findings` |

## Conventions
- Always start from `get_orange_sources` — fixing the few highest-impact sources clears many oranges at once; chasing individual oranges does not scale.
- When working through oranges by hand, take the check types most likely to be real first — out-of-bounds array index, non-initialized variable, division by zero, shift — then overflow and pointer dereference, then the rest; and start with the files that have the fewest oranges (each is more likely a genuine issue).
- Never justify an orange without inspecting its range; "it's probably imprecision" is not triage.
- Prefer constraining inputs (configuration) over adding defensive code, when the orange is purely input-driven.

---

Copyright 2026 The MathWorks, Inc.

---
