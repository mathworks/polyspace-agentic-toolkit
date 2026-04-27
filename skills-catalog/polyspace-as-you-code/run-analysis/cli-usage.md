# Running Polyspace as You Code from the command line

| Platform      | Binary name |
|---------------|-------------|
| Linux / macOS | `polyspace-as-you-code` (R2026a+) or `polyspace-bug-finder-access` (older) |
| Windows       | `polyspace-as-you-code.exe` (R2026a+) or `polyspace-bug-finder-access.exe` (older) |

## How to find the binaries

Polyspace binaries are in `<polyspace_root>/polyspace/bin/`. To find `<polyspace_root>`:

1. Check the `$POLYSPACE_ROOT` environment variable: `echo $POLYSPACE_ROOT`
2. If not set, check whether the binary is already in PATH: `which polyspace-as-you-code`
3. If neither works, ask the user for the Polyspace installation path.

If the binary is not in PATH, use the full path: `$POLYSPACE_ROOT/polyspace/bin/polyspace-as-you-code`.

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
