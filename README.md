# Polyspace Agentic Toolkit

Analyze or test C/C++ code using AI applications with the official Polyspace&reg; Agentic Toolkit from MathWorks&reg;.

## What It Does
The Polyspace Agentic Toolkit gives your agent the knowledge and context to work with Polyspace efficiently. With the Polyspace MCP Server and its companion skills, you can ask your AI assistant to perform Polyspace workflows. For example:

- **"Make this file compliant with `<coding standard>`"** — Run an analysis, fix violations, and re-run until the file is clean.
- **"Run Bug Finder on my component and prioritize what to fix"** — Analyze multiple files, review findings, and rank by severity.
- **"Prove this module is free of run-time errors"** — Run Code Prover to formally verify the absence of overflows, null dereferences, and other run-time errors.
- **"Triage the orange checks and tell me which are real bugs."** — Inspect unproven Code Prover checks and separate real issues from analysis imprecision.
- **"Fix these findings"** — Understand each finding, apply a code fix, and re-run analysis to confirm.
- **"Justify this finding"** — Insert a correctly formatted Polyspace annotation comment, optionally using pre-approved texts from a team justification catalog.
- **"Set up `<coding standard>` checking"** — Create or modify the checkers XML file to enable specific coding standards.
- **"Configure build options for my project"** — Generate a build options file from a build command or `compile_commands.json`.
- **"What does the `-target` option do?"** — Look up documentation for any Polyspace option, checker, or coding rule.
- **"Generate unit tests for this function"** — Write tests using the Polyspace XUnit framework (PSTUnit).
- **"Find functions in this folder not covered by tests"** — Run xUnit tests and find code coverage of source functions.

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
                                             | Polyspace        |
                                             |      (binary)    |
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

Polyspace R2026a recommended. Previous versions back to R2025a are supported.

The Polyspace Agentic Toolkit is supported on Linux, macOS (Apple silicon only), and Windows operating systems.

## Quick Start

