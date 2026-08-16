# Schemas

## Purpose

This directory contains JSON Schema files used to validate configuration files used by the OpenCode Builder.

The goal of schemas is to ensure that configuration files follow the expected structure before the builder generates `opencode.json`.

Schemas improve:

- Configuration validation
- Error reporting
- Reliability
- Developer experience

---

## Current Status

Status: **Active** — implemented in Builder V2.7 (JSON Schema Validation, Phase 10.6).

Schema validation runs as **Stage 3** of the V2.7 pipeline, gated by the pre-flight dependency
check (F2). Every loaded config source is validated against its schema BEFORE the builder's
own validation logic:

```
config sources
   -> Pre-flight dependency check (F2)   [Stage 3 entry gate]
   -> JSON Schema validation (F1)        [Stage 3]
   -> Builder Validation                 [Stage 4]
   -> Backup (F4 retention) -> Merge -> Generate (F5 provenance) -> Verify (F7 diff) -> Write
```

Behavior rules:

- `schemas/` missing (or empty) -> warning `No schema directory found ... skipping schema validation.` and the build continues (backward compatible with V2.5-era configs).
- Any source that fails its schema aborts the build with a `Schema '<name>': <file> failed: ...` message.
- Schema files are hand-edited sources, like `profiles/` and `providers/` — they are NOT generated.

---

## Schema Files

| File | Validates | Required |
|------|-----------|----------|
| `schema.json` | generated `opencode.json` (root shape, documentation only) | - |
| `settings.schema.json` | `profiles/<profile>/settings.json` | yes |
| `provider.schema.json` | `providers/<id>.json` | per active provider |
| `models.schema.json` | `models.json` AND `<provider>-models.json` (profile-level per-provider model files) | if file exists |
| `plugins.schema.json` | `profiles/<profile>/plugins.json` | if file exists |
| `mcp.schema.json` | `profiles/<profile>/mcp.json` | if file exists |
| `targets.schema.json` | `profiles/<profile>/target.json` (target artifact, P2) | if file exists |

The V2.5 profile-level per-provider model files (`profiles/<profile>/<provider>-models.json`)
are covered by `models.schema.json`, as planned.

---

## Supported Schema Subset

The builder implements a compact JSON Schema validator in PowerShell 5.1
(no `Test-Json -Schema` availability). Supported keywords:

- `$schema` (informational, ignored)
- `type` (string / number / object / array / boolean / null)
- `required`
- `properties`
- `additionalProperties: false`
- `items`
- `enum`
- `$ref` (local same-file references only, e.g. `#/definitions/name`)

See `docs/JSON_SCHEMAS.md` for the full documentation of each schema file.

---

## Planned Usage (superseded)

The "Planned" state below was implemented by Builder V2.7. It is kept for history:

Configuration Files -> JSON Schema Validation -> Builder Validation -> Configuration Merge -> Generate opencode.json

---

## Why JSON Schemas?

Instead of manually checking every required field in PowerShell, schemas allow configuration files to be validated automatically.

Example benefits:

- Missing required fields
- Invalid property names
- Incorrect value types
- Better error messages
- Easier maintenance

---

## Notes

This folder was intentionally included before schema implementation so the project structure stays stable. Builder V2.7 activates it.

## Adapter-Owned Schemas

- `claude-code-routing.schema.json` - routing profile schema for the Claude
  Code unique adapter (see `adapters/claude-code/`).
