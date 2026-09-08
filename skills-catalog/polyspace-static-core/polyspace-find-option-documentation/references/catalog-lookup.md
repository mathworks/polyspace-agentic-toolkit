# Looking Up Option Documentation from Catalog JSON Files

When the Polyspace MCP Server is not available, you can look up documentation URLs
directly from the JSON catalog files that ship with every Polyspace installation (R2025a+).

## File locations

```
<polyspace_root>/help/docCatalog/cshapi_helptarget/<product>.json
<polyspace_root>/help/docCatalog/referenceapi/<product>.json
```

Where `<polyspace_root>` is the Polyspace installation root. Invoke
`resolve-polyspace-root` to obtain it.

Product files: `bugfinder.json`, `codeprover.json`, `polyspace_test.json`, `polyspace_access.json`.

## CSH helptarget file structure

```json
{
  "helplocation": "bugfinder",
  "helptargets": {
    "target": [{"path": "ref/targetprocessortarget.html", "page_format": "doc_center"}],
    "sources": [{"path": "ref/sourcefilessources.html", "page_format": "doc_center"}]
  }
}
```

Keys are option flag names without the leading dash (e.g. `-target` → key `"target"`).

## ReferenceAPI file structure

```json
{
  "refItems": [
    {
      "href": "ref/targetprocessortarget.html",
      "refentity": [{"type": "analysisopt", "name": "Target processor type (-target)"}],
      "refpurpose": "Specify the target processor type for the analysis",
      "introduced": "R2016a"
    }
  ]
}
```

The flag is embedded in parentheses in the `name` field: extract with `\((-[^)]+)\)`.
Some entries have multiple flags: `"Source files (-sources, -sources-list-file)"`.

For Polyspace Access subcommands, `refentity` entries have names like
`"polyspace-access -upload"` with type `"function"`.

## Lookup algorithm for options

1. Strip leading dash from the flag name (e.g. `-target` → `target`)
2. Open `cshapi_helptarget/<product>.json`, look up the key in `helptargets`
3. If found: build URL as `https://www.mathworks.com/help/{helplocation}/{path}`
4. If NOT found in CSH: open `referenceapi/<product>.json`, scan `refItems` where
   `refentity[].type == "analysisopt"`, extract flags from `name` with the regex above
5. If matched: build URL from `href`, include `refpurpose` as description

Product priority: Bug Finder (`bugfinder.json`) → Code Prover (`codeprover.json`) →
Polyspace Test (`polyspace_test.json`). For `polyspace-access` subcommands use
`polyspace_access.json`.

## URL format

```
https://www.mathworks.com/help/{helplocation}/{path}
```

Where `helplocation` comes from the CSH file's top-level field (e.g. `"bugfinder"`)
and `path` from the matched entry (e.g. `"ref/targetprocessortarget.html"`).

----

Copyright 2026 The MathWorks, Inc.

----
