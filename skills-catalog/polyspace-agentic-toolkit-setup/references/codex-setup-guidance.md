# OpenAI Codex — Setup Guidance

Status: Validated on macOS. Linux/Windows commands included.

## Global Config Path

- Linux/macOS: `~/.codex/config.toml`
- Windows: `%USERPROFILE%\.codex\config.toml` (unverified — confirm on your system if this does not work)

If `CODEX_HOME` is set, the config path is `$CODEX_HOME/config.toml` instead.

## Phase 3b: Configure Codex

### Register MCP server

**Preferred method** — use the CLI:

```bash
codex mcp add polyspace -- <ABSOLUTE_PATH_TO_BINARY> --polyspace-root=<POLYSPACE_ROOT>
```

Omit `--polyspace-root` if no Polyspace installation was found.

**Manual method** — edit `~/.codex/config.toml` directly:

```toml
[mcp_servers.polyspace]
command = "<ABSOLUTE_PATH_TO_BINARY>"
args = ["--polyspace-root=<POLYSPACE_ROOT>"]
tool_timeout_sec = 600
```

**CRITICAL:** The TOML key must be `mcp_servers` (underscore). `mcp-servers` is silently ignored.

**Windows only** — add the `WINDIR` environment variable:

```toml
[mcp_servers.polyspace]
command = "<ABSOLUTE_PATH_TO_BINARY>"
args = ["--polyspace-root=<POLYSPACE_ROOT>"]
tool_timeout_sec = 600
env_vars = ["WINDIR"]
```

### Extra fields after CLI registration

`codex mcp add` does not write `tool_timeout_sec` or `env_vars`. After running the CLI command, edit `~/.codex/config.toml` to add:
- **All platforms:** `tool_timeout_sec = 600` (default is too short for Polyspace analysis)
- **Windows only:** `env_vars = ["WINDIR"]`

### Register global skills (only the confirmed groups)

Run the shared install script with the skill groups confirmed in Phase 2 as arguments, so only those groups are linked (no arguments links all):
- Linux/macOS: `scripts/install-global-skills.sh <group> [<group> ...]`
- Windows: `scripts/install-global-skills.ps1 <group> [<group> ...]`

Example: `scripts/install-global-skills.sh polyspace-core polyspace-static-core polyspace-code-prover`

## Quirks

- Codex uses TOML, not JSON.
- `mcp_servers` must use an underscore — this is critical.
- Global skills come from `~/.agents/skills/`, not from `.codex-plugin/`.
- User config can be overridden by project config (`.codex/config.toml`).

## Verification

```bash
codex mcp list
codex mcp get polyspace --json
```

Then restart Codex and test: "What Polyspace tools are available?"

## Fallback

If `codex mcp add` is unavailable or fails:

> 1. Edit `~/.codex/config.toml` directly and add the `[mcp_servers.polyspace]` section shown above.
> 2. Create `~/.agents/skills/` symlinks manually (see shared install script for the list).
> 3. Restart Codex.

---

Copyright 2026 The MathWorks, Inc.

---
