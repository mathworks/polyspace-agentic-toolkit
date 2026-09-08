# Transferring database review comments from the command line

Review statuses and comments stored in a results database (`.psbf` for Bug Finder,
`.pscp` for Code Prover) can be carried into another results database of the same
product **without the MCP server**, using `polyspace-comments-import`. This is the
command-line equivalent of the `transfer_polyspace_comments` MCP tool.

Use it for this case: a previous results database already holds review
decisions — for example, statuses a user set earlier in the Polyspace user
interface — and a **new analysis run** (possibly launched by the agent) has produced
a fresh database. Import the earlier comments so the new results inherit them.

## How to find the binary

Invoke `resolve-polyspace-root` to obtain `<polyspace_root>`. The binary is at
`<polyspace_root>/polyspace/bin/polyspace-comments-import`.

## Usage

```
polyspace-comments-import -diff-rte <reference_results_folder> <destination_results_folder>
```

Imports comments from the **reference** folder (the previous run that holds the
review decisions) into the **destination** folder (the fresh run that should inherit
them). Order matters: reference first, destination second. Both must be the same
product.

- `-diff-rte` — required; the mode that diffs the two runs and transfers the
  comments.

Run `polyspace-comments-import -help` for the authoritative option list.

---

Copyright 2026 The MathWorks, Inc.

---
