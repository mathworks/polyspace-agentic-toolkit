---
name: polyspace-agentic-toolkit-setup
description: Sets up the Polyspace Agentic Toolkit for any supported AI agent. Use when the user asks to "set up Polyspace", "set up the Polyspace Agentic Toolkit", "install the Polyspace MCP Server", "configure Polyspace for my agent", or wants to get Polyspace working with their AI application.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.3"
---
# Polyspace Agentic Toolkit — Setup Skill

Automated setup for the Polyspace Agentic Toolkit. This skill guides through platform detection, MCP server binary installation, agent configuration, and verification.

## When NOT to Use

- Just reading the already-configured Polyspace installation path — invoke `resolve-polyspace-root`

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
| Windows x86_64 | `$env:OS` = Windows_NT or `OSTYPE` contains msys/cygwin | `polyspace-mcp-server-win64.exe` | `%LOCALAPPDATA%\polyspace\polyspace-mcp-server.exe` |

Intel Mac (`uname -m` = x86_64 on Darwin) is not supported — no Intel Mac binary is published.

### 1b. Determine the Polyspace installation root

The setup must resolve an explicit Polyspace root and pin it via `--polyspace-root` (step 3b). Do NOT rely on the MCP server's runtime auto-discovery — it is unreliable and must not be used as the resolution strategy.

Look for `polyspace-as-you-code` (or `polyspace-bug-finder-access` for older versions) in PATH. If found, note the Polyspace root — the binary is at `<root>/polyspace/bin/<binary>`, so strip two parent directories.

If not in PATH, check the installer registry file `polyspace_products.prf` at the platform-specific default location.

If neither resolves the root, mark it **not found** — Phase 2 will ask the user for the installation path before proceeding.

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
- Linux/macOS: `~/.config/polyspace-agentic-toolkit/config.json`
- Windows: `%APPDATA%\polyspace-agentic-toolkit\config.json`

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

### 1h. Detect installed Polyspace products

Using the Polyspace root resolved in step 1b, list the product launchers in
`<root>/polyspace/bin/` to determine which Polyspace products are installed.
This drives which skill groups to recommend in Phase 2 — the user should not
install skills for products they do not have. On Windows the launchers carry a
`.exe` suffix.

| Product | Launcher in `<root>/polyspace/bin/` (any of) | Skill group |
|---------|----------------------------------------------|-------------|
| Polyspace as You Code | `polyspace-as-you-code`, `polyspace-bug-finder-access` (older releases) | `polyspace-as-you-code` |
| Polyspace Bug Finder | `polyspace-bug-finder`, `polyspace-bug-finder-server` | `polyspace-bug-finder` |
| Polyspace Code Prover | `polyspace-code-prover`, `polyspace-code-prover-server` | `polyspace-code-prover` |
| Polyspace Test | `polyspace-test` | `polyspace-test` |

Build the **recommended skill-group set** from what was detected:

- **`polyspace-core`** — always (every toolkit user needs it).
- **`polyspace-static-core`** — whenever any of Polyspace as You Code, Bug
  Finder, or Code Prover is detected (those products depend on its shared
  review / fix / justify skills).
- The matching product group for each product detected above.

If the Polyspace root was **not found** in step 1b, product detection is not
possible — Phase 2 asks the user which products they have (defaulting to all
four) after asking for the installation path, then derives the set the same way.

## Phase 2: Plan

Present a summary of all findings to the user:

```
Polyspace Agentic Toolkit — Setup Plan

Platform:           <detected platform>
Polyspace root:     <path or "NOT FOUND — will ask">
Polyspace version:  <R20XXx or "not found">

MCP server:
  Installed:        <path and version or "not found">
  Latest:           <vX.Y.Z from GitHub>
  Install to:       <install_path>

AI agent:           <detected agent>
MCP registration:   <up to date / stale — will update / not configured — will configure>

Polyspace products detected (step 1h):
  Polyspace as You Code:  <yes / no>
  Polyspace Bug Finder:   <yes / no>
  Polyspace Code Prover:  <yes / no>
  Polyspace Test:         <yes / no>

Skills to install (only what you need):
  polyspace-core          (always)
  polyspace-static-core   (shared — any static-analysis product)
  <one line per detected product group, e.g. polyspace-code-prover>

Proceed with this skill set? [Y/n]  (you can add or drop groups)
```

If the Polyspace root was **not found** in Phase 1, ask the user for the installation path now and validate it as in step 1b (check `<path>/polyspace/bin/` and `VersionInfo.xml`) before showing "Proceed?". If the user has no Polyspace installed, note that Polyspace must be installed first — the toolkit can still be set up, but the tools will not work until Polyspace is present and setup is re-run to pin its root.

**Confirm the skill set.** Present the detected products and the recommended
skill-group set (from step 1h). Let the user add or drop groups before
continuing — for example, they may want a product's skills even though that
product is not installed yet, or may want to skip one they will not use. If the
root was not found, ask which of the four products they have (defaulting to all)
and derive the set the same way. Record the **confirmed skill-group set** —
Phase 3 installs exactly those groups, nothing more.

