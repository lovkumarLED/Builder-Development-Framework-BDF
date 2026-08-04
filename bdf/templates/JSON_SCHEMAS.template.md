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

# Models File

`models.json`

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| models | Object | Yes | Collection of model definitions. |

---

## Validation Rules

- Model identifiers must be unique.
- Every model must contain valid configuration.
- The builder copies this object directly into every active provider.

---

# Plugins File

`plugins.json`

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| plugin | Object | Yes | Collection of plugin definitions. |

---

## Validation Rules

- Plugin identifiers must be unique.
- Invalid plugin configuration causes the build to fail.

---

# Service Configuration File

`service.json`

## Schema

| Key | Type | Required | Description |
|------|------|----------|-------------|
| service | Object | Yes | Collection of service definitions. |

---

## Validation Rules

- Service identifiers must be unique.
- Invalid service configuration causes the build to fail.

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
| plugins.json | Yes |
| service.json | Yes |
| {{CURRENT_PROVIDER}}.json | Yes |

---

The following file is generated automatically.

| File | Editable |
|------|----------|
| {{GENERATED_ARTIFACT}} | No |

Generated files should never be modified manually.

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

# Current Status

## Implemented

- settings.json
- models.json
- plugins.json
- service.json
- {{CURRENT_PROVIDER}}.json

## Planned

Additional configuration schemas will only be documented after implementation.

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

service.json

↓

Generated Configuration
```

Each file contributes one independent section to the final configuration.

No configuration file is responsible for another file's contents.

**Document Version:** {{DOC_VERSION}}

**Status:** Current JSON Schemas
