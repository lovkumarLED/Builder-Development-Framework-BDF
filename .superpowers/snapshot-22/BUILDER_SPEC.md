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

Stage 3 runs the active-provider model guard after merging models.

Every active provider must produce a models source (profile `<provider>-models.json`, `providers/<p>/models.json`, inline, or global). A provider without any models source is NOT considered active: it is dropped with a warning, removed from the generated configuration, and removed from `settings.json` (the reduced list is persisted, backed up first). If no active provider remains, the build aborts.

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

Active providers without a models source are dropped after merge, before generation.

The drop is announced with a warning and the reduced list is persisted to `settings.json`:

```
Provider '<name>': models not found (no <provider>-models.json, providers/<name>/models.json, inline, or global models.json). Provider will not be considered active and was removed from settings.json.
```

The provider is absent from `opencode.json` and from `settings.json`.

Stage 8 round-trip check.

After writing, `settings.json` `activeProviders` must match the resolved list:

```
Verification failed: settings.json activeProviders (<stored list>) does not match the resolved list (<resolved list>).
```

The build fails before finishing if the round-trip check fails.

---

## Regeneration Guarantee

This specification fully describes the current builder and its predecessors.

An agent can regenerate the current builder `scripts\build-opencode-v2.7.ps1` from this document alone.

The retained V2.5 sections above also allow regenerating the previous builder `scripts\build-opencode-v2.5.ps1`, and the historical pipeline section documents V2.1 (`scripts\build-opencode-v2.ps1`) for reference.

Every function name, parameter, stage label, and error message above matches the respective script verbatim, including the V2.7 function contracts and verbatim messages below.

Regeneration order:

```
AGENT.md -> ... -> BUILDER_SPEC.md -> plan
```

---

# Builder V2.7 (JSON Schema Validation)

Builder V2.7 is the current builder implementation.

It is built on the V2.5 pipeline (documented above) and adds a schema-validation stage plus the hardening feature set F1-F7.

Every V2.5 stage and function remains intact; the historical V2.5 and V2.1 sections above are retained for regeneration.

---

## V2.7 Pipeline (canonical 9 stages)

The V2.7 build follows this canonical nine-stage order.

| Stage | Name | Notes |
|-------|------|-------|
| 0 | Discover-Providers | unchanged (V2.5) |
| 1 | Load Profile | unchanged |
| 2 | Load Provider | provider reference check; merging happens in Stage 6 |
| 3 | Schema Validation | NEW - F1 (JSON Schema) + F2 (pre-flight) entry gate |
| 4 | Validation | was V2.5 Stage 2 |
| 5 | Backup | was V2.5 Stage 4 - honors F4 retention |
| 6 | Merge | providers + models + plugins + mcp + final merge |
| 7 | Generation | writes opencode.json + F5 provenance sidecar |
| 8 | Verification | round-trip + F7 diff summary + F4 prune |

No stage may be skipped.

---

## V2.7 Feature Set (F1-F7)

