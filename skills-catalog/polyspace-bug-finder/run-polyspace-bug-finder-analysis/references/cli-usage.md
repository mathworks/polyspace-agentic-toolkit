# Running Polyspace Bug Finder from the command line

Read this only when the Polyspace MCP server is unavailable. It carries the
CLI-specific mechanics; the conceptual guidance (editions, the SARIF trace
limitation, compile-error handling) is in `SKILL.md` and is not repeated here.

| Platform      | Binary name |
|---------------|-------------|
| Linux / macOS | `polyspace-bug-finder-server` (server) or `polyspace-bug-finder` (desktop) |
| Windows       | `polyspace-bug-finder-server.exe` or `polyspace-bug-finder.exe` |

## How to find the binaries

Invoke `resolve-polyspace-root` to obtain `<polyspace_root>`. Binaries are at
`<polyspace_root>/polyspace/bin/`. A user has one edition or the other; both take
the **same launch options**. Pick whichever exists and, below, let `<bf>` stand for
that binary (append `.exe` on Windows).

## Usage

```
<bf> -options-file <options_file.txt> \
     -sources <file1>,<file2> \
     -checkers-activation-file <checkers.xml> \
     -results-dir <output_dir>
```

The analysis produces a `.psbf` results database inside `<output_dir>`.
`-checkers-activation-file` is optional (selects which defects/rules run).
On success there is no stdout output — the result is the populated `<output_dir>`.
`<bf>` is the command-line analyzer and runs non-interactively by default; it does
**not** launch a GUI, so no extra flag is needed to suppress one.

## Launch gotchas

- **Invoke the executable directly** — do not wrap the launch in a shell, script,
  or helper command; wrapping can cause spurious internal errors.
- **Sandboxing breaks Bug Finder.** Running the analyzer or the exporter inside a
  restricted sandbox can raise false internal errors or stall the export. Run
  outside the sandbox; if a run fails in a sandbox, reproduce it outside before
  reporting a product bug.
- **Windows quoted paths** — if the environment cannot launch a quoted
  `C:\Program Files\...` path, use the 8.3 short form, e.g.
  `C:\Progra~1\Polyspace_Server\R2026a\polyspace\bin\polyspace-bug-finder-server.exe`.
- On a compile failure, read the log in `<output_dir>` (`Polyspace_R*.log`) and fix
  the options file per SKILL.md's compile-error guidance.

## Reading results

Export the results for structured parsing:

```
polyspace-results-export -format json-sarif \
    -results-dir <output_dir> \
    -output-name <output_dir>/results.sarif
```

This SARIF has no `codeFlows` — the SARIF array that records a finding's
step-by-step source→sink event trace — so it gives location/message/family/impact
but not the source→sink trace (see SKILL.md) — rerun via the MCP server when a
trace is needed. To see all options, run `<bf> -help`.

---

Copyright 2026 The MathWorks, Inc.

---
