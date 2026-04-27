# Running polyspace-configure from the command line

## How to find the binary

The `polyspace-configure` binary is in `<polyspace_root>/polyspace/bin/`. To find `<polyspace_root>`:

1. Check the `$POLYSPACE_ROOT` environment variable: `echo $POLYSPACE_ROOT`
2. If not set, check whether the binary is already in PATH: `which polyspace-configure`
3. If neither works, ask the user for the Polyspace installation path.

If the binary is not in PATH, use the full path: `$POLYSPACE_ROOT/polyspace/bin/polyspace-configure`.

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
