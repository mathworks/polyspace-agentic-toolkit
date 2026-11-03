---
name: polyspace-configure-checkers
description: Creates or modifies Polyspace checkers configuration files. Use when the user asks to "configure checkers", "set up MISRA checking", "enable CWE", "create checkers file", or needs to select coding standards for Polyspace analysis.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.3"
---
# How to Configure Checkers for Polyspace

Create or modify the checkers XML file that defines which coding rules and defect checkers Polyspace uses during analysis.

## Using the MCP tool

**If the `configure_checkers_for_polyspace` tool is available**, use it:
- `checkers_file_path` (required): absolute path to the XML file to create (must have `.xml` extension)
- `standards`: an array of the standards to enable at the standard level. There is no
  per-standard parameter and no `"all"` value — pass the identifiers themselves, chosen from
  `bug_finder_findings`, `misra_c_2012`, `misra_c_2023`, `misra_c_2025`, `misra_cpp_2023`,
  `cert_c`, `cert_cpp`, `cwe` (for example `["misra_c_2023", "cwe"]`)
- `launch_checkers_selection_ui` (optional): set to `true` to open the interactive UI instead

Exactly one of `standards` and `launch_checkers_selection_ui` must be given; they are mutually
exclusive. Named subsets (MISRA mandatory/required/advisory, CERT levels, CWE top-25) cannot be
selected through this tool — it switches whole standards on.

## Otherwise using the binary / writing the XML directly

**Otherwise**, read `references/cli-usage.md` in this skill's directory for how to write the checkers XML file directly or launch the interactive UI.

---

Copyright 2026 The MathWorks, Inc.

---
