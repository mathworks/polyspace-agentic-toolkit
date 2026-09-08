---
name: review-polyspace-code-prover-results
description: Reads, explains, and prioritizes Polyspace Code Prover results from a .pscp database. Use when the user asks "what did Code Prover find", "explain this red/orange/green/gray check", "why is this check orange", "was most of my code analyzed", "what are the most critical run-time errors", or wants the root cause of a check.
license: MathWorks BSD-3-Clause
metadata:
  author: MathWorks
  version: "1.3"
---
# How to Review Polyspace Code Prover Results

Read and explain a Code Prover `.pscp` database, then prioritize what matters. Code Prover is a *sound* verifier — the color of a check is a proof outcome, not a heuristic score. Interpreting the colors correctly is the whole job; getting the model wrong leads agents to "fix" safe code and ignore real errors.

## When to Use
- Understanding what a Code Prover run found and how critical it is.
- Explaining why a specific check is red, orange, green, or gray.
- Finding the root cause of a check when it is far from the check location.
- Judging coverage — was most of the code actually verified.

## When NOT to Use
- Running the verification — use `run-polyspace-code-prover-analysis`.
- Deciding **what to do** about an **orange** (real bug vs. imprecision), reducing orange, or an orange sitting in dead/unreachable code — use `triage-orange-checks`. This skill only *explains* a check's color; the decision belongs to `triage-orange-checks`.
- Reviewing Bug Finder / as-you-code defects or coding-standard violations (not Code Prover checks) — use `polyspace-review-findings`.
- Setting a review status / justifying checks — use `polyspace-justify-in-database`.
- Understanding what a checker *rule* means in general — use `polyspace-find-checker-documentation`.

## The color model (read this first)

| Color | Meaning | What to do |
|-------|---------|-----------|
| **Red** | Proven error on **every** execution reaching this operation — a definite run-time error. | Highest priority. Route the fix to `polyspace-fix-findings`. |
| **Gray** | Unreachable / dead code (checker `UNR`, family `RTE Check`). | Investigate the **cause** (see Key consequences below) — may be a downstream symptom of an upstream red, or intentional defensive code. Do not blindly delete. |
| **Orange** | Unproven — Code Prover could neither prove safe nor prove faulty for all executions. **Not necessarily a bug.** | Do not blindly fix. Route to `triage-orange-checks`. |
| **Green** | Proven safe on every execution, for the analyzed configuration. | Leave it. Do not modify. |

Common run-time checkers, all in the `RTE Check` family: `ZDV` (division by zero), `OBAI` (out-of-bounds array index), `IDP` (illegally dereferenced pointer), `NIP` (non-initialized pointer), `NIV` (non-initialized variable), `OVFL` (overflow), `UNR` (unreachable code). In `get_polyspace_results_list`, filter `family: "RTE Check"` for all of them, or `rule_id` with the bare acronym (e.g. `UNR`) for one.

Key consequences:
- A **red stops the path**: operations after a red on that path show up gray. Fixing the red lets Code Prover verify that code — the downstream gray is re-analyzed and may turn green, orange, or even red — so fix reds before judging gray. **Establish the link structurally, don't infer it:** a gray follows from a red only when a red lies earlier on *every* path reaching it — an earlier statement in the same function, or a callee that errors on all paths. Locate the reds first (filter `color: "Red"`), then for a gray in the same function or call chain confirm a red precedes it on the control-flow path (`get_polyspace_result_details` code flow + the source snapshot). If no red precedes it, the gray is its own finding — intentional defensive code or a misconfiguration — not a red symptom.
- **Soundness is scoped.** Green means proven safe *only* within the analyzed sources, build configuration, target/compiler model, stubs, and assumptions — and *only* for the run-time-error families Code Prover checks. Never present green as proof that the code is free of all bugs, and check the `get_code_prover_assumptions` MCP tool when a green rests on how a stub or input was modeled.

## How the program was modeled (read colors in this light)

- **Entry point.** Code Prover needs a `main`. Verifying a module/library instead *generates* one that calls every uncalled function with **full-range** globals and inputs. That model decides what is reachable — code the generated main never reaches stays gray — and a unit run (no real call context) yields far more orange than a whole-application run.
- **Stubbed functions.** Undefined or uncalled functions are auto-stubbed: non-pointer returns take the full type range, returned pointers are assumed non-NULL and safe to dereference, pointer arguments may be written any value, and stubs are assumed not to modify globals. Many oranges (and some reds) trace to these assumptions, not to real defects — confirm with `get_code_prover_assumptions`.

