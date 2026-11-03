---
name: triage-orange-checks
description: Triages Polyspace Code Prover orange (unproven) checks and decides what to do about them. Use when the user asks to "reduce orange", "which oranges are real bugs", "which oranges can I justify", "find defects hidden in orange", "what should I do about this orange", "is this orange in dead/unreachable code", or wants to separate genuine potential run-time errors from analysis imprecision. For merely explaining what a check's color means (without deciding what to do), use review-polyspace-code-prover-results.
license: MathWorks BSD-3-Clause
metadata:
  author: MathWorks
  version: "1.3"
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

1. **Rank the sources of imprecision** — `get_orange_sources` (optionally `min_impact` to focus on high-impact ones). Each source reports its `sourceType`, how many oranges it causes, and — for the types a constraint file can bound — whether **DRS applies**. Every source this tool returns is an imprecision source; the `sourceType` says what kind and therefore how it can be narrowed:
   - a **stubbed function** or an **external variable** is bounded by constraints, and these are the entries that carry the DRS flag;
   - a **volatile variable** carries **no DRS flag at all** — it is still an input source, and it comes with the file and line of its declaration instead, so start from the code at that location.

   Do not read a missing DRS flag as "not an input source": read `sourceType` first, and only then the flag.
2. **Inspect one orange's ranges** — `get_static_ranges` at the check's line (get the `source_file_snapshot` from `list_source_file_snapshots` — it is the `path` field of that file's entry, passed verbatim). Read the computed range: is the faulty value produced by **local logic** right there, or is the range wide only because it traces back to an **unbounded external input**? Confirm the origin two ways:
   - **Cross-check `get_orange_sources`.** If this check's ID appears under any source there — with or without a DRS flag — its width comes from an input, stub or volatile read rather than from local code, and that points to imprecision. Only a check that no source claims is a candidate for local origin — but before concluding "no source", check the **Check-pattern notes** below, because some checks (e.g. NIV/NIP dereferences) carry their attribution on a sibling check.
   - **Walk the callers with `get_call_graph` (`direction: "callers"`)** on the enclosing function. If the wide value arrives as a parameter or return from callers (or from a stubbed input), the origin is *upstream* → imprecision; if the faulty subset is produced by a computation on the line itself, the origin is *local* → likely a real defect.

   Use the decision heuristic below for the verdict.
Note: an orange is always on **reachable** code — Code Prover attempted a proof there and could not conclude. Genuinely unreachable/dead code is **gray** (checker `UNR`), never orange, so there is no such thing as "an orange in unreachable code" to triage here. If a check you expected to be orange shows up gray, it is dead code (often downstream of an upstream red) — handle it via `review-polyspace-code-prover-results`, not in orange triage.

Note: adding Data Range Specifications / constraint files to actually remove input-driven oranges is a **configuration** task and is out of scope for these skills — report that the oranges are input-driven and recommend constraining the inputs.

### Otherwise using the binary directly

**If the MCP server is NOT available**, read `references/cli-usage.md` in this folder.

## Decision heuristic

| Signal | Verdict | Route |
|--------|---------|-------|
| The check's ID is claimed by a `get_orange_sources` entry (stub, external or volatile), and the range traces to that input | Imprecision | `polyspace-justify-in-database` (or constrain via config) |
| Range shows a genuinely faulty subset from local computation | Potential defect | `polyspace-fix-findings` |

## Check-pattern notes

Specific checker / code-pattern situations where the generic Step 2 workflow needs an extra move. Each entry is **how to recognize it** → **what to do**. This list is expected to grow; longer cases will graduate to their own `references/` page.

### Pointer dereference — IDP / NIP / NIV travel as a pack
**Recognize:** a single pointer dereference produces several checks at the **same `file:line`** (e.g. IDP for the pointer's bounds, NIV for the dereferenced value, NIP for the pointer value). Code Prover attributes the imprecision to **only one** of them — usually the IDP (pointer bounds) — so a companion NIV/NIP is **missing from `get_orange_sources`** and its `get_polyspace_result_details` shows only a full-range value with a single self-referential `IMPRECISION_EVENT`. This is not "no source".

**Do:** list the co-located checks (`get_polyspace_results_list`, filter by file + line, disambiguate with `column`), run Step 2 against the sibling that **does** appear in `get_orange_sources`, and apply one verdict to the whole pack — justify or fix them together.

## Conventions
- Always start from `get_orange_sources` — fixing the few highest-impact sources clears many oranges at once; chasing individual oranges does not scale.
- When working through oranges by hand, take the check types most likely to be real first — out-of-bounds array index, non-initialized variable, division by zero, shift — then overflow and pointer dereference, then the rest; and start with the files that have the fewest oranges (each is more likely a genuine issue).
- Never justify an orange without inspecting its range; "it's probably imprecision" is not triage.
- Prefer constraining inputs (configuration) over adding defensive code, when the orange is purely input-driven.

---

Copyright 2026 The MathWorks, Inc.

---
