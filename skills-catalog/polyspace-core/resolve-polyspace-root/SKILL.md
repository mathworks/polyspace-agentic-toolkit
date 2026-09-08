---
name: resolve-polyspace-root
description: >
  Return the Polyspace installation root path (`<polyspace_root>`). Use when a
  skill or CLI fallback needs the Polyspace root directory and the MCP server
  is not available.
metadata:
  author: MathWorks
  version: "2.1"
---

# Resolve Polyspace Root

Return the Polyspace installation root (`<polyspace_root>`) that `polyspace-agentic-toolkit-setup` stored. This skill only reads the stored value — it does not discover the root itself.

## When to Use

- Before invoking a Polyspace binary in CLI-fallback mode
- When any skill needs `<polyspace_root>` and the MCP server is not available

## When NOT to Use

- Installing or configuring the MCP server, or (re)detecting / changing the Polyspace installation — invoke `polyspace-agentic-toolkit-setup`

## Workflow

Read the toolkit state file that `polyspace-agentic-toolkit-setup` wrote:

| Platform | State file |
|----------|-----------|
| Linux/macOS | `~/.config/polyspace-agentic-toolkit/config.json` |
| Windows | `%APPDATA%\polyspace-agentic-toolkit\config.json` |

Use its `polyspaceRoot` field as `<polyspace_root>`; binaries are at `<polyspace_root>/polyspace/bin/`.

If the state file does not exist, or `polyspaceRoot` is empty or missing, the toolkit has not been set up — invoke `polyspace-agentic-toolkit-setup` to resolve and store the root, then read the state file again.

----

Copyright 2026 The MathWorks, Inc.

----
