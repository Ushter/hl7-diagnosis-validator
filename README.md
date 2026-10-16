# HL7 Diagnosis Validator

Lua workflow that checks HL7 DG1 diagnosis codes against two SQLite reference tables and reports codes absent from both.

## Workflow

1. Parse an incoming HL7 message with a configured VMD.
2. Look up each DG1 code in `diagnosis_primary`.
3. Fall back to `diagnosis_secondary` when no match exists.
4. Queue the unknown diagnosis codes with their segment indices and descriptions.

## Setup

Requires Iguana's `hl7`, `db`, `json`, and `queue` APIs. Add `src/main.lua` and `src/diagnosis_lookup.lua` to a Translator project. Set `DIAGNOSIS_DB_PATH` to your SQLite database and `HL7_VMD_PATH` to a compatible VMD whose parsed message exposes DG1. `.env.example` documents variables; it is not loaded automatically.

Each reference table must expose `code` and `description`. Supply appropriately licensed reference data locally. No clinical code sets, databases, VMDs, or patient messages are distributed.

## Run local unit tests

From this repository directory, use Lua 5.4:

```sh
lua tests/lookup_test.lua
```

These tests use synthetic fixtures and mocked Iguana APIs. They do not replace testing inside Iguana.
