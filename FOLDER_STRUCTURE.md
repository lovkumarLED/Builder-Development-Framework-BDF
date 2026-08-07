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

├── agent/
├── backup/
├── docs/
├── node_modules/
├── profiles/
├── providers/
├── schemas/
├── scripts/
├── skills/
├── .gitignore
├── opencode.json
├── opencode.provenance.json
├── opencode.jsonc
├── package-lock.json
└── package.json
```

Each directory has a dedicated responsibility.

`node_modules/`, `package.json`, `package-lock.json`, and `.gitignore` belong to the npm tooling for the skills; they are not configuration sources.

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

CURRENT_RELEASE.md

PROJECT_STATE.md

release_registry.json

ADAPTER.md

AI/

planning/

_agent/

bdf/

.superpowers/
```

## _agent/

Contains the session continuity files and the journey tracker.

```
_agent/

JOURNEY_TO_V3.md

SESSION_LOG.md

SESSION_WORKFLOW.md
```

## .superpowers/

Contains the subagent-driven-development (SDD) ledger and per-session snapshots.

The SDD ledger lives in `.superpowers/sdd/` and records task briefs, reports, and reviews for large plan builds.

Per-session snapshots live in `.superpowers/snapshot-<SESSION N>/` and pin the builder-document set so a clean-room build can reproduce the exact feature set (see `AI/FULL_SYSTEM_CHECK.md` Part 5).

## planning/

Contains long-term planning and vision documents.

```
planning/

BDF_ROAD_TO_V3.md

DECISIONS.md

FUTURE_IDEAS.md

NEXT_PHASE_IMPLEMENTATION_PLAN.md

VERSION_STRATEGY.md
```

Defines the destination (BDF V3) and the version philosophy.

## bdf/

Contains the reusable Builder Development Framework.

Generic engineering knowledge shared by every builder project.

## bdf/templates/

Contains the reusable documentation templates.

Per `bdf/templates/README.md`, the templates sync mirrors of the core project documents: each template mirrors one reference document (ARCHITECTURE, FOLDER_STRUCTURE, JSON_SCHEMAS, TESTING, README, CHANGELOG, ROADMAP, AGENT, and the rest), and a template change is a framework change that re-checks every document that references it.

## ADAPTER.md

Contains the project-specific facts of this project.

Defines how the generic framework applies to this project.

## AI/

Contains AI task documents.

Includes the build-continuation rule:

```
AI/CONTINUE_PROJECT_BUILD.md
```

## PROJECT_STATE.md

Contains the living state snapshot of the repository.

Regenerated after every major refactor.

## CURRENT_RELEASE.md

Contains the generated quick reference for the current release.

Generated from the release registry by the release manager.

## release_registry.json

Contains the machine-readable release history.

The only hand-edited release artifact.

The AI records the release facts here after implementation and testing.

The user reviews the facts before the release manager runs.

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

The builder selects the profile at invocation time.

```
profiles/

default/

coding/

experimental/

minimal/
```

The `default` profile is the primary profile (settings, plugins, mcp, per-provider models). It currently exposes `omniroute` via `omniroute-models.json`. No provider files carry literal keys (P1 env-key policy; `{env:VAR}` placeholders only).

`coding/` is a fully developed secondary profile (settings, `<provider>-models.json`, plugins, mcp). `experimental/` and `minimal/` carry `settings.json`, a small `omniroute-models.json` (so the active-provider guard keeps omniroute), and a `target.json` each; they contribute their provider selection to the build.

---

## default/

Contains the active OpenCode configuration.

```
default/

settings.json

<provider>-models.json

plugins.json

mcp.json

target.json (optional)
```

---

### settings.json

Purpose:

General profile configuration.

Contains profile-level settings used by the builder.

The builder also writes the resolved `activeProviders` list back to this file after provider selection (backed up first).

---

### <provider>-models.json

Purpose:

Profile-level model definitions for a single provider.

The file name follows the pattern `<provider>-models.json` (for example `omniroute-models.json`), one file per active provider.

Carries the highest model-source precedence.

---

### plugins.json

Purpose:

Defines OpenCode plugins enabled for the profile.

---

### mcp.json

Purpose:

Defines MCP server configuration for the profile.

---

### target.json (optional, P2)

Purpose:

Names the generated target artifact for this profile (e.g. `opencode.json`).

Resolved during Stage 1 (Load Profile); missing or invalid file falls back to `opencode.json`.

Drives the output file, backup prefix (`<base>_*`), provenance sidecar (`<base>.provenance.json`), WhatIf names, and retention.

