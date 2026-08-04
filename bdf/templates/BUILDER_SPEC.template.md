# BUILDER_SPEC Template

> Template: builder functional specification. Becomes `BUILDER_SPEC.md`.

---

# Builder Specification

> Functional specification for the {{PROJECT_NAME}} builder.

---

# Purpose

The builder is responsible for generating the final `{{GENERATED_ARTIFACT}}` configuration used by {{APP_NAME}}.

It acts as the automation layer between the modular source configuration and the final generated configuration.

The builder is the only component that generates `{{GENERATED_ARTIFACT}}`.

It never modifies the source configuration files.

---

# Design Goals

The builder was designed to achieve the following goals.

- Eliminate manual editing of `{{GENERATED_ARTIFACT}}`.
- Keep configuration modular.
- Preserve source configuration.
- Produce deterministic output.
- Fail safely on invalid configuration.
- Support future expansion without redesigning the project.

These goals influence every stage of the build process.

---

# Responsibilities

The builder is responsible for automation only.

It transforms source configuration into generated configuration.

The builder does **not** define configuration.

Configuration is defined exclusively by the source configuration files.

This separation keeps implementation independent from configuration.

---

The builder SHALL

- Read configuration.
- Validate configuration.
- Preserve previous output.
- Merge configuration.
- Generate output.
- Report errors.

The builder SHALL NOT

- Modify source files.
- Modify documentation.
- Modify provider definitions.
- Modify source configuration.
- Require manual editing of generated files.

---

# Inputs

The builder reads configuration from the selected profile.

The profile is chosen at invocation time.

```
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/

settings file

models file

plugins file

service configuration file
```

The settings file is required.

The other files are optional.

Only the sections that exist are merged into the generated configuration.

and

```
{{PROVIDER_DIR}}/

provider definition
```

---

# Output

The builder generates exactly one file.

```
{{GENERATED_ARTIFACT}}
```

This file is consumed by {{APP_NAME}}.

---

# Build Pipeline

The complete build process follows this sequence.

```
Start

↓

Load Profile

↓

Load Provider

↓

Validate

↓

Create Backup

↓

Merge Configuration

↓

Generate {{GENERATED_ARTIFACT}}

↓

Finish
```

Every build follows this order.

No stage may be skipped.

---

# Stage 1 — Load Profile

The builder begins by loading the profile selected at invocation time.

The profile is passed as a parameter.

```
-Profile <profile-name>
```

The default profile is

```
{{DEFAULT_PROFILE}}
```

The builder loads the profile configuration.

The build stops immediately if the required settings file is missing.

### Why

The profile defines **what** configuration should be used.

Loading the profile first ensures that all subsequent stages operate on the correct configuration set.

---

# Stage 2 — Load Provider

The builder reads the active provider list from the profile settings.

The builder loads every provider listed.

Provider definitions are read from `{{PROVIDER_DIR}}/`.

### Why

Provider definitions are independent from profiles.

Separating provider configuration allows connection details to change without modifying profile configuration.

---

# Stage 3 — Validation

Before generating the configuration, the builder validates the project.

Validation includes

- The selected profile exists.
- The settings file exists.
- Configuration syntax is valid.
- The provider list exists and is an array.
- The provider list contains at least one provider.
- Provider files exist.
- Provider identifiers match provider filenames.
- At least one provider was loaded.

The build must stop immediately when validation fails.

Partial output is never generated.

### Why

Validation prevents invalid configurations from reaching {{APP_NAME}}.

It is significantly easier to detect configuration problems during generation than after the application starts.

---

# Stage 4 — Backup

Before overwriting an existing configuration, the builder creates a backup.

Backups are stored in

```
{{BACKUP_DIR}}/
```

Each backup uses a timestamp-based filename.

Example

```
{{GENERATED_ARTIFACT}}_2026-08-02_18-30-45.json
```

Backups are never modified after creation.

### Why

Backups guarantee that a previously working configuration can always be restored.

Configuration generation should never destroy the last known working configuration.

---

# Stage 5 — Merge

The builder combines the source configuration.

Current merge order

```
Provider

↓

Models

↓

Plugins

↓

Service Configuration

↓

Generated Configuration
```

Models are injected into every active provider.

Plugins and service sections are merged only when the corresponding profile file exists.

Each section is merged exactly once.

### Why

Configuration is intentionally stored in separate files.

The merge stage combines these independent components into a single configuration that {{APP_NAME}} can consume.

---

# Stage 6 — Generation

The builder converts the merged configuration into the required format.

The generated file is written to

```
{{GENERATED_ARTIFACT}}
```

The previous configuration is replaced only after a successful build.

### Why

{{APP_NAME}} expects a single configuration file.

Generation converts the modular project structure into the format required by {{APP_NAME}}.

---

# Logging

The builder should clearly report every major stage of execution.

Example

```
Loading profile

Loading providers

Validating configuration

Creating backup

Generating configuration

Build completed successfully
```

Logging should make it possible to identify the stage where a build failed without inspecting the builder source code.

---

# Error Handling

The builder follows a fail-fast strategy.

If an unrecoverable error occurs, the build process terminates immediately.

The builder never attempts partial generation.

Every reported error should clearly communicate:

- What failed.
- Where it failed.
- Why it failed.
- What should be checked.

This behavior prevents invalid configurations from being generated.

---

# Configuration Ownership

The builder treats files differently depending on ownership.

## Source Files

Editable.

```
settings file

models file

plugins file

service configuration file

provider definition
```

---

## Generated File

Not editable.

```
{{GENERATED_ARTIFACT}}
```

The builder always regenerates this file.

---

# Builder Rules

The builder MUST

- Create backups before overwrite.
- Stop on validation failure.
- Produce valid output.
- Preserve source configuration.
- Keep build stages independent.

The builder MUST NOT

- Edit profile files.
- Edit provider files.
- Edit documentation.
- Edit generated backups.
- Continue after validation failure.

---

# Current Scope

The current builder intentionally supports only the functionality required by the current project.

Implemented

- Dynamic provider loading
- Dynamic profile selection
- Optional profile sections
- Single generated configuration
- Backup creation
- Configuration validation

Features outside this scope are intentionally excluded until they are designed, implemented, and tested.

Future functionality will be documented after implementation.

---

# Builder Lifecycle

```
Configuration

↓

Builder

↓

Validation

↓

Backup

↓

Merge

↓

Generation

↓

{{APP_NAME}}
```

---

# Builder Guarantees

When a build completes successfully, the builder guarantees:

- Source configuration remains unchanged.
- A backup exists.
- Generated output is valid.
- Configuration was validated before generation.
- {{APP_NAME}} receives a complete configuration.

---

# Success Criteria

A successful build satisfies all of the following.

✓ All required files loaded.

✓ Validation completed.

✓ Backup created.

✓ Configuration merged.

✓ `{{GENERATED_ARTIFACT}}` generated.

✓ {{APP_NAME}} can read the generated configuration.

---

# Builder Status

Current Builder

Version

```
V2.1
```

Script

```
{{BUILDER_SCRIPT}}
```

Status

```
Stable
```

Future versions of the builder will update this document after implementation.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Current Builder Specification
