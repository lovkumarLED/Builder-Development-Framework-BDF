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

# models.json

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| models | Object | Yes | Collection of model definitions. |

---

## Validation Rules

- Model identifiers must be unique.
- Every model must contain valid configuration.
- The builder copies this object directly into the selected provider.

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
| plugins.json | Yes |
| mcp.json | Yes |
| omniroute.json | Yes |

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

**Document Version:** 1.0

**Status:** Current JSON Schemas