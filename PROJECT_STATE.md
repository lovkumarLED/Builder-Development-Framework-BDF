# PROJECT STATE

> Living snapshot of the OpenCode Configuration Manager.

> Regenerated after every major refactor.

---

# 1. Executive Summary

The OpenCode Configuration Manager is a modular configuration generation system.

Its purpose is to generate a valid `opencode.json` from a set of smaller configuration files.

The project separates:

- Source configuration
- Builder implementation
- Generated configuration
- Documentation

The documentation is organized into two layers.

Layer 1: the Builder Development Framework (BDF), reusable engineering knowledge shared by every builder project.

Layer 2: the OpenCode-specific project documentation.

The project-specific facts are defined in the project adapter:

```
ADAPTER.md
```

This document is the living state snapshot of the repository.

It is regenerated after every major refactor.

---

# 2. Current Version

Version

```
2.3.0
```

Status

```
Framework Generalization
```

## Version History
<!-- AUTO-GENERATED START -->
| Version | Status | Description |
|----------|--------|-------------|
| 2.4.0 | Current | Builder V2.5 Active-Provider Selector: discovers all providers, interactive active-provider selection persisted to settings.json, profile-level <provider>-models.json with highest precedence. |
| 2.3.0 | Previous | BDF V2.5 framework generalization: generalized the framework for reuse across OpenCode, Claude Code, and KiloCode targets. |
| 2.2.0 | Previous | Builder V2.1: extended validation, modular merge pipeline, provider-specific models, output verification, and automated testing. |
<!-- AUTO-GENERATED END -->

---

# 3. Current Folder Structure

```
.config/
└── opencode/
```

The `opencode` directory is the root of the entire project.

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

## docs/

Contains all project documentation.

```
docs/

├── _agent/
│   ├── SESSION_LOG.md
│   ├── SESSION_WORKFLOW.md
│   └── JOURNEY_TO_V3.md
├── AI/
│   ├── BUILD_BLUEPRINT_FRAMEWORK.md
│   ├── BUILD_BUILDER_V2.1.md
│   ├── BUILD_BUILDER_V2.5.md
│   ├── BUILD_RELEASE_MANAGER.md
│   ├── CONTINUE_PROJECT_BUILD.md
│   ├── CONTINUE_RELEASE_MANAGER.md
│   ├── DISTRIBUTE_SUBAGENTS.md
│   ├── PLAN_RELEASE_MANAGER.md
│   ├── START_TASK.md
│   └── UPGRADE_BLUEPRINT_FRAMEWORK.md
├── planning/
│   ├── BDF_ROAD_TO_V3.md
│   ├── DECISIONS.md
│   ├── FUTURE_IDEAS.md
│   └── VERSION_STRATEGY.md
├── bdf/
│   ├── AI_WORKFLOW.md
│   ├── BLUEPRINT_ENGINE.md
│   ├── BUILDER_EVOLUTION.md
│   ├── BUILDER_PHASES.md
│   ├── FRAMEWORK.md
│   ├── FRAMEWORK_LIFECYCLE.md
│   ├── LESSONS_LEARNED.md
│   ├── MIGRATION.md
│   ├── NEW_PROJECT_GUIDE.md
│   ├── PROJECT_ADAPTER.md
│   ├── PROJECT_GENERATOR.md
│   ├── README.md
│   ├── RELEASE_MANAGER.md
│   ├── TESTING.md
│   ├── VERSION.md
│   └── templates/
│       ├── README.md
│       └── *.template.md
├── ADAPTER.md
├── AGENT.md
├── ARCHITECTURE.md
├── BUILDER_SPEC.md
├── CHANGELOG.md
├── CONTRIBUTING_FOR_AI.md
├── CURRENT_RELEASE.md
├── DESIGN_PRINCIPLES.md
├── FOLDER_STRUCTURE.md
├── JSON_SCHEMAS.md
├── PROJECT_STATE.md
├── README.md
├── release_registry.json
├── ROADMAP.md
├── TESTING.md
└── TROUBLESHOOTING.md
```

