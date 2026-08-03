# PROJECT STATE Template

> Template: living state snapshot. Becomes `PROJECT_STATE.md`.

---

# PROJECT STATE

> Living snapshot of {{PROJECT_NAME}}.

> Regenerated after every major refactor.

---

# 1. Executive Summary

{{PROJECT_NAME}} is a modular configuration generation system.

Its purpose is to generate a valid `{{GENERATED_ARTIFACT}}` from a set of smaller configuration files.

The project separates:

- Source configuration
- Builder implementation
- Generated configuration
- Documentation

The documentation is organized into two layers.

Layer 1: the Blueprint Framework, reusable engineering knowledge shared by every builder project.

Layer 2: the {{APP_NAME}}-specific project documentation.

This document is the living state snapshot of the repository.

It is regenerated after every major refactor.

---

# 2. Current Version

Version

```
{{CURRENT_VERSION}}
```

Status

```
{{PROJECT_STATUS}}
```

## Version History

| Version | Status | Description |
|----------|--------|-------------|
| {{CURRENT_VERSION}} | Current | {{VERSION_DESCRIPTION}} |

---

# 3. Current Folder Structure

```
{{PROJECT_ROOT}}
```

The project is organized into independent directories.

```
{{FOLDER_TREE}}
```

## Purpose of Each Folder

{{FOLDER_PURPOSE_TABLE}}

---

# 4. Architecture Overview

The architecture separates configuration, implementation, and generated output.

```
Configuration

↓

Builder

↓

Generated Configuration

↓

Application
```

Each layer communicates only with the layer immediately below it.

Dependencies always point downward.

## Components

| Component | Responsibility |
|------------|----------------|
| Source Configuration | Defines user configuration |
| Provider | Defines API connection |
| Builder | Merges configuration |
| Backup | Preserves previous configuration |
| {{APP_NAME}} | Uses generated configuration |

## Build Pipeline

```
Source Files

↓

Profile

↓

Provider

↓

Builder

↓

Validation

↓

Backup

↓

Generation

↓

{{GENERATED_ARTIFACT}}

↓

{{APP_NAME}}
```

## Source of Truth

Editable source files:

- Provider definitions
- Source configuration
- Documentation
- Builder scripts

Generated output:

- `{{GENERATED_ARTIFACT}}`

Generated files are never edited manually.

---

# 5. Blueprint Framework

Generic engineering knowledge shared by every builder project.

Lives in:

```
blueprint/
```

## Contents

| Document | Purpose |
|----------|---------|
| `FRAMEWORK.md` | The complete engineering process |
| `VERSION.md` | Blueprint versioning |
| `MIGRATION.md` | Adopting the framework in an existing project |
| `PROJECT_GENERATOR.md` | Creating a new builder project |
| `LESSONS_LEARNED.md` | Reusable engineering lessons |
| `templates/` | Reusable documentation templates |

The blueprint contains no project-specific knowledge.

Project names appear only as examples.

---

# 6. Builder Implementation

The project-specific implementation.

## {{CONFIG_SOURCE_DIR}}/

Contains profile-specific configuration.

The builder selects the profile at invocation time.

## {{PROVIDER_DIR}}/

Contains provider definitions.

## {{SCRIPTS_DIR}}/

Contains automation scripts.

The builder script is `{{BUILDER_SCRIPT}}`.

## {{BACKUP_DIR}}/

Stores timestamped backups of the generated configuration.

Created automatically by the builder before each build.

## {{GENERATED_ARTIFACT}}

The generated configuration.

{{APP_NAME}} reads this file during startup.

Never edited manually.

---

# 7. AI Workflow

AI agents are guided by `AGENT.md`.

Every agent reads `AGENT.md` first.

## Read Order

```
README.md

↓

PROJECT_STATE.md

↓

ARCHITECTURE.md

↓

BUILDER_SPEC.md

↓

DESIGN_PRINCIPLES.md

↓

FOLDER_STRUCTURE.md

↓

JSON_SCHEMAS.md

↓

CONTRIBUTING_FOR_AI.md
```

## Session Continuity

Sessions span multiple context windows.

At session start:

- Read `_agent/SESSION_WORKFLOW.md`.
- Read `_agent/SESSION_LOG.md`.
- Check the `Next:` line of the most recent entry.

At session end:

- Follow `_agent/SESSION_WORKFLOW.md`.
- Write the session summary to `_agent/SESSION_LOG.md`.

## Project State

After every major refactor:

- Regenerate `PROJECT_STATE.md`.
- Keep the 15-section structure.
- Never leave it stale.

---

# 8. Documentation Structure

| Document | Description |
|----------|-------------|
| `AGENT.md` | AI agent entry guide |
| `ARCHITECTURE.md` | Overall system architecture |
| `DESIGN_PRINCIPLES.md` | Core engineering principles |
| `FOLDER_STRUCTURE.md` | Directory and file responsibilities |
| `JSON_SCHEMAS.md` | Configuration file schemas |
| `BUILDER_SPEC.md` | Builder implementation specification |
| `CONTRIBUTING_FOR_AI.md` | AI contribution rules |
| `TESTING.md` | Testing procedures |
| `TROUBLESHOOTING.md` | Common issues and fixes |
| `ROADMAP.md` | Planned future improvements |
| `CHANGELOG.md` | Project version history |
| `PROJECT_STATE.md` | Living state snapshot |
| `_agent/` | Session continuity files |
| `blueprint/` | Reusable Blueprint Framework |

---

# 9. Template System

Reusable documentation templates live in:

```
blueprint/templates/
```

Templates are generic.

They contain no project-specific knowledge.

Project-specific values appear only as placeholders.

```
{{PLACEHOLDER_NAME}}
```

Every template becomes one project document when a new builder project is created.

---

# 10. Versioning System

The project follows a simple versioning strategy.

Major Version

```
Large architectural changes.
```

Minor Version

```
New functionality.
```

Patch Version

```
Bug fixes and documentation improvements.
```

## Project Versioning

Recorded in `CHANGELOG.md`.

Future plans belong exclusively in `ROADMAP.md`.

## Blueprint Versioning

The Blueprint Framework is versioned independently.

Recorded in `blueprint/VERSION.md`.

---

# 11. Current Status

## Implemented

- {{IMPLEMENTED_FEATURES}}

## Not Implemented

- {{PLANNED_FEATURES}}

Planned features are documented only in `ROADMAP.md`.

---

# 12. Known Limitations

- {{KNOWN_LIMITATIONS}}

These limitations simplify development and provide a stable foundation for future expansion.

---

# 13. Next Planned Work

## Immediate

- {{IMMEDIATE_NEXT_STEPS}}

## Roadmap Phases

- {{ROADMAP_PHASES}}

All phases are planned only. They are documented exclusively in `ROADMAP.md`.

---

# 14. File Relationships

```
{{FILE_RELATIONSHIP_MAP}}
```

---

# 15. Important Engineering Decisions

1. Generated configuration is never edited manually.
2. Source configuration is always the source of truth.
3. Documentation First: documentation is part of the project.
4. Documentation is split into two layers: generic blueprint and project-specific docs.
5. Future features are documented only in `ROADMAP.md`.
6. The Blueprint Framework is versioned independently from the project.
7. Session continuity files externalize context across sessions.
8. `PROJECT_STATE.md` is regenerated after every major refactor to keep the repository state current.
9. A major refactor is any change that adds, removes, moves, or renames files, or changes architecture.
10. Consistency is more important than speed.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Current Project State
