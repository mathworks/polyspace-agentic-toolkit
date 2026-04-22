# Claude Code — Setup Guidance

Status: Automated — tested

## Global Config Path

MCP server config is managed by `claude mcp add-json` with `-s user` scope. The settings file is at:
- Linux/macOS: `~/.claude/settings.json`
- Windows: `%USERPROFILE%\.claude\settings.json`

Do NOT write `~/.claude/.mcp.json` directly — Claude Code ignores manually written files and only reads MCP servers registered through its CLI.

## Phase 3b: Configure Claude Code

### Register MCP server

```bash
claude mcp add-json polyspace '{
  "command": "<ABSOLUTE_PATH_TO_BINARY>",
  "args": ["--polyspace-root=<POLYSPACE_ROOT>"]
}' -s user
```

Replace `<ABSOLUTE_PATH_TO_BINARY>` with the absolute path to the installed binary (e.g., `/home/username/.local/bin/polyspace-mcp-server`). Do NOT use `~`. Omit `--polyspace-root` from `args` if no Polyspace installation was found.

### Register marketplace (optional — enables plugin auto-discovery)

If this repo is cloned locally:

```bash
claude plugin marketplace add "<ABSOLUTE_PATH_TO_REPO>"
claude plugin install polyspace-as-you-code@polyspace-agentic-toolkit
claude plugin install polyspace-test@polyspace-agentic-toolkit
```

If installing from GitHub:

```bash
claude plugin marketplace add "https://github.com/polyspace/polyspace-agentic-toolkit"
claude plugin install polyspace-as-you-code@polyspace-agentic-toolkit
claude plugin install polyspace-test@polyspace-agentic-toolkit
```

### Configure permissions

Add MCP tool permissions to `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__polyspace__*"
    ]
  }
}
```

If skills are stored outside the project directory, also add:

```json
"Read(<ABSOLUTE_PATH_TO_REPO>/skills-catalog/**)"
```

## Quirks

- MCP tools become available in the **next session** (or immediately if the session is restarted).
- `claude plugin` commands may not be available in older Claude Code versions — see fallback below.

## Verification

```bash
claude mcp list
claude plugin list
```

Confirm `polyspace` appears in the MCP server list.

## Fallback

If `claude plugin` commands fail (e.g., not available in the user's Claude Code version):

1. Skip plugin installation — skills can be used by reading SKILL.md files directly from the repo.
2. The MCP server registration via `claude mcp add-json` still works independently of the plugin system.
3. If `claude` CLI is not available at all, the user can manually edit `~/.claude/settings.json` to add the MCP server under `mcpServers`.
