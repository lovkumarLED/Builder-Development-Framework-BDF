# Builder Evolution

> How future builder versions are created.

---

# Purpose

This document describes how future builder versions are created.

Builder evolution is predictable.

Creating Builder V2.2 means updating the entire ecosystem, not only modifying the builder script.

The user describes the requested improvements.

The framework determines the remaining work.

---

# Evolution Principles

1. Evolution is a full-system change, not a script change.
2. Every version updates documentation, templates, tests, and version records.
3. Migration notes are written for every behavior change.
4. The current builder remains the starting point.
5. No stage may be skipped.
6. The order of stages is fixed.

---

# Evolution Workflow

Every builder version follows the same workflow.

```
Current Builder

↓

Requested Features

↓

Impact Analysis

↓

Architecture Changes

↓

Documentation Changes

↓

Template Changes

↓

Builder Changes

↓

Testing Changes

↓

Migration Notes

↓

Version Release
```

No stage may be skipped.

---

# Stage Definitions

## Current Builder

The existing implementation and documentation.

The starting point of every evolution.

## Requested Features

The improvements the user wants.

The user describes the desired behavior only.

## Impact Analysis

The framework determines:

- Which builder stages change.
- Which documentation changes.
- Which templates change.
- Which tests change.
- Which migration notes are required.

Impact analysis is performed by the Blueprint Engine.

## Architecture Changes

Changes to how components connect.

Architecture changes are documented before implementation.

## Documentation Changes

Every affected project document is updated.

Documentation ships with the implementation in the same change.

## Template Changes

Every affected template is updated.

A template change is a framework change.

## Builder Changes

The implementation changes.

The builder is modified after the architecture and documentation plan exist.

## Testing Changes

Tests are added or modified to cover the new behavior.

Existing tests are re-run.

## Migration Notes

Instructions for existing users.

Migration notes explain:

- What changed.
- What must be done.
- What is no longer supported.

## Version Release

The version is released only after every previous stage is complete.

Releases are produced by the project's release manager from a release registry, so version documentation is generated instead of hand-written.

---

# Inputs and Outputs

## Inputs

| Input | Source |
|-------|--------|
| Current Builder | The existing project. |
| Requested Improvements | The user. |

## Outputs

| Output | Destination |
|--------|-------------|
| Architecture Changes | Architecture documentation. |
| Documentation Changes | Project documentation. |
| Template Changes | Templates (when affected). |
| Builder Changes | The implementation. |
| Testing Changes | The test suite. |
| Version Update | The version file and changelog. |
| Migration Notes | The migration notes document. |
| Release | The released version. |

---

# Version Sequencing

Versions follow a fixed sequence.

```
Builder V2

↓

Builder V2.1

↓

Builder V2.2

↓

Builder V3
```

A new version is created from the current version, never from an older version.

```
Builder V2 + Improvements = Builder V2.1

Builder V2.1 + Improvements = Builder V2.2
```

---

# What the Framework Determines

The framework determines:

- What changed.
- Which documentation changes.
- Which templates change.
- Which migration notes are required.
- Which version number results.

The user determines only:

- The requested improvements.

---

# Evolution Rules

## Rule 1 — Never Skip the Ecosystem

A version that changes only the builder script is not a version.

It is an incomplete change.

## Rule 2 — Document Before Implementing

Documentation changes are planned before builder changes.

The implementation follows the documentation.

## Rule 3 — Migration Notes for Behavior Changes

Any change that alters existing behavior requires migration notes.

Additive features do not require migration notes.

## Rule 4 — Backward Compatibility

New versions preserve previously working functionality.

Breaking changes require a major version bump.

## Rule 5 — Tests Define Done

A version is complete when its tests pass and previous tests still pass.

## Rule 6 — Version Records Are Updated

The version file and the changelog record the new version.

The roadmap moves completed work to the changelog.

---

# Evolution and the Framework

| Component | Role in Evolution |
|-----------|-------------------|
| `BLUEPRINT_ENGINE.md` | Performs the impact analysis. |
| `FRAMEWORK.md` | Defines the engineering process. |
| `PROJECT_ADAPTER.md` | Provides project-specific facts. |
| `FRAMEWORK_LIFECYCLE.md` | Tracks the lifecycle stage. |
| `BUILDER_PHASES.md` | Defines the Alpha → Beta → General Release gates a build must pass before release. |
| `AI_WORKFLOW.md` | Guides the agent through the workflow. |
| `VERSION.md` | Records framework version changes. |
| `templates/` | Supplies updated templates. |

---

# Evolution Checklist

- [ ] Requested improvements recorded.
- [ ] Impact analysis completed.
- [ ] Architecture changes documented.
- [ ] Documentation updated.
- [ ] Templates updated (when affected).
- [ ] Builder updated.
- [ ] Tests updated and passing.
- [ ] Migration notes written (when required).
- [ ] Version records updated.
- [ ] Release generated.

---

**Document Version:** 1.0

**Status:** Active Builder Evolution
