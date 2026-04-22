# Polyspace Agentic Toolkit — Agent Instructions

## Setup

If the user asks to set up the Polyspace Agentic Toolkit, use the setup skill at
`skills-catalog/polyspace-agentic-toolkit-setup/SKILL.md`. This automates
MCP server binary installation, agent registration, and skill configuration.

## Skills

Polyspace skill files are in `skills-catalog/`. Each skill has a `SKILL.md` with
instructions the assistant reads on-demand.

You MUST use the Read tool to read the relevant skill file BEFORE performing any
Polyspace task. Do NOT answer from memory — always verify against the skill files.

## MCP Tools

Five MCP tools are available when the Polyspace MCP Server is connected:
- `run_polyspace_as_you_code` — run analysis on a C/C++ source file
- `configure_build_options_for_polyspace` — create a build options file
- `configure_checkers_for_polyspace` — create or modify the checkers XML
- `get_polyspace_documentation` — list available Polyspace options via -help
- `query_justification_catalog` — query a justification catalog for pre-approved texts