**Prerequisites:**
* An installation of at least one of these [Polyspace](https://www.mathworks.com/products/polyspace.html) products version R2025a or later: Polyspace as You Code, Polyspace Bug Finder, Polyspace Code Prover, or Polyspace Test 
* Supported AI coding agent
* Git&trade;

The Polyspace Agentic Toolkit helps you install and configure the Polyspace MCP Server, or can be configured to use your existing installation.

### Full Setup (recommended)

Clone the repository to a permanent location.

```
git clone https://github.com/mathworks/polyspace-agentic-toolkit.git
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
* Detects which Polyspace products you have installed (as You Code, Bug Finder, Code Prover, Test)
* Downloads and registers the MCP server binary with your agent
* Installs **only the skills for the products you have** — you confirm the set before anything is installed

> **Why selective?** The toolkit ships skills for every Polyspace product, but agents trigger the right skill more reliably when fewer are loaded. Setup therefore installs only the skill groups matching your installed products (plus the always-on `polyspace-core`, and the shared `polyspace-static-core` whenever any static-analysis product is present). To add or remove products later, just re-run setup ("Set up the Polyspace Agentic Toolkit") and adjust the confirmed set.

> **Claude Code — no clone required**: If you already have the MCP server binary configured, you can add the skills directly without cloning. Always install `polyspace-core`. For static analysis (Polyspace as You Code, Bug Finder, or Code Prover), also install the shared `polyspace-static-core` plugin plus the product plugin(s) you have. Add only the plugins matching your installed Polyspace products:
> ```
> claude plugin marketplace add "https://github.com/mathworks/polyspace-agentic-toolkit"
> claude plugin install polyspace-core@polyspace-agentic-toolkit          # always
> claude plugin install polyspace-static-core@polyspace-agentic-toolkit   # shared review/fix/justify — with any static-analysis product
> claude plugin install polyspace-as-you-code@polyspace-agentic-toolkit   # Polyspace as You Code (file-level analysis)
> claude plugin install polyspace-bug-finder@polyspace-agentic-toolkit    # Polyspace Bug Finder (multi-file / component)
> claude plugin install polyspace-code-prover@polyspace-agentic-toolkit   # Polyspace Code Prover (prove absence of run-time errors)
> claude plugin install polyspace-test@polyspace-agentic-toolkit          # Polyspace Test
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

| Tools | Description |
| --- | --- |
| `run_polyspace_as_you_code`, `run_polyspace_bug_finder`, `run_polyspace_code_prover` | Run Polyspace as You Code, Bug Finder, or Code Prover on C/C++ code to find defects, coding-standard violations, and run-time errors. |
| `configure_build_options_from_ccdb`, `configure_build_options_from_build_command`, `configure_checkers_for_polyspace` | Generate build options from a compilation database (`compile_commands.json`) or a build command, and select which checkers run. |
| `get_polyspace_documentation` | Look up Polyspace command-line options and documentation. |
| `get_polyspace_results_list`, `get_polyspace_results_summary`, `get_polyspace_result_details`, `list_source_file_snapshots`, `search_source_file_snapshots`, `get_source_file_snapshot`, `get_symbol_navigation`, `get_macro_expansion`, `get_analysis_options`, `get_call_graph`, `get_variable_accesses`, `get_dead_code_blocks` | Explore and inspect analysis results: list and summarize findings, drill into a finding, browse analyzed source, navigate symbols, macros, call graphs, and variable accesses, and list dead code blocks. |
| `get_code_prover_assumptions`, `get_concurrency_model`, `get_orange_sources`, `get_static_ranges` | Code Prover&ndash;specific inspection: proof assumptions, concurrency model, orange (unproven) sources, and computed value ranges. |
| `add_review_information_to_result`, `transfer_polyspace_comments`, `query_justification_catalog`, `generate_report` | Triage and reporting: set review status and justifications, carry comments across runs, query the justification catalog, and generate reports. |

> Code Prover&ndash;specific tools are registered only when a Code Prover analysis is active.

## Agent Skills

Skills are instructional markdown guides in [`skills-catalog/`](skills-catalog/) that teach the AI assistant how to perform Polyspace workflows. Each skill has a `SKILL.md` with step-by-step instructions and a `manifest.yaml` with metadata.

Skills are organized into groups. Automated setup installs only the groups you need — the mapping below is what it applies, and what to install by hand if you prefer:

| Group | Install when | Provides |
| --- | --- | --- |
| **`polyspace-core`** | **Always** | Resolve installation root, configure build options, documentation entry points |
| **`polyspace-static-core`** | Any static-analysis product is present (Polyspace as You Code, Bug Finder, **or** Code Prover) | Shared review, fix, and justify findings; configure checkers; checker and option documentation |
| **`polyspace-as-you-code`** | You have Polyspace as You Code | File-level analysis of the file you are editing |
| **`polyspace-bug-finder`** | You have Polyspace Bug Finder | Multi-file / whole-component analysis |
| **`polyspace-code-prover`** | You have Polyspace Code Prover | Prove the absence of run-time errors |
| **`polyspace-test`** | You have Polyspace Test | Author and run PSTUnit tests |

Two invariants: **`polyspace-core` is always installed**, and **`polyspace-static-core` is installed as soon as any static-analysis product (as You Code, Bug Finder, or Code Prover) is present** — it holds the review/fix/justify workflow those products share. `polyspace-test` drives dynamic testing and does **not** require `polyspace-static-core`. Install only the groups for the products you actually have: agents trigger the right skill more reliably when fewer are loaded. When you install plugins by hand, install `polyspace-static-core` yourself alongside any static-analysis product plugin — it is not pulled in automatically.

### Polyspace Core

Always installed.

| Skill | Description |
| --- | --- |
| [resolve-polyspace-root](skills-catalog/polyspace-core/resolve-polyspace-root/) | Resolve the Polyspace installation root for CLI fallbacks |
| [polyspace-configure-build-options](skills-catalog/polyspace-core/polyspace-configure-build-options/) | Create a build options file from a build command or compilation database |
| [polyspace-documentation-entry-points](skills-catalog/polyspace-core/polyspace-documentation-entry-points/) | Top-level Polyspace documentation URLs |

### Polyspace Static Core

Shared static-analysis skills. Install alongside any static-analysis product (Polyspace as You Code, Bug Finder, or Code Prover).

| Skill | Description |
| --- | --- |
| [polyspace-review-findings](skills-catalog/polyspace-static-core/polyspace-review-findings/) | Read, explain, and prioritize defects and coding-standard violations |
| [polyspace-fix-findings](skills-catalog/polyspace-static-core/polyspace-fix-findings/) | Understand, fix, or justify findings after analysis |
| [polyspace-justify-in-code](skills-catalog/polyspace-static-core/polyspace-justify-in-code/) | Justify a finding with an in-source annotation comment |
| [polyspace-justify-in-database](skills-catalog/polyspace-static-core/polyspace-justify-in-database/) | Record a review status/rationale in the results database and carry it across re-runs |
| [polyspace-query-justification-catalog](skills-catalog/polyspace-static-core/polyspace-query-justification-catalog/) | Catalog JSON schema and matching rules |
| [polyspace-configure-checkers](skills-catalog/polyspace-static-core/polyspace-configure-checkers/) | Create or modify the checkers XML file |
| [polyspace-find-checker-documentation](skills-catalog/polyspace-static-core/polyspace-find-checker-documentation/) | Find documentation for defects and coding standards |
| [polyspace-find-option-documentation](skills-catalog/polyspace-static-core/polyspace-find-option-documentation/) | Find documentation for Polyspace analysis options |

### Polyspace as You Code

Install if you have Polyspace as You Code. File-level analysis of the file you are editing.

| Skill | Description |
| --- | --- |
| [run-polyspace-as-you-code-analysis](skills-catalog/polyspace-as-you-code/run-polyspace-as-you-code-analysis/) | Run a file-level analysis on a single C/C++ source file |

### Polyspace Bug Finder

Install if you have Polyspace Bug Finder. Multi-file / whole-component analysis.

| Skill | Description |
| --- | --- |
| [run-polyspace-bug-finder-analysis](skills-catalog/polyspace-bug-finder/run-polyspace-bug-finder-analysis/) | Run Bug Finder across several files or a whole component |

### Polyspace Code Prover

Install if you have Polyspace Code Prover. Prove the absence of run-time errors.

| Skill | Description |
| --- | --- |
| [run-polyspace-code-prover-analysis](skills-catalog/polyspace-code-prover/run-polyspace-code-prover-analysis/) | Run Code Prover on C/C++ code |
| [review-polyspace-code-prover-results](skills-catalog/polyspace-code-prover/review-polyspace-code-prover-results/) | Read, explain, and prioritize red/orange/green/gray checks |
| [triage-orange-checks](skills-catalog/polyspace-code-prover/triage-orange-checks/) | Triage orange (unproven) checks and decide what to do about them |

### Polyspace Test

Install if you have Polyspace Test.

| Skill | Description |
| --- | --- |
| [generate-polyspace-test-xunit-tests](skills-catalog/polyspace-test/generate-polyspace-test-xunit-tests/) | Author PSTUnit tests — test plan and test source (C and C++ API reference) |
| [run-polyspace-test-xunit-tests](skills-catalog/polyspace-test/run-polyspace-test-xunit-tests/) | Build and run XUnit tests (CMake/Makefile integration, generate main, common errors) |

### Setup

The setup skill is read in place from the cloned repository during installation — it is not installed as a plugin.

| Skill | Description |
| --- | --- |
| [polyspace-agentic-toolkit-setup](skills-catalog/polyspace-agentic-toolkit-setup/) | Automated setup for supported AI agents |

## Polyspace Configuration Files

Several Polyspace MCP Server tools accept paths to configuration files that are typically shared across a team or organization. These files can live anywhere accessible to the AI assistant. For example, they can be checked into the repository alongside the source code, stored on a shared network drive, or maintained in a central location by your team.

| File | Used by | Description |
| --- | --- | --- |
| Checkers XML | `run_polyspace_as_you_code`, `run_polyspace_bug_finder`, `run_polyspace_code_prover`, `configure_checkers_for_polyspace` | Defines which defects and coding standards are enabled during a Polyspace analysis. |
| Build options file | `run_polyspace_as_you_code`, `run_polyspace_bug_finder`, `run_polyspace_code_prover`, `configure_build_options_from_build_command`, `configure_build_options_from_ccdb` | Specifies include paths, defines, and compiler settings. |
| Options file | `run_polyspace_as_you_code`, `run_polyspace_bug_finder`, `run_polyspace_code_prover` | Additional Polyspace analysis options. |
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
| polyspace-root | Root directory of the Polyspace installation. If not set, the server uses the first Polyspace installation found on `PATH` (from the Polyspace binaries in `<polyspace_root>/polyspace/bin`). | `"--polyspace-root=/usr/local/Polyspace/R2026a"` |
| log-folder | Directory where server log files are written. | `"--log-folder=/tmp/polyspace-logs"` |
| log-level | Log verbosity level. Default: `info`. | `"--log-level=debug"` |
| disable-telemetry | To disable anonymized data collection, set this argument to `true`. For details, see [Data Collection](#data-collection). | `"--disable-telemetry=true"` |

You can also set the Polyspace root by using the `MW_MCP_SERVER_POLYSPACE_ROOT` environment variable. `--polyspace-root` takes precedence over the environment variable, which takes precedence over `PATH`.

## Data Collection

The Polyspace MCP Server may collect fully anonymized information about your usage of the server and send it to MathWorks. This data collection helps MathWorks improve products and is on by default. To opt out of data collection, set the argument `--disable-telemetry` to `true`.

## Contributing

We welcome feedback through [GitHub Issues](https://github.com/mathworks/polyspace-agentic-toolkit/issues). Pull requests are reviewed for ideas and feedback but are not merged from external contributors. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Security Considerations

When using the Polyspace Agentic Toolkit and Polyspace MCP Server, you should thoroughly review and validate all tool calls before you run them. Always keep a human in the loop for important actions and only proceed once you are confident the call will do exactly what you expect. For more information, see [User Interaction Model (MCP)](https://modelcontextprotocol.io/specification/2025-06-18/server/tools#user-interaction-model) and [Security Considerations (MCP)](https://modelcontextprotocol.io/specification/2025-06-18/server/tools#security-considerations).

## Licensing and Usage

The license is available in the [LICENSE.md](LICENSE.md) file in this GitHub repository.

MCP servers are only permitted to be used with MATLAB and Polyspace in accordance with the MathWorks Software License Agreement, and must not be shared by multiple users. Contact MathWorks if you need to support shared or centralized server use.

## Contact Support

MathWorks encourages you to use this repository and provide feedback. To request technical support or submit an enhancement request, [create a GitHub issue](https://github.com/mathworks/polyspace-agentic-toolkit/issues) or [contact technical support](https://www.mathworks.com/support/contact_us.html). For product issues and support, see the [Polyspace documentation](https://www.mathworks.com/help/overview/code-verification.html) for your product.

---

Copyright 2026 The MathWorks, Inc.

---
