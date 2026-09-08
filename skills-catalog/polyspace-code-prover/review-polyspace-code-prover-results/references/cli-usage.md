# Reviewing Code Prover results from the command line

When the MCP server is unavailable, export the `.pscp` results to a structured
file and read that.

## How to find the binaries

Invoke `resolve-polyspace-root` to obtain `<polyspace_root>`. Binaries are at
`<polyspace_root>/polyspace/bin/`.

## Export the results

```
polyspace-results-export -format json-sarif \
    -results-dir <output_dir> \
    -output-name <output_dir>/results.sarif
```

The SARIF 2.1.0 JSON lists every check with its rule, file, line, and a
`kind`/`level` that maps to the Code Prover color:

| SARIF | Code Prover color |
|-------|-------------------|
| `error` | Red (proven error) |
| `warning` | Orange (unproven) |
| `pass` / `none` reachable | Green (proven safe) |
| unreachable | Gray (dead code) |

## Reading a specific check

Filter the SARIF by `ruleId`, file, and line to isolate a check. The `codeFlows`
array (the SARIF field that records a finding's step-by-step trace) holds the
flow Code Prover recorded. For value ranges, call-graph tracing,
macro expansion, concurrency, and assumptions, the MCP tools are strongly
preferred — the exported SARIF does not include Code Prover static ranges or the
task model. If only the CLI is available, run
`polyspace-code-prover -help` to locate reporting options, and prefer generating
an HTML/PDF report with `polyspace-report-generator` for the richer views.

---

Copyright 2026 The MathWorks, Inc.

---
