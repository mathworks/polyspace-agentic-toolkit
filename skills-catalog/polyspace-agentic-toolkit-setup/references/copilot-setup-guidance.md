# GitHub Copilot — Setup Guidance

Status: Automated — tested

## Global Config Path

VS Code uses dedicated `mcp.json` files for MCP configuration (not `settings.json`).

**User-level** (recommended — available across all workspaces):
- Windows: `%APPDATA%\Code\User\mcp.json`
- macOS: `~/Library/Application Support/Code/User/mcp.json`
- Linux: `~/.config/Code/User/mcp.json`

**Workspace-level** (alternative — shared via source control):
- All platforms: `.vscode/mcp.json` in the project directory

Use the VS Code command **"MCP: Open User Configuration"** to open the user-level file if unsure of the path.

## Phase 3b: Configure GitHub Copilot

### Register MCP server

Read the user-level `mcp.json` if it exists. Add or update the `servers.polyspace` entry, preserving other server entries:

```json
{
  "servers": {
    "polyspace": {
      "type": "stdio",
      "command": "<ABSOLUTE_PATH_TO_BINARY>",
      "args": ["--polyspace-root=<POLYSPACE_ROOT>"]
    }
  }
}
```

Omit `--polyspace-root` from `args` if no Polyspace installation was found.

Note: the key is `servers` (not `mcpServers`), and each entry needs `"type": "stdio"`.

### Register global skills (only the confirmed groups)

Run the shared install script with the skill groups confirmed in Phase 2 as arguments, so only those groups are linked into `~/.agents/skills/` (no arguments links all):
- Linux/macOS: `scripts/install-global-skills.sh <group> [<group> ...]`
- Windows: `scripts/install-global-skills.ps1 <group> [<group> ...]`

Example: `scripts/install-global-skills.sh polyspace-core polyspace-static-core polyspace-code-prover`

Fallback: if `~/.agents/skills/` cannot be created, use `~/.copilot/skills/`.

## Quirks

- VS Code uses `mcp.json` files, **not** a `mcp.servers` key in `settings.json`.
- The config key is `"servers"` (not `"mcpServers"`).
- VS Code natively parses JSONC (JSON with comments), but setup should write valid JSON to avoid merge conflicts.
- No per-project setup needed when using the user-level config.

## Verification

1. Check that the user-level `mcp.json` contains the `servers.polyspace` entry.
2. Check that skill symlinks exist in `~/.agents/skills/`.
3. Reload VS Code window (Command Palette > "Developer: Reload Window").
4. Ask Copilot: "What Polyspace tools are available?"

## Fallback

If automated config writing fails:

> 1. In VS Code, run the command **"MCP: Open User Configuration"** (Cmd/Ctrl + Shift + P).
> 2. Add a `"polyspace"` entry under `"servers"` with the command and args shown above.
> 3. Save and reload VS Code.

---

Copyright 2026 The MathWorks, Inc.

---