## Purpose of Each Folder

| Folder | Purpose |
|--------|---------|
| `backup/` | Automatic configuration backups |
| `profiles/` | Profile-specific configuration |
| `providers/` | Provider definitions |
| `schemas/` | Reserved for future JSON Schema validation |
| `scripts/` | Builder scripts |
| `docs/` | Project documentation |
| `docs/_agent/` | Session continuity + journey tracker |
| `docs/AI/` | AI task documents (including build-continuation rule) |
| `docs/planning/` | Long-term planning and vision (road to V3) |
| `docs/bdf/` | Reusable Builder Development Framework |

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
| Profile | Defines user configuration |
| Provider | Defines API connection |
| Builder | Merges configuration |
| Backup | Preserves previous configuration |
| OpenCode | Uses generated configuration |

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

opencode.json

↓

OpenCode
```

## Source of Truth

Editable source files:

- Provider definitions
- Profile configuration
- Documentation
- Builder scripts

Generated output:

- `opencode.json`

Generated files are never edited manually.

---

# 5. Builder Development Framework

Generic engineering knowledge shared by every builder project.

Lives in:

```
bdf/
```

## Contents

| Document | Purpose |
|----------|---------|
| `FRAMEWORK.md` | The complete engineering process |
| `BLUEPRINT_ENGINE.md` | The intelligence layer |
| `PROJECT_ADAPTER.md` | Making the framework project-specific |
| `BUILDER_EVOLUTION.md` | Creating future builder versions |
| `BUILDER_PHASES.md` | The Alpha → Beta → General Release quality gates every builder build must pass |
| `FRAMEWORK_LIFECYCLE.md` | The master lifecycle reference |
| `AI_WORKFLOW.md` | The AI agent workflow |
| `VERSION.md` | Framework versioning |
| `MIGRATION.md` | Adopting the framework in an existing project |
| `PROJECT_GENERATOR.md` | Creating a new builder project |
| `NEW_PROJECT_GUIDE.md` | Onboarding process for starting a new project |
| `RELEASE_MANAGER.md` | The generic release process |
| `TESTING.md` | The generic test-harness pattern |
| `LESSONS_LEARNED.md` | Reusable engineering lessons |
| `templates/` | Reusable documentation templates |

The framework contains no project-specific knowledge.

Project names appear only as examples.

The OpenCode Configuration Manager is the first project built using the framework.

The project adapter defines the project-specific facts:

```
ADAPTER.md
```

---

# 6. OpenCode Builder

The project-specific implementation.

## profiles/

Contains profile-specific configuration.

The builder selects the profile at invocation time.

```
profiles/

default/

coding/

experimental/

minimal/
```

The `default` profile is fully configured.

```
default/

settings.json

models.json

plugins.json

mcp.json
```

Additional profiles contain only `settings.json` and contribute their provider selection to the build.

## providers/

Contains provider definitions.

```
providers/

omniroute.json
```

The current implementation contains a single provider.

Each provider may optionally own provider-specific models:

```
providers/<provider>/models.json
```

These take precedence over inline provider models and the global profile models.

Profile-level provider models (`profiles/<profile>/<provider>-models.json`, V2.5) take precedence over the provider-folder file.

## scripts/

Contains automation scripts.

```
build-opencode-v2.5.ps1
```

The current builder (Builder V2.5, Active-Provider Selector): provider discovery, provider selection via prompt or `-Provider` argument, persisted `activeProviders`, profile-level `<provider>-models.json` precedence.

```
build-opencode-v2.ps1
```

The established builder (Builder V2.1, evolved in place from V2.0), retained alongside V2.5.

```
test-opencode-v2.5.ps1
```

The V2.5 test harness (12 tests), including the docs-spec sync test `Test-BuilderSpecCoversV25`.

```
test-opencode-v2.ps1
```

The automated test harness (17 tests: 9 builder + 8 Release Docs).

```
release-manager.ps1
```

The release manager: generates all release documentation from `release_registry.json`.

```
build-opencode.ps1
```

The legacy builder, retained for reference.

## backup/

Stores timestamped backups of the generated configuration.

Created automatically by the builder before each build.

## opencode.json

The generated configuration.

OpenCode reads this file during startup.

Never edited manually.

---

# 7. AI Workflow

AI agents are guided by `AGENT.md`.

Every agent reads `AGENT.md` first.

The master framework AI workflow is defined in:

```
bdf/AI_WORKFLOW.md
```

## Read Order

```
README.md

