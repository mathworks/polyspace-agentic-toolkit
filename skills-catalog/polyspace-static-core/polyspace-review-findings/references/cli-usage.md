# Reviewing Polyspace findings from the command line

When the MCP server is unavailable, export the results (`.psbf` / `.payc`) to a
structured file and read that.

## How to find the binaries

Invoke `resolve-polyspace-root` to obtain `<polyspace_root>`. Binaries are at
`<polyspace_root>/polyspace/bin/`.

## Export the results

```
polyspace-results-export -format json-sarif \
    -results-dir <output_dir> \
    -output-name <output_dir>/results.sarif
```

The SARIF 2.1.0 JSON lists every finding with its `ruleId` (the checker
family:acronym, e.g. `Defect:INT_ZERO_DIV`, `MISRA-C3:8.4`), file, line, message,
and a `level`:

| SARIF `level` | Meaning |
|---------------|---------|
| `error` / `warning` | a reported finding (defect or coding-standard violation) |
| `note` | informational |

Group findings by `ruleId` to separate defects (`Defect:*`) from coding-standard
violations, and to see where they concentrate.

## Reading a specific finding

Filter the SARIF by `ruleId`, file, and line to locate a finding and read its
message. Note the SARIF's limit: it does **not** carry the **event trace /
dataflow** — the `codeFlows` array (the SARIF field that records a finding's
step-by-step source→sink event trace) is empty in the `polyspace-results-export`
output (verified on both Bug Finder and as-you-code results, both editions). So
from the CLI you get the finding's endpoint (file, line, message, impact) but
**not** the source→sink path of a dataflow defect (tainted data, use-after-free).

For the event trace, call-graph tracing, variable read/write sites, macro
expansion, and the concurrency model, use the **MCP tools** — the exported SARIF
carries none of them. If only the CLI is available, you can generate an HTML/PDF
report with `polyspace-report-generator` for richer views; run
`polyspace-results-export -help` for the available formats and filters.

## Edition note

The reduced detail above is a property of the SARIF export, **not** of the edition:
`polyspace-bug-finder` (desktop) and `polyspace-bug-finder-server` (server) export
the same location-only SARIF. If review needs flow detail, the fix is the MCP
server (which reads the results database directly), not switching editions.

---

Copyright 2026 The MathWorks, Inc.

---
