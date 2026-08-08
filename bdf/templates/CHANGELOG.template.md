# CHANGELOG Template

> Template: version history. Becomes `CHANGELOG.md`.

---

# CHANGELOG

> Chronological history of {{PROJECT_NAME}}.

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

# Release Manager Section

The current and previous entries are written by the release manager ({{RELEASE_MANAGER_SCRIPT}}) from the release registry ({{RELEASE_REGISTRY}}), between the special markers:

- `<!-- AUTO-GENERATED START -->` opens the generated section.
- `<!-- AUTO-GENERATED END -->` closes it.

Generated entries carry the modern subsections: Highlights, New Features, Improvements, Bug Fixes, Breaking Changes, Migration Required, Testing Summary, Known Issues, and Documentation.

The release manager never touches manual entries outside the markers.

---

<!-- AUTO-GENERATED START -->

# Version {{CURRENT_VERSION}}

## Status

Current

---

## Date

```
{{ENTRY_DATE}}
```

---

## Summary

{{VERSION_DESCRIPTION}}

---

## Highlights

- {{HIGHLIGHT_1}}
- {{HIGHLIGHT_2}}

---

## New Features

- {{NEW_FEATURE_1}}
- {{NEW_FEATURE_2}}

---

## Improvements

- {{IMPROVEMENT_1}}
- {{IMPROVEMENT_2}}

---

## Bug Fixes

- {{BUG_FIX_1}}

---

## Breaking Changes

{{BREAKING_CHANGES}}

---

## Migration Required

{{MIGRATION_REQUIRED}}

---

## Testing Summary

{{TESTING_SUMMARY}}

---

## Known Issues

{{KNOWN_ISSUES}}

---

## Documentation

{{DOC_STATUS}}

- {{DOC_UPDATED_1}}
- {{DOC_UPDATED_2}}

---

<!-- AUTO-GENERATED END -->

# Version 1.0.0

## Status

Legacy

## Date

```
{{ENTRY_DATE}}
```

## Summary

Initial implementation of {{PROJECT_NAME}}.

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
- AGENT.md
- ARCHITECTURE.md
- DESIGN_PRINCIPLES.md
- FOLDER_STRUCTURE.md
- JSON_SCHEMAS.md
- BUILDER_SPEC.md
- CONTRIBUTING_FOR_AI.md
- TESTING.md
- TROUBLESHOOTING.md
- ROADMAP.md
- CHANGELOG.md
- PROJECT_STATE.md
- ADAPTER.md
- LESSONS_LEARNED.md

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
| {{CURRENT_VERSION}} | Current | {{VERSION_DESCRIPTION}} |
| 1.0.0 | Legacy | Initial project implementation |

---

# Recording Future Changes

Every new version should include:

- Version number
- Date
- Summary
- Highlights
- New Features
- Improvements
- Bug Fixes
- Breaking Changes
- Migration Required
- Testing Summary
- Known Issues
- Documentation updates

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

**Document Version:** {{DOC_VERSION}}

**Status:** Active Changelog