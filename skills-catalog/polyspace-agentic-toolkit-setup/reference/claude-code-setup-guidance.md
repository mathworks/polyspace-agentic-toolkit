# Claude Code — Setup Guidance

**Status: Tested**

This reference file contains Claude Code-specific instructions for Phase 3b of the setup skill.

## Overview

Claude Code uses a plugin system with a marketplace. The `polyspace-as-you-code` plugin delivers analysis and remediation skills, the `polyspace-test` plugin delivers test generation skills, and the `polyspace-agentic-toolkit-setup` plugin delivers the setup skill. Neither ships MCP server configuration (MCP config is system-specific and can't be meaningfully defaulted). The setup skill registers the MCP server using `claude mcp add-json` so it is managed by Claude Code's native settings system.

## Global Config Path

MCP server config is managed by `claude mcp add-json` with `-s user` scope. Do NOT write `~/.claude/.mcp.json` directly — Claude Code ignores manually written files and only reads MCP servers registered through its CLI.

## Phase 3b: Register Plugin

### Step 1: Add the marketplace

If installing from GitHub:

```bash
claude plugin marketplace add "https://github.com/mathworks/polyspace-agentic-toolkit"
```

If the repo is cloned locally, use the absolute path instead:

```bash
claude plugin marketplace add "<ABSOLUTE_PATH_TO_REPO>"
```

If the marketplace is already registered, this is a no-op. Continue to the next step.

### Step 2: Install plugins

```bash
claude plugin install polyspace-as-you-code@polyspace-agentic-toolkit
claude plugin install polyspace-test@polyspace-agentic-toolkit
```

Claude's native prompt will ask the user to choose scope for each plugin. Do NOT implement your own scope selection — let Claude Code handle it.

### Step 3: Register MCP server

Use `claude mcp add-json` to register the Polyspace MCP server at user scope:

On Linux/macOS:

```bash
claude mcp add-json polyspace '{"command":"<ABSOLUTE_PATH_TO_BINARY>","args":["--polyspace-root=<POLYSPACE_ROOT>"]}' -s user
```

On Windows (PowerShell) — single quotes do not work, use escaped double quotes:

```powershell
claude mcp add-json polyspace "{`"command`":`"<ABSOLUTE_PATH_TO_BINARY>`",`"args`":[`"--polyspace-root=<POLYSPACE_ROOT>`"]}" -s user
```

All paths must be absolute expanded paths (e.g., `/home/username/.local/bin/polyspace-mcp-server` or `C:\Users\username\AppData\Local\polyspace\polyspace-mcp-server.exe`). Do not use `~` or `%LOCALAPPDATA%`.

If no Polyspace installation was found during discovery, omit `--polyspace-root` from `args`. However, warn the user that without it the server relies on auto-discovery from the Polyspace installer registry (`polyspace_products.prf`), and if auto-discovery fails, the MCP tools will not work until `--polyspace-root` is configured manually.

Do NOT write `~/.claude/.mcp.json` directly — Claude Code ignores that file and only reads MCP servers registered through `claude mcp add` / `claude mcp add-json`.

The MCP tools become available in the next session (or immediately if the session is restarted).

### Step 4: Verify plugin installation

```bash
claude plugin list 2>&1
```

Confirm that `polyspace-as-you-code@polyspace-agentic-toolkit` and `polyspace-test@polyspace-agentic-toolkit` appear in the output.

## If Plugin Commands Fail

If `claude` CLI commands fail (e.g., not available in the user's Claude Code version):

1. Report the error clearly.
2. Skip plugin installation — skills can be used by reading SKILL.md files directly from the repo.
3. The MCP server registration (Step 3) via `claude mcp add-json` still works independently of the plugin system.
4. If `claude` CLI is not available at all, the user can manually edit `~/.claude/settings.json` to add the MCP server under `mcpServers`.

## Verification

```bash
claude mcp list
claude plugin list
```

Confirm `polyspace` appears in the MCP server list and plugins are installed.

---

Copyright 2026 The MathWorks, Inc.

---