Validated against `schemas/targets.schema.json` when present.

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

The current implementation contains one provider.

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
- `apiKey` as `{env:OMNIROUTE_API_KEY_OPENCODE}` placeholder only (P1 policy)

Provider definitions are independent from profiles.

## Provider-specific models

Each provider may own provider-specific models:

```
providers/<provider>/models.json
```

When present, these take precedence over inline provider models and the global profile models.

## Managed By

Developer

## Manual Editing

Yes.

---

# schemas/

```
schemas/
```

## Purpose

Contains the live JSON Schema files used by Builder V2.7.

The goal of schemas is to ensure that configuration files follow the expected structure before the builder generates `opencode.json`.

The schemas are validated by the builder (F1) before its own validation stage: a missing `schemas/` directory produces a warning and the build continues (V2.5-era compatibility).

## Contents

```
schemas/

schema.json

settings.schema.json

provider.schema.json

models.schema.json

plugins.schema.json

mcp.schema.json

targets.schema.json

README.md
```

The seven schema files are the machine-readable definitions behind `JSON_SCHEMAS.md`:

- `schema.json` — root shape of the generated `opencode.json` (documentation only; not validated by the builder pipeline).
- `settings.schema.json` — validates `profiles/<profile>/settings.json`.
- `provider.schema.json` — validates `providers/<id>.json`.
- `models.schema.json` — covers both `models.json` and `<provider>-models.json` (profile-level per-provider model files).
- `plugins.schema.json` — validates `profiles/<profile>/plugins.json`.
- `mcp.schema.json` — validates `profiles/<profile>/mcp.json`.
- `targets.schema.json` — validates `profiles/<profile>/target.json` (target artifact, P2).

`README.md` describes the validation flow and the artifact list.

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

The primary script is the OpenCode configuration builder (Builder V2.7).

```
build-opencode-v2.7.ps1
```

Builder V2.5 is retained.

```
build-opencode-v2.5.ps1
```

Builder V2.1 is retained.

```
build-opencode-v2.ps1
```

The automated test harness verifies the builder and the release pipeline.

```
test-opencode-v2.7.ps1
```

The V2.5 test harness is retained.

```
test-opencode-v2.5.ps1
```

The V2.1 test harness is retained.

```
test-opencode-v2.ps1
```

The release manager generates all release documentation from the release registry.

```
release-manager.ps1
```

The previous builder is retained as a legacy script.

```
build-opencode.ps1
```

---

## build-opencode-v2.7.ps1

Purpose

Generates the final `opencode.json`.

Responsibilities

- Discover all providers from `providers/*.json`.
- Select the active providers (interactive menu / `-Provider` / `-NonInteractive`).
- Persist the selection back to `settings.json` (backed up first, `$schema` preserved, UTF-8 no-BOM, only when the list differs).
- Validate config sources against `schemas/*.schema.json` before builder validation (F1).
- Pre-flight dependency check: every input file must exist before any merge (F2).
- Support `-WhatIf` dry runs (validate + merge only, write nothing) (F3).
- Prune backups to the newest `-KeepBackups` per prefix (F4).
- Write provenance sidecar `opencode.provenance.json` (F5).
- Support `-Doctor` read-only diagnostics (F6).
- Print a merge diff summary vs the previous backup (F7).
- Load configuration files.
- Validate configuration (structure, duplicates, malformed definitions).
- Merge configuration in stages.
- Create backup.
- Verify generated configuration before writing.
- Generate output.

Supports

- Dynamic profile selection.
- Active-provider discovery and selection.
- Settings persistence.
- Optional profile sections.
- Provider-specific models with profile-level precedence.
- JSON Schema validation (seven live schemas under `schemas/`).
- Backup retention, provenance stamping, doctor / dry-run CLI.

Model-source precedence (highest first):

```
profiles/<profile>/<provider>-models.json
providers/<provider>/models.json
inline provider models
profiles/<profile>/models.json
```

---

## build-opencode-v2.5.ps1

Purpose

Generates the final `opencode.json`.

Responsibilities

- Discover all providers from `providers/*.json`.
- Select the active providers (interactive menu / `-Provider` / `-NonInteractive`).
- Persist the selection back to `settings.json` (backed up first, `$schema` preserved, UTF-8 no-BOM, only when the list differs).
- Load configuration files.
- Validate configuration (structure, duplicates, malformed definitions).
- Merge configuration in stages.
- Create backup.
- Verify generated configuration before writing.
- Generate output.

Supports

