# Polyspace&reg; Agentic Toolkit

Run Polyspace&reg; as You Code&trade; static code analysis on your C/C++ code using AI applications with the official Polyspace Agentic Toolkit from MathWorks&reg;.

## What It Does
The Polyspace Agentic Toolkit gives your agent the knowledge and context to work with Polyspace efficiently. With the Polyspace MCP Server and its companion skills, you can ask your AI assistant to perform Polyspace as You Code and Polyspace Test workflows. For example:

- **"Make this file compliant with `<coding standard>`"** — Run a Polyspace as You Code analysis, fix violations, and re-run analysis until the file is clean.
- **"Check that my changes are compliant"** — Analyze a modified file and address any new findings.
- **"Fix these findings"** — Understand each finding, apply a code fix, and re-run analysis to confirm.
- **"Justify this finding"** — Insert a correctly formatted Polyspace annotation comment, optionally using pre-approved texts from a team justification catalog.
- **"Set up `<coding standard>` checking"** — Create or modify the checkers XML file to enable specific coding standards.
- **"Configure build options for my project"** — Generate a build options file from a build command or `compile_commands.json`.
- **"What does the `-target` option do?"** — Look up documentation for any Polyspace option, checker, or coding rule.
- **"Generate unit tests for this function"** — Write tests using the Polyspace XUnit framework (PSTUnit).

## How It Works

```
                        +-------------------+
                        |    AI Assistant   |
                        |  (Claude, Copilot,|
                        |   Amp, Cursor...) |
                        +--------+----------+
                                 |
                    reads skills |  calls tools
                    (markdown)   |  (MCP protocol)
                                 |
          +----------------------+----------------------+
          |                                             |
          v                                             v
  +----------------+                         +--------------------+
  | skills-catalog/|                         | Polyspace MCP      |
  | SKILL.md files |                         | Server (binary)    |
  +----------------+                         +--------+-----------+
                                                      |
                                                      v
                                             +------------------+
                                             | Polyspace as You |
                                             | Code (binary)    |
                                             +------------------+
```

The AI assistant reads **skills** (instructional markdown files) for domain knowledge and calls **MCP tools** for execution. Skills work with or without the MCP server. Each skill includes both the MCP tool path and a direct binary fallback.

## Supported Platforms

