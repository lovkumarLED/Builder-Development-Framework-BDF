# CHANGELOG

> Chronological history of the OpenCode Configuration Manager.

---

# Purpose

This document records the history of significant project changes.

Only completed work should appear in this document.

Future plans belong exclusively in:

```
ROADMAP.md
```

The changelog should provide enough information for a developer to understand how the project evolved over time.

---

# Versioning Policy

The project follows a simple versioning strategy.

Major Version

Large architectural changes.

Minor Version

New functionality.

Patch Version

Bug fixes and documentation improvements.

Example

```
1.0.0

1.1.0

1.1.1
```

---

<!-- AUTO-GENERATED START -->

# Version 2.3.0

## Status

Current

---

## Date

```
2026-08-04
```

---

## Summary

BDF V2.5 framework generalization: generalized the framework for reuse across OpenCode, Claude Code, and KiloCode targets.

---

## Highlights

- Framework generalization (first step to BDF V3)
- Single source of truth for adapter fields
- Testable adapter validation checklist
- Impact Analysis record for the Blueprint Engine
- Generic release process documented (RELEASE_MANAGER.md)
- Generic test-harness pattern documented (TESTING.md)

---

## New Features

- bdf/NEW_PROJECT_GUIDE.md - the onboarding process for starting a new project with the framework
- bdf/RELEASE_MANAGER.md - the generic release process document (registry, generator, generated documents)
- bdf/TESTING.md - the generic test-harness pattern document
- Adapter field table now lives only in templates/ADAPTER.template.md (single source of truth)
- Adapter validation checklist (executable yes/no criteria) in PROJECT_ADAPTER.md
- Impact Analysis record required output of the Blueprint Engine Impact Analysis stage

---

## Improvements

- Framework boundaries audited: OpenCode-specific file names removed from bdf/ (Layer 1 no longer depends on Layer 2)
- templates/README.md: placeholder audit ({{PLACEHOLDER_NAME}} row added), cross-reference matrix, provider placeholders confirmed generic, template sync rule stated
- FRAMEWORK.md and bdf/README.md register the three new framework documents
- Reference ADAPTER.md passes the new adapter validation checklist
- docs/TESTING.md aligned with bdf/TESTING.md (test groups + definition of complete)

---

## Bug Fixes

- Removed OpenCode-specific file names from bdf/MIGRATION.md and bdf/PROJECT_ADAPTER.md examples
- Generalized a Layer 2 description in bdf/MIGRATION.md from OpenCode-specific to project-specific

---

## Breaking Changes

None

---

## Migration Required

No

---

## Testing Summary

17/17 tests passed, exit code 0

---

## Known Issues

None

---

## Documentation

Updated

- bdf/NEW_PROJECT_GUIDE.md (new)
- bdf/RELEASE_MANAGER.md (new)
- bdf/TESTING.md (new)
- bdf/FRAMEWORK.md
- bdf/PROJECT_ADAPTER.md
- bdf/AI_WORKFLOW.md
- bdf/PROJECT_GENERATOR.md
- bdf/BLUEPRINT_ENGINE.md
- bdf/MIGRATION.md
- bdf/README.md
- bdf/VERSION.md
- bdf/templates/README.md
- bdf/templates/ADAPTER.template.md
- ADAPTER.md
- PROJECT_STATE.md
- ROADMAP.md
- TESTING.md
- CHANGELOG.md
- CURRENT_RELEASE.md
- _agent/JOURNEY_TO_V3.md

---

# Version 2.2.0

## Status

Previous

---

## Date

```
2026-08-04
```

---

## Summary

Builder V2.1: extended validation, modular merge pipeline, provider-specific models, output verification, and automated testing.

---

## Highlights

- Provider-specific models
- Modular merge pipeline
- Extended validation
- Pre-write output verification
- Automated test harness

---

## New Features

- scripts/test-opencode-v2.ps1 - automated test harness (17 tests: 9 builder + 8 Release Docs)
- Provider-specific models: providers/<provider>/models.json takes precedence over inline provider models and global models.json
- -ConfigRoot parameter on the builder for isolated test builds
- Output verification stage (JSON round-trip, providers, models, plugins, MCP) before writing

---

## Improvements

