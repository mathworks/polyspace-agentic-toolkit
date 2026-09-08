# Sourcegraph Amp — Setup Guidance

Status: EXPERIMENTAL — untested

## Global Config Path

| Platform | Path |
|----------|------|
| macOS / Linux | `~/.config/amp/settings.json` |
| Windows | `%USERPROFILE%\.config\amp\settings.json` |

## Phase 3b: Configure Amp

### Register MCP server and skills

Read the existing config if it exists. Add or update two settings, preserving all other entries:

1. MCP server under `amp.mcpServers`:

```json
{
  "amp.mcpServers": {
    "polyspace": {
      "command": "<ABSOLUTE_PATH_TO_BINARY>",
      "args": ["--polyspace-root=<POLYSPACE_ROOT>"]
    }
  }
}
```

Omit `--polyspace-root` from `args` if no Polyspace installation was found.

2. Skills — install only the confirmed groups, then point Amp at them.

   Amp loads every skill under `amp.skills.path`, so pointing it at the full
   `skills-catalog` would load skills for products the user does not have.
   Instead, run the shared install script with the skill groups confirmed in
   Phase 2 so only those groups are linked into `~/.agents/skills/`:
   - Linux/macOS: `scripts/install-global-skills.sh <group> [<group> ...]`
   - Windows: `scripts/install-global-skills.ps1 <group> [<group> ...]`

   Then set `amp.skills.path` to that directory:

```json
{
  "amp.skills.path": "<ABSOLUTE_PATH_TO_HOME>/.agents/skills"
}
```

If `amp.skills.path` already has a value, append this path (colon-separated, semicolon on Windows) rather than replacing.

### Check permissions

Check for `amp.mcpPermissions` in the config. If it contains reject rules that would block the server, warn the user and suggest adding an allow rule. Do not modify permissions without explicit confirmation.

## Quirks

- All Amp settings use the `amp.` prefix (e.g., `amp.mcpServers`, not just `mcpServers`).
- Global settings do not require trust approval; workspace settings do. Always configure globally.
- On Windows, use backslash paths and semicolons as path separators for `amp.skills.path`.

## Verification

1. Check that `~/.config/amp/settings.json` contains the `amp.mcpServers.polyspace` entry.
2. Restart Amp.
3. Ask: "What Polyspace tools are available?"
4. Run `amp mcp doctor` if available.

## Fallback

If automated config writing fails:

> 1. Open `~/.config/amp/settings.json` in a text editor (create the file and directory if they don't exist).
> 2. Add the `amp.mcpServers.polyspace` and `amp.skills.path` entries shown above.
> 3. Save the file and restart Amp.

---

Copyright 2026 The MathWorks, Inc.

---