| Agent | Setup |
|-------|-------|
| [Claude Code](https://claude.ai/code) | Automated |
| [GitHub&reg; Copilot](https://github.com/features/copilot) | Automated |
| [OpenAI&reg; Codex](https://openai.com/codex) | Automated |
| [Gemini&trade; CLI](https://github.com/google-gemini/gemini-cli) | Automated |
| [Sourcegraph Amp](https://ampcode.com/) | Automated |
| [Cursor](https://www.cursor.com/) | Automated |

Polyspace as You Code R2026a recommended. Previous versions back to R2024b are supported.

The Polyspace Agentic Toolkit is supported on Linux, macOS, and Windows operating systems.

## Quick Start

**Prerequisites:**
* [Polyspace as You Code](https://www.mathworks.com/products/polyspace.html) R2024b or later
* Supported AI coding agent
* Git&trade;

The Polyspace Agentic Toolkit helps you install and configure the Polyspace MCP Core Server, or can be configured to use your existing installation.

### Full Setup (recommended)

Clone the repository to a permanent location.

```
git clone https://github.com/polyspace/polyspace-agentic-toolkit.git
cd polyspace-agentic-toolkit
```

Launch your agent from the toolkit directory, and ask it to set up the toolkit.

```
Set up the Polyspace Agentic Toolkit
```

The agent: 
* Reads the setup skill
* Detects your platform
* Locates your Polyspace installation
* Downloads and registers the MCP server binary with your agent
* Installs skills from the toolkit

> **Claude Code — no clone required**: If you already have the MCP server binary configured, you can add the skills directly without cloning:
> ```
> claude plugin marketplace add "https://github.com/polyspace/polyspace-agentic-toolkit"
> claude plugin install polyspace-as-you-code@polyspace-agentic-toolkit
> ```

### Already Have the MCP Server Binary?

If you installed the binary manually, you just need skills. Clone this repo and ask your agent: "Set up the Polyspace Agentic Toolkit" to skip the download and configure skills only.

### Verify
Ask your agent:

```
Run Polyspace on a sample file and show me the results.
```

The agent searches the current directory for a C or C++ file to run an analysis on. If no file is found, the agent creates a sample file with some existing defects, runs an analysis on the file, and displays Polyspace results.

## MCP Tools

The Polyspace Agentic Toolkit provides the following tools:

| Tool | Description |
| --- | --- |
| `run_polyspace_as_you_code` | Run Polyspace as You Code on a C/C++ source file to find coding standard violations and defects. |
| `configure_build_options_for_polyspace` | Create a build options file from a build command or compilation database (`compile_commands.json`). |
| `configure_checkers_for_polyspace` | Create or modify the checkers XML file that selects which coding standards to check. |
| `get_polyspace_documentation` | List available command-line options for `polyspace-as-you-code` or `polyspace-configure`. |
| `query_justification_catalog` | Query a justification catalog JSON file for pre-approved justification texts matching one or more findings. |

## Agent Skills

Skills are instructional markdown guides in [`skills-catalog/`](skills-catalog/) that teach the AI assistant how to perform Polyspace workflows. Each skill has a `SKILL.md` with step-by-step instructions and a `manifest.yaml` with metadata.

### Polyspace as You Code

| Skill | Description |
| --- | --- |
| [run-analysis](skills-catalog/polyspace-as-you-code/run-analysis/) | Run an analysis on a C/C++ source file |
| [fix-findings](skills-catalog/polyspace-as-you-code/fix-findings/) | Understand, fix, or justify findings after analysis |
| [justify-findings](skills-catalog/polyspace-as-you-code/justify-findings/) | Annotation syntax, formatting, and writing guidelines |
| [query-justification-catalog](skills-catalog/polyspace-as-you-code/query-justification-catalog/) | Catalog JSON schema and matching rules |
| [configure-build-options](skills-catalog/polyspace-as-you-code/configure-build-options/) | Create a build options file |
| [configure-checkers](skills-catalog/polyspace-as-you-code/configure-checkers/) | Create or modify the checkers XML file |
| [find-checker-documentation](skills-catalog/polyspace-as-you-code/find-checker-documentation/) | Find documentation for defects and coding standards |
| [find-option-documentation](skills-catalog/polyspace-as-you-code/find-option-documentation/) | Find documentation for Polyspace analysis options |
| [documentation-entry-points](skills-catalog/polyspace-as-you-code/documentation-entry-points/) | Top-level Polyspace documentation URLs |

### Polyspace Test

| Skill | Description |
| --- | --- |
| [generate-xunit-tests](skills-catalog/polyspace-test/generate-xunit-tests/) | Step-by-step guide to write XUnit tests (includes C and C++ API reference) |

### Setup

| Skill | Description |
| --- | --- |
| [polyspace-agentic-toolkit-setup](skills-catalog/polyspace-agentic-toolkit-setup/) | Automated setup for supported AI agents |

## Team Configuration Files

Several Polyspace MCP Server tools accept paths to configuration files that are typically shared across a team or organization. These files can live anywhere accessible to the AI assistant. For example, they can be checked into the repository alongside the source code, stored on a shared network drive, or maintained in a central location by your team.

| File | Used by | Description |
| --- | --- | --- |
| Checkers XML | `run_polyspace_as_you_code`, `configure_checkers_for_polyspace` | Defines which defects and coding standards are enabled during a Polyspace analysis. |
| Build options file | `run_polyspace_as_you_code`, `configure_build_options_for_polyspace` | Specifies include paths, defines, and compiler settings. |
| Options file | `run_polyspace_as_you_code` | Additional Polyspace as You Code analysis options. |
| Justification catalog | `query_justification_catalog` | Pre-approved justification texts for known findings. |

To have your AI assistant use these files automatically, create an **agent instructions file** at the root of your project. Most AI applications support a project-level instructions file that the assistant reads at the start of every conversation:

| AI Application | Instructions File |
| --- | --- |
| Claude Code | `CLAUDE.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Sourcegraph Amp | `AGENTS.md` |

Add instructions like the following to your project's instructions file, replacing the paths with the actual locations of your team's configuration files:

```markdown
## Polyspace Configuration

When running Polyspace analysis on C/C++ files, always use these team configuration files:

- Checkers: /path/to/checkers.xml
- Build options: /path/to/build_options_file.txt
- Options: /path/to/options_file.txt

When querying the justification catalog for pre-approved texts, use:
- Catalog: /path/to/justification_catalog.json
```

## Arguments

Customize the behavior of the server by providing arguments in the `args` array when configuring your AI application.

| Argument | Description | Example |
| ------------- | ------------- | ------------- |
| polyspace-root | Root directory of the Polyspace as You Code installation. If not set, the server automatically detects the installation from the installer registry (`polyspace_products.prf`). | `"--polyspace-root=/usr/local/Polyspace/R2026a"` |
| log-folder | Directory where server log files are written. | `"--log-folder=/tmp/polyspace-logs"` |
| log-level | Log verbosity level. Default: `info`. | `"--log-level=debug"` |
| disable-telemetry | To disable anonymized data collection, set this argument to `true`. For details, see [Data Collection](#data-collection). | `"--disable-telemetry=true"` |

Arguments can also be set via environment variables: `POLYSPACE_ROOT`.

## Data Collection

The Polyspace MCP Server may collect fully anonymized information about your usage of the server and send it to MathWorks. This data collection helps MathWorks improve products and is on by default. To opt out of data collection, set the argument `--disable-telemetry` to `true`.

## Trademarks
Polyspace is a registered trademark of The MathWorks, Inc. See [mathworks.com/trademarks](https://www.mathworks.com/trademarks) for a list of additional trademarks. Other product or brand names may be trademarks or registered trademarks of their respective holders.

## Contributing
We welcome feedback through [GitHub Issues](https://github.com/polyspace/polyspace-agentic-toolkit/issues). Pull requests are reviewed for ideas and feedback but are not merged from external contributors. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Licensing and Usage
The Polyspace MCP server is only permitted to be used with Polyspace products in accordance with the MathWorks Software License Agreement, and must not be shared by multiple users. Contact MathWorks if you need to support shared or centralized use.

## Contact Support
MathWorks encourages you to use this repository and provide feedback. To request technical support or submit an enhancement request, [create a GitHub issue](https://github.com/polyspace/polyspace-agentic-toolkit/issues) or email [genai-support@mathworks.com](mailto:genai-support@mathworks.com). For Polyspace as You Code issues and support, see the [Polyspace as You Code documentation](https://www.mathworks.com/help/payc).

#

When using the Polyspace MCP Server, you should thoroughly review and validate all tool calls before you run them. Always keep a human in the loop for important actions and only proceed once you are confident the call will do exactly what you expect. For more information, see [User Interaction Model (MCP)](https://modelcontextprotocol.io/specification/2025-06-18/server/tools#user-interaction-model) and [Security Considerations (MCP)](https://modelcontextprotocol.io/specification/2025-06-18/server/tools#security-considerations).

The Polyspace MCP Server may only be used with Polyspace installations that are used as a Personal Automation Server. Use with a central Automation Server is not allowed. Please contact MathWorks if Automation Server use is required. For more information see the [Program Offering Guide (MathWorks)](https://www.mathworks.com/help//pdf_doc/offering/offering.pdf).

---

Copyright 2026 The MathWorks, Inc.

---
