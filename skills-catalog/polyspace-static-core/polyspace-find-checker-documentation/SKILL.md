---
name: polyspace-find-checker-documentation
description: Finds documentation for Polyspace checkers and coding rules. Use when the user asks "what does this checker do", "find checker documentation", "explain this Polyspace rule", or wants to understand a specific Polyspace finding.
license: MathWorks BSD-3-Clause
metadata:
  version: "2.3"
---
# How to Find Polyspace Checker Documentation

Find the documentation page for a Polyspace checker or coding rule (e.g., `MISRA C:2012:Rule-8.4`, `INT_ZERO_DIV`).

## Preferred Method: `find_checker_doc` Parameter

**If the `get_polyspace_documentation` tool is available**, use it with the `find_checker_doc` parameter:

```
find_checker_doc = "Defect:INT_ZERO_DIV"
find_checker_doc = "MISRA C:2012:Rule-8.4"
find_checker_doc = "SEI CERT C:ARR30-C"
find_checker_doc = "RTE Check:COR"
find_checker_doc = "CWE:119"
```

The format is `FAMILY:ACRONYM`, where the family is one of the documentation catalog's families listed below and the acronym is the checker's short name. This returns the exact documentation URL, fix guidance URL (when available), and description directly from the installed Polyspace catalog.

Accepted families: `Defect`, `RTE Check`, `Code Metric`, `Custom Rule`, `MISRA C:2012`, `MISRA C:2023`, `MISRA C:2025`, `MISRA C++:2008`, `MISRA C++:2023`, `SEI CERT C`, `SEI CERT C++`, `AUTOSAR C++14`, `ISO/IEC TS 17961`, `CWE`, `Guidelines`.

The catalog's family names are not always the family a results database reports. A coding-rule
finding carries its standard as its family, so those pass through unchanged. But Code Prover
run-time checks are reported in results under the family `Run-time Check`, which the catalog
does not accept — use `RTE Check` for them (`RTE Check:COR`, not `Run-time Check:COR`). If a
finding's family is not in the list above, pick the catalog family that describes the checker
rather than passing the results value through.

The acronym needs the same trimming. A coding-rule check identifier in the results repeats the
standard before the rule number, so pass only the rule number: `Rule-8.4` and `8.4` are both
accepted, and a directive works as either `Dir-4.6` or the `D4.6` spelling the results use. Passing
a whole check identifier, standard included, does not resolve — you get an unknown-family error, or
a plain "not found in the catalog" answer. Read either as *the input was wrong*, not as *this
checker is undocumented*: re-map the family, trim the rule number, and retry once before telling the
user no documentation exists.

This is the fastest, most reliable path — it requires no URL pattern guessing or web search.

## Without MCP: Direct Catalog Lookup

**Otherwise**, read `references/catalog-lookup.md` in this skill's directory for how to look up checker documentation URLs directly from the installed JSON catalog files (includes anchor construction rules for all families).

## Legacy Fallback: URL Patterns

Use this fallback only when both the MCP server and the catalog files are unavailable.

### Documentation URL patterns

Rule and checker pages are under `https://www.mathworks.com/help/bugfinder/ref/` with these naming patterns:

| Standard | Index page | Page pattern | Example |
|----------|-----------|--------------|---------|
| MISRA C 2012 | misra-c-2012-reference.html | misrac2012rule{N}.html or misrac2012d{N}.html for directives | Rule 8.4 -> misrac2012rule8.4.html, Dir 4.1 -> misrac2012d4.1.html |
| MISRA C 2023 | misra-c-2023-reference.html | misrac2023rule{N}.html or misrac2023d{N}.html | Same pattern as 2012 |
| MISRA C 2025 | misra-c-2025-reference.html | misrac2025rule{N}.html or misrac2025d{N}.html | Same pattern as 2012 |
| MISRA C++ 2008 | misra-c2008-rules.html | misrac2008rule{N with dashes removed}.html | Rule 0-1-1 -> misrac2008rule011.html |
| MISRA C++ 2023 | misra-cpp-2023-rules-and-directives.html | misracpp2023rule{N}.html or misracpp2023d{N}.html | Rule 0.0.1 -> misracpp2023rule0.0.1.html |
| AUTOSAR C++14 | autosar-cpp-14.html | autosarc14rule{letter}{N with dashes removed}.html | A0-1-1 -> autosarc14rulea011.html |
| CERT C | cert-c-rules-and-recommendations.html | certcrule{id lowered with dashes removed}.html | ARR30-C -> certcrulearr30c.html |
| CERT C++ | cert-c-rules.html | certc{id lowered with dashes and -CPP suffix removed}cpp.html | EXP52-CPP -> certcexp52cpp.html |
| ISO/IEC TS 17961 | isoiec-ts-17961-rules.html | isoiects17961{id lowered}.html | accfree -> isoiects17961accfree.html |
| CWE | cwe-common-weakness-enumeration-rules.html | cwe{N}.html | CWE-119 -> cwe119.html |
| Defects | defect-reference.html | No predictable pattern | Use web search instead |

All index pages are relative to `https://www.mathworks.com/help/bugfinder/`

If you cannot determine the page URL from the patterns above and you have a web search tool (not a URL fetch tool), search for:
```
site:mathworks.com/help/bugfinder <checker_name>
```

**ACTION REQUIRED**: Use your web fetch tool to read the documentation page. Do not answer from memory alone.

---

Copyright 2026 The MathWorks, Inc.

---