| # | Feature | Behavior |
| --- | --- | --- |
| F1 | JSON Schema Validation | Validate config sources against schemas/*.schema.json BEFORE builder validation (Stage 3). Non-breaking: missing schemas -> warn + skip. |
| F2 | Pre-flight dependency check | Before merge, verify every active-provider provider ref + profile files + schema files exist; report ALL missing, then abort with clear error. Catches the modal.json bug class. |
| F3 | -WhatIf dry-run | Validate + merge only; write nothing, no backups; print planned changes + exit 0. |
| F4 | Backup retention | Prune backup/ to newest N per prefix (`<artifactBase>_*`, `settings_*`). Param -KeepBackups, default 10. |
| F5 | Provenance stamp | Sidecar `<artifactBase>.provenance.json` (builderVersion, profile, providers, generatedUtc, outputSha256). Never writes INTO the target artifact. |
| F6 | -Doctor diagnose | Read the REAL config at -ConfigRoot, validate sources against schemas + dependency refs, print File \| Status \| Detail table; exit 0 clean / 1 issues. No writes. |
| F7 | Merge diff summary | After a successful build, print Added/Removed/Updated (providers, model counts, mcp servers, plugins) vs previous backup artifact. |

---

## Target artifact resolution (P2, config-driven)

The generated artifact name is **dynamic and resolved when a profile runs**, never fixed in
builder code. An optional `profiles/<profile>/target.json` names the output artifact:

```json
{
    "artifact": "opencode.json"
}
```

Resolution rules (Stage 1 / Load Profile):

- File present and valid (`artifact` non-empty string) -> `$TargetArtifact = artifact`.
- File missing, unreadable, or invalid -> `$TargetArtifact = "opencode.json"` (backward compatible).
- `artifact` without `.json` suffix gets it appended.

`$TargetArtifact` drives every hardcoded string in the builder:

- Output write path: `<ConfigRoot>\<artifact>`
- Backup prefix: `<artifactBase>_*.json` (base name = artifact minus extension)
- Provenance sidecar: `<ConfigRoot>\<artifactBase>.provenance.json`
- WhatIf messages, F7 diff scan, and F4 retention prune on the artifact prefix

A future Claude target profile would set `"artifact": "claude.json"` (or whatever the
consumer needs) in its `target.json` — code stays untouched. The target file is validated
against `schemas/targets.schema.json` during Stage 3 (optional source; skipped if absent).

## API key policy (P1, mandatory)

- Provider source files (`providers/<id>.json`) and the generated artifact must contain
  **only** `{env:VAR_NAME}` placeholders, never literal API key values.
- The builder NEVER carries, restores, or invents API keys. A key may appear in generated
  output only if a provider source file already contains it (as a placeholder).
- Missing provider files are reported by the pre-flight F2 check; they are never "restored"
  from backups.
- Example: `providers/omniroute.json` uses `{env:OMNIROUTE_API_KEY_OPENCODE}`.

---

## Command Line Interface (V2.7)

The V2.7 builder accepts all V2.5 parameters (unchanged) plus five new ones.

```
-SchemaDir      <path>           default: <ConfigRoot>\schemas
-WhatIf                         switch, dry run
-KeepBackups    <int>           default: 10
-Doctor                        switch, read-only diagnose
-ProvenancePath <path>          default: <ConfigRoot>\<artifactBase>.provenance.json
```

| Parameter | Default | Effect |
| --- | --- | --- |
| `-SchemaDir` | `<ConfigRoot>\schemas` | Directory containing the `*.schema.json` files used at Stage 3. |
| `-WhatIf` | switch | Dry run. Validates and merges only; writes nothing; prints planned changes; exits 0. |
| `-KeepBackups` | 10 | Keeps the newest N files per prefix (`opencode_*`, `settings_*`) in `backup/`. |
| `-Doctor` | switch | Read-only mode that diagnoses the real config at `-ConfigRoot`; no writes. |
| `-ProvenancePath` | `<ConfigRoot>\<artifactBase>.provenance.json` | Path of the provenance sidecar written by F5 (default derives from the target artifact). |

---

## V2.7 Function Contracts

### Test-SchemaCompliance

Params

```
[string]$Path
[object]$Schema
```

Returns

```
[pscustomobject]@{
    Valid   = [bool]
    Errors  = [string[]]
}
```

Validates a JSON file against a schema object.

Supported subset:

- `$schema` (informational)
- `type`
- `required`
- `properties`
- `additionalProperties: false`
- `items`
- `enum`
- `$ref` (local same-file only, e.g. `#/definitions/name`)

---

### Invoke-SourceSchemaCheck

Params

```
[string]$File
[string]$SchemaName
```

Throws the verbatim schema failure contract.

---

### Get-SchemaForSource

Params

```
[string]$FileName
```

Returns the schema file name for a source file.

Covers run

```
<provider>-models.json  ->  models.schema.json
models.json             ->  models.schema.json
```

Returns `$null` when no schema applies to the file.

---

### Assert-InputFilesExist

No parameters.

Returns `[string[]]` of every missing input file (provider files for active providers, profile files, referenced schema files). Never throws.

Called at the Stage 3 entry gate.

---

### Get-CurrentSources

No parameters.

Returns the source files for the current profile:

- settings.json (required)
- models.json (optional)
- plugins.json (optional)
- mcp.json (optional)
- active provider files
- profile-level `<provider>-models.json`

---

### Prune-Backups

Params

```
[int]$Keep
```

Keeps the newest N files per prefix (`opencode_*`, `settings_*`) in `backup/`.

---

### Write-ProvenanceFile

Params

```
[string]$OutputSha256
```

Writes the `opencode.provenance.json` sidecar.

---

### Get-LatestBackupConfig

No parameters.

Returns the parsed content of the newest `backup/opencode_*.json`.

Returns `$null` when no backup artifact exists.

---

### Compare-BackupDiff

Params

```
[object]$Final
```

Returns diff lines (Added / Removed / Updated) compared with the previous backup artifact.

---

### Invoke-Doctor

No parameters.

Read-only diagnostics.

Prints a `File | Status | Detail` table. Returns `$true` when clean, `$false` when issues are found.

---

## V2 Verbatim Messages V2.7

- Schema failure: `Schema '<schema-name>': <file> failed: <property> <message>.`
- Schema skip: `[!] No schema directory found at <SchemaDir> - skipping schema validation.`
- Pre-flight fail: `['] 'Pre-flight failed: N (missing up-front rows)mber of missing inputs.` then per file `[+] (See `[x] Missing: <path>`
- Pre-flight pass: `[+] All input dependencies present.`
- Schema pass: `[+] All sources pass schema validation.`
- Pre-flight-File pass: `[+] All input files present.`
- WhatIf: `[WhatIf] Would write <OutputFile>` / `[WhatIf] Would write <ProvenancePath>` / `[WhatIf] Planned changes:` (both paths derive from the resolved target artifact)
- Doctor summary: `Doctor: N file(s) checked, M issue(s) found.` then `Doctor: configuration is clean.` / `Doctor: configuration has issues.`
- Diff line: `Added provider: <id>` / `Removed provider: <id>` / `Provider '<id>' model count: <n> -> <n>` / `Added mcp server: <name>` / `Removed mcp server: <name>` / `Added plugin: <id>` / `Removed plugin: <id>`
- No diff: `No changes detected vs previous backup.` / `No prior backup artifact found: no diff to report.`
- Success: `[+] Builder V2.7 finished successfully.`

PowerShell 5.1 has no `Test-Json -Schema`, so the validator runs inside the builder.

---

## V2.7 Supported JSON Schema Subset

The builder implements a compact JSON Schema validator (PowerShell 5.1 has no `Test-Json -Schema`).

Supported:

- `type` — string / number / object / array / boolean / null
- `required`
- `properties`
- `additionalProperties: false`
- `items`
- `enum`
- `$ref` — local same-file only, e.g. `#/definitions`

`$schema` is informational only; no `additionalProperties` enforcement is applied unless `additionalProperties: false` is present and no `$schema`-driven enforcement exists.

`$schema` is not enforced.

Validation is implemented inside the builder.

---

# Builder Status

Current Builder

Version

```
V2.7
```

Script

```
build-opencode-v2.7.ps1
```

Status

```
Stable
```

Previous Version

```
V2.5 (build-opencode-v2.5.ps1)
```

Previous

was V2.1 (build-opencode-v2.ps1).

Immersion builder is archived under the version here:

Prior builders remain documented for historical regeneration:

```
V2.5 (build-opencode-v2.5.ps1)   documented above
V2.1 (build-opencode-v2.ps1)    documented in the pipeline section
```

Future versions of the builder will update this document after implementation.

---

**Document Version:** 1.0

**Status:** Current Builder Specification