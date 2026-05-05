# Reading a justification catalog directly

Read the JSON file and match entries against the finding's family and acronym.

## Catalog JSON schema

```json
{
  "justifications": [
    {
      "family": "Defect",
      "acronym": "INT_ZERO_DIV",
      "comment": "Division is guarded by a non-zero check on the denominator"
    },
    {
      "family": "*",
      "acronym": "*",
      "comment": ["Generic justification 1", "Generic justification 2"]
    }
  ]
}
```

## Fields

- `family`: the finding family to match (e.g., `"Defect"`, `"MISRA-C3"`)
- `acronym`: the finding acronym to match (e.g., `"INT_ZERO_DIV"`, `"8.4"`)
- `comment`: a string or an array of strings with pre-approved justification texts

## Matching rules

- Match by `family` and `acronym` (case-insensitive)
- `"*"` in either field matches any value (wildcard)
- Both `family` and `acronym` must match for an entry to be selected
- Multiple entries can match a single finding — collect all matching comments

---

Copyright 2026 The MathWorks, Inc.

---
