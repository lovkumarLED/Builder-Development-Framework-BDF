# ARCHITECTURE Template

> Template: high-level architecture. Becomes `ARCHITECTURE.md`.

---

# Architecture

> High-level architecture of {{PROJECT_NAME}}.

---

# Purpose

{{PROJECT_NAME}} separates configuration into small, independent components that can be maintained individually and automatically merged into a final `{{GENERATED_ARTIFACT}}` file.

The primary goal is to eliminate manual editing of a large configuration file while keeping the system modular, maintainable, and extensible.

---

# Design Principles

The architecture follows the following principles:

- Single Responsibility
- Separation of Concerns
- Modular Configuration
- Configuration over Hardcoding
- Automation over Manual Editing
- Documentation First

Every component has exactly one responsibility.

---

# Architectural Philosophy

The architecture follows a strict separation between configuration, implementation, and generated output.

The project is intentionally divided into independent layers.

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

This separation reduces coupling and makes future changes easier to implement without affecting unrelated parts of the system.

---

# High-Level Architecture

The following diagram illustrates the overall system structure.

```text
                        Source Configuration

        +--------------------------------------------+
        |                                            |
        |   {{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/        |
        |                                            |
        |   ├── settings file                        |
        |   ├── <provider>-models.json               |
        |   ├── models file                          |
        |   ├── plugins file                         |
        |   ├── service configuration file           |
        |   └── optional target file                 |
        |                                            |
        +--------------------------------------------+

                         +

        +--------------------------------------------+
        |                                            |
        | {{PROVIDER_DIR}}/                                 |
        |                                            |
        | └── provider definition                    |
        |                                            |
        +--------------------------------------------+

                         │
                         ▼

                {{BUILDER_SCRIPT}}

                         │
                         ▼

                 Configuration Validation

                         │
                         ▼

                 Backup Existing Config

                         │
                         ▼

                 Merge Configuration

                         │
                         ▼

                  Generate {{GENERATED_ARTIFACT}}

                         │
                         ▼

                      {{APP_NAME}}
```

---

# Component Overview

The project consists of five major components.

## 1. Configuration Sources

Configuration sources define the configuration that should be included in the generated artifact.

A source profile contains:

- settings
- models
- plugins
- service configuration
- per-provider model files (`<provider>-models.json`)
- an optional target file naming the generated artifact

Source profiles do not contain provider definitions.

---

## 2. Providers

Providers define how the application communicates with an external service.

A provider contains:

- provider metadata
- API configuration
- connection information

Provider definitions are independent from source profiles.

---

## 3. Builder

The builder is responsible for generating the final configuration.

Responsibilities:

- Load source configuration.
- Load provider definitions.
- Validate configuration.
- Create backups.
- Generate `{{GENERATED_ARTIFACT}}`.

The builder never modifies the source configuration files.

---

## 4. Generated Configuration

`{{GENERATED_ARTIFACT}}`

This file is generated automatically.

It is considered a build artifact.

It should never be edited manually.

Any configuration changes should always be made to the source files.

---

## 5. Application

The application only reads the generated configuration.

The application has no knowledge of:

- source profiles
- builders
- provider definitions
- documentation

It only consumes the generated `{{GENERATED_ARTIFACT}}`.

---

# Dependency Direction

Dependencies always point downward.

```
Configuration Sources

↓

Providers

↓

Builder

↓

Generated Configuration

↓

Application
```

Higher layers never depend on lower layers.

This keeps the architecture predictable and minimizes coupling.

---

# Build Pipeline

The following diagram shows what happens during a build.

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

---

## Builder Pipeline Evolution

The builder has evolved through versioned pipelines while keeping the same architecture.

The historical pipeline is the diagram above.

### Builder V2.5 (Active-Provider Selector)

Builder V2.5 introduces active-provider selection to the build.

The user chooses which providers are active at build time.

Selection runs before profile loading:

```
Discover Providers

↓

Select & Persist Active Providers

↓

Load Profile
```

The resolved active provider list is persisted in the profile settings file, which becomes a builder-writable source file.

Settings are backed up before overwrite and written only when the list differs.

Per-provider model files override provider and global models.

### Builder V2.7 (JSON Schema Validation)

Builder V2.7 extends the pipeline with a schema-validation stage and renumbers the build into a canonical nine-stage pipeline.

| Stage | Name | Notes |
|-------|------|-------|
| 0 | Discover Providers | unchanged |
| 1 | Load Profile | unchanged |
| 2 | Load Provider | provider reference check; merging happens in Stage 6 |
| 3 | Schema Validation | JSON Schema source check + pre-flight dependency check |
| 4 | Validation | structural validation |
| 5 | Backup | honors backup retention |
| 6 | Merge | providers + models + plugins + service configuration |
| 7 | Generation | writes {{GENERATED_ARTIFACT}} + provenance sidecar |
| 8 | Verification | round-trip check + diff summary + retention prune |

JSON Schema validation is non-breaking: missing schemas produce a warning and a skip.

Dependency references are checked before merge so that missing inputs abort early with a single report.

### Provenance and Backup Retention

The build records provenance in a sidecar file ({{PROVENANCE_SIDECAR}}).

The sidecar captures builder version, profile, active providers, generation timestamp, and output hash.

The sidecar never writes into the generated artifact.

Backups are pruned to the newest N files per prefix so the backup directory cannot grow without bound.

---

# Release Pipeline

Release documentation is generated, not hand-written.

The release pipeline mirrors the build pipeline: one source of facts, one generator, generated artifacts.

```
{{RELEASE_REGISTRY}}

↓

{{RELEASE_MANAGER_SCRIPT}}

↓

{{RELEASE_ARTIFACTS}}
```

Generated release artifacts are never edited manually.

---

# Separation of Responsibilities

| Component | Responsibility |
|------------|----------------|
| Profile | Defines user configuration |
| Provider | Defines API connection |
| Builder | Merges configuration |
| Backup | Preserves previous configuration |
| Application | Uses generated configuration |

Each component is independent.

No component performs the responsibility of another component.

---

# Source of Truth

The project distinguishes between editable source files and generated output.

## Editable Source Files

The following files represent the authoritative project configuration.

- Provider definitions
- Source configuration
- Documentation
- Builder scripts

These files should be modified directly by the developer.

---

## Generated Output

The following file is generated automatically.

```
{{GENERATED_ARTIFACT}}
```

Generated files are disposable.

They must never be edited manually.

Whenever configuration changes are required, the source files should be updated and the builder executed again.

---

# Configuration Lifecycle

The following diagram shows the developer workflow.

```
Edit Source Files

↓

Run Builder

↓

Validate Configuration

↓

Create Backup

↓

Generate Configuration

↓

Application Uses Configuration
```

---

# Design Constraints

The current architecture intentionally limits functionality to reduce complexity during the initial implementation.

Current constraints include:

- One active profile at build time
- One provider definition (dynamic loading supported)
- One generated configuration
- One active builder

These constraints simplify development and provide a stable foundation for future expansion.

Future architectural improvements will be introduced only after the current implementation is fully documented and tested.

---

# Current Architecture Status

## Implemented

- Modular configuration
- Provider integration
- Source configuration
- Builder
- Backup system
- Generated configuration
- Documentation

## Not Implemented

The following are intentionally outside the current architecture.

- Advanced validation

These features are considered future enhancements and are not part of the current implementation.

---

# Long-Term Vision

The architecture is designed to remain stable even as additional features are introduced.

Future improvements should extend the existing architecture rather than replacing it.

Whenever possible, new functionality should be introduced by adding new modules instead of modifying existing ones.

This approach minimizes breaking changes and keeps the project maintainable over time.

- Keep configuration modular.
- Avoid duplicated configuration.
- Make configuration easy to maintain.
- Keep generated files separate from source files.
- Allow future expansion without redesigning the project.
- Ensure every component has a clearly defined responsibility.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Current Architecture
