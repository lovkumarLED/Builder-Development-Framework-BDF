# JSON_SCHEMAS Template

> Template: configuration file schemas. Becomes `JSON_SCHEMAS.md`.

---

# JSON Schemas

> Specification of every configuration file used by {{PROJECT_NAME}}.

---

# Purpose

{{PROJECT_NAME}} stores configuration in multiple independent configuration files.

Each configuration file has a single responsibility.

This document describes:

- Purpose
- Location
- Ownership
- Expected structure
- Builder usage

Only the current implementation is documented.

Future configuration files will be added after they are implemented.

---

# Global Rules

Every configuration file follows these rules.

## Encoding

- UTF-8

---

## Format

- JSON Object

---

## Comments

Comments are not permitted.

---

## Trailing Commas

Trailing commas are not permitted.

---

## Ownership

Configuration files are maintained by the developer.

Generated files are maintained by the builder.

---

## Validation

Every configuration file must pass validation before configuration generation begins.

If validation fails, the build process must terminate immediately.

---

# Profile Settings File

`settings.json`

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| activeProviders | Array<String> | Yes | List of provider identifiers to load. |

---

## Example

```json
{
    "activeProviders": [
        "{{CURRENT_PROVIDER}}"
    ]
}
```

---

## Validation Rules

- The array must contain at least one provider.
- Provider names must be unique.
- Every provider listed must exist inside the `{{PROVIDER_DIR}}/` directory.

---

## Builder-Written

`settings.json` is a source file that the builder also writes.

After the user (or a CLI switch) resolves the active provider list, the builder persists it back to `activeProviders`.

- The current file is backed up before any rewrite.
- `$schema` is preserved when present.
- Written as UTF-8 without BOM.
- Written only when the resolved list differs from the stored list; a no-op run leaves the file untouched.

---

# Model Definitions File

`models.json`

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| models | Object | Yes | Collection of model definitions. |

---

## Validation Rules

- Model identifiers must be unique.
- Model names must be unique within a models source.
- Every model must contain valid configuration.
- Model resolution per active provider follows this precedence (first source that exists wins):

```
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/<provider>-models.json   (highest)
{{PROVIDER_DIR}}/<provider>/models.json
inline provider models
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/models.json (global)
(none)
```

---

# Per-Provider Models File

`<provider>-models.json`

Profile-level provider models.

## Location

```
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/<provider>-models.json
```

One file per active provider, named after the provider id (for example `{{CURRENT_PROVIDER}}-models.json`).

Optional: the file is loaded only when it exists.

## Schema

Same shape as `models.json`.

| Key | Type | Required | Description |
|------|------|----------|-------------|
| models | Object | Yes | Collection of model definitions. |

Each model entry has the same shape as a `models.json` entry (for example `name`).

## Model entry shape

| Key | Type | Required | Description |
|------|------|----------|-------------|
| name | String | Yes | Display name. |
| variants | Object | No | Named reasoning overlays (see below). |
| reasoning | Boolean | No | Whether the model reasons. |
| temperature | Number | No | Sampling temperature. |
| limit | Number | No | Token limit. |

`variants` is a map of level → settings object. The settings keys follow the
provider's reasoning format (the optional `reasoningFormat` field on the
provider file):

| Reasoning format | Levels | Settings keys |
|------------------|--------|---------------|
| `opencode` (default) | `default`, `minimal`, `high`, `max` | `reasoningEffort` |
| `openai` | `none`, `low`, `medium`, `high`, `xhigh` | `reasoningEffort` |
| `claude` | `low`, `high`, `max` | `thinking.type`, `thinking.budgetTokens` |
| `gemini` | `minimal`, `low`, `medium`, `high` | `thinkingConfig.thinkingBudget` |
| `none` | — | no variants written |

The schema keeps `variants` permissive (`{"type": "object"}`) so new settings
keys never fail older builders; unknown keys pass through unchanged.

## Validation Rules

- Model identifiers must be unique (duplicate keys are rejected).
- Model names must be unique within the file.
- The `models` section is required.
- The file carries the highest precedence: it overrides `{{PROVIDER_DIR}}/<provider>/models.json`, inline provider models, and the global `models.json`.

---

# Plugins File

`plugins.json`

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| plugin | Array of strings | Yes | Collection of plugin identifiers. |

---

## Validation Rules

- Plugin identifiers must be unique.
- Invalid plugin configuration causes the build to fail.

---

# MCP Configuration File

`mcp.json`

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| mcp | Object | Yes | Collection of MCP server definitions. |

---

## Validation Rules

- MCP identifiers must be unique.
- Invalid MCP configuration causes the build to fail.

---

# Target Configuration File

`target.json` (P2, optional)

Profile-level target artifact; selects the file the builder generates for this profile.

## Location

```
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/target.json
```

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| artifact | String | Yes | Generated artifact file name (e.g. `{{GENERATED_ARTIFACT}}`). |

---

## Validation Rules

