# Folder Structure

> Directory and file organization of the OpenCode Configuration Manager.

---

# Purpose

The OpenCode Configuration Manager is organized into independent directories, where each directory has a single responsibility.

This separation improves maintainability, readability, and future expansion.

The builder relies on this structure when generating the final configuration.

---

# Root Directory

```
.config/
└── opencode/
```

The `opencode` directory is the root of the entire project.

Everything required by the configuration manager exists inside this directory.

---

# Project Structure

```
opencode/

├── backup/
├── docs/
├── profiles/
├── providers/
├── scripts/
└── opencode.json
```

Each directory has a dedicated responsibility.

---

# backup/

```
backup/
```

## Purpose

Stores automatically created backups of the generated `opencode.json`.

Before generating a new configuration, the builder creates a timestamped backup of the previous configuration.

This allows recovery if a configuration change introduces errors.

## Example

```
backup/

opencode_2026-08-02_18-30-45.json
```

## Managed By

Builder

## Manual Editing

Not required.

---

# docs/

```
docs/
```

## Purpose

Contains all project documentation.

The documentation explains the project architecture, configuration files, testing procedures, troubleshooting steps, and future roadmap.

Documentation is intended for both humans and AI coding agents.

## Contents

```
README.md

ARCHITECTURE.md

FOLDER_STRUCTURE.md

JSON_SCHEMAS.md

BUILDER_SPEC.md

TESTING.md

TROUBLESHOOTING.md

ROADMAP.md

CHANGELOG.md
```

## Managed By

Developer

## Manual Editing

Yes.

---

# profiles/

```
profiles/
```

## Purpose

Contains profile-specific configuration.

Profiles define the configuration that will be merged into the final OpenCode configuration.

The current implementation contains a single profile.

```
profiles/

default/
```

---

## default/

Contains the active OpenCode configuration.

```
default/

settings.json

models.json

plugins.json

mcp.json
```

---

### settings.json

Purpose:

General profile configuration.

Contains profile-level settings used by the builder.

---

### models.json

Purpose:

Defines every AI model available inside the profile.

Responsible only for model configuration.

---

### plugins.json

Purpose:

Defines OpenCode plugins enabled for the profile.

---

### mcp.json

Purpose:

Defines MCP server configuration for the profile.

---

## Managed By

Developer

## Manual Editing

Yes.

---

# providers/

```
providers/
```

## Purpose

Contains provider definitions.

Each provider describes how OpenCode communicates with an AI provider.

The current implementation contains a single provider.

```
providers/

omniroute.json
```

---

## omniroute.json

Purpose:

Defines the OmniRoute provider.

Contains:

- provider metadata
- API configuration
- connection settings

Provider definitions are independent from profiles.

## Managed By

Developer

## Manual Editing

Yes.

---

# scripts/

```
scripts/
```

## Purpose

Contains automation scripts.

The primary script is the OpenCode configuration builder.

```
build-opencode.ps1
```

---

## build-opencode.ps1

Purpose

Generates the final `opencode.json`.

Responsibilities

- Load configuration files.
- Validate configuration.
- Create backup.
- Merge configuration.
- Generate output.

The builder never edits source configuration files.

---

## Managed By

Developer

## Manual Editing

Yes.

---

# opencode.json

```
opencode.json
```

## Purpose

Generated OpenCode configuration.

This file is produced automatically by the builder.

OpenCode reads this file during startup.

---

## Important

This file is considered a generated artifact.

It should never be edited manually.

Any configuration changes must be made to the source files.

---

# Directory Relationships

```
profiles/

↓

providers/

↓

builder

↓

backup

↓

opencode.json

↓

OpenCode
```

---

# Ownership

| Directory | Owner |
|------------|-------|
| backup | Builder |
| docs | Developer |
| profiles | Developer |
| providers | Developer |
| scripts | Developer |
| opencode.json | Builder |

---

# Editing Rules

## Edit Manually

- docs/
- profiles/
- providers/
- scripts/

## Do Not Edit

- backup/
- opencode.json

Generated files should always be recreated by the builder.

---

# Current Status

## Existing

- backup/
- docs/
- profiles/
- providers/
- scripts/
- opencode.json

## Planned

Additional directories will only be documented after they are implemented.

Future project ideas are documented exclusively in `ROADMAP.md`.

---

**Document Version:** 1.0

**Status:** Current Project Structure