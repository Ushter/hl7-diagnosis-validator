# HL7 Diagnosis Validator

Lua workflow that checks HL7 DG1 diagnosis codes against two SQLite reference tables and reports codes absent from both.

## Workflow

1. Parse an incoming HL7 message with a configured VMD.
2. Look up each DG1 code in `DG_Codes_1500`.
3. Fall back to `DG_Codes_72500` when no match exists.
4. Queue the unknown diagnosis codes with their segment indices and descriptions.

## Setup

Requires Iguana's `hl7`, `db`, `json`, and `queue` APIs. Add `src/main.lua` and `src/diagnosis_lookup.lua` to a Translator project. Set `DIAGNOSIS_DB_PATH` to your SQLite database and `HL7_VMD_PATH` to a compatible VMD whose parsed message exposes DG1. `.env.example` documents variables; it is not loaded automatically.

Each reference table must expose `DG_Codes` and `DG_Description`. Supply appropriately licensed reference data locally. No clinical code sets, databases, VMDs, or patient messages are distributed.

## Refactoring

Based on Meer Ushter's recovered Query channel. Removed the embedded original HL7 message and personal database path, removed unused queries and debug traces, escaped SQL string literals, used one database connection per message, and closed it after lookup failures. The original two-table lookup order is retained. The portfolio version adds structured queue output; the recovered version only assembled an internal string.

Tests use synthetic codes to cover primary lookup, fallback, unknown codes, empty input, and SQL quote escaping. Actual HL7 parsing and Iguana integration have not been tested here. This is a lookup demonstration, not clinical decision support.

## Run local unit tests

From this repository directory, use Lua 5.4:

```sh
lua tests/lookup_test.lua
```

These tests use synthetic fixtures and mocked Iguana APIs. They do not replace testing inside Iguana.
