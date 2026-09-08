---
name: polyspace-find-option-documentation
description: "REQUIRED before searching for any Polyspace option documentation page. Use when the user asks about a Polyspace option (-c, -target, -sources, -boolean-types, -misra3, etc.), wants to find an option's doc page, or asks 'what does this option do'. This skill contains the only reliable method to locate option reference pages — URLs cannot be guessed from the flag name."
license: MathWorks BSD-3-Clause
metadata:
  version: "2.3"
---
# How to Find Polyspace Option Documentation

Find the documentation page for a Polyspace analysis option (e.g., `-target`, `-compiler`, `-misra3`).

**IMPORTANT**: The documentation page URL cannot be guessed from the flag name — it uses the GUI title, not the flag. Do not attempt to construct or guess URLs.

## Preferred Method: `find_option_doc` Parameter

**If the `get_polyspace_documentation` tool is available**, use it with the `find_option_doc` parameter:

```
find_option_doc = "-target"
```

This returns the exact documentation URL, option name, and description directly from the installed Polyspace catalog. Accepts the flag with or without the leading dash (`"-target"` or `"target"`).

It also works for `polyspace-access` flags like `-upload`: `find_option_doc = "-upload"`.

This is the fastest, most reliable path — it requires no manual lookup or web search.

## Without MCP: Direct Catalog Lookup

**Otherwise**, read `references/catalog-lookup.md` in this skill's directory for how to look up option documentation URLs directly from the installed JSON catalog files.

## Legacy Fallback: Manual `-help` Lookup

Use this fallback only when both the MCP server and the catalog files are unavailable.

### Step 1: Get the option description and accepted values

Run the binary directly:

```
polyspace-as-you-code -help
```

Or for polyspace-configure options:

```
polyspace-configure -help
```

#### How to find the binaries

Invoke `resolve-polyspace-root` to obtain `<polyspace_root>`. Binaries are at
`<polyspace_root>/polyspace/bin/`.

Find the option in the output — it shows the accepted values and the category it belongs to.

### Step 2: Find the full documentation page

From the `-help` output, note the **category heading** the option appears under (e.g., "Checkers Behavior", "Target & Compiler"). Then use the mapping below to go directly to the right documentation page. The `-help` headings do NOT match the website page names — always use this table:

| `-help` heading | Documentation page |
|---|---|
| Bug Finder Analysis | https://www.mathworks.com/help/bugfinder/configure-coding-rule-checks-and-code-metrics.html |
| Checkers Behavior | https://www.mathworks.com/help/bugfinder/configure-coding-rule-checks-and-code-metrics.html |
| Check Behavior | https://www.mathworks.com/help/bugfinder/modify-analysis-assumption.html |
| Target & Compiler | https://www.mathworks.com/help/bugfinder/mimic-build.html |
| Input & Stubbing | https://www.mathworks.com/help/bugfinder/specify-code-behavior.html |
| Multitasking | https://www.mathworks.com/help/bugfinder/configure-multitasking-checks.html |
| Post Verification | https://www.mathworks.com/help/bugfinder/polyspace-analyis-with-windows-or-linux-scripts.html |
| General Options | https://www.mathworks.com/help/bugfinder/configur-review-import.html |

If the option is not found on the mapped page, try the full reference list at
https://www.mathworks.com/help/bugfinder/referencelist.html?type=analysisopt (may require JavaScript).

Fetch the matching page — it lists individual options with direct links to their reference pages.

If you have a web search tool (not a URL fetch tool), you can alternatively search for:
```
site:mathworks.com/help/bugfinder polyspace "<option_name>" option
```
Use quotes around the option name and add "polyspace" and "option" as context words — this is essential for short or common option names like `-c` or `-library`.

**ACTION REQUIRED**: Do not answer from memory alone. Use the approaches above to get the accurate documentation.

---

Copyright 2026 The MathWorks, Inc.

---
