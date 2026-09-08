# Cursor — Setup Guidance

Status: EXPERIMENTAL — untested

## Global Config Path

- Linux/macOS: `~/.cursor/mcp.json`
- Windows: `%USERPROFILE%\.cursor\mcp.json` (unverified — confirm on your system if this does not work)

## Phase 3b: Configure Cursor

### Register MCP server

Read the existing config (create the file if it does not exist). Add or update the `mcpServers.polyspace` entry, preserving other server entries:

```json
{
  "mcpServers": {
    "polyspace": {
      "command": "<ABSOLUTE_PATH_TO_BINARY>",
      "args": ["--polyspace-root=<POLYSPACE_ROOT>"]
    }
  }
}
```

Omit `--polyspace-root` from `args` if no Polyspace installation was found.

### Register global skills (only the confirmed groups)

Run the shared install script with the skill groups confirmed in Phase 2 as arguments, so only those groups are linked (no arguments links all):
- Linux/macOS: `scripts/install-global-skills.sh <group> [<group> ...]`
- Windows: `scripts/install-global-skills.ps1 <group> [<group> ...]`

Example: `scripts/install-global-skills.sh polyspace-core polyspace-static-core polyspace-code-prover`

## Quirks

- Use `mcpServers` (camelCase), not `mcp.servers`.
- Cursor supports `${userHome}` in paths, but absolute paths are more reliable.
- Cursor has a 40-tool limit across all MCP servers. The Polyspace MCP Server registers 20+ tools depending on the active Polyspace products, so account for that if you enable other MCP servers.

## Verification

1. Check that `~/.cursor/mcp.json` contains the `mcpServers.polyspace` entry.
2. Restart Cursor.
3. Ask: "What Polyspace tools are available?"

## Fallback

If automated config writing fails:

> 1. Open `~/.cursor/mcp.json` in a text editor (create the file if it doesn't exist).
> 2. Add a `"polyspace"` entry under `"mcpServers"` with the command and args shown above.
> 3. Save the file and restart Cursor.

---

Copyright 2026 The MathWorks, Inc.

---
