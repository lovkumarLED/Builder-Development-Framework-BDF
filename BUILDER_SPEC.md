# Builder Specification

> Functional specification for the OpenCode Configuration Builder.

---

# Purpose

The builder is responsible for generating the final `opencode.json` configuration used by OpenCode.

It acts as the automation layer between the modular source configuration and the final generated configuration.

The builder is the only component that generates `opencode.json`.

It never modifies the source configuration files.

---

# Design Goals

The builder was designed to achieve the following goals.

- Eliminate manual editing of `opencode.json`.
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

Configuration is defined exclusively by the source JSON files.

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
- Modify profile configuration.
- Require manual editing of generated files.

---

# Inputs

The builder reads configuration from the selected profile.

The profile is chosen at invocation time.

```
profiles/<profile>/

settings.json

models.json

plugins.json

mcp.json
```

`settings.json` is required.

`models.json`, `plugins.json`, and `mcp.json` are optional.

Only the sections that exist are merged into the generated configuration.

and

```
providers/

omniroute.json
```

---

# Output

The builder generates exactly one file.

```
opencode.json
```

This file is consumed by OpenCode.

---

# Build Pipeline

The complete build process follows this sequence.

```
Start

↓

Load Profile

↓

Validate

↓

Merge Configuration
(settings → providers → models → plugins → mcp)

↓

Create Backup

↓

Generate Final Configuration

↓

Verify Output

↓

Write opencode.json

↓

Finish
```

Every build follows this order.

No stage may be skipped.

---

# Release Pipeline

Release documentation follows the same automation philosophy as the builder: facts are written once, documentation is generated, and generated artifacts are never edited manually.

The release pipeline has one hand-edited input and one generator.

```
docs/release_registry.json
    |
    v
scripts/release-manager.ps1
    |
    +---> CHANGELOG.md          (generated marker section only)
    +---> CURRENT_RELEASE.md    (generated quick reference)
    +---> bdf/VERSION.md        (generated compatibility rows)
    +---> PROJECT_STATE.md      (generated version history table)
```

The registry (`docs/release_registry.json`) is the only hand-edited release artifact.

It is the sequence authority for version documentation.

The release manager (`scripts/release-manager.ps1`) generates all release documentation from it.

## Marker Policy

`CHANGELOG.md` and `PROJECT_STATE.md` carry

```
<!-- AUTO-GENERATED START -->

...

<!-- AUTO-GENERATED END -->
```

The release manager rewrites only the content between the markers.

Manual prose above and below the markers is never touched.

If the markers are missing, the script aborts rather than guessing.

## Failure Policy

Generation is all-or-nothing.

Validation happens before anything is written.

If any input fails validation, nothing is written and the script exits with failure.

The repository is left exactly as it was before the run.

## Release Workflow

Every release follows the same workflow.

```
AI updates release_registry.json

    v

User reviews the release facts

    v

Run release-manager.ps1

    v

Generated Docs (CHANGELOG, CURRENT_RELEASE, VERSION, PROJECT_STATE)

    v

Commit
```

The generated files are never edited manually.

---

# Stage 1 — Load Profile

The builder begins by loading the profile selected at invocation time.

The profile is passed as a parameter.

```
-Profile <profile-name>
```

The default profile is

```
default
```

Example

```
build-opencode-v2.ps1 -Profile default
```

The builder loads

- settings.json (required)
- models.json (optional)
- plugins.json (optional)
- mcp.json (optional)

The build stops immediately if settings.json is missing.

### Why

The profile defines **what** configuration should be used.

Loading the profile first ensures that all subsequent stages operate on the correct configuration set.

---

# Stage 2 — Load Provider

The builder reads

```
activeProviders
```

from

```
settings.json
```

The builder loads every provider listed.

Current implementation

```
omniroute
```

The provider definition is read from

```
providers/omniroute.json
```

### Why

Provider definitions are independent from profiles.

Separating provider configuration allows connection details to change without modifying profile configuration.

---

# Stage 3 — Validation

Before generating the configuration, the builder validates the project.

Validation includes

