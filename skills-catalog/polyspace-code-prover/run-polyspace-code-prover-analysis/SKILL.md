---
name: run-polyspace-code-prover-analysis
description: Runs Polyspace Code Prover on C/C++ code, producing a results database (.pscp). Use when the user asks to "run Code Prover", "prove absence of run-time errors", "formally verify this code", wants proof-backed guarantees or memory safety, or wants red/orange/green/gray run-time error checks.
license: MathWorks BSD-3-Clause
metadata:
  author: MathWorks
  version: "1.3"
---
# How to Run Polyspace Code Prover

Run Code Prover to formally verify C/C++ code and produce a `.pscp` results database that the review skills consume. Code Prover is a *sound* verifier: it proves whether each operation is safe on **every** execution, not just whether a bug pattern is present.

## When to Use
- The user wants to prove the absence of run-time errors (overflow, out-of-bounds, division by zero, non-initialized reads, invalid pointers).
- The user asks to run Code Prover on a project, file set, or component.

## When NOT to Use
- Fast, file-level defect / coding-standard checking as you edit — use `run-polyspace-as-you-code-analysis` (Polyspace as You Code).
- Finding defects or coding-standard violations (MISRA, CERT, CWE) — use `run-polyspace-bug-finder-analysis` (Polyspace Bug Finder).
- Reading or explaining results that already exist — use `review-polyspace-code-prover-results`.

## Workflow

You need two things before running: the source files and an **options file** describing the build (compiler, target, includes, defines) and the checks. Reuse an existing options file from the project (`.psopts`) or invoke `polyspace-configure-build-options` to create one.

### Choosing how to run — MCP is strongly preferred

Code Prover ships as a **desktop** (`polyspace-code-prover`) or **server**
(`polyspace-code-prover-server`) edition; a user has one or the other. This
affects which run path gives usable results:

- **Polyspace MCP Server available** — best in every case. It exposes full result
  detail (line of each check, traceback, numerical values) for **either** edition.
  Use the MCP tool below.
- **No MCP, server edition** — acceptable. The CLI fallback still gives the detail
  the review skills need. See `references/cli-usage.md`.
- **No MCP, desktop edition only** — the desktop SARIF export omits line-of-check,
  traceback, and numerical values, so downstream review is crippled. **Do not
  silently proceed.** Advise the user to install the Polyspace MCP server (best) or
  the server edition (compromise); run only if they accept degraded results.
  Details in `references/cli-usage.md`.

### Using the MCP tool

**If the Polyspace MCP Server is available**, use the `run_polyspace_code_prover` tool:
- `file_paths` (required): comma-separated absolute paths to the C/C++ files.
- `results_dir` (required): absolute path to the output directory.
- `options_file` (required): absolute path to the Polyspace options file.
- `verification_level` (optional): stop level, default 2. Higher levels prove more (fewer oranges) but cost far more time; values above 4 are unusual.

The tool returns `results_file` — the absolute path to the produced `.pscp`. **Keep this path**; every review skill needs it.

### Otherwise using the binary directly

**If the MCP server is NOT available**, read `references/cli-usage.md` in this folder.

## Handling compilation errors

Code Prover compiles the code before verifying. **A compilation failure is not always fatal, and that is the trap:** by default the analysis skips the file(s) that failed to compile and continues with the rest. The run then "succeeds" and produces results — but a file that never compiled was never analyzed, so its checks are missing and checks elsewhere that depend on data flowing through it can be wrong or strange. Do not trust results until every file compiled.

Always confirm compilation before reviewing: read the analysis log in `results_dir` (e.g. `Polyspace_R*.log`) for `error:` lines. To make a compilation failure stop the run instead of silently skipping the file, add `-stop-if-compile-error` to the options file. When there are errors, fix the **options file** (missing include path, define, wrong target/compiler) — not the source — and re-run.

## After a successful run

Report the `results_file` path and hand off to `review-polyspace-code-prover-results` to read and prioritize the checks. Do not attempt to interpret raw counts here.

## Conventions
- Never modify source files to make compilation pass — fix the options file.
- Always report and keep track of the returned `.pscp` path; it is the key to all downstream review.
- Keep the default stop level (`-to`); a deeper level costs significantly more analysis time — raise it only if the user explicitly asks for deeper verification.

---

Copyright 2026 The MathWorks, Inc.

---