↓

PROJECT_STATE.md

↓

ADAPTER.md

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
- Read `_agent/JOURNEY_TO_V3.md` — current position on the road to V3.

At session end:

- Follow `_agent/SESSION_WORKFLOW.md`.
- Write the session summary to `_agent/SESSION_LOG.md`, including the `Journey:` line.
- Update the `Current Position` section of `_agent/JOURNEY_TO_V3.md`.

## Build Continuation

Large version builds that exceed the context budget stop at a clean checkpoint, write
`AI/CONTINUE_BUILD_<VERSION>_<STEP>.md`, and resume from it in the next session.
Rule: `AI/CONTINUE_PROJECT_BUILD.md`.

## Project State

After every major refactor:

- Regenerate `PROJECT_STATE.md`.
- Keep the 15-section structure.
- Never leave it stale.

## Release Workflow

Releases follow one workflow:

1. The AI records the release facts in `docs/release_registry.json`.
2. The user reviews the release facts.
3. Run `release-manager.ps1` — it generates CHANGELOG.md, CURRENT_RELEASE.md, bdf/VERSION.md, and this version history table.
4. Run the test harness (Release Docs group must pass).
5. Commit.

Generated release files are never edited manually.

The registry is the sequence authority.

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
| `CURRENT_RELEASE.md` | Quick reference for the current release (generated) |
| `PROJECT_STATE.md` | Living state snapshot |
| `ADAPTER.md` | Project-specific facts |
| `_agent/SESSION_WORKFLOW.md` | Session start, end, and log rules |
| `_agent/SESSION_LOG.md` | Session history |
| `_agent/JOURNEY_TO_V3.md` | Live tracker of progress toward BDF V3 |
| `planning/` | Long-term planning: BDF_ROAD_TO_V3, VERSION_STRATEGY, FUTURE_IDEAS, DECISIONS |
| `AI/CONTINUE_PROJECT_BUILD.md` | Build checkpoint + resume rule for large versions |
| `AI/` | AI task documents |
| `bdf/` | Reusable Builder Development Framework |

---

# 9. Template System

Reusable documentation templates live in:

```
bdf/templates/
```

Templates are generic.

They contain no project-specific knowledge.

Project-specific values appear only as placeholders.

Placeholders follow the convention defined in:

```
bdf/templates/README.md
```

Every template becomes one project document when a new builder project is created.

Current templates:

- `README.template.md`
- `AGENT.template.md`
- `ARCHITECTURE.template.md`
- `DESIGN_PRINCIPLES.template.md`
- `BUILDER_SPEC.template.md`
- `FOLDER_STRUCTURE.template.md`
- `JSON_SCHEMAS.template.md`
- `CONTRIBUTING_FOR_AI.template.md`
- `TESTING.template.md`
- `TROUBLESHOOTING.template.md`
- `ROADMAP.template.md`
- `CHANGELOG.template.md`
- `LESSONS_LEARNED.template.md`
- `PROJECT_STATE.template.md`
- `ADAPTER.template.md`

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

The release sequence is defined by `docs/release_registry.json` — the registry is the sequence authority.

All version documentation (CHANGELOG marker section, CURRENT_RELEASE.md, bdf/VERSION.md compatibility rows, this version history table) is generated from the registry by the release manager.

Future plans belong exclusively in `ROADMAP.md`.

## Framework Versioning

The Builder Development Framework is versioned independently.

Recorded in `bdf/VERSION.md`.

