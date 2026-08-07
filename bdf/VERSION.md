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
2.2.1
```

Status

```
Active
```

---

# Compatibility

| Item | Value |
|------|-------|
| Framework Version | 2.2.1 |
| Supported Builder Versions | V2.7, V2.5, V2.3, V2.1 |
| Compatible Projects | OpenCode Configuration Manager documentation |
| Last Updated | 2026-08-06 |
| Breaking Changes | None |
| Migration Required | No |

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

Builder V2.7 extends the same architectural shape with:

- JSON Schema validation (F1) of config sources before builder validation.
- Pre-flight dependency check (F2) that aborts on any missing input.
- `-WhatIf` dry-run (F3).
- Backup retention pruning (F4).
- Provenance sidecar (F5).
- `-Doctor` read-only diagnostics (F6).
- Merge diff summary vs the previous backup (F7).

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

## Version 2.2.1

Date

```
2026-08-06
```

Status

```
Current
```

Summary

```
Full template-to-reference sync (Part 7 of the full-system check): all 15 template pairs now mirror the reference docs' V2.5/V2.7 structure; placeholder audit back to parity.
```

Changed

- `templates/BUILDER_SPEC.template.md` — Release Pipeline, Stage 7 Verification, Model Precedence, Builder V2.5 + V2.7 sections, current-builder status.
- `templates/ARCHITECTURE.template.md` — Release Pipeline, builder pipeline evolution, per-provider model files, provenance/retention concepts.
- `templates/FOLDER_STRUCTURE.template.md` — Root Directory, schemas/, mcp.json, `<provider>-models.json`, target.json, provenance sidecar; obsolete file entries removed.
- `templates/JSON_SCHEMAS.template.md` — mcp.json, per-provider models, target.json, builder-written files, schema table, validation subset.
- `templates/CHANGELOG.template.md` — modern entry subsections (Highlights, New Features, Improvements, Bug Fixes, Testing Summary, Known Issues, Docs Updated).
- `templates/ROADMAP.template.md` — Phases 9-13 incl. Framework Generalization, Active-Provider Selector, JSON Schema Validation, Claude Code/KiloCode builders, Destination BDF V3.
- `templates/TESTING.template.md` — V2.5 Active-Provider Selector and V2.7 JSON Schema Validation test groups.
- `templates/AGENT.template.md`, `templates/PROJECT_STATE.template.md` — Build Continuation + Release Workflow sections.
- `templates/README.template.md` — Documentation Architecture + Releases sections.
- `templates/LESSONS_LEARNED.template.md` — Lessons 11-12 added.
- `templates/README.md` — placeholder table extended 36 → 54 rows; audit clean (54 used = 54 rows).

Breaking Changes

```
None
```

Migration Required

```
No
```

---

## Version 2.2.0

Date

```
2026-08-06
```

Status

```
Previous
```

Summary

```
Registered Builder V2.7 (JSON Schema Validation) in the supported-builder list and the reference documentation.
```

Changed

- `VERSION.md` — compatibility table now lists V2.7 as a supported builder version.
- `ARCHITECTURE.md`, `BUILDER_SPEC.md`, `README.md`, `ADAPTER.md`, `FOLDER_STRUCTURE.md`, `JSON_SCHEMAS.md`, `TESTING.md` — Builder V2.7 (F1-F7, 9-stage pipeline) documented as the current builder.
- `templates/` — example placeholders updated to the current runner scripts where they name the builder.

Breaking Changes

```
None
```

Migration Required

```
No
```

---

## Version 2.1.1

Date

```
2026-08-05
```

Status

```
Current
```

Summary

```
Template sync: ADAPTER.template.md gained the three release fields the reference adapter already defined (Release Registry, Release Artifacts, Release Manager Entry Point).
```

Changed

- `templates/ADAPTER.template.md` — field table + sections now match the reference `ADAPTER.md` (single source of truth restored).
- `templates/README.md` — placeholder audit gained the three new tokens (`{{RELEASE_REGISTRY}}`, `{{RELEASE_ARTIFACTS}}`, `{{RELEASE_MANAGER_SCRIPT}}`).

Breaking Changes

```
None
```

Migration Required

```
No
```

---

## Version 2.1.0

Date

```
2026-08-04
```

Status

```
Previous
```

Summary

```
BDF V2.5 framework generalization: generalized the framework for reuse across targets.
```

Added

- `NEW_PROJECT_GUIDE.md` — the onboarding process for starting a new project.
- `RELEASE_MANAGER.md` — the generic release process.
- `TESTING.md` — the generic test-harness pattern.
- The adapter field table moved into `templates/ADAPTER.template.md` (single source of truth).
- The adapter validation checklist in `PROJECT_ADAPTER.md`.
- The Impact Analysis record in `BLUEPRINT_ENGINE.md`.
- The placeholder audit and cross-reference matrix in `templates/README.md`.

Changed

- `FRAMEWORK.md`, `bdf/README.md` registered the three new framework documents.
- `AI_WORKFLOW.md` and `PROJECT_GENERATOR.md` reference the new project guide.
- `MIGRATION.md` generalized an example and a layer description.
- Templates now state the sync rule (templates mirror the reference implementation).

Breaking Changes

```
None
```

Migration Required

```
No
```

---

## Version 2.0.0

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
| 2.2.1 | Current | Full template-to-reference sync (15 pairs, placeholder audit 54/54) |
| 2.2.0 | Previous | Builder V2.7 (JSON Schema Validation) registered |
| 2.1.1 | Previous | Template sync: ADAPTER template release fields |
| 2.1.0 | Previous | BDF V2.5 framework generalization |
| 2.0.0 | Previous | Builder Development Framework rename + intelligence layer |
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
