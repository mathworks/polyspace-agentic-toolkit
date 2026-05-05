---
name: polyspace-agentic-toolkit-setup
description: Sets up the Polyspace Agentic Toolkit for any supported AI agent. Use when the user asks to "set up Polyspace", "set up the Polyspace Agentic Toolkit", "install the Polyspace MCP Server", "configure Polyspace for my agent", or wants to get Polyspace working with their AI application.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.0"
---
# Polyspace Agentic Toolkit — Setup Skill

Automated setup for the Polyspace Agentic Toolkit. This skill guides through platform detection, MCP server binary installation, agent configuration, and verification.

## Overview

The setup follows 5 phases:

1. **Discover** — detect platform, Polyspace installation, existing config, and agent
2. **Plan** — present findings and proposed actions to the user
3. **Execute** — download binary, register MCP server, configure skills
4. **Verify** — confirm the MCP server is connected and working
5. **Report** — final summary

## Phase 1: Discover

Run these discovery steps silently (no user interaction needed).

### 1a. Detect platform

| Platform | Detection | Binary asset name | Install path |
|----------|-----------|-------------------|--------------|
| Linux x86_64 | `uname -s` = Linux, `uname -m` = x86_64 | `polyspace-mcp-server-glnxa64` | `~/.local/bin/polyspace-mcp-server` |
| macOS arm64 | `uname -s` = Darwin, `uname -m` = arm64 | `polyspace-mcp-server-maca64` | `~/.local/bin/polyspace-mcp-server` |
| macOS x86_64 | `uname -s` = Darwin, `uname -m` = x86_64 | `polyspace-mcp-server-maci64` | `~/.local/bin/polyspace-mcp-server` |
| Windows x86_64 | `$env:OS` = Windows_NT or `OSTYPE` contains msys/cygwin | `polyspace-mcp-server-win64.exe` | `%LOCALAPPDATA%\polyspace\polyspace-mcp-server.exe` |

### 1b. Check for existing Polyspace installation

Look for `polyspace-as-you-code` (or `polyspace-bug-finder-access` for older versions) in PATH. If found, note the Polyspace root — the binary is at `<root>/polyspace/bin/<binary>`, so strip two parent directories.

If not in PATH, check the installer registry file `polyspace_products.prf` at the platform-specific default location. If neither works, the MCP server will auto-discover at runtime — note this for the plan.

**Validate the Polyspace version.** Read `VersionInfo.xml` from the Polyspace root (`<root>/polyspace/VersionInfo.xml` or `<root>/VersionInfo.xml`) and extract the release string. Polyspace must be **R2024b or later**. If the version is older, report it in the plan and warn that it is unsupported.

### 1c. Check latest MCP server version

Query GitHub for the latest release:

```bash
curl -sL https://api.github.com/repos/polyspace/polyspace-agentic-toolkit/releases/latest | grep '"tag_name"' | head -1 | sed 's/.*"\(v[^"]*\)".*/\1/'
```

Record the latest tag (e.g., `v1.0.0`).

### 1d. Check for existing MCP server binary

Check if the binary already exists at the install path. If yes, note the version (run `polyspace-mcp-server --version`). Compare with the latest version from step 1c.

### 1e. Check for existing config

Check for a prior state file:
- Linux/macOS: `~/.polyspace-agentic-toolkit/config.json`
- Windows: `%LOCALAPPDATA%\polyspace-agentic-toolkit\config.json`

If a config exists with valid paths, note the stored values as defaults for Phase 2.

### 1f. Detect the current AI agent

Determine which agent is running this setup:
- **Claude Code**: Check for `CLAUDE_CODE` env var or `claude` in PATH
- **GitHub Copilot**: Check for VS Code workspace markers (`.vscode/`)
- **Cursor**: Check for `.cursor/` directory or Cursor-specific env vars
- **Amp**: Check for `amp` in PATH or `AMP_HOME` env var
- **Codex**: Check for `codex` in PATH or `CODEX_HOME` env var
- **Gemini CLI**: Check for `gemini` in PATH

### 1g. Check for existing agent configuration

Check if the MCP server is already registered with the detected agent (e.g., check `claude mcp list`, `.vscode/mcp.json`, etc.).

If a `polyspace` MCP server entry already exists, compare its command, binary path, and args (including `--polyspace-root`) against the expected values from this setup. If they all match, the config is **up to date** — note this for the plan. If any value differs, the config is **stale and must be updated** in Phase 3.

## Phase 2: Plan

Present a summary of all findings to the user:

```
Polyspace Agentic Toolkit — Setup Plan

Platform:           <detected platform>
Polyspace root:     <path or "will auto-discover at runtime">
Polyspace version:  <R20XXx or "not found">

MCP server:
  Installed:        <path and version or "not found">
  Latest:           <vX.Y.Z from GitHub>
  Install to:       <install_path>

AI agent:           <detected agent>
MCP registration:   <up to date / stale — will update / not configured — will configure>
Skills:             <will install from skills-catalog/>

Proceed? [Y/n]
```

Wait for user confirmation before proceeding.

## Phase 3: Execute

Run all steps without interruption.

### 3a. Download and install the MCP server binary