## Workflow

### Using the MCP tools

**If the Polyspace MCP Server is available**, all tools take `results_file` (the `.pscp` path from `run-polyspace-code-prover-analysis`).

1. **Summary** — `get_polyspace_results_summary`: counts per color and coverage. Low green + high gray usually signals an early red or an unreached entry point (bad main/task model), not clean code.
2. **List** — `get_polyspace_results_list`. Review the **non-green subset** by default: filter `color: "Red"` first (definite errors), then orange and relevant gray. Green checks are proof evidence, not triage material — pull them only when the user asks for proof/audit evidence for a specific property. Each result carries a `result_id`. Triage from the results, not from the `Polyspace*.log` (logs are for failed or incomplete runs).
3. **Explain one check** — `get_polyspace_result_details` with the `result_id`: SARIF code flow and variable usage. For what the *rule* means in general, delegate to `polyspace-find-checker-documentation`.
4. **Trace a distant root cause** — a check is *nonlocal* whenever the value that triggers it (the operand in the `get_polyspace_result_details` code flow) originates off its own line: a function parameter, a global, a returned value, or a stubbed input, rather than a literal or a computation on that line. When it is nonlocal you **must** trace before explaining — do not explain a nonlocal check from its own line alone:
   - `list_source_file_snapshots` to get the opaque `source_file_snapshot` id (pass it verbatim).
   - `get_static_ranges` at the check's line — the values Code Prover computed there; a full-type or surprising range whose source is not on the line confirms the cause is upstream.
   - `get_call_graph` (`direction: "callers"`) to see which callers supply the offending values.
   - If the check sits on a macro, `get_macro_expansion` at that line shows the code actually analyzed.
5. **Shared variables & the data dictionary** — Code Prover classifies each global as non-shared, shared-unprotected, or shared-protected; this per-variable read/write map (its *data dictionary*) is a review dimension distinct from per-line checks. Unprotected shared globals surface via the **Shared unprotected global variable** result (protected → green, potentially unprotected → orange). **Concurrency detection is not automatic** in Code Prover — it produces results only when the *run* was configured for it (automatic detection via `-enable-concurrency-detection`, or an explicitly modeled task/thread set). That configuration happens at analysis time in `run-polyspace-code-prover-analysis`, not in this review; if the run had neither, there are simply no concurrency results — read that as *unconfigured*, never as *no concurrency issues*. Call `get_concurrency_model` first (loads the task/thread model into cache), then `get_variable_accesses` for the variable's read/write sites and its shared/protected status. (A named "data race" defect is Bug Finder, not Code Prover.)
6. **Check assumptions** — `get_code_prover_assumptions` when a green or an orange hinges on how a stub or external input was modeled. It returns the verification's assumption table; most entries are analysis-wide, so call it with `results_file` alone to see the full set. `function_name` and `file_filter` are optional filters that only narrow the table to a function or source file — they do not surface additional assumptions.

### Otherwise using the binary directly

**If the MCP server is NOT available**, read `references/cli-usage.md` in this folder.

## Prioritization

Report findings in this order, and route the follow-up work:
1. **Red** — definite errors → `polyspace-fix-findings`.
2. **Gray from an upstream red** — a gray with a red proven to precede it on all paths (establish this structurally — see "red stops the path" above, not by inference); resolves once the red is fixed, so group it with its cause.
3. **Orange with real-defect potential** → `triage-orange-checks`.
4. **Remaining orange (imprecision)** → `triage-orange-checks` or `polyspace-justify-in-database`.
5. **Green / intentional gray** — no action.

## Review is complete when
- No unreviewed red checks remain — each is either fixed (`polyspace-fix-findings`) or recorded in the database with a review status and a rationale (`polyspace-justify-in-database`), e.g. deferred or justified as not-a-defect-in-context.
- Orange checks are triaged — each is fixed (a real defect), shown to be caused by a justified assumption (imprecision from a stub or full-range input that is acceptable), or otherwise reviewed with a documented rationale (via `triage-orange-checks` / `polyspace-justify-in-database`).
- Gray `UNR` checks are classified as intentional defensive code vs. dead/misconfigured code.

## Conventions
- Always establish coverage (summary) before reporting individual checks — a low-coverage run can hide errors as gray.
- Never recommend "fixing" green or fixing orange before triage; orange is not a defect until shown to be one.
- When a check's cause is not local, trace it (ranges + callers) before explaining it — the fix belongs at the root, not the symptom.

---

Copyright 2026 The MathWorks, Inc.

---
