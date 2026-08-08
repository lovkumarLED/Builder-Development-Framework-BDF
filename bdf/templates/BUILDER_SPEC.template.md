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

# Release Pipeline

Release documentation follows the same automation philosophy as the build: facts are written once, documentation is generated, and generated artifacts are never edited manually.

The release pipeline has one hand-edited input and one generator.

```
{{RELEASE_REGISTRY}}
    |
    v
{{RELEASE_MANAGER_SCRIPT}}
    |
    +---> {{RELEASE_ARTIFACTS}}
```

The registry ({{RELEASE_REGISTRY}}) is the only hand-edited release artifact.

It is the sequence authority for version documentation.

The release manager ({{RELEASE_MANAGER_SCRIPT}}) generates all release documentation from it.

## Marker Policy

Generated release documents carry content markers.

```
<!-- AUTO-GENERATED START -->

...

<!-- AUTO-GENERATED END -->
```

The release manager rewrites only the content between the markers.

Manual prose above and below the markers is never touched.

If the markers are missing, the generator aborts rather than guessing.

## Failure Policy

Generation is all-or-nothing.

Validation happens before anything is written.

If any input fails validation, nothing is written and the script exits with an error.

The repository is left exactly as it was before the run.

## Release Workflow

Every release follows the same workflow.

```
AI updates {{RELEASE_REGISTRY}}

    v

User reviews the release facts

    v

Run {{RELEASE_MANAGER_SCRIPT}}

    v

Generated release artifacts

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

### Model Precedence

Each provider can own its own models.

When resolving models for a provider, the builder uses the first source that exists:

1. Provider-specific models file

```
{{PROVIDER_DIR}}/<provider>/models.json
```

2. Inline models inside the provider definition file

```
{{PROVIDER_DIR}}/<provider>.json  ->  provider.<provider>.models
```

3. Global models file

```
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/models.json
```

Provider-specific models win over inline models, which win over global.

Global models are only injected into a provider when the provider has no models of its own.

This keeps builder behavior stable: a provider with an empty models object receives the global models.

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

# Stage 7 — Verification

Before writing, the builder verifies the generated configuration in memory.

Verification passes:

- Output validity (round-trip parse succeeds).
- Providers exist for every active provider.
- Models are correctly attached to each provider.
- Plugins are present when configured.
- Service configuration is present when configured.

The build fails before writing when any verification step fails.

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

# Builder V2.5 (Active-Provider Selector)

Builder V2.5 is a versioned builder implementation.

The pipeline stages documented above describe the earlier builder pipeline.

Builder V2.5 adds active-provider selection to that pipeline.

The user chooses which providers are active at build time.

The selection is persisted in the profile settings file, which is now a builder-writable source file.

---

## Command Line Interface

The builder accepts the following parameters.

```
-Profile        <profile-name>   default: {{DEFAULT_PROFILE}}
-ConfigRoot     <path>           default: <config-root>
-Provider       <ids>            default: (empty)
-NonInteractive                  switch, default: off
```

| Parameter | Default | Effect |
| --- | --- | --- |
| `-Profile` | `{{DEFAULT_PROFILE}}` | Selects the profile directory `{{CONFIG_SOURCE_DIR}}/<profile>`. |
| `-ConfigRoot` | `<config-root>` | Root directory containing the source configuration, provider definitions, backups, and the generated artifact. |
| `-Provider` | (empty) | Comma- or space-separated provider ids. Overrides interactive selection and the stored list. The given order is preserved. An unknown id aborts the build. |
| `-NonInteractive` | off | Skips the interactive menu and uses the stored settings list. |

### Why

Active-provider selection must work in unattended runs.

The provider and non-interactive parameters make the build reproducible from scripts.

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
Stage 8 — Verify Settings Persistence Round-trip
```

Stage 0 runs before profile loading.

It discovers ALL providers (not only the active ones), then resolves the active list, and persists the result to the settings file when it differs.

Stage 3 runs the active-provider model guard after merging models.

Every active provider must produce a models source (profile `<provider>-models.json`, provider-specific `models.json`, inline, or global).

A provider without any models source is NOT considered active: it is dropped with a warning, removed from the generated configuration, and removed from the settings file (the reduced list is persisted, backed up first).

If no active provider remains, the build aborts.

Stage 8 is new to V2.5.

After writing the generated artifact, the builder reloads the settings file and confirms that the persisted active provider list matches the resolved list.

No stage may be skipped.

---

## Function Contracts

The following functions are introduced by V2.5.

### Discover-Providers