1. Download the binary for the detected platform from the latest GitHub release:
   `https://github.com/polyspace/polyspace-agentic-toolkit/releases/latest`

2. Create the install directory if needed:
   - Linux/macOS: `mkdir -p ~/.local/bin`
   - Windows: `mkdir -p "$env:LOCALAPPDATA\polyspace"` (PowerShell)

3. Move the binary to the install path.

4. Post-download platform steps:

   | Platform | Steps |
   |----------|-------|
   | Linux | `chmod +x ~/.local/bin/polyspace-mcp-server` |
   | macOS | `chmod +x ~/.local/bin/polyspace-mcp-server` then `xattr -d com.apple.quarantine ~/.local/bin/polyspace-mcp-server` |
   | Windows | `Unblock-File -Path "$env:LOCALAPPDATA\polyspace\polyspace-mcp-server.exe"` |

### 3b. Configure the AI agent

Read the appropriate per-agent setup guidance file from `reference/` in this folder:

| Agent | Reference file |
|-------|---------------|
| Claude Code | `reference/claude-code-setup-guidance.md` |
| GitHub Copilot | `reference/copilot-setup-guidance.md` |
| Cursor | `reference/cursor-setup-guidance.md` |
| Sourcegraph Amp | `reference/amp-setup-guidance.md` |
| OpenAI Codex | `reference/codex-setup-guidance.md` |
| Gemini CLI | `reference/gemini-cli-setup-guidance.md` |

Follow the steps in the reference file to register the MCP server and configure skills for the detected agent.

When configuring the MCP server command, include the `--polyspace-root=<POLYSPACE_ROOT>` argument if a Polyspace installation was found. This tells the server where to find Polyspace binaries without relying on PATH.

**Skip this step if the existing agent configuration is already up to date** (as determined in step 1g). Only add or update the `polyspace` MCP entry — never overwrite entries for other MCP servers.

### 3c. Register global skills (for agents that support it)

For agents that read skills from `~/.agents/skills/`, run the appropriate install script:
- Linux/macOS: `scripts/install-global-skills.sh` (from the repo root)
- Windows: `scripts/install-global-skills.ps1` (from the repo root)

These scripts create symlinks from `~/.agents/skills/` to the skills-catalog in this repo.

### 3d. Save state

Write configuration to the platform-specific state directory:

| Platform | State directory |
|----------|----------------|
| Linux/macOS | `~/.polyspace-agentic-toolkit/` |
| Windows | `%LOCALAPPDATA%\polyspace-agentic-toolkit\` |

Create the directory if needed:
- Linux/macOS: `mkdir -p ~/.polyspace-agentic-toolkit`
- Windows: `mkdir -p "$env:LOCALAPPDATA\polyspace-agentic-toolkit"` (PowerShell)

Write `config.json`:

```json
{
  "toolkitRoot": "<TOOLKIT_ROOT>",
  "mcpServerPath": "<INSTALL_PATH>",
  "mcpServerArch": "<ARCH>",
  "polyspaceRoot": "<POLYSPACE_ROOT>",
  "polyspaceVersion": "<VERSION>",
  "configuredPlatforms": ["<PLATFORM>"],
  "lastSetup": "<ISO_8601_TIMESTAMP>"
}
```

## Phase 4: Verify

Confirm the setup works:

1. Check that the MCP server binary exists and is executable at the install path.
2. If Polyspace is installed, run a quick connectivity test:
   - Use the `configure_checkers_for_polyspace` tool to enable MISRA C:2012 checkers on a temporary file.
   - If the tool succeeds and returns a checker configuration, the MCP server is connected and Polyspace is found.
3. If Polyspace is not installed, skip the connectivity test and note that the user must install Polyspace before using the tools.

## Phase 5: Report

Present a final summary:

```
Polyspace Agentic Toolkit — Setup Complete

Binary:     <install_path>
Agent:      <agent_name> — MCP server registered
Skills:     Installed from skills-catalog/
Polyspace:  <found at path / not found — install required>

Next steps:
- If Polyspace is not installed: Install Polyspace as You Code from
  https://www.mathworks.com/products/polyspace.html
- Try: "Analyze source.c for MISRA C:2012 compliance"
```

## Re-run behavior

When setup is run again: read existing config from `~/.polyspace-agentic-toolkit/config.json` as defaults, run full discovery, present plan showing current vs. proposed state (e.g., "Binary installed at v1.0.0 — update to v1.1.0?"), then execute and verify.

- Re-download the binary if the installed version is older than the latest GitHub release
- Re-write agent configuration only if it is stale (binary path, args, or `--polyspace-root` differ from expected values) — skip if already up to date
- Only add or update the `polyspace` MCP entry — never overwrite entries for other MCP servers
- Always update the state file

## Conventions and guardrails

- **All paths must be absolute** when written to config files (no `~` expansion — resolve to full path).
- **Never skip verification** — always confirm the MCP server responds.
- **Error handling**: If any step fails, report the error clearly and suggest manual steps. Do not proceed to the next phase if a critical step fails.
- **Cross-platform**: All commands must work on the user's detected platform. When in doubt, show both Unix and Windows variants.

---

Copyright 2026 The MathWorks, Inc.

---
