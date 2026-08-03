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

Layer 1: the Blueprint Framework, reusable engineering knowledge shared by every builder project.

Layer 2: the OpenCode-specific project documentation.

This document is the living state snapshot of the repository.

It is regenerated after every major refactor.

---

# 2. Current Version

Version

```
2.0.3
```

Status

```
Stable Foundation
```

## Version History

| Version | Status | Description |
|----------|--------|-------------|
| 2.0.3 | Current | Project state system |
| 2.0.2 | Previous | Session continuity system |
| 2.0.1 | Previous | Blueprint Framework documentation architecture |
| 2.0.0 | Previous | Builder V2 implementation |
| 1.0.0 | Legacy | Initial project implementation |

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
├── scripts/
└── opencode.json
```

## docs/

Contains all project documentation.

```
docs/

├── _agent/
│   ├── SESSION_LOG.md
│   └── SESSION_WORKFLOW.md
├── AI/
│   ├── BUILD_BLUEPRINT_FRAMEWORK.md
│   └── START_TASK.md
├── blueprint/
│   ├── FRAMEWORK.md
│   ├── LESSONS_LEARNED.md
│   ├── MIGRATION.md
│   ├── PROJECT_GENERATOR.md
│   ├── README.md
│   ├── VERSION.md
│   └── templates/
│       ├── README.md
│       └── *.template.md
├── AGENT.md
├── ARCHITECTURE.md
├── BUILDER_SPEC.md
├── CHANGELOG.md
├── CONTRIBUTING_FOR_AI.md
├── DESIGN_PRINCIPLES.md
├── FOLDER_STRUCTURE.md
├── JSON_SCHEMAS.md
├── PROJECT_STATE.md
├── README.md
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
| `scripts/` | Builder scripts |
| `docs/` | Project documentation |
| `docs/_agent/` | Session continuity files |
| `docs/AI/` | AI task documents |
| `docs/blueprint/` | Reusable Blueprint Framework |

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

# 5. Blueprint Framework

Generic engineering knowledge shared by every builder project.

Lives in:

```
blueprint/
```

## Contents

| Document | Purpose |
|----------|---------|
| `FRAMEWORK.md` | The complete engineering process |
| `VERSION.md` | Blueprint versioning |
| `MIGRATION.md` | Adopting the framework in an existing project |
| `PROJECT_GENERATOR.md` | Creating a new builder project |
| `LESSONS_LEARNED.md` | Reusable engineering lessons |
| `templates/` | Reusable documentation templates |

The blueprint contains no project-specific knowledge.

Project names appear only as examples.

The OpenCode Configuration Manager is the first project built using the framework.

---

# 6. OpenCode Builder

The project-specific implementation.

## profiles/

Contains profile-specific configuration.

The builder selects the profile at invocation time.

```
profiles/

default/
```

The `default` profile is fully configured.

```
default/

settings.json

models.json

plugins.json

mcp.json
```

## providers/

Contains provider definitions.

```
providers/

omniroute.json
```

The current implementation contains a single provider.

## scripts/

Contains automation scripts.

```
build-opencode-v2.ps1
```

The current builder.

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

## Read Order

```
README.md

↓

PROJECT_STATE.md

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

At session end:

- Follow `_agent/SESSION_WORKFLOW.md`.
- Write the session summary to `_agent/SESSION_LOG.md`.

## Project State

After every major refactor:

- Regenerate `PROJECT_STATE.md`.
- Keep the 15-section structure.
- Never leave it stale.

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
| `PROJECT_STATE.md` | Living state snapshot |
| `_agent/SESSION_WORKFLOW.md` | Session start, end, and log rules |
| `_agent/SESSION_LOG.md` | Session history |
| `AI/` | AI task documents |
| `blueprint/` | Reusable Blueprint Framework |

---

# 9. Template System

Reusable documentation templates live in:

```
blueprint/templates/
```

Templates are generic.

They contain no project-specific knowledge.

Project-specific values appear only as placeholders.

```
{{PLACEHOLDER_NAME}}
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

Future plans belong exclusively in `ROADMAP.md`.

## Blueprint Versioning

The Blueprint Framework is versioned independently.

Recorded in `blueprint/VERSION.md`.

Current blueprint version:

```
1.1.0
```

---

# 11. Current Status

## Implemented

- Modular configuration architecture
- OmniRoute provider integration
- Profile-based configuration
- Dynamic profile selection
- Dynamic provider loading
- Separate model management
- Separate plugin management
- Separate MCP management
- Automatic configuration generation
- Automatic backup creation
- Builder V2
- Documentation framework
- Blueprint Framework
- Session continuity system
- Project state system

## Not Implemented

- Additional providers
- Advanced validation
- Extended CLI features
- Automated testing

Planned features are documented only in `ROADMAP.md`.

---

# 12. Known Limitations

- One active profile at build time.
- One provider definition (dynamic loading supported).
- One generated configuration.
- One active builder.
- Manual testing only.
- Documentation expanded only after implementation.

These limitations simplify development and provide a stable foundation for future expansion.

---

# 13. Next Planned Work

## Immediate

- Commit the docs repository (modified files, `blueprint/`, `_agent/`, `AI/`).

## Roadmap Phases

Phase 3 — Multiple Profiles

Phase 4 — Additional Providers

Phase 5 — Validation Framework

Phase 6 — Automated Testing

Phase 7 — Builder Refactoring

Phase 8 — Documentation Expansion

All phases are planned only. They are documented exclusively in `ROADMAP.md`.

---

# 14. File Relationships

```
AGENT.md
|
|-- points to the read order documents
|-- points to blueprint/FRAMEWORK.md
|-- points to _agent/ session files
|-- defines the project state rules

README.md
|
|-- overview of the project
|-- documents the two-layer architecture
|-- links every documentation file

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

blueprint/
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
4. Documentation is split into two layers: generic blueprint and project-specific docs.
5. Future features are documented only in `ROADMAP.md`.
6. The Blueprint Framework is versioned independently from the project.
7. Session continuity files externalize context across sessions.
8. `PROJECT_STATE.md` is regenerated after every major refactor to keep the repository state current.
9. A major refactor is any change that adds, removes, moves, or renames files, or changes architecture.
10. Consistency is more important than speed.

---

**Document Version:** 1.0

**Status:** Current Project State
