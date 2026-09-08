---
name: run-polyspace-as-you-code-analysis
description: Runs Polyspace as You Code (PAYC) static analysis on a single C/C++ file — the file you are editing — to find defects and coding-standard violations. The default when the request targets one file, e.g. "run Polyspace analysis on source.c", "check my code"/"check this file", "check that my change is MISRA/CERT compliant", "find or fix the defects in this file". For several files or a whole component use run-polyspace-bug-finder-analysis; to prove absence of run-time errors use run-polyspace-code-prover-analysis. Requires the Polyspace as You Code product.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.4"
---
# How to Run Polyspace as You Code Analysis

Run Polyspace as You Code (PAYC) on a C/C++ source file to find standard violations, defects, and coding rule issues.

## When NOT to Use

- The user wants defect and coding-standard analysis **across several files / a whole component** (finding interprocedural, cross-file defects), rather than fast single-file checking — use `run-polyspace-bug-finder-analysis` instead.
- The user wants to **formally prove the absence of run-time errors** (a full Code Prover verification with red/orange/green/gray checks), rather than fast file-level defect and coding-standard checking — use `run-polyspace-code-prover-analysis` instead.

## Pre-analysis setup

Before running, gather build configuration:

1. Look for existing Polyspace IDE config in `.vscode/settings.json` (`polyspace.analysisOptions.*`), `.project`, or `.vs/`. If found, use it to populate the build options, checkers, and options file paths.
2. Otherwise, ask the user for pre-created config files or a team script that launches Polyspace.
3. Otherwise, search for `compile_commands.json` or a `Makefile`/`CMakeLists.txt` and create a build options file (invoke the `polyspace-configure-build-options` skill).
4. For simple standalone files, build options may not be needed.

If no checkers file exists, invoke the `polyspace-configure-checkers` skill to create one.

## Running the analysis

### Using the MCP tool

**If the `run_polyspace_as_you_code` tool is available**, use it:
- `source_file_path` (required): absolute path to the C/C++ file
- `checkers_file_path` (optional): path to checkers XML file
- `build_options_file_path` (optional): path to build options file
- `polyspace_options_file_path` (optional): path to additional options file
- `baseline_folder_path_to_use` (optional): path to a folder with previous results for baseline comparison
- `baseline_folder_path_to_store` (optional): path to a folder to store results persistently

### Otherwise using the binary directly

**Otherwise**, read `references/cli-usage.md` in this skill's directory for direct command-line usage.

## Handling errors

If compilation fails, check `<output_dir>/polyspace_err.log` for compiler error details. Common causes:
- Missing include paths or defines — regenerate the build options file using a build command or compilation database
- Wrong compiler, language, or target settings in the options file

## After analysis

If the user wants to **understand or prioritize** what was found (not fix it yet) — "what did it find", "which are serious", "explain this one" — hand off to the `polyspace-review-findings` skill (shared with Bug Finder), which reads the results database and ranks defects and coding-standard violations.

If the user asked to fix findings or make the code compliant (not just run analysis), and findings are reported:

- **If skills are available**, invoke the `polyspace-fix-findings` skill. Do NOT skip the skill and call MCP tools directly — the skill defines the full fix/justify workflow.
- **If skills are not available**, read the `polyspace-fix-findings` and `polyspace-justify-in-code` skills (in the `polyspace-static-core` group) for the fix/justify workflows.

---

Copyright 2026 The MathWorks, Inc.

---