- Validated against `{{SCHEMA_DIR}}/targets.schema.json` when present (`artifact`: string, `additionalProperties: false`).
- Missing, unreadable, or schema-invalid `target.json` falls back to `{{GENERATED_ARTIFACT}}` (backward compatible).
- The builder derives the backup prefix (`<base>_*`), provenance sidecar (`<base>.provenance.json`), WhatIf names, and retention prefix from the artifact base name.

---

# Provider File

`{{CURRENT_PROVIDER}}.json`

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| id | String | Yes | Unique provider identifier. |
| provider | Object | Yes | Provider definition. |

---

### provider.{{CURRENT_PROVIDER}}

| Key | Type | Required |
|------|------|----------|
| connection | String | Yes |
| name | String | Yes |
| credentials | String | Yes |
| options | Object | Yes |
| models | Object | Yes |

---

## Validation Rules

- `id` must match the provider filename.
- The provider object must contain exactly one root provider.
- The `models` object is populated by the builder during generation.

---

# Source Files vs Generated Files

The following files are considered source files.

| File | Editable |
|------|----------|
| settings.json | Yes |
| models.json | Yes |
| <provider>-models.json | Yes |
| plugins.json | Yes |
| mcp.json | Yes |
| target.json | Yes (optional) |
| {{CURRENT_PROVIDER}}.json | Yes |

`settings.json` is also written by the builder (see the Builder-Written section above): it persists the resolved `activeProviders` list back to the file, with a backup created first.

---

The following files are generated automatically.

| File | Editable |
|------|----------|
| {{GENERATED_ARTIFACT}} | No |
| {{PROVENANCE_SIDECAR}} | No |

Generated files should never be modified manually.

---

# Builder-Written Files

The builder writes exactly three artifacts:

- `settings.json` write-back: the resolved `activeProviders` list, backed up first, `$schema` preserved, UTF-8 no BOM, written only when the list differs.
- `{{GENERATED_ARTIFACT}}`: the merged output configuration, produced from all source files.
- `{{PROVENANCE_SIDECAR}}`: provenance recorded next to the output (builder version, profile, active providers, timestamp, output SHA-256).

All other configuration files are user-owned source files.

---

# Validation Rules

Every configuration file must satisfy the following rules.

- Valid syntax.
- Correct encoding.
- Correct root object.
- Required fields must exist.
- No duplicate provider identifiers.
- No duplicate model identifiers.

Validation is performed by the builder before configuration generation.

---

# JSON Schema Files

The live schema files live in `{{SCHEMA_DIR}}/`.

| File | Validates | Required | additionalProperties |
|------|-----------|----------|----------------------|
| `schema.json` | Root shape of the generated `{{GENERATED_ARTIFACT}}` (documentation only; not validated by the builder pipeline) | — | — |
| `settings.schema.json` | `{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/settings.json` | `activeProviders` (array of strings) | false |
| `provider.schema.json` | `{{PROVIDER_DIR}}/{{CURRENT_PROVIDER}}.json` | `id` (string), `provider` (object) | false |
| `models.schema.json` | Covers BOTH `models.json` AND `<provider>-models.json` (profile-level per-provider model files) | `models` (object); model entries require `name` (string) | false |
| `plugins.schema.json` | `{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/plugins.json` | `plugin` (array of strings) | false |
| `mcp.schema.json` | `{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/mcp.json` | `mcp` (object); server entries permissive by design | false at root |
| `targets.schema.json` | `{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/target.json` | `artifact` (string) | false |

Each configuration source file has a matching `*.schema.json` file.

---

# Validation Subset

The builder implements schema validation inside the script: {{SHELL}} has no native schema test, so a compact validator is used.

The supported keyword subset:

- `type` (string / number / object / array / boolean / null).
- `required`.
- `properties`.
- `additionalProperties: false`.
- `items`.
- `enum`.
- `$ref` (local same-file references only).

---

# Current Status

## Implemented

- settings.json
- models.json
- <provider>-models.json
- plugins.json
- mcp.json
- target.json
- {{CURRENT_PROVIDER}}.json

## Planned

Additional configuration schemas will only be documented after implementation.

Future configuration formats belong exclusively in `ROADMAP.md`.

Implemented in Builder {{CURRENT_VERSION}}.

## JSON Schema Files (Builder V2.7)

The live schema files live in `{{SCHEMA_DIR}}/`.

Each configuration source file has a matching `*.schema.json` file.

## Validation Subset (PS 5.1)

The builder implements schema validation inside the script.

{{SHELL}} has no native schema test, so a compact validator is used.

---

# Configuration Relationships

The builder loads configuration in the following order.

```
settings.json

↓

provider

↓

models.json

↓

plugins.json

↓

mcp.json

↓

Generated Configuration
```

Each file contributes one independent section to the final configuration.

No configuration file is responsible for another file's contents.

## Adapter-Owned Schemas (generic)

Unique bounded adapters may own schema files under the engine schemas
directory; adapter schema responsibilities live in the adapter's own
documentation.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Current JSON Schemas