No parameters.

Returns every valid provider id from the provider directory, in filename order.

Every provider file is loaded and validated.

A malformed provider file causes a terminating error listing ALL bad files.

Throws when no provider files exist.

Throws when any file is malformed.

---

### Select-ActiveProviders

Prints a numbered menu and returns the selected provider list.

Providers already in the current selection are marked as active.

Input grammar:

- Comma- or space-separated numbers choose the matching providers.
- `a` selects all discovered providers.
- `n` selects none.
- Empty input keeps the current selection.

---

### Resolve-ActiveProviders

Returns the resolved provider id list.

Resolution order:

1. `-Provider` is non-empty — wins over everything. The given order is preserved. An id that was not discovered throws.
2. `-NonInteractive` — returns the stored settings list.
3. Otherwise — calls `Select-ActiveProviders` with the discovered list and the stored list.

---

### Persist-ActiveProviders

Returns nothing.

Aborts the build when the selection is empty.

Rewrites the settings file only when the active list differs from the stored list.

Before overwriting, the current settings file is backed up.

The schema declaration is preserved.

The rewritten file is UTF-8 without BOM.

---

### Compare-JsonArrays

Returns whether two arrays are equal as lists of strings.

Used to decide whether the settings file must be rewritten.

---

### Get-ProfileProviderModels

Returns the parsed profile models file for a provider.

Returns nothing when the file does not exist.

File:

```
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/<provider>-models.json
```

Checks duplicate keys.

Checks duplicate model names.

Throws when the models section is missing or invalid.

---

## Selection Rules

- The interactive menu accepts comma/space separated numbers, `a` for all, `n` for none, and empty input to keep the current selection.
- `-Provider` takes precedence over the stored list and the menu. The given order is preserved. An unknown id aborts the build.
- `-NonInteractive` skips the menu and uses the stored settings list.
- `Persist-ActiveProviders` aborts the build when the selection is empty.
- The stored list is written back to the settings file only when it differs from the previous list.

---

## Model Precedence

Models for an active provider resolve from the first source that exists.

1. Profile-level models file

```
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/<provider>-models.json
```

2. Provider-specific models file

```
{{PROVIDER_DIR}}/<provider>/models.json
```

3. Inline models inside the provider definition file

```
{{PROVIDER_DIR}}/<provider>.json  ->  provider.<provider>.models
```

4. Global models file

