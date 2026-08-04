# README Template

> Template: project entry point. Becomes `README.md`.

---

# {{PROJECT_NAME}}

> A modular configuration management system for {{APP_NAME}}.

---

## Overview

{{PROJECT_NAME}} is a modular configuration system designed to simplify the management of {{APP_NAME}}.

Instead of manually maintaining a large configuration file, the project separates configuration into smaller, independent files and automatically generates the final configuration through a builder script.

This approach makes the configuration easier to maintain, easier to extend, and significantly reduces the risk of configuration errors.

---

## Current Features

- Modular configuration architecture
- Provider integration
- Profile-based configuration
- Dynamic profile selection
- Dynamic provider loading
- Separate model management
- Separate plugin management
- Separate service management
- Automatic configuration generation
- Automatic backup creation
- Structured project documentation

---

## Project Structure

The project is organized into several independent components.

| Component | Purpose |
|-----------|---------|
| `{{CONFIG_SOURCE_DIR}}/` | Profile-specific configuration |
| `{{PROVIDER_DIR}}/` | Provider definitions |
| `{{BACKUP_DIR}}/` | Automatic configuration backups |
| `{{SCRIPTS_DIR}}/` | Builder scripts |
| `{{DOCS_DIR}}/` | Project documentation |

---

## Documentation

The documentation is split into multiple files.

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
| `ADAPTER.md` | Project-specific facts |
| `LESSONS_LEARNED.md` | Reusable engineering lessons |

---

## Current Status

### Implemented

- Configuration management for {{APP_NAME}}
- Provider integration
- Profile-based configuration
- Dynamic profile selection
- Dynamic provider loading
- Automatic configuration builder
- Backup system
- Project documentation

### Not Yet Implemented

The following features are planned but **are not currently part of the project**:

- Additional providers
- Advanced validation
- Extended CLI features

These planned features are documented only in `ROADMAP.md`.

---

## Source of Truth

The project follows a strict source-of-truth policy.

### Source Files

These files are intended to be edited manually.

- Provider definitions
- Profile configuration
- Documentation
- Builder scripts

### Generated Files

Generated files are never edited manually.

Current generated file:

- `{{GENERATED_ARTIFACT}}`

All changes should always be made to the source files and regenerated using the builder.

---

## Project Philosophy

This project follows a few simple principles:

- Keep configuration modular.
- Avoid duplicated configuration.
- Separate implementation from configuration.
- Prefer automation over manual editing.
- Document everything that exists.
- Keep future ideas separate from completed features.

---

## Project Status

The project is currently under active development.

All documentation describes the current implementation only.

Future features are intentionally excluded from the architecture and implementation documents until they are fully designed, implemented, and tested.

Planned work is documented separately in `ROADMAP.md`.

---

**Version:** {{CURRENT_VERSION}}

**Document Version:** {{DOC_VERSION}}

Documentation Status: Current Implementation
