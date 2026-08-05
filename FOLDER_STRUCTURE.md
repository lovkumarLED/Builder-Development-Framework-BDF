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

├── backup/
├── docs/
├── profiles/
├── providers/
├── schemas/
├── scripts/
└── opencode.json
```

Each directory has a dedicated responsibility.

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
```

## _agent/

Contains the session continuity files and the journey tracker.

```
_agent/

JOURNEY_TO_V3.md

SESSION_LOG.md

SESSION_WORKFLOW.md
```

## planning/

Contains long-term planning and vision documents.

```
planning/

BDF_ROAD_TO_V3.md

DECISIONS.md

FUTURE_IDEAS.md

VERSION_STRATEGY.md
```

Defines the destination (BDF V3) and the version philosophy.

## bdf/

Contains the reusable Builder Development Framework.

Generic engineering knowledge shared by every builder project.

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

The `default` profile is fully configured.

Additional profiles contain only `settings.json` and contribute their provider selection to the build.

---

## default/

Contains the active OpenCode configuration.

```
default/

settings.json

<provider>-models.json

models.json

plugins.json

mcp.json
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

### models.json

Purpose:

Defines every AI model available inside the profile.

Responsible only for model configuration.

---

### plugins.json

Purpose:

Defines OpenCode plugins enabled for the profile.

---

### mcp.json

Purpose:

Defines MCP server configuration for the profile.

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

The current implementation contains a single provider.

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

Reserved for future JSON Schema validation of configuration files.

The goal of schemas is to ensure that configuration files follow the expected structure before the builder generates `opencode.json`.

At the current stage of the project (Builder V2.1), no JSON Schema validation has been implemented yet.

Validation is currently performed by PowerShell code inside the builder.

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

The primary script is the OpenCode configuration builder (Builder V2.5).

```
build-opencode-v2.5.ps1
```

Builder V2.1 is retained.

```
build-opencode-v2.ps1
```

The automated test harness verifies the builder and the release pipeline.

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