```
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/models.json
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
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/<provider>-models.json

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

Model names must be unique.

Non-active providers' model files are ignored.

Only the models of providers in the active list are ever read or merged.

---

## Settings Write Policy

The profile settings file is a builder-writable source file.

The builder writes it:

- Only when the active list differs from the stored list.
- With a backup at

```
{{BACKUP_DIR}}/settings_<profile>_<timestamp>.json
```

before overwrite.

- With the schema declaration preserved.
- As UTF-8 without BOM.

---

## Regeneration Guarantee

This specification fully describes the current builder and its predecessors.

An agent can regenerate the current builder script from this document alone.

The retained V2.5 sections above also allow regenerating the previous builder, and the historical pipeline section documents the earlier builder for reference.

Every function name, parameter, and stage label above matches the respective script.

---

# Builder V2.7 (JSON Schema Validation)

Builder V2.7 is a versioned builder implementation.

It is built on the V2.5 pipeline (documented above) and adds a schema-validation stage plus the hardening feature set F1-F7.

Every V2.5 stage and function remains intact; the historical sections above are retained for regeneration.

---

## V2.7 Pipeline (9 Stages)

The V2.7 build follows this canonical nine-stage order.

| Stage | Name | Notes |
|-------|------|-------|
| 0 | Discover Providers | active-provider discovery, selection, persistence |
| 1 | Load Profile | unchanged |
| 2 | Load Provider | provider reference check; merging happens in Stage 6 |
| 3 | Schema Validation | NEW — F1 (JSON Schema) + F2 (pre-flight) entry gate |
| 4 | Validation | structural validation |
| 5 | Backup | honors F4 retention |
| 6 | Merge | providers + models + plugins + service configuration + final merge |
| 7 | Generation | writes {{GENERATED_ARTIFACT}} + F5 provenance sidecar |
| 8 | Verification | round-trip + F7 diff summary + F4 prune |

No stage may be skipped.

---

## V2.7 Feature Set (F1-F7)

| # | Feature | Behavior |
| --- | --- | --- |
| F1 | JSON Schema Validation | Validate configuration sources against schema files BEFORE builder validation. Non-breaking: missing schemas result in a warning and a skip. |
| F2 | Pre-flight dependency check | Before merge, verify every active-provider reference, profile file, and referenced schema file exists; report ALL missing inputs, then abort with a clear error. |
| F3 | Dry-run | Validate and merge only; write nothing, no backups; print planned changes; exit successfully. |
| F4 | Backup retention | Prune the backup directory to the newest N files per prefix. Configurable retention count. |
| F5 | Provenance stamp | Write a sidecar file with builder version, profile, providers, generation timestamp, and output hash. Never writes INTO the generated artifact. |
| F6 | Diagnostics | Read the real configuration at the config root, validate sources against schemas and dependency references, print a status table, and exit with a clean or issue signal. No writes. |
| F7 | Merge diff summary | After a successful build, print an added/removed/updated summary (providers, model counts, plugins, service entries) versus the previous backup artifact. |

---

## Target Artifact Resolution (P2)

The generated artifact name is dynamic and resolved when a profile runs, never fixed in the builder code.

An optional target file in the profile names the output artifact.

```json
{
    "artifact": "{{GENERATED_ARTIFACT}}"
}
```

Resolution rules (Stage 1 / Load Profile):

- File present and valid (artifact is a non-empty string) — the artifact name is used.
- File missing, unreadable, or invalid — the default artifact is used (backward compatible).
- An artifact value without the expected suffix gets the suffix appended.

The resolved target drives every hardcoded value in the builder:

- Output write path.
- Backup prefix (base name minus extension).
- Provenance sidecar path.
- Dry-run messages, diff scan, and retention prune on the artifact prefix.

The target file is validated against its schema during Stage 3 (optional source; skipped if absent).

---

## API Key Policy (P1)

- Provider source files and the generated artifact must contain **only** environment-variable placeholders, never literal API key values.
- The builder NEVER carries, restores, or invents API keys. A key may appear in generated output only if a provider source file already contains it (as a placeholder).
- Missing provider files are reported by the pre-flight check (F2); they are never "restored" from backups.

---

## Command Line Interface (V2.7)

The V2.7 builder accepts all V2.5 parameters (unchanged) plus additional parameters.

```
-SchemaDir        <path>           default: <config-root>/schemas
-WhatIf           <switch>         dry run
-KeepBackups      <int>            default: 10
-Doctor           <switch>         read-only diagnose
-ProvenancePath   <path>           default: <config-root>/<artifactBase>.provenance.json
```

| Parameter | Default | Effect |
| --- | --- | --- |
| `-SchemaDir` | `<config-root>/schemas` | Directory containing the schema files used at Stage 3. |
| `-WhatIf` | switch | Dry run. Validates and merges only; writes nothing; prints planned changes; exits successfully. |
| `-KeepBackups` | 10 | Keeps the newest N files per prefix in the backup directory. |
| `-Doctor` | switch | Read-only mode that diagnoses the real configuration at the config root; no writes. |
| `-ProvenancePath` | `<config-root>/<artifactBase>.provenance.json` | Path of the provenance sidecar written by F5 (default derives from the resolved target artifact). |

---

## V2.7 Function Contracts

The following functions are introduced by V2.7 (names are illustrative identifiers).

| Function | Contract |
| --- | --- |
| `Test-SchemaCompliance` | Validates a file against a schema object; returns validity and error list. |
| `Invoke-SourceSchemaCheck` | Runs the schema check for a source file and throws on failure. |
| `Get-SchemaForSource` | Maps a source file name to its schema file name; returns nothing when no schema applies. |
| `Assert-InputFilesExist` | Returns the list of every missing input file; never throws. |
| `Get-CurrentSources` | Returns the source files for the current profile. |
| `Prune-Backups` | Keeps the newest N files per prefix in the backup directory. |
| `Write-ProvenanceFile` | Writes the provenance sidecar. |
| `Get-LatestBackupConfig` | Returns the parsed content of the newest backup artifact. |
| `Compare-BackupDiff` | Returns diff lines (added / removed / updated) against the previous backup artifact. |
| `Invoke-Doctor` | Runs read-only diagnostics; prints a status table; reports whether the configuration is clean. |

---

## Supported JSON Schema Subset

The builder implements a compact JSON Schema validator.

Supported:

- `$schema` (informational only, not enforced)
- `type`
- `required`
- `properties`
- `additionalProperties: false`
- `items`
- `enum`
- `$ref` — local same-file only, e.g. `#/definitions`

Validation is implemented inside the builder.

---

# Builder Status

Current Builder

Version

```
current builder
```

Script

