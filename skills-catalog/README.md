# Skills Catalog

The skills catalog organizes agent skills into groups. Each group is a directory containing one or more skills (each with a `SKILL.md` and `manifest.yaml`).

## Skill Groups

| Group | Description | Skills |
|-------|-------------|--------|
| [polyspace-as-you-code](polyspace-as-you-code/) | Static analysis workflows for C/C++ | 9 |
| [polyspace-test](polyspace-test/) | Unit test generation with PSTUnit | 1 (+2 reference files) |
| [polyspace-agentic-toolkit-setup](polyspace-agentic-toolkit-setup/) | Automated setup for any supported AI agent | 1 |

## How Skills Are Installed

Skills are not auto-discovered from this catalog. Each agent platform has a manifest file (in the repo root) that explicitly scopes which skill groups are included. See the [README](../README.md) for per-agent installation instructions.