Current framework version:

```
2.1.0
```

---

# 11. Current Status

## Implemented

- Modular configuration architecture
- OmniRoute provider integration
- Profile-based configuration
- Multiple profiles (default, coding, experimental, minimal)
- Dynamic profile selection
- Dynamic provider loading
- Separate model management
- Separate plugin management
- Separate MCP management
- Automatic configuration generation
- Automatic backup creation
- Builder V2
- Builder V2.1 (extended validation, modular merge pipeline, provider-specific models, output verification)
- Builder V2.3 / BDF V2.5 (framework generalization: NEW_PROJECT_GUIDE, RELEASE_MANAGER, TESTING framework docs, adapter validation checklist, Impact Analysis record)
- Builder V2.5 (Active-Provider Selector: provider discovery, persisted activeProviders, profile-level `<provider>-models.json` precedence)
- Automated test harnesses (V2.1: 17 tests — 9 builder + 8 Release Docs; V2.5: 12 tests)
- Release Manager V1 (registry-driven release documentation)
- Documentation framework
- Builder Development Framework
- Blueprint Engine
- Project adapter
- Session continuity system
- Project state system

## Not Implemented

- Additional providers
- JSON Schema validation
- Extended CLI features

Planned features are documented only in `ROADMAP.md`.

---

# 12. Known Limitations

- One active profile at build time.
- One provider definition (dynamic loading supported).
- One generated configuration.
- One active builder.
- JSON Schema validation not implemented (duplicate and structure validation handled by the builder).
- Documentation expanded only after implementation.

These limitations simplify development and provide a stable foundation for future expansion.

---

# 13. Next Planned Work

## Immediate

- Commit the docs repository (BDF V2.5 changes, `bdf/` new + modified docs, `ADAPTER.md`, `_agent/`, `AI/`).

## Roadmap Phases

Phase 4 — Additional Providers

Phase 8 — Documentation Expansion

Phase 11 — Claude Code Builder V1 (next on the road to V3)

Phases 5, 6, and 7 (Validation Framework, Automated Testing, Builder Refactoring) were completed in Builder V2.1 (version 2.2.0).

Phase 10 (BDF V2.5: Framework Generalization) was completed in version 2.3.0.

All phases are planned only. They are documented exclusively in `ROADMAP.md`.

---

# 14. File Relationships

```
AGENT.md
|
|-- points to the read order documents
|-- points to bdf/FRAMEWORK.md
|-- points to ADAPTER.md
|-- points to _agent/ session files
|-- defines the project state rules

README.md
|
|-- overview of the project
|-- documents the two-layer architecture
|-- links every documentation file

ADAPTER.md
|
|-- defines every project-specific fact
|-- referenced by the framework components

ARCHITECTURE.md
|
|-- describes the build pipeline
|-- defines the source of truth

FOLDER_STRUCTURE.md
|
|-- describes every folder and file
|-- defines ownership

BUILDER_SPEC.md
|
|-- implements the builder specification

CHANGELOG.md
|
|-- records completed work

ROADMAP.md
|
|-- records planned work

bdf/
|
|-- generic engineering knowledge
|-- templates generate project documentation

_agent/
|
|-- session continuity files
|-- referenced by AGENT.md

PROJECT_STATE.md
|
|-- snapshot of all of the above
|-- regenerated after every major refactor
```

---

# 15. Important Engineering Decisions

1. Generated configuration is never edited manually.
2. Source configuration is always the source of truth.
3. Documentation First: documentation is part of the project.
4. Documentation is split into two layers: generic framework and project-specific docs.
5. Future features are documented only in `ROADMAP.md`.
6. The Builder Development Framework is versioned independently from the project.
7. Session continuity files externalize context across sessions.
8. `PROJECT_STATE.md` is regenerated after every major refactor to keep the repository state current.
9. A major refactor is any change that adds, removes, moves, or renames files, or changes architecture.
10. Consistency is more important than speed.

---

**Document Version:** 1.1

**Status:** Current Project State
