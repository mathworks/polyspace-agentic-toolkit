---
name: run-polyspace-bug-finder-analysis
description: Runs Polyspace Bug Finder on C/C++ code — static analysis that finds defects and coding-standard violations across several files / a whole component (interprocedural, cross-file) — producing a results database (.psbf). Use when the request targets multiple files, a component, or a project, or names Bug Finder, e.g. "run Bug Finder", "find defects across my component", "check this project for defects and MISRA/CERT violations". For a single file or the change you are editing use run-polyspace-as-you-code-analysis; to prove absence of run-time errors use run-polyspace-code-prover-analysis. Requires the Polyspace Bug Finder product.
license: MathWorks BSD-3-Clause
metadata:
  author: MathWorks
  version: "1.2"
---
# How to Run Polyspace Bug Finder

Run Bug Finder to analyze C/C++ code and produce a `.psbf` results database that
the review skills consume. Bug Finder looks for **defects** (bug patterns) and
**coding-standard violations** (MISRA, CERT, CWE, …) across the **set of files you
give it** — so it finds interprocedural, cross-file defects (tainted data
source→sink, use-after-free across functions, data races) that single-file
as-you-code analysis cannot.

## When to Use
- The user wants to find defects and/or coding-standard violations in a component,
  module, or multi-file set.
- The user asks to run Bug Finder on a project or file set.

## When NOT to Use
- Fast, file-level checking as you edit a single file — use
  `run-polyspace-as-you-code-analysis` (Polyspace as You Code).
- Proving the **absence** of run-time errors (red/orange/green/gray checks) — use
  `run-polyspace-code-prover-analysis` (Polyspace Code Prover).
- Reading or explaining results that already exist — use `polyspace-review-findings`.

## Workflow

You need three things before running: the source files, and an **options file**
describing the build (compiler, target, includes, defines). Configuring that
options file is out of scope here — reuse an existing one from the project
(`.psopts`, a team script, or IDE settings), or invoke `polyspace-configure-build-options`.
Which defects and rules run is controlled by a checkers file — reuse one or invoke
`polyspace-configure-checkers`.

### Choosing how to run — MCP is strongly preferred

Bug Finder ships as a **desktop** (`polyspace-bug-finder`) or **server**
(`polyspace-bug-finder-server`) edition; a user has one or the other. Both run the
analysis and produce the same `.psbf`. What differs by run path is how much result
detail is available to the review skills:

- **Polyspace MCP Server available** — best. It reads the `.psbf` directly and
  exposes full result detail — finding location, message, **and the event trace /
  dataflow (source→sink)** — for either edition. Use the MCP tool below.
- **No MCP — CLI fallback.** The `polyspace-results-export` SARIF lists each finding
  with its location, message, family, and impact, but it does **not** contain the
  event trace / dataflow — its `codeFlows` array (the SARIF field that records a
  finding's step-by-step source→sink path) is absent. So CLI-only review can rank and locate
  findings, but cannot follow the source→sink path of a dataflow defect. This
  limitation is the same for **both** editions — it is a property of the SARIF
  export, not of desktop vs server. Prefer installing the MCP server for
  full-detail review; use the CLI as a degraded fallback. Details in `references/cli-usage.md`.

### Using the MCP tool

**If the Polyspace MCP Server is available**, use the `run_polyspace_bug_finder`
tool:
- `file_paths` (required): comma-separated absolute paths to the C/C++ files.
- `results_dir` (required): absolute path to the output directory.
- `options_file` (required): absolute path to the Polyspace options file.
- `checkers_file_path` (optional): path to the checkers activation file.

The tool returns `results_file` — the absolute path to the produced `.psbf`.
**Keep this path**; every review skill needs it.

### Otherwise using the binary directly

**If the MCP server is NOT available**, read `references/cli-usage.md` in this folder.

## Handling compilation errors

Bug Finder compiles the code before analyzing. By default, if some files fail to
compile the analysis **continues with the files that did compile** — you still get
results, but they are incomplete (findings from the failed files are missing, and
some checkers may show unexpected results). The analysis only stops entirely when
the `-stop-if-compile-error` option is set.
Either way, treat compile failures as something to fix: read the analysis log in
`results_dir` (e.g. `Polyspace_R*.log`), identify the failing compile command and
the first error, then correct the **options file** (missing include path, define,
wrong target/compiler) — not the source. Re-run. Fix the first error first; later
errors are often cascades of it.

## After a successful run

Report the `results_file` path and hand off to `polyspace-review-findings` to read and
prioritize the defects and coding-standard violations. If the user asked to fix or
justify findings (not just run analysis), invoke `polyspace-fix-findings` after the review.
Do not attempt to interpret raw counts here.

## Conventions
- Never modify source files to make compilation pass — fix the options file.
- Always preserve the returned `.psbf` path; it is the key to all downstream review.
- Bug Finder's value over as-you-code is cross-file analysis — run it over the
  whole related file set, not one file at a time, so interprocedural defects
  surface.

---

Copyright 2026 The MathWorks, Inc.

---
