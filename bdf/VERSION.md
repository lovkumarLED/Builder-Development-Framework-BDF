# Framework Version

> Versioning and compatibility of the Builder Development Framework.

---

# Purpose

The Builder Development Framework is versioned independently from any builder project.

This document records the current framework version, its compatibility, and its evolution history.

Every change to the framework must be recorded here.

---

# Current Version

Version

```
2.0.0
```

Status

```
Active
```

---

# Compatibility

| Item | Value |
|------|-------|
| Framework Version | 2.0.0 |
| Supported Builder Versions | V2.1 |
| Compatible Projects | OpenCode Configuration Manager documentation |
| Last Updated | 2026-08-04 |
| Breaking Changes | Yes — framework renamed from Blueprint Framework |
| Migration Required | Yes — see `MIGRATION.md` |

---

# Compatibility Notes

## Supported Builder Versions

The framework describes the builder architecture (load, validate, backup, merge, generate).

Framework 2.0.0 supports the Builder V2 and Builder V2.1 architectures.

Builder V2.1 extends V2 with the same architectural shape:

- Extended validation (duplicate and malformed definition detection).
- Modular merge pipeline.
- Provider-specific models.
- Pre-write output verification.
- Automated testing.

The project's release manager (`release-manager.ps1`) supports the registry workflow: release facts are recorded once in `release_registry.json`, and the changelog, quick reference, compatibility rows, and project state version history are generated from it. The generated table rows in this document are never edited manually.

Future builder architecture versions will be listed here when they are documented.

## Compatible Projects

Projects that use this framework version.

The OpenCode Configuration Manager is the first project built using the framework.

---

# Versioning Policy

Framework evolution is tracked independently from builder evolution.

Major Version

```
Changes that break the structure or process of existing projects.
```

Minor Version

```
Additive changes. New templates, new workflow stages, new concepts.
```

Patch Version

```
Fixes and clarifications. No structural change.
```

Example

```
1.0.0

1.1.0

2.0.0
```

---

# Change History

## Version 2.0.0

Date

```
2026-08-03
```

Status

```
Current
```

Summary

```
Renamed the framework to Builder Development Framework (BDF) and added the intelligence layer.
```

Added

- `BLUEPRINT_ENGINE.md` — the intelligence layer and change pipeline.
- `PROJECT_ADAPTER.md` — project-specific adapter concept.
- `BUILDER_EVOLUTION.md` — predictable builder evolution workflow.
- `FRAMEWORK_LIFECYCLE.md` — master lifecycle reference.
- `AI_WORKFLOW.md` — the master AI agent workflow.
- `templates/ADAPTER.template.md` — project adapter template.
- The four framework questions.

Changed

- Framework renamed from Blueprint Framework to Builder Development Framework (BDF).
- Framework folder renamed from `blueprint/` to `bdf/`.
- `FRAMEWORK.md` updated to reference the new components.
- `PROJECT_GENERATOR.md` now requires a project adapter stage.
- Templates reference the framework instead of OpenCode.

Breaking Changes

```
Yes
```

Migration Required

```
Yes
```

---

## Version 1.1.0

Date

```
2026-08-03
```

Status

```
Previous
```

Summary

```
Added the PROJECT_STATE template.
```

Added

- `PROJECT_STATE.template.md` generic template.
- Project state regeneration rules for builder projects.

Breaking Changes

```
None
```

Migration Required

```
No
```

---

## Version 1.0.0

Date

```
2026-08-03
```

Status

```
Previous
```

Summary

```
Initial release of the Blueprint Framework.
```

Added

- Framework process documentation.
- Project generation workflow.
- Migration guide.
- Reusable documentation templates.
- Reusable lessons document.
- Independent framework versioning.

Breaking Changes

```
None
```

Migration Required

```
No
```

---

# Version History

| Version | Status | Description |
|----------|--------|-------------|
| 2.0.0 | Current | Builder Development Framework rename + intelligence layer |
| 1.1.0 | Previous | PROJECT_STATE template added |
| 1.0.0 | Previous | Initial Blueprint Framework release |

---

# Evolution Rules

Every change to the framework must:

- Update this document.
- Update the change history.
- Follow the versioning policy.

When the framework changes:

1. Existing projects do not need to change unless a breaking change is declared.
2. Breaking changes require a major version bump.
3. Migration guidance is added to the migration guide.

---

**Document Version:** 1.1

**Status:** Active Framework Version