- The selected profile exists.
- settings.json exists.
- JSON syntax is valid.
- `activeProviders` exists and is an array.
- `activeProviders` contains at least one provider.
- `activeProviders` contains no duplicate provider identifiers.
- Provider files exist.
- Provider identifier matches the provider filename.
- The provider section is present and non-empty.
- No duplicate provider identifiers across active provider files.
- No duplicate model identifiers (raw text, not collapsed by parsing).
- No duplicate model names within a models source.
- No duplicate plugin identifiers.
- No duplicate MCP identifiers.
- Malformed provider definitions are rejected.
- Malformed profile definitions are rejected.
- Missing required fields are rejected.
- Invalid configuration structure is rejected.
- At least one provider was loaded.

The build must stop immediately when validation fails.

Partial output is never generated.

### Why

Validation prevents invalid configurations from reaching OpenCode.

It is significantly easier to detect configuration problems during generation than after OpenCode starts.

---

# Stage 4 — Backup

Before overwriting an existing configuration, the builder creates a backup.

Backups are stored in

```
backup/
```

Each backup uses a timestamp-based filename.

Example

```
opencode_2026-08-02_18-30-45.json
```

Backups are never modified after creation.

### Why

Backups guarantee that a previously working configuration can always be restored.

Configuration generation should never destroy the last known working configuration.

---

# Stage 5 — Merge

The builder combines the source configuration.

Merge is split into independent stages.

```
Merge Settings

↓

Merge Providers

↓

Merge Models

↓

Merge Plugins

↓

Merge MCP

↓

Generate Final Configuration
```

Each stage is implemented as its own function and can be maintained independently.

Plugins and MCP sections are merged only when the corresponding profile file exists.

Each section is merged exactly once.

### Model Precedence

Each provider can own its own models.

When resolving models for a provider, the builder uses the first source that exists:

1. Provider-specific models file

```
providers/<provider>/models.json
```

2. Inline models inside the provider definition file

```
providers/<provider>.json  ->  provider.<provider>.models
```

3. Global models file

```
profiles/<profile>/models.json
```

Provider-specific models win over inline models, which win over global models.

Global models are only injected into a provider when the provider has no models of its own.

This keeps Builder V2 behavior: a provider with an empty `models` object receives the global models.

### Why

Configuration is intentionally stored in separate files.

The merge stage combines these independent components into a single configuration that OpenCode can consume.

---

# Stage 6 — Generation

The builder converts the merged configuration into formatted JSON.

The generated file is written to

```
opencode.json
```

The previous configuration is replaced only after a successful build.

### Why

OpenCode expects a single configuration file.

Generation converts the modular project structure into the format required by OpenCode.

---

# Stage 7 — Verification

Before writing, the builder verifies the generated configuration in memory.

Verification passes:

- JSON validity (round-trip parse succeeds).
- Providers exist for every active provider.
- Models are correctly attached to each provider.
- Plugins are present when configured.
- MCP configuration is present when configured.

The build fails before writing if any verification step fails.

Partial or invalid output is never written.

### Why

Verification catches generation defects before they can replace a working configuration.

The backup guarantees recovery; verification guarantees the new output is valid.

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
settings.json

models.json

plugins.json

mcp.json

omniroute.json
```

---

## Generated File

Not editable.

```
opencode.json
```

The builder always regenerates this file.

---

# Builder Rules

The builder MUST

- Create backups before overwrite.
- Stop on validation failure.
- Produce valid JSON.
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

OpenCode
```

---

# Builder Guarantees

When a build completes successfully, the builder guarantees:

- Source configuration remains unchanged.
- A backup exists.
- Generated JSON is valid.
- Configuration was validated before generation.
- OpenCode receives a complete configuration.

---

# Success Criteria

A successful build satisfies all of the following.

✓ All required files loaded.

✓ Validation completed.

✓ Backup created.

✓ Configuration merged.

✓ `opencode.json` generated.

✓ OpenCode can read the generated configuration.

---

# Builder Status

Current Builder

Version

```
V2.1
```

Script

```
build-opencode-v2.ps1
```

Status

```
Stable
```

Future versions of the builder will update this document after implementation.

---

**Document Version:** 1.0

**Status:** Current Builder Specification