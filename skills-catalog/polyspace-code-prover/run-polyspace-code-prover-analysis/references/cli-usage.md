# Running Polyspace Code Prover from the command line

Read this only when the Polyspace MCP server is unavailable.

| Platform      | Binary name |
|---------------|-------------|
| Linux / macOS | `polyspace-code-prover-server` (server) or `polyspace-code-prover` (desktop) |
| Windows       | `polyspace-code-prover-server.exe` or `polyspace-code-prover.exe` |

## How to find the binaries

Invoke `resolve-polyspace-root` to obtain `<polyspace_root>`. Binaries are at
`<polyspace_root>/polyspace/bin/`. A user has one edition or the other; both take
the **same launch options**. Pick whichever exists and, below, let `<cp>` stand for
that binary (append `.exe` on Windows). Per SKILL.md, only the **server** edition's
SARIF export carries the line/traceback/numerical detail review needs — do not fall
through to a raw desktop run unless the user accepted degraded results.

## Usage

```
<cp> -options-file <options_file.txt> \
     -sources <file1>,<file2> \
     -results-dir <output_dir>
```

The verification produces a `.pscp` results database inside `<output_dir>`.
The stop level defaults to Level 2; pass `-to "Software Safety Analysis Level N"` only if the user asked for deeper verification (see SKILL.md).
On success there is no stdout output — the result is the populated `<output_dir>`.

## Launch gotchas

- **Invoke the executable directly** — do not wrap the launch in a shell, script,
  or helper command; wrapping can cause spurious internal errors.
- **Sandboxing breaks Code Prover.** Running the verifier or the exporter inside a
  restricted sandbox can raise false internal errors such as
  `exception Match(Match) raised` or stall the export. Run outside the sandbox; if
  a run fails in a sandbox, reproduce it outside before reporting a product bug.
- **Windows quoted paths** — if the environment cannot launch a quoted
  `C:\Program Files\...` path, use the 8.3 short form, e.g.
  `C:\Progra~1\Polyspace_Server\R2026a\polyspace\bin\polyspace-code-prover-server.exe`.
- On a compile failure, read the log in `<output_dir>` (`Polyspace_R*.log`) for
  `error:` lines and fix the options file per SKILL.md's compile-error guidance
  (add `-stop-if-compile-error` to halt instead of silently skipping the file).

## Reading results

Export the results for structured parsing:

```
polyspace-results-export -format json-sarif \
    -results-dir <output_dir> \
    -output-name <output_dir>/results.sarif
```

Only the **server** edition's export carries line-of-check, traceback, and
numerical values (see SKILL.md). To see all options, run `<cp> -help`.

---

Copyright 2026 The MathWorks, Inc.

---
