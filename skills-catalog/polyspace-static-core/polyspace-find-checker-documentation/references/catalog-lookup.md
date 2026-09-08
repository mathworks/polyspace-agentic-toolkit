# Looking Up Checker Documentation from Catalog JSON Files

When the Polyspace MCP Server is not available, you can look up documentation URLs
directly from the JSON catalog files that ship with every Polyspace installation (R2025a+).

## File locations

```
<polyspace_root>/help/docCatalog/cshapi_helptarget/<product>.json
<polyspace_root>/help/docCatalog/referenceapi/<product>.json
```

Where `<polyspace_root>` is the Polyspace installation root. Invoke
`resolve-polyspace-root` to obtain it.

Product files: `bugfinder.json`, `codeprover.json`, `polyspace_test.json`, `polyspace_access.json`.

## CSH helptarget file structure

```json
{
  "helplocation": "bugfinder",
  "helptargets": {
    "int_zero_div": [{"path": "ref/integerdivisionbyzero.html", "page_format": "doc_center"}],
    "int_zero_div_fix_section": [{"path": "ref/integerdivisionbyzero.html#int_zero_div_fix_section", "page_format": "doc_center"}],
    "misra_c3_8.4": [{"path": "ref/misrac2012rule8.4.html", "page_format": "doc_center"}],
    "cert_c_arr30_c": [{"path": "ref/certcrulearr30c.html", "page_format": "doc_center"}]
  }
}
```

Keys are **anchors** constructed from the finding's family and acronym using the rules below.

## Anchor construction rules

| Family | Anchor pattern | Example |
|--------|---------------|---------|
| `Defect` | `{acronym_lowercase}` | `INT_ZERO_DIV` → `int_zero_div` |
| `RTE Check` | `check_{ACRONYM}` (case preserved) | `COR` → `check_COR` |
| `Code Metric` | `code_metric_{ACRONYM}` (case preserved) | `CALLING` → `code_metric_CALLING` |
| `Custom Rule` | `custom_rule_{acronym}` (lowercase) | `Custom XYZ` → `custom_rule_custom xyz` |
| `MISRA C:2012` | `misra_c3_{number}` (Rule) or `misra_c3_D{number}` (Dir) | `Rule-8.4` → `misra_c3_8.4`, `Dir-4.1` → `misra_c3_D4.1` |
| `MISRA C:2023` | `misra_c_2023_{number}` or `misra_c_2023_D{number}` | `Rule-8.4` → `misra_c_2023_8.4` |
| `MISRA C:2025` | `misra_c_2025_{number}` or `misra_c_2025_D{number}` | `Rule-8.4` → `misra_c_2025_8.4` |
| `MISRA C++:2008` | `misra_cpp_{rule_dashes→underscores}` | `Rule-0-1-1` → `misra_cpp_0_1_1` |
| `MISRA C++:2023` | `misra_cpp_2023_{rule_dots_preserved}` | `Rule-0.0.1` → `misra_cpp_2023_0.0.1` |
| `SEI CERT C` | `cert_c_{id_lower_dashes→underscores}` | `ARR30-C` → `cert_c_arr30_c` |
| `SEI CERT C++` | `cert_cpp_{id_lower_dashes→underscores}` | `EXP52-CPP` → `cert_cpp_exp52_cpp` |
| `AUTOSAR C++14` | `autosar_cpp14_{id_lower_dashes→underscores}` | `A0-1-1` → `autosar_cpp14_a0_1_1` |
| `ISO/IEC TS 17961` | `iso_17961_{id_lower_dashes→underscores}` | `accfree` → `iso_17961_accfree` |
| `CWE` | `cwe_{id_lower_dashes→underscores}` | `119` → `cwe_119` |
| `Guidelines` | `guidelines_{id_lower_dashes→underscores}` | `sc01` → `guidelines_sc01` |

**Fix section**: for Bug Finder defects, append `_fix_section` to the anchor
(e.g. `int_zero_div_fix_section`). If present in the catalog, it provides fix guidance.

## Lookup algorithm for checkers

1. Split into `FAMILY:ACRONYM` by matching `FAMILY` against the accepted family list (anchor table above): the longest family that prefixes the finding and is followed by `:` wins (families can contain colons, e.g. `MISRA C:2012:Rule-8.4` → `MISRA C:2012`). `ACRONYM` is the remainder after that `:`.
2. Build the CSH anchor using the table above
3. Open `cshapi_helptarget/<product>.json`, look up the anchor key in `helptargets`
4. If found: build URL as `https://www.mathworks.com/help/{helplocation}/{path}`
5. Also look up `{anchor}_fix_section` — if present, build a second URL for fix guidance
6. For description/metadata: open `referenceapi/<product>.json`, find matching `refItem`
   by `href` — the `refpurpose` field has the short description, `introduced` has the release

Product selection:
- Defects, coding standards (MISRA, CERT, CWE, AUTOSAR, ISO 17961, Guidelines) → `bugfinder.json`
- RTE Checks, Code Metrics (Code Prover) → `codeprover.json`
- Code Metrics (Bug Finder) → `bugfinder.json`

## URL format

```
https://www.mathworks.com/help/{helplocation}/{path}
```

Where `helplocation` comes from the CSH file's top-level field (e.g. `"bugfinder"`)
and `path` from the matched entry (e.g. `"ref/integerdivisionbyzero.html"`).

----

Copyright 2026 The MathWorks, Inc.

----
