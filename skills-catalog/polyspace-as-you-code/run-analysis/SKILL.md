---
name: run-analysis
description: Runs Polyspace as You Code static analysis on C/C++ source files. Use when the user asks to "run analysis", "check my code", "analyze this file", "make this MISRA compliant", "check compliance", or wants to find defects and coding standard violations in C/C++ code.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.0"
---
# How to Run Polyspace as You Code Analysis

Run Polyspace as You Code (PAYC) on a C/C++ source file to find standard violations, defects, and coding rule issues.

## Pre-analysis setup

Before running, gather build configuration:

1. Look for existing Polyspace IDE config in `.vscode/settings.json` (`polyspace.analysisOptions.*`), `.project`, or `.vs/`. If found, use it to populate the build options, checkers, and options file paths.
2. Otherwise, ask the user for pre-created config files or a team script that launches Polyspace.
3. Otherwise, search for `compile_commands.json` or a `Makefile`/`CMakeLists.txt` and create a build options file (read `configure-build-options/SKILL.md` in the parent folder).
4. For simple standalone files, build options may not be needed.

If no checkers file exists, read `configure-checkers/SKILL.md` in the parent folder to create one.

## Running the analysis

### Using the MCP tool

**If the Polyspace MCP Server is available**, use the `run_polyspace_as_you_code` tool:
- `source_file_path` (required): absolute path to the C/C++ file
- `checkers_file_path` (optional): path to checkers XML file
- `build_options_file_path` (optional): path to build options file
- `polyspace_options_file_path` (optional): path to additional options file
- `baseline_folder_path_to_use` (optional): path to previous results for baseline comparison
- `baseline_folder_path_to_store` (optional): path to store results persistently

### Otherwise using the binary directly

**If the Polyspace MCP Server is NOT available**, read `cli-usage.md` in this folder for direct command-line usage.

## Handling errors

If compilation fails, check `<output_dir>/polyspace_err.log` for compiler error details. Common causes:
- Missing include paths or defines — regenerate the build options file using a build command or compilation database
- Wrong compiler, language, or target settings in the options file

## After analysis

If findings are reported, read `fix-findings/SKILL.md` and `justify-findings/SKILL.md` in the parent folder for the fix/justify workflows.