- Validation extended: duplicate provider/model/plugin/MCP identifiers, duplicate model names, malformed provider and profile definitions, missing required fields, invalid configuration structure
- Duplicate-key detection scans raw JSON text (PowerShell 5.1 ConvertFrom-Json silently drops duplicates)
- Merge logic split into independent stages: settings, providers, models, plugins, MCP, final
- Concise count-based logging (e.g. Provider 'omniroute': 58 model(s))

---

## Bug Fixes

- Fixed $Section: here-string parse errors
- Fixed unreliable PSObject.Properties.Count checks (wrapped with @())
- Fixed plugin single-element array unrolling in output (return ,$Plugins.plugin)
- Removed 2 corrupted backups created during intermediate buggy runs

---

## Breaking Changes

None

---

## Migration Required

No

---

## Testing Summary

17/17 tests passed, exit code 0

---

## Known Issues

None

---

## Documentation

Updated

- BUILDER_SPEC.md
- CHANGELOG.md
- PROJECT_STATE.md
- TESTING.md
- ROADMAP.md
- FOLDER_STRUCTURE.md
- ARCHITECTURE.md
- ADAPTER.md
- README.md
- bdf/VERSION.md
<!-- AUTO-GENERATED END -->

# Version 2.1.0

## Status

Previous

## Date

```
2026-08-03
```

## Summary

Documentation architecture: adopted the Builder Development Framework (BDF) upgrade.

---

## Added

- `bdf/BLUEPRINT_ENGINE.md` — the intelligence layer and change pipeline.
- `bdf/PROJECT_ADAPTER.md` — the project adapter concept.
- `bdf/BUILDER_EVOLUTION.md` — predictable builder evolution workflow.
- `bdf/FRAMEWORK_LIFECYCLE.md` — master lifecycle reference.
- `bdf/AI_WORKFLOW.md` — the master AI agent workflow.
- `bdf/templates/ADAPTER.template.md` — project adapter template.
- `ADAPTER.md` — the OpenCode project adapter (first implementation).

---

## Changed

- Framework renamed from Blueprint Framework to Builder Development Framework (BDF).
- Framework folder renamed from `blueprint/` to `bdf/`.
- `AGENT.md` read order now includes `ADAPTER.md`.
- `README.md`, `AGENT.md`, and `FOLDER_STRUCTURE.md` updated to reference `bdf/`.
- Framework version bumped to 2.0.0 (breaking change, migration in `bdf/MIGRATION.md`).

---

## Documentation

Updated

- README.md
- AGENT.md
- FOLDER_STRUCTURE.md
- CHANGELOG.md
- PROJECT_STATE.md
- bdf/README.md
- bdf/FRAMEWORK.md
- bdf/VERSION.md
- bdf/MIGRATION.md
- bdf/PROJECT_GENERATOR.md
- bdf/LESSONS_LEARNED.md
- bdf/templates/README.md
- bdf/templates/PROJECT_STATE.template.md

---

## Breaking Changes

None

---

# Version 2.0.3

## Status

Previous

## Date

```
2026-08-03
```

## Summary

Documentation infrastructure: added the project state system.

---

## Added

- `PROJECT_STATE.md` with the 15-section living state snapshot.
- `blueprint/templates/PROJECT_STATE.template.md` generic template.
- Project state section in AGENT.md.
- Project state regeneration rules.

---

## Changed

- AGENT.md now requires `PROJECT_STATE.md` regeneration after every major refactor.
- AGENT.md read order now includes `PROJECT_STATE.md`.
- `_agent/SESSION_WORKFLOW.md` now reads `PROJECT_STATE.md` at session start and regenerates it at session end after a major refactor.

---

## Documentation

Updated

- AGENT.md
- README.md
- FOLDER_STRUCTURE.md
- ROADMAP.md
- CHANGELOG.md
- _agent/SESSION_WORKFLOW.md
- blueprint/VERSION.md
- blueprint/templates/README.md

---

## Breaking Changes

None

---

# Version 2.0.2

## Status

Previous

## Date

```
2026-08-03
```

## Summary

Documentation infrastructure: added the session continuity system.

---

## Added

- `_agent/SESSION_WORKFLOW.md` with session start, end, and log rules.
- `_agent/SESSION_LOG.md` with the session history.
- Session continuity section in AGENT.md.

