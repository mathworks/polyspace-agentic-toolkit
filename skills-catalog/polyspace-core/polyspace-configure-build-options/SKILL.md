---
name: polyspace-configure-build-options
description: Creates Polyspace build options files from build commands or compilation databases. Use when the user asks to "configure build options", "create build options file", "set up Polyspace build", or needs to configure compiler settings for Polyspace analysis.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.3"
---
# How to Configure Build Options for Polyspace

Create a Polyspace build options file from either a build command (sniffing) or a compilation database (`compile_commands.json`). Exactly one source must be provided.

## Using the MCP tool

**If the `configure_build_options_from_build_command` or `configure_build_options_from_ccdb` tool is available**, use one depending on your source:

- To sniff a **build command**, use `configure_build_options_from_build_command`:
  - `build_options_file_path` (required): absolute path to the output file to create
  - `build_command` (required): the project build command to sniff
  - `extra_polyspace_configure_options_file_path` (optional): extra polyspace-configure options
- To use a **compilation database**, use `configure_build_options_from_ccdb`:
  - `build_options_file_path` (required): absolute path to the output file to create
  - `ccdb_file_path` (required): absolute path to `compile_commands.json`
  - `extra_polyspace_configure_options_file_path` (optional): extra polyspace-configure options

**macOS**: Build command sniffing (`build_command`) is not supported on macOS because System Integrity Protection (SIP) blocks `polyspace-configure` from tracing processes. Use `ccdb_file_path` with a `compile_commands.json` instead.

## Otherwise using the binary directly

**Otherwise**, read `references/cli-usage.md` in this skill's directory for direct command-line usage with `polyspace-configure`.

## Finding a compilation database

- **CMake**: add `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` to your CMake configure command
- **Bear**: run `bear -- make` (or your build command) to generate `compile_commands.json`
- **Other build systems**: check if your build system has native support for generating `compile_commands.json`

## Common issues

- Wrong compiler detected — specify the compiler explicitly in the extra options file
- Missing include paths — ensure the build command or compilation database is complete
- To see all available polyspace-configure options, run `polyspace-configure -help`

---

Copyright 2026 The MathWorks, Inc.

---
