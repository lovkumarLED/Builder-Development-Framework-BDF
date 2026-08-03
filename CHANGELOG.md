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

# Version 2.0.3

## Status

Current

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

Current

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
| 2.0.3 | Current | Project state system |
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