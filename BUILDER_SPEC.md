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

# Builder V2.5 (Active-Provider Selector)

Builder V2.5 is the current builder implementation.

The stages described above document the historical V2.1 pipeline.

Builder V2.5 adds active-provider selection to that pipeline.

The user chooses which providers are active at build time.

The selection is persisted in `settings.json`, which is now a builder-writable source file.

---

## Command Line Interface

The builder accepts the following parameters.

```
-Profile        <profile-name>   default: default
-ConfigRoot     <path>           default: $HOME\.config\opencode
-Provider       <ids>            default: (empty)
-NonInteractive                  switch, default: off
```

| Parameter | Default | Effect |
| --- | --- | --- |
| `-Profile` | `default` | Selects the profile directory `profiles/<profile>`. |
| `-ConfigRoot` | `$HOME\.config\opencode` | Root directory containing `profiles/`, `providers/`, `backup/`, and `opencode.json`. |
| `-Provider` | (empty) | Comma or space separated provider ids. Overrides interactive selection and the stored list. The given order is preserved. An unknown id aborts the build. |
| `-NonInteractive` | off | Skips the interactive menu and uses the stored `settings.json` list. |

### Why

Active-provider selection must work in unattended runs.

`-Provider` and `-NonInteractive` make the build reproducible from scripts.

---

## Stage List

The V2.5 build follows this order.

```
Stage 0 — Discover / Select / Persist Providers
Stage 1 — Load Profile
Stage 2 — Validate
Stage 3 — Merge
Stage 4 — Create Backup
Stage 5 — Generate Final Configuration
Stage 6 — Verify Output
Stage 7 — Write Output
Stage 8 — Verify settings.json Persistence Round-trip
```

Stage 0 runs before profile loading.

It discovers ALL providers (not only the active ones), then resolves the active list, and persists the result to `settings.json` when it differs.

Stage 8 is new to V2.5.

After writing `opencode.json`, the builder reloads `settings.json` and confirms that the persisted `activeProviders` match the resolved list.

No stage may be skipped.

---

## New Function Contracts

### Discover-Providers

No parameters.

Returns every valid provider id from `providers/*.json`, in filename order.

Every `.json` file in `providers/` is loaded and validated.

A malformed provider file causes a terminating error listing ALL bad files.

Throws when no provider files exist:

```
No provider files found in <providers-root>
```

Throws when any file is malformed:

```
Provider discovery failed for: <file> - <message>; <file> - <message>
```

---

### Select-ActiveProviders

Params

```
[string[]]$Discovered
[string[]]$Current
```

Returns the selected provider id list.

Prints a numbered menu.

Providers already in the current selection are marked `(active)`.

Input grammar:

- Comma or space separated numbers choose the matching providers.
- `a` selects all discovered providers.
- `n` selects none.
- Empty input keeps the current selection.

---

### Resolve-ActiveProviders

Params

```
[string[]]$Discovered
[string[]]$Stored
```

Returns the resolved provider id list.

Resolution order:

1. `-Provider` is non-empty — wins over everything. The given order is preserved. An id that was not discovered throws:

```
Provider not found: <id> (discovered: <comma-separated list>)
```

2. `-NonInteractive` — returns the stored `settings.json` list.
3. Otherwise — calls `Select-ActiveProviders` with the discovered list and the stored list.

---

### Persist-ActiveProviders

Params

```
[string[]]$Active
```

Returns nothing.

Aborts the build when the selection is empty:

```
No active providers selected; build aborted.
```

Rewrites `settings.json` only when the active list differs from the stored list.

Difference is detected with `Compare-JsonArrays`.

Before overwriting, the current `settings.json` is backed up to

```
backup\settings_<profile>_<timestamp>.json
```

`$schema` is preserved.

The rewritten file is UTF-8 without BOM.

---

### Compare-JsonArrays

Params

```
[object[]]$A
[object[]]$B
```

Returns `$true` when the counts are equal and every element matches as a string.

Returns `$false` otherwise.

Used to decide whether `settings.json` must be rewritten.

---

### Get-ProfileProviderModels

Params

```
[string]$ProviderId
```

Returns the parsed profile models file for the provider.

Returns `$null` when the file does not exist.

File

```
profiles/<profile>/<provider>-models.json
```

Checks duplicate keys via `Assert-NoDuplicateKeys` (section `model`).

Checks duplicate model names via `Assert-NoDuplicateModelNames`.

Throws when the `models` section is missing or invalid:

```
Profile models file '<file>' validation failed: 'models' section is missing or invalid.
```

---

## Selection Rules

- The interactive menu accepts comma/space separated numbers, `a` for all, `n` for none, and empty input to keep the current selection.
- `-Provider` takes precedence over the stored list and the menu. The given order is preserved. An unknown id aborts the build.
- `-NonInteractive` skips the menu and uses the stored `settings.json` list.
- `Persist-ActiveProviders` aborts the build when the selection is empty.
- The stored list is written back to `settings.json` only when it differs from the previous list.

---

## Model Precedence

Models for an active provider resolve from the first source that exists.

1. Profile-level models file

```
profiles/<profile>/<provider>-models.json
```

2. Provider-specific models file

```
providers/<provider>/models.json
```

3. Inline models inside the provider definition file

```
providers/<provider>.json  ->  provider.<provider>.models
```

4. Global models file

```
profiles/<profile>/models.json
```

5. None — no models configured for the provider.

Profile-level models win over provider-specific models, which win over inline models, which win over global models.

Global models are only injected into a provider when the provider has no models of its own.

Non-active providers are never considered for any source.

### Why

Models are owned at the profile level first.

A profile can override the models of any provider without editing provider files.

---

## <provider>-models.json Shape

Profile-level models are stored per provider.

```
profiles/<profile>/<provider>-models.json

{
    "models": {
        "<model-id>": {
            ...model definition...
        }
    }
}
```

The `models` object maps model identifiers to model definitions.

Keys must be unique.

`Assert-NoDuplicateKeys` scans the raw text with section `model`.

Model names must be unique.

`Assert-NoDuplicateModelNames` reads the `name` of every model.

Non-active providers' model files are ignored.

Only the models of providers in the active list are ever read or merged.

---

## settings.json Write Policy

`settings.json` is a builder-writable source file.

The builder writes it:

- Only when the active list differs from the stored list.
- With a backup at

```
backup\settings_<profile>_<timestamp>.json
```

before overwrite.

- With `$schema` preserved.
- As UTF-8 without BOM.

---

## Verification Additions

Every active provider must have a models source.

The source may be profile-level, provider folder, inline, or global.

Otherwise the build fails before writing:

```
Verification failed: active provider '<name>' has no models.
```

Stage 8 round-trip check.

After writing, `settings.json` `activeProviders` must match the resolved list:

```
Verification failed: settings.json activeProviders (<stored list>) does not match the resolved list (<resolved list>).
```

The build fails before finishing if either check fails.

---

## Regeneration Guarantee

This specification fully describes the builder.

An agent can regenerate `scripts\build-opencode-v2.5.ps1` from this document alone.

Every function name, parameter, stage label, and error message above matches the script verbatim.

Regeneration order:

```
AGENT.md -> ... -> BUILDER_SPEC.md -> plan
```

---

# Builder Status

Current Builder

Version

```
V2.5
```

Script

```
build-opencode-v2.5.ps1
```

Status

```
Stable
```

Previous Version

```
V2.1 (build-opencode-v2.ps1)
```

Future versions of the builder will update this document after implementation.

---

**Document Version:** 1.0

**Status:** Current Builder Specification