```
{{BUILDER_SCRIPT}}
```

Status

```
Stable
```

The exact builder version is defined by the project adapter.

Prior builder versions remain documented for historical regeneration.

Future versions of the builder will update this document after implementation.

---

# Scaffold Mode (Universal, V3)

The framework ships a UNIVERSAL scaffold that works the SAME way for EVERY
open-source coding agent, not only the framework's own projects.

Script

```
{{UNIVERSAL_SCRIPT}}      (universal core)
{{AGENT_WRAPPER_SCRIPT}}  (wrapper = universal, this agent)
```

Arguments: `-Agent <name>`, `-ConfigRoot` (defaults to the agent's
`~/.config/<agent>`), `-NonInteractive`, `-List`, `-Bootstrap`.

## User-Run vs System-Run (rule)

The scaffolds are SYSTEM-RUN ONLY. The user never runs them. The only scripts the
user runs are the BUILDERS (`{{BUILDER_SCRIPT}}` for this project, and the
per-agent builder for any other). The system (AI) runs the scaffold once per agent
to create the profile structure and seed `mcp.json`/`plugins.json` from the agent's
own main JSON. After seeding, the user edits profiles/providers and runs only the
builder.

## Discovery (V3 rule)

1. Probes the open-source agent registry (extensible `$AgentRegistry`, see
   "Agent Registry") in standard locations.
2. One found -> use it. Multiple found -> user picks. None found -> the
   framework ASKS: "Give me the location of your coding agents" (a config
   folder) and scaffolds whatever the user points at.
3. `-List` prints discovered open-source coding agents only.
   Closed-source agents are never scanned or written.

## Contract

The framework's ONE job is scanning + splitting + seeding the profiles. It never
invents content and never writes into user-owned files.

1. Scan the agent's OWN MAIN `.json` config file FIRST, read-only. Only the
   agent's own primary main file (registry order) is the source of truth —
   the framework never scans another agent's config.
   - `.provenance.json` files are NEVER scanned as main configs.
2. Split the scanned sections: provider (guidance only) / mcp / plugin.
3. Paste into `profiles/<profile>/` (coding is ALWAYS the default profile):
   - `mcp` section    -> `profiles/coding/mcp.json` (seeded if missing)
   - plugin section   -> `profiles/coding/plugins.json` (seeded if missing)
   - experimental/minimal -> mcp.json + plugins.json created EMPTY, never filled.
   - **mcp.json / plugins.json are USER-OWNED after creation.** The framework
     NEVER overwrites them on later runs. The user edits MCPs and plugins by
     hand; the framework's job is to create the files once.
4. The framework creates the `providers/` folder (like the profile folders), but
   NEVER writes `providers/<id>.json` or `<id>-models.json` — provider and model
   files are 100% user-owned. The framework prints guidance about the detected
   provider section only.
5. Ensure profiles always exist: `coding` (main) + `experimental` + `minimal`.
   Each profile carries exactly three files: `settings.json`, `mcp.json`,
   `plugins.json`.
6. `settings.json` is the ONLY file the framework writes freely:
   - File missing  -> create with `$schema` + `activeProviders` (detected from
     the main config's provider section). NEVER copy-paste the whole config.
   - File exists   -> merge ONLY `$schema` + `activeProviders` when missing;
     NEVER clobber any user key, never paste the agent shape.
7. The user may add more profiles or edit any file at any time. The framework
   only ever ensures the three profile folders + the three files per profile.
8. `-Bootstrap` generates `build-<agent>.ps1`, `test-<agent>.ps1`,
   `scaffold-<agent>.ps1` for that agent from a source builder.

## No-Secrets Rule (ULTIMATE)

The SYSTEM's own artifacts — scripts, templates, docs, examples — NEVER contain
a literal API key or secret; only `{env:VAR}` placeholders or fictional examples.
User-owned files (main config, profiles, providers) may contain literal keys —
the user protects them. The scaffold and builder COPY user content verbatim
(scan → copy → paste), so generated output reflects whatever the user's source
files contain, keys included.

## Non-JSON Guard

Never touch `.jsonc` or any non-`.json` file on its own. A non-`.json` config
candidate asks the user `[y/N]` before reading; in `-NonInteractive` mode it is
silently skipped.

## Agent Registry (extensible)

```
{{UNIVERSAL_SCRIPT}} -> $AgentRegistry
  Name, Home (config dir), Main (.json file names), PlugKeys, Schema
```

---

**Document Version:** {{DOC_VERSION}}

**Status:** Current Builder Specification
