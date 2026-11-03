---
name: polyspace-query-justification-catalog
description: Queries a Polyspace justification catalog for pre-approved texts. Use when the user asks to "query justification catalog", "find pre-approved justification", "look up catalog", or needs to find pre-approved justification texts for Polyspace findings.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.2"
---
# How to Query a Justification Catalog

A justification catalog is a JSON file containing pre-approved justification texts for Polyspace findings.

## Using the MCP tool

**If the `query_justification_catalog` tool is available**, use it:
- `findings` (required): one or more findings as `FAMILY:ACRONYM`, comma-separated (e.g., `"Defect:INT_ZERO_DIV,MISRA-C3:8.4"`)
- `catalog_file_path` (required): absolute path to the catalog JSON file

Each finding is split at its **first** colon: everything before it is the family, everything
after it is the acronym. So a family name that itself contains a colon — the results database
spells coding-standard families that way, e.g. `MISRA C:2023` — cannot be passed literally.
Use the catalog's own family spelling (the annotation-style name, e.g. `MISRA-C-2023`), or pass
`*` as the family (`*:8.4`) to match on the acronym alone.

The acronym needs the same care. A coding-rule check identifier in the results already repeats the
standard before the rule number, so the acronym to pass is only the trailing rule number: from a
check reported as the 2012 standard followed by `8.4`, pass `8.4`. Acronyms are matched exactly
(case-insensitively), so a standard prefix left in place matches nothing and you get the "no match"
line below for a finding the catalog does cover. Defect acronyms need no stripping.

The response is text: one block per finding, either the matching pre-approved comments or
`No matching justifications found in catalog for FAMILY:ACRONYM`. That "no match" line is a
successful answer, not an error — it means the catalog has no pre-approved text for that
finding, so write a justification yourself.

## Otherwise reading the catalog directly

**Otherwise**, read `references/catalog-schema.md` in this skill's directory for the JSON schema and matching rules to read the file directly.

---

Copyright 2026 The MathWorks, Inc.

---
