# Triaging orange checks from the command line

The orange-source ranking and static value ranges are Code Prover analysis data
that the export formats do not fully expose, so the MCP tools are strongly
preferred for triage. When only the CLI is available:

## How to find the binaries

Invoke `resolve-polyspace-root` to obtain `<polyspace_root>`. Binaries are at
`<polyspace_root>/polyspace/bin/`.

## List the orange checks

```
polyspace-results-export -format json-sarif \
    -results-dir <output_dir> \
    -output-name <output_dir>/results.sarif
```

In the SARIF, orange checks appear with `level: "warning"`. Group them by
`ruleId` and by function to find where orange concentrates — the CLI equivalent
of "which constructs generate the most orange".

## Deeper triage requires the MCP tools

The per-check computed value ranges, the DRS-applicable flag, and the ranked
orange sources are Code Prover internal analysis data. They are **not** exposed
by any CLI export — they are not in the SARIF — so without the MCP server you
cannot reproduce the orange-source ranking or the per-check ranges. Fall back to
listing and grouping the oranges from the SARIF (above); for the ranking and
ranges, use the MCP tools (`get_orange_sources`, `get_static_ranges`).

Report generation (`polyspace-report-generator`) is **not** a substitute: it
produces a human-readable document of results for people to archive or share,
not a data source for agent triage, and its output does not contain the
orange-source ranking.

---

Copyright 2026 The MathWorks, Inc.

---
