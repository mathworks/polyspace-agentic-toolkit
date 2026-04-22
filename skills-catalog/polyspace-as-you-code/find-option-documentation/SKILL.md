---
name: find-option-documentation
description: Finds documentation for Polyspace analysis options. Use when the user asks "what does this option do", "find option documentation", "explain Polyspace option", or wants to understand a specific Polyspace command-line option.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.0"
---
# How to Find Polyspace Option Documentation

Find the documentation page for a Polyspace analysis option (e.g., `-target`, `-compiler`, `-misra3`).

**IMPORTANT**: The documentation page URL cannot be guessed from the flag name — it uses the GUI title, not the flag. Do not attempt to construct or guess URLs.

## Step 1: Get the option description and accepted values

Run the binary to list all available options:

```
polyspace-as-you-code -help
```

Or for polyspace-configure options:

```
polyspace-configure -help
```

Find the option in the output — it shows the accepted values and the category it belongs to.

## Step 2: Find the full documentation page

Fetch one of these index pages and look for the link to the option:

1. https://www.mathworks.com/help/bugfinder/analysis-options.html — lists option categories (Target and Compiler, Inputs and Stubbing, etc.). Fetch the relevant category page to find the direct link to the option reference page.
2. https://www.mathworks.com/help/bugfinder/command-line-only-options.html — directly lists command-line-only options with links to their reference pages.

If you have a web search tool (not a URL fetch tool), you can alternatively search for:
```
site:mathworks.com/help/bugfinder <option_name>
```

**ACTION REQUIRED**: Do not answer from memory alone. Use the approaches above to get the accurate documentation.
