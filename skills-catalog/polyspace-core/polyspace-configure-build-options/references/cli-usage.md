# Running polyspace-configure from the command line

## How to find the binary

Invoke `resolve-polyspace-root` to obtain `<polyspace_root>`. The binary is at
`<polyspace_root>/polyspace/bin/polyspace-configure`.

## Usage

**From a compilation database:**

```
polyspace-configure \
    -output-options-file <build_options.txt> \
    -allow-overwrite -no-sources \
    -compilation-database <compile_commands.json>
```

**From a build command (sniffing):**

| Platform      | Command                                                         |
|---------------|-----------------------------------------------------------------|
| Linux / macOS | `polyspace-configure ... sh -c "<build_command>"`               |
| Windows       | `polyspace-configure ... cmd /c "<build_command>"`              |

```
polyspace-configure \
    -output-options-file <build_options.txt> \
    -allow-overwrite -no-sources \
    sh -c "<build_command>"
```

Optional: prepend `-options-file <extra_options.txt>` for additional polyspace-configure options.

The `-no-sources` flag is important: it excludes `-sources` from the output so Polyspace as You Code can specify its own single file later.

---

Copyright 2026 The MathWorks, Inc.

---
