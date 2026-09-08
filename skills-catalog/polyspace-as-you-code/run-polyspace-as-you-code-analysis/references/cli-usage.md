# Running Polyspace as You Code from the command line

| Platform      | Binary name |
|---------------|-------------|
| Linux / macOS | `polyspace-as-you-code` (R2026a+) or `polyspace-bug-finder-access` (older) |
| Windows       | `polyspace-as-you-code.exe` (R2026a+) or `polyspace-bug-finder-access.exe` (older) |

## How to find the binaries

Invoke `resolve-polyspace-root` to obtain `<polyspace_root>`. Binaries are at
`<polyspace_root>/polyspace/bin/`.

## Usage

```
polyspace-as-you-code -sources <file> \
    [-checkers-activation-file <checkers.xml>] \
    [-options-file <build_options.txt>] \
    [-options-file <options_file.txt>] \
    [-import-comments <baseline_folder>] \
    -results-dir <output_dir>
```

Then export results to SARIF for structured parsing:

```
polyspace-results-export -format json-sarif \
    -results-dir <output_dir> \
    -output-name <output_dir>/results.sarif
```

Read the resulting `results.sarif` file (standard SARIF 2.1.0 JSON format) to get findings.

To see all available analysis options, run `polyspace-as-you-code -help` (or `polyspace-bug-finder-access -help` for older versions).

---

Copyright 2026 The MathWorks, Inc.

---
