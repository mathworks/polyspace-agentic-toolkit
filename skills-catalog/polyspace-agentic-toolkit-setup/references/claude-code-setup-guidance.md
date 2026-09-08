# Claude Code — Setup Guidance

**Status: Tested**

This reference file contains Claude Code-specific instructions for Phase 3b of the setup skill.

## Overview

Claude Code uses a plugin system with a marketplace. The toolkit ships several plugins:

- `polyspace-core` — cross-product foundations (resolve the Polyspace root, configure build options, find documentation entry points). **Always install this**, regardless of which Polyspace products are present.
- `polyspace-static-core` — shared static-analysis skills (configure checkers, find checker/option documentation, fix findings, justify in code and in the results database, query the justification catalog). Install when any of Polyspace as You Code, Bug Finder, or Code Prover is available.
- `polyspace-as-you-code` — run Polyspace as You Code file-level analysis. Install when Polyspace as You Code is available.
- `polyspace-bug-finder` — run Polyspace Bug Finder defect and coding-standard analysis across several files. Install when Polyspace Bug Finder is available.
- `polyspace-code-prover` — run and review Polyspace Code Prover verification and triage orange checks. Install when Polyspace Code Prover is available.
- `polyspace-test` — generate, run, and measure coverage of PSTUnit tests. Install when Polyspace Test is available.

Install only the product plugins that match the user's installed Polyspace products — agents trigger the right skills more reliably when fewer are loaded. Install `polyspace-static-core` whenever you install any of the static-analysis product plugins (`polyspace-as-you-code`, `polyspace-bug-finder`, `polyspace-code-prover`), since those depend on its shared skills.

The setup skill itself is **not** installed as a plugin: it is read in place from the cloned repository to bootstrap installation. No plugin ships MCP server configuration (MCP config is system-specific and can't be meaningfully defaulted). The setup skill registers the MCP server using `claude mcp add-json` so it is managed by Claude Code's native settings system.

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

Always install `polyspace-core`:

```bash
claude plugin install polyspace-core@polyspace-agentic-toolkit
```

Then install only the plugins for the skill groups confirmed in Phase 2 (from the product detection in step 1h) — not the whole list below. Install `polyspace-static-core` if any static-analysis product (as You Code, Bug Finder, Code Prover) is present:

```bash
# Shared static-analysis skills — install if any of the static products below are present
claude plugin install polyspace-static-core@polyspace-agentic-toolkit
# Polyspace as You Code
claude plugin install polyspace-as-you-code@polyspace-agentic-toolkit
# Polyspace Bug Finder
claude plugin install polyspace-bug-finder@polyspace-agentic-toolkit
# Polyspace Code Prover
claude plugin install polyspace-code-prover@polyspace-agentic-toolkit
# Polyspace Test
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

Confirm that `polyspace-core@polyspace-agentic-toolkit` and each product plugin you installed (e.g. `polyspace-static-core`, `polyspace-as-you-code`, `polyspace-bug-finder`, `polyspace-code-prover`, and/or `polyspace-test`, each suffixed `@polyspace-agentic-toolkit`) appear in the output.

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
