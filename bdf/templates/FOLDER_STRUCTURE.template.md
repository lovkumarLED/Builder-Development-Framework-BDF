# FOLDER_STRUCTURE Template

> Template: directory and file organization. Becomes `FOLDER_STRUCTURE.md`.

---

# Folder Structure

> Directory and file organization of {{PROJECT_NAME}}.

---

# Purpose

{{PROJECT_NAME}} is organized into independent directories, where each directory has a single responsibility.

This separation improves maintainability, readability, and future expansion.

The builder relies on this structure when generating the final configuration.

---

# Project Structure

```
project/

├── {{BACKUP_DIR}}/
├── {{DOCS_DIR}}/
├── {{CONFIG_SOURCE_DIR}}/
├── {{PROVIDER_DIR}}/
├── {{SCRIPTS_DIR}}/
└── {{GENERATED_ARTIFACT}}
```

Each directory has a dedicated responsibility.

---

# {{BACKUP_DIR}}/

## Purpose

Stores automatically created backups of the generated `{{GENERATED_ARTIFACT}}`.

Before generating a new configuration, the builder creates a timestamped backup of the previous configuration.

This allows recovery if a configuration change introduces errors.

## Example

```
{{BACKUP_DIR}}/

{{GENERATED_ARTIFACT}}_2026-08-02_18-30-45.json
```

## Managed By

Builder

## Manual Editing

Not required.

---

# {{DOCS_DIR}}/

## Purpose

Contains all project documentation.

The documentation explains the project architecture, configuration files, testing procedures, troubleshooting steps, and future roadmap.

Documentation is intended for both humans and AI coding agents.

## Contents

```
README.md

AGENT.md

ARCHITECTURE.md

DESIGN_PRINCIPLES.md

FOLDER_STRUCTURE.md

JSON_SCHEMAS.md

BUILDER_SPEC.md

CONTRIBUTING_FOR_AI.md

TESTING.md

TROUBLESHOOTING.md

ROADMAP.md

CHANGELOG.md

LESSONS_LEARNED.md
```

## Managed By

Developer

## Manual Editing

Yes.

---

# {{CONFIG_SOURCE_DIR}}/

## Purpose

Contains profile-specific configuration.

Profiles define the configuration that will be merged into the final configuration.

The builder selects the profile at invocation time.

```
{{CONFIG_SOURCE_DIR}}/

{{DEFAULT_PROFILE}}/

other-profiles/
```

The default profile is fully configured.

Additional profiles contain only the settings file and contribute their provider selection to the build.

---

## {{DEFAULT_PROFILE}}/

Contains the active configuration.

```
{{DEFAULT_PROFILE}}/

settings.json

models.json

plugins.json

service.json
```

---

### settings.json

Purpose:

General profile configuration.

Contains profile-level settings used by the builder.

---

### models.json

Purpose:

Defines every model available inside the profile.

Responsible only for model configuration.

---

### plugins.json

Purpose:

Defines plugins enabled for the profile.

---

### service.json

Purpose:

Defines service configuration for the profile.

---

## Managed By

Developer

## Manual Editing

Yes.

---

# {{PROVIDER_DIR}}/

## Purpose

Contains provider definitions.

Each provider describes how the application communicates with an external service.

The current implementation contains a single provider.

```
{{PROVIDER_DIR}}/

{{CURRENT_PROVIDER}}.json
```

---

## {{CURRENT_PROVIDER}}.json

Purpose:

Defines the provider.

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

# {{SCRIPTS_DIR}}/

## Purpose

Contains automation scripts.

The primary script is the configuration builder.

```
{{BUILDER_SCRIPT}}
```

---

## {{BUILDER_SCRIPT}}

Purpose

Generates the final `{{GENERATED_ARTIFACT}}`.

Responsibilities

- Load configuration files.
- Validate configuration.
- Create backup.
- Merge configuration.
- Generate output.

Supports

- Dynamic profile selection.
- Dynamic provider loading.
- Optional profile sections.

The builder never edits source configuration files.

---

## Managed By

Developer

## Manual Editing

Yes.

---

# {{GENERATED_ARTIFACT}}

## Purpose

Generated configuration.

This file is produced automatically by the builder.

The application reads this file during startup.

---

## Important

This file is considered a generated artifact.

It should never be edited manually.

Any configuration changes must be made to the source files.

---

# Directory Relationships

```
{{CONFIG_SOURCE_DIR}}/

↓

{{PROVIDER_DIR}}/

↓

builder

↓

{{BACKUP_DIR}}/

↓

{{GENERATED_ARTIFACT}}

↓

{{APP_NAME}}
```

---

# Ownership

| Directory | Owner |
|------------|-------|
| {{BACKUP_DIR}} | Builder |
| {{DOCS_DIR}} | Developer |
| {{CONFIG_SOURCE_DIR}} | Developer |
| {{PROVIDER_DIR}} | Developer |
| {{SCRIPTS_DIR}} | Developer |
| {{GENERATED_ARTIFACT}} | Builder |

---

# Editing Rules

## Edit Manually

- {{DOCS_DIR}}/
- {{CONFIG_SOURCE_DIR}}/
- {{PROVIDER_DIR}}/
- {{SCRIPTS_DIR}}/

## Do Not Edit

- {{BACKUP_DIR}}/
- {{GENERATED_ARTIFACT}}

Generated files should always be recreated by the builder.

---

# Current Status

## Existing

- {{BACKUP_DIR}}/
- {{DOCS_DIR}}/
- {{CONFIG_SOURCE_DIR}}/
- {{PROVIDER_DIR}}/
- {{SCRIPTS_DIR}}/
- {{GENERATED_ARTIFACT}}

## Planned

Additional directories will only be documented after they are implemented.

Future project ideas are documented exclusively in `ROADMAP.md`.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Current Project Structure
