---
name: query-justification-catalog
description: Queries a Polyspace justification catalog for pre-approved texts. Use when the user asks to "query justification catalog", "find pre-approved justification", "look up catalog", or needs to find pre-approved justification texts for Polyspace findings.
license: MathWorks BSD-3-Clause
metadata:
  version: "1.0"
---
# How to Query a Justification Catalog

A justification catalog is a JSON file containing pre-approved justification texts for Polyspace findings.

## Using the MCP tool

**If the Polyspace MCP Server is available**, use the `query_justification_catalog` tool:
- `findings` (required): one or more findings as `FAMILY:ACRONYM`, comma-separated (e.g., `"Defect:INT_ZERO_DIV,MISRA-C3:8.4"`)
- `catalog_file_path` (required): absolute path to the catalog JSON file

## Otherwise reading the catalog directly

**If the Polyspace MCP Server is NOT available**, read `catalog-schema.md` in this folder for the JSON schema and matching rules to read the file directly.
