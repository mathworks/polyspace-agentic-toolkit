# Skills Catalog

The skills catalog organizes agent skills into groups. Each group is a directory containing one or more skills (each with a `SKILL.md` and `manifest.yaml`).

## Skill Groups

| Group | Description | Skills |
|-------|-------------|--------|
| [polyspace-core](polyspace-core/) | Cross-product foundations for every Polyspace product: resolve the installation root, configure build options, find documentation entry points. Always installed. | 3 |
| [polyspace-static-core](polyspace-static-core/) | Shared static-analysis skills used by Polyspace as You Code, Bug Finder, and Code Prover (not Test): configure checkers, find checker/option documentation, review findings, fix findings, justify in code and in the results database, query the justification catalog. | 8 |
| [polyspace-as-you-code](polyspace-as-you-code/) | Run Polyspace as You Code file-level analysis on C/C++ | 1 |
| [polyspace-bug-finder](polyspace-bug-finder/) | Run Polyspace Bug Finder defect and coding-standard analysis across several files | 1 |
| [polyspace-code-prover](polyspace-code-prover/) | Run and review Polyspace Code Prover verification (red/orange/green/gray checks); triage orange checks | 3 |
| [polyspace-test](polyspace-test/) | Generate, run, and measure coverage of PSTUnit tests | 2 |
| [polyspace-agentic-toolkit-setup](polyspace-agentic-toolkit-setup/) | Automated setup for any supported AI agent | 1 |

## How Skills Are Installed

Skills are not auto-discovered from this catalog. Each agent platform has a manifest file (in the repo root) that explicitly scopes which skill groups are included. See the [README](../README.md) for per-agent installation instructions.

---

Copyright 2026 The MathWorks, Inc.

---
