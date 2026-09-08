---
name: polyspace-justify-in-code
description: Justifies Polyspace findings by adding annotation comments in the C/C++ source code. Use when the user asks to "add a Polyspace annotation", "justify a finding in the source/in code", "mark as false positive in the code", "suppress a finding with a comment", or wants an in-source justification the next analysis will read. For recording a review status in the results database instead, use polyspace-justify-in-database.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.3"
---
# How to Justify Polyspace Findings

Use Polyspace annotation comments to justify findings that are false positives, intentional behavior, or prevented by external constraints (hardware, protocol, caller validation).

**This skill uses source code comments only.** Do not offer alternative methods (XML files, external config files, etc.). The annotation is always a comment inserted directly in the source code, either on the finding line or as a block around the finding lines.

Recording a review status *in the results database* (Bug Finder `.psbf` or Code Prover `.pscp`, and transferring it across re-runs) is a different mechanism — use `polyspace-justify-in-database` for that. This skill covers only in-source annotations.

## When NOT to Use
- Recording a review status/rationale **in the results database** (`.psbf`/`.pscp`), or carrying reviews across re-runs — use `polyspace-justify-in-database`. That is the other half of the justify pair: this skill writes a comment in the source; `polyspace-justify-in-database` writes a status into the database.
- Deciding *whether* a finding is a real defect or acceptable in the first place — review it first (`polyspace-review-findings` for Bug Finder / as-you-code findings, `triage-orange-checks` for Code Prover oranges).
- Fixing a real error in the code — use `polyspace-fix-findings`.

## Annotation syntax

### Line mode (default)

Insert at the end of the finding line:

```c
code_on_finding_line; /* polyspace FAMILY:ACRONYM [Status] "justification text" */
```

### Block mode

Insert around the finding lines:

```c
/* polyspace-begin FAMILY:ACRONYM [Status] "justification text" */
code_on_finding_lines;
/* polyspace-end FAMILY:ACRONYM */
```

## FAMILY:ACRONYM format

Both `FAMILY` and `ACRONYM` must match the exact values from the analysis results. Examples:
- `Defect:INT_ZERO_DIV` — Bug Finder defect
- `MISRA-C3:8.4` — MISRA C 2012 rule (family `MISRA-C3`)
- `MISRA-C-2023:8.4` — MISRA C 2023 rule (family `MISRA-C-2023`)
- `CERT-C:DCL00-C` — CERT C rule
- `CWE:119` — CWE weakness

Do not guess family names — for example, MISRA C 2012 uses family `MISRA-C3` and MISRA C 2023 uses family `MISRA-C-2023`.

## Status values

- `Justified` (default)
- `Not a defect`
- `No action planned`

## Severity (optional)

Append severity after the status with a colon:

```c
/* polyspace FAMILY:ACRONYM [Justified:High] "justification text" */
```

Values: `High`, `Medium`, `Low`.

## Justification text guidelines

A good justification explains **why** the deviation is acceptable. Include:
- The **reason** for the deviation (e.g., hardware access, portability, performance, adopted code that cannot be modified, code quality, project convention)
- **Specific details** — reference the relevant function, variable, constraint, or platform

Keep it concise (under 20 words), no trailing period. Examples:
- `"Hardware register read requires cast to uint32_t"`
- `"Vendor-supplied HAL library cannot be modified"`
- `"Inline assembly required for cycle-critical ISR"`
- `"int is 32-bit on all target platforms for this project"`
- `"Helper macro reduces repetition across 12 call sites"`
- `"Denominator checked non-zero by caller validate_input()"`

## User confirmation

**Always ask the user for confirmation before inserting the annotation.** Present:
1. The finding (family, acronym, message, location)
2. Your proposed justification text
3. The exact annotation you plan to insert

Wait for explicit approval before editing the file.

## Pre-approved justification catalog

If the project has a justification catalog JSON file:

**If the `query_justification_catalog` tool is available**, use it with the `findings` and `catalog_file_path` arguments to get pre-approved justification texts.

**Otherwise**, invoke the `polyspace-query-justification-catalog` skill, or if skills are not available, read `polyspace-query-justification-catalog/SKILL.md` in this skill's parent folder for the catalog JSON schema and how to query it directly.

If no catalog file is provided and the project has IDE markers (`.vscode/`, `.project`, `.vs/`), the user may have a justification catalog configured in the IDE extension settings — ask them.

## Next analysis

On the next Polyspace analysis run, the annotation is recognized and the finding is marked as justified.

---

Copyright 2026 The MathWorks, Inc.

---