- Dynamic profile selection.
- Active-provider discovery and selection.
- Settings persistence.
- Optional profile sections.
- Provider-specific models with profile-level precedence.

Model-source precedence (highest first):

```
profiles/<profile>/<provider>-models.json
providers/<provider>/models.json
inline provider models
profiles/<profile>/models.json
```

---

## build-opencode-v2.ps1

Purpose

Generates the final `opencode.json`.

Responsibilities

- Load configuration files.
- Validate configuration (structure, duplicates, malformed definitions).
- Merge configuration in stages.
- Create backup.
- Verify generated configuration before writing.
- Generate output.

Supports

- Dynamic profile selection.
- Dynamic provider loading.
- Optional profile sections.
- Provider-specific models.

The builder never edits source configuration files.

---

## test-opencode-v2.7.ps1

Purpose

Automated verification of the V2.7 builder.

Responsibilities

- Build isolated temporary fixtures.
- Run the builder against each fixture.
- Assert expected success or failure.
- Verify JSON Schema validation (valid pass, missing required / wrong type / additionalProperties / provider violation / models violation fail).
- Verify the missing-schema-directory warning-and-continue path.
- Verify the pre-flight dependency check aborts on missing inputs.
- Verify `-WhatIf` writes nothing and exits 0.
- Verify `-Doctor` exits 0 clean / 1 on corrupt config.
- Verify `-KeepBackups` retention pruning.
- Verify the provenance sidecar (fields + output SHA-256).
- Verify the merge diff summary (Added/Removed lines, silent on identical).
- Verify existing V2.5 behavior still passes.
- Verify the P2 dynamic target artifact (target.json -> custom artifact + prefix + provenance).
- Verify the P1 gate (no literal API keys in generated output).
- Report pass/fail results.

Covers 30 tests.

---

## test-opencode-v2.5.ps1

Purpose

Automated verification of the V2.5 builder.

Responsibilities

- Build isolated temporary fixtures.
- Run the builder against each fixture.
- Assert expected success or failure.
- Verify active-provider discovery (all `providers/*.json`).
- Verify active-provider selection (interactive, `-Provider`, `-NonInteractive`).
- Verify settings.json persistence round-trip and backup creation.
- Verify model-source precedence (profile-level > provider folder > inline > global).
- Verify failure modes (empty selection, duplicate model keys, malformed providers).
- Report pass/fail results.

---

## test-opencode-v2.ps1

Purpose

Automated verification of the builder and the release pipeline.

Responsibilities

- Build isolated temporary fixtures.
- Run the builder against each fixture.
- Assert expected success or failure.
- Run the release manager against a temp copy of the docs.
- Assert registry, CHANGELOG, CURRENT_RELEASE, and VERSION.md consistency.
- Report pass/fail results.

Covers 17 tests: 9 builder tests (including failure modes and backup safety) plus 8 Release Docs tests (registry shape, generated outputs, determinism, CURRENT_RELEASE match, registry/CHANGELOG consistency, VERSION.md rows, missing-marker abort, read-only real-docs check).

Test 17 is the only test that reads the real docs, and it is strictly read-only.

---

## release-manager.ps1

Purpose

Generates all release documentation from the release registry.

Responsibilities

- Read and validate `release_registry.json`.
- Generate the CHANGELOG marker section.
- Generate `CURRENT_RELEASE.md`.
- Update the `bdf/VERSION.md` compatibility rows.
- Update the `PROJECT_STATE.md` version history table.
- Verify generated output before writing (all-or-nothing).

The release manager never touches manual prose outside the markers.

Generated release files are never edited manually.

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

# opencode.provenance.json

```
opencode.provenance.json
```

## Purpose

Generated provenance sidecar for the configuration build.

Written by Builder V2.7 (F5) to the root of the configuration directory, next to `opencode.json`.

Contains:

- builder version
- profile
- active providers
- generated timestamp (UTC)
- SHA-256 of the generated `opencode.json` content

The provenance is written **never into `opencode.json`**: the sidecar keeps the generated configuration consumer-schema safe.

## Managed By

Builder

## Manual Editing

Not required.

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
| schemas | Developer |
| scripts | Developer |
| opencode.json | Builder |

---

# Editing Rules

## Edit Manually

- docs/
- profiles/
- providers/
- schemas/
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
- schemas/
- scripts/
- opencode.json

## Planned

Additional directories will only be documented after they are implemented.

Future project ideas are documented exclusively in `ROADMAP.md`.

---

**Document Version:** 1.2

**Status:** Current Project Structure