---

## Changed

- AGENT.md now guides agents to read session files at session start and write them at session end.

---

## Documentation

Updated

- AGENT.md
- FOLDER_STRUCTURE.md
- CHANGELOG.md

---

## Breaking Changes

None

---

# Version 2.0.1

## Status

Previous

## Date

```
2026-08-03
```

## Summary

Documentation architecture: added the reusable Blueprint Framework.

---

## Added

- `blueprint/` folder containing the reusable engineering process.
- Blueprint documentation templates.
- Blueprint versioning.
- Project generation workflow.
- Migration guide.
- Reusable lessons document.

---

## Changed

- README.md now describes the two-layer documentation architecture.
- AGENT.md points to the Blueprint Framework for generic engineering knowledge.
- FOLDER_STRUCTURE.md documents the `blueprint/` and `AI/` folders.

---

## Documentation

Updated

- README.md
- AGENT.md
- FOLDER_STRUCTURE.md
- CHANGELOG.md

---

## Breaking Changes

None

---

# Version 2.0.0

## Status

Previous

## Date

```
2026-08-03
```

## Summary

Builder V2 implementation.

---

## Added

- Dynamic profile selection.
- Dynamic provider loading.
- Optional profile sections.
- Improved validation.
- Better console output.
- Improved error reporting.

---

## Changed

- The current builder is now `build-opencode-v2.ps1`.
- The previous builder is retained as a legacy script.
- Models are injected into every active provider.
- Optional profile sections are merged only when present.

---

## Documentation

Updated

- BUILDER_SPEC.md
- ARCHITECTURE.md
- FOLDER_STRUCTURE.md
- TESTING.md
- ROADMAP.md
- CHANGELOG.md

---

## Breaking Changes

None

---

# Version 1.0.0

## Status

Legacy

## Summary

Initial implementation of the OpenCode Configuration Manager.

---

## Added

- Modular project structure.
- Provider configuration.
- Profile configuration.
- Builder implementation.
- Backup system.
- Documentation framework.

---

## Documentation

Created

- README.md
- ARCHITECTURE.md
- FOLDER_STRUCTURE.md
- JSON_SCHEMAS.md
- BUILDER_SPEC.md
- DESIGN_PRINCIPLES.md
- CONTRIBUTING_FOR_AI.md
- TESTING.md
- TROUBLESHOOTING.md
- CHANGELOG.md

---

## Architecture

Implemented

- Source configuration.
- Generated configuration.
- Configuration builder.
- Provider abstraction.
- Profile abstraction.

---

## Builder

Implemented

- Configuration loading.
- Validation.
- Configuration merging.
- Backup creation.
- Configuration generation.

---

## Testing

Implemented

- Manual testing guide.
- Verification procedures.
- Regression testing procedures.

---

## Known Limitations

Current implementation supports:

- One provider.
- One active profile.
- Manual testing.

Future enhancements will be tracked separately in

```
ROADMAP.md
```

---

# Version History

| Version | Status | Description |
|----------|--------|-------------|
| 2.3.0 | Current | BDF V2.5 framework generalization |
| 2.2.0 | Previous | Builder V2.1 (validation, merge pipeline, provider-specific models, verification, automated tests) |
| 2.1.0 | Previous | Builder Development Framework adoption |
| 2.0.3 | Previous | Project state system |
| 2.0.2 | Previous | Session continuity system |
| 2.0.1 | Previous | Blueprint Framework documentation architecture |
| 2.0.0 | Previous | Builder V2 implementation |
| 1.0.0 | Legacy | Initial project implementation |

---

# Recording Future Changes

Every new version should include:

- Version number
- Date
- Summary
- Added
- Changed
- Fixed
- Removed
- Documentation updates
- Breaking changes (if any)

---

# Example

## Version 1.1.0

Date

```
YYYY-MM-DD
```

### Added

- New feature

### Changed

- Existing behavior

### Fixed

- Bug fixes

### Removed

- Removed functionality

### Documentation

- Updated documentation

### Breaking Changes

None

---

# Guidelines

Do not record:

- Planned features.
- Experimental work.
- Incomplete implementations.

Only completed and verified changes should appear in this document.

---

**Document Version:** 1.0

**Status:** Active Changelog