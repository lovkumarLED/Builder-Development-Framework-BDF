# Blueprint Version

> Versioning and compatibility of the Blueprint Framework.

---

# Purpose

The Blueprint Framework is versioned independently from any builder project.

This document records the current blueprint version, its compatibility, and its evolution history.

Every change to the blueprint must be recorded here.

---

# Current Version

Version

```
1.1.0
```

Status

```
Active
```

---

# Compatibility

| Item | Value |
|------|-------|
| Blueprint Version | 1.1.0 |
| Supported Builder Versions | Builder V2 |
| Compatible Projects | OpenCode Configuration Manager documentation |
| Last Updated | 2026-08-03 |
| Breaking Changes | None |
| Migration Required | No |

---

# Compatibility Notes

## Supported Builder Versions

The blueprint describes the builder architecture (load, validate, backup, merge, generate).

Blueprint 1.0.0 supports the Builder V2 architecture.

Future builder architecture versions will be listed here when they are documented.

## Compatible Projects

Projects that use this blueprint version.

The OpenCode Configuration Manager is the first project built using the blueprint.

---

# Versioning Policy

Blueprint evolution is tracked independently from builder evolution.

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

1.1.1
```

---

# Change History

## Version 1.1.0

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
- Independent blueprint versioning.

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
| 1.1.0 | Current | PROJECT_STATE template added |
| 1.0.0 | Previous | Initial Blueprint Framework release |

---

# Evolution Rules

Every change to the blueprint must:

- Update this document.
- Update the change history.
- Follow the versioning policy.

When the blueprint changes:

1. Existing projects do not need to change unless a breaking change is declared.
2. Breaking changes require a major version bump.
3. Migration guidance is added to the migration guide.

---

**Document Version:** 1.0

**Status:** Active Blueprint Version