Wait for user confirmation before proceeding.

## Phase 3: Execute

Run all steps without interruption.

### 3a. Download and install the MCP server binary

1. Download the binary for the detected platform from the latest GitHub release:
   `https://github.com/mathworks/polyspace-agentic-toolkit/releases/latest`

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

Read the appropriate per-agent setup guidance file from `references/` in this folder:

| Agent | Reference file |
|-------|---------------|
| Claude Code | `references/claude-code-setup-guidance.md` |
| GitHub Copilot | `references/copilot-setup-guidance.md` |
| Cursor | `references/cursor-setup-guidance.md` |
| Sourcegraph Amp | `references/amp-setup-guidance.md` |
| OpenAI Codex | `references/codex-setup-guidance.md` |
| Gemini CLI | `references/gemini-cli-setup-guidance.md` |

Follow the steps in the reference file to register the MCP server and configure skills for the detected agent.

When configuring the MCP server command, always include the `--polyspace-root=<POLYSPACE_ROOT>` argument, using the root resolved in Phase 1b / Phase 2. This pins the Polyspace installation explicitly instead of relying on the server's runtime auto-discovery. (Only omit it in the edge case where the user confirmed Polyspace is not yet installed — in which case the tools will not work until setup is re-run with a resolved root.)

**Skip this step if the existing agent configuration is already up to date** (as determined in step 1g). Only add or update the `polyspace` MCP entry — never overwrite entries for other MCP servers.

### 3c. Register skills (only the confirmed groups)

Install **only** the skill groups confirmed in Phase 2 — never the whole
catalog. The per-agent reference file (step 3b) states how skills are installed
for the detected agent; honor the confirmed set there:

- **Plugin-based agents** (e.g. Claude Code): install only the plugins for the
  confirmed groups.
- **Symlink-based agents** (read `~/.agents/skills/`): run the shared install
  script with the confirmed group names as arguments, so only those groups are
  linked (from the repo root):
  - Linux/macOS: `scripts/install-global-skills.sh <group> [<group> ...]`
  - Windows: `scripts/install-global-skills.ps1 <group> [<group> ...]`

  With no arguments the script links every group (backward-compatible), but
  setup should always pass the confirmed set. Example:
  `scripts/install-global-skills.sh polyspace-core polyspace-static-core polyspace-code-prover`

### 3d. Save state

Write configuration to the platform-specific state directory:

| Platform | State directory |
|----------|----------------|
| Linux/macOS | `~/.config/polyspace-agentic-toolkit/` |
| Windows | `%APPDATA%\polyspace-agentic-toolkit\` |

Create the directory if needed:
- Linux/macOS: `mkdir -p "$HOME/.config/polyspace-agentic-toolkit"`
- Windows: `mkdir -p "$env:APPDATA\polyspace-agentic-toolkit"` (PowerShell)

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

This state `config.json` is the single source of truth for the resolved Polyspace root. The operative root at MCP runtime is the `--polyspace-root` argument in the agent's MCP registration (step 3b); in CLI-fallback mode (MCP server unavailable), `resolve-polyspace-root` reads `polyspaceRoot` from this same state file. Keep the two in sync. If Polyspace was not found (the user confirmed it is not installed yet), leave `polyspaceRoot` empty and re-run setup once Polyspace is installed. All paths recorded here must be absolute.

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
Skills:     <confirmed groups, e.g. polyspace-core, polyspace-static-core, polyspace-code-prover>
Polyspace:  <found at path / not found — install required>

Next steps:
- If Polyspace is not installed: Install Polyspace as You Code from
  https://www.mathworks.com/products/polyspace.html
- Try: "Analyze source.c for MISRA C:2012 compliance"
```

## Re-run behavior

When setup is run again: read existing config from the state file (`~/.config/polyspace-agentic-toolkit/config.json`; `%APPDATA%\polyspace-agentic-toolkit\config.json` on Windows) as defaults, run full discovery, present plan showing current vs. proposed state (e.g., "Binary installed at v1.0.0 — update to v1.1.0?"), then execute and verify.

- Re-download the binary if the installed version is older than the latest GitHub release
- Re-write agent configuration only if it is stale (binary path, args, or `--polyspace-root` differ from expected values) — skip if already up to date
- Only add or update the `polyspace` MCP entry — never overwrite entries for other MCP servers
- Always update the state file (step 3d) with the current root

## Conventions and guardrails

- **All paths must be absolute** when written to config files (no `~` expansion — resolve to full path).
- **Never skip verification** — always confirm the MCP server responds.
- **Error handling**: If any step fails, report the error clearly and suggest manual steps. Do not proceed to the next phase if a critical step fails.
- **Cross-platform**: All commands must work on the user's detected platform. When in doubt, show both Unix and Windows variants.

---

Copyright 2026 The MathWorks, Inc.

---
