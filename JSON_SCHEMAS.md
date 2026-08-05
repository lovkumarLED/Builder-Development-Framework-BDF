# JSON Schemas

> Specification of every JSON configuration file used by the OpenCode Configuration Manager.

---

# Purpose

The OpenCode Configuration Manager stores configuration in multiple independent JSON files.

Each JSON file has a single responsibility.

This document describes:

- Purpose
- Location
- Ownership
- Expected structure
- Builder usage

Only the current implementation is documented.

Future JSON files will be added after they are implemented.

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

# settings.json

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| activeProviders | Array<String> | Yes | List of provider identifiers to load. |

---

## Example

```json
{
    "activeProviders": [
        "omniroute"
    ]
}
```

---

## Validation Rules

- The array must contain at least one provider.
- Provider names must be unique.
- Every provider listed must exist inside the `providers/` directory.

---

## Builder-Written

`settings.json` is a source file that the builder also writes.

After the user (or `-Provider` / `-NonInteractive`) resolves the active provider list, the builder persists it back to `activeProviders`.

- The current file is backed up to `backup/settings_<profile>_<timestamp>.json` before any rewrite.
- `$schema` is preserved when present.
- Written as UTF-8 without BOM.
- Written only when the resolved list differs from the stored list; a no-op run leaves the file untouched.

---

# models.json

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
profiles/<profile>/<provider>-models.json   (highest)
providers/<provider>/models.json
inline provider models
models.json (global)
(none)
```

---

# <provider>-models.json

Profile-level provider models.

## Location

```
profiles/<profile>/<provider>-models.json
```

One file per active provider, named after the provider id (for example `omniroute-models.json`).

Optional: the file is loaded only when it exists.

## Schema

Same shape as `models.json`.

| Key | Type | Required | Description |
|------|------|----------|-------------|
| models | Object | Yes | Collection of model definitions. |

Each model entry has the same shape as a `models.json` entry (for example `name`).

## Validation Rules

- Model identifiers must be unique (duplicate keys are rejected).
- Model names must be unique within the file.
- The `models` section is required.
- The file carries the highest precedence: it overrides `providers/<provider>/models.json`, inline provider models, and the global `models.json`.

---

# plugins.json

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| plugin | Object | Yes | Collection of plugin definitions. |

---

## Validation Rules

- Plugin identifiers must be unique.
- Invalid plugin configuration causes the build to fail.

---

# mcp.json

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| mcp | Object | Yes | Collection of MCP server definitions. |

---

## Validation Rules

- MCP identifiers must be unique.
- Invalid MCP configuration causes the build to fail.

---

# omniroute.json

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| id | String | Yes | Unique provider identifier. |
| provider | Object | Yes | Provider definition. |

---

### provider.omniroute

| Key | Type | Required |
|------|------|----------|
| npm | String | Yes |
| name | String | Yes |
| apiKey | String | Yes |
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
| omniroute.json | Yes |

`settings.json` is also written by the builder (see the Builder-Written section above): it persists the resolved `activeProviders` list back to the file, with a backup created first.

---

The following file is generated automatically.

| File | Editable |
|------|----------|
| opencode.json | No |

Generated files should never be modified manually.

---

# Validation Rules

Every JSON file must satisfy the following rules.

- Valid JSON syntax.
- UTF-8 encoding.
- Correct root object.
- Required fields must exist.
- No duplicate provider identifiers.
- No duplicate model identifiers.

Validation is performed by the builder before configuration generation.

---

# Current Status

## Implemented

- settings.json
- models.json
- <provider>-models.json
- plugins.json
- mcp.json
- omniroute.json

## Planned

Additional JSON schemas will only be documented after implementation.

Future configuration formats belong exclusively in `ROADMAP.md`.

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

**Document Version:** 1.1

**Status:** Current JSON Schemas