# Gemini CLI — Setup Guidance

Status: Automated — tested

## Global Config Path

- Linux/macOS: `~/.gemini/settings.json`
- Windows: `%USERPROFILE%\.gemini\settings.json` (unverified — confirm on your system if this does not work)

## Phase 3b: Configure Gemini CLI

### Register MCP server

Read `~/.gemini/settings.json` if it exists. Add or update the `mcpServers.polyspace` entry, preserving all other settings:

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

- Use `mcpServers` (camelCase) at the top level of `settings.json`.
- Do **NOT** use `gemini mcp add` from within a running Gemini session — it causes recursive invocation and file locking issues. Always write the config file directly.

## Verification

1. Check that `~/.gemini/settings.json` contains the `mcpServers.polyspace` entry.
2. Check that skill symlinks exist in `~/.agents/skills/`.
3. Restart Gemini CLI.
4. Ask: "What Polyspace tools are available?"

## Fallback

If automated config writing fails:

> 1. Open `~/.gemini/settings.json` in a text editor.
> 2. Add a `"polyspace"` entry under `"mcpServers"` with the command and args shown above.
> 3. Save the file and restart Gemini CLI.

---

Copyright 2026 The MathWorks, Inc.

---
