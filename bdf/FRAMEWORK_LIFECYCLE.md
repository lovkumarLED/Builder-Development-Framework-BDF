# Framework Lifecycle

> The master lifecycle reference for every builder project.

---

# Purpose

This document describes the complete lifecycle of every builder project.

From the first idea to the final archive.

It is the master lifecycle reference.

Every stage of every project maps onto this lifecycle.

---

# Lifecycle Overview

```
Idea

↓

Blueprint

↓

Builder

↓

Testing

↓

Release

↓

Maintenance

↓

Next Version

↓

Archive
```

The order is fixed.

A project may stop at any stage.

A project never skips a stage.

---

# Stage 1 — Idea

## Definition

The project exists as a concept.

## Decisions

- What configuration does the target application need?
- Where does the configuration come from?
- What is the generated configuration artifact?
- Who maintains the source configuration?

## Guidance

The idea is checked against the builder lifecycle defined in `FRAMEWORK.md`.

If the idea does not fit the lifecycle, the idea is reconsidered before any work begins.

## Exit Criteria

The idea fits the builder lifecycle.

---

# Stage 2 — Blueprint

## Definition

The project becomes a plan.

## Decisions

- Which project adapter is required.
- Which project documents are generated.
- Which templates are copied.
- Which schemas are defined.

## Guidance

The project generation workflow in `PROJECT_GENERATOR.md` guides this stage.

The project adapter in `PROJECT_ADAPTER.md` defines the project-specific details.

## Exit Criteria

Every project document exists.

Every placeholder is replaced.

---

# Stage 3 — Builder

## Definition

The implementation is created.

## Guidance

The builder follows the specification generated from `BUILDER_SPEC.template.md`.

The implementation follows the framework engineering principles.

## Exit Criteria

The builder performs the full pipeline:

```
Load → Validate → Backup → Merge → Generate
```

---

# Stage 4 — Testing

## Definition

The implementation is verified.

## Guidance

The testing guide generated from `TESTING.template.md` defines the procedure.

The build enters its Alpha Phase per `BUILDER_PHASES.md`: it runs end to end and known issues are recorded.

## Exit Criteria

All tests pass.

---

# Stage 5 — Release

## Definition

The project version is released.

## Guidance

The changelog records the release.

The roadmap removes completed work.

The build passes its Beta Phase (test suite green, migration notes written) and reaches General Release per `BUILDER_PHASES.md` — only then does it become the main builder.

## Exit Criteria

- All tests pass.
- Documentation describes the current implementation.
- Version records are current.
- The build reached General Release.

---

# Stage 6 — Maintenance

## Definition

The project is in active use.

Changes are small and controlled.

## Guidance

Every change follows the change pipeline in `BLUEPRINT_ENGINE.md`.

Documentation, tests, and version records are updated with every change.

## Exit Criteria

None. The project remains here until the next version or the archive.

---

# Stage 7 — Next Version

## Definition

The project evolves to a new version.

## Guidance

The evolution workflow in `BUILDER_EVOLUTION.md` guides this stage.

The user provides the requested improvements.

The framework determines the remaining work.

## Exit Criteria

The new version is released.

The project returns to Maintenance.

---

# Stage 8 — Archive

## Definition

The project reaches end of life.

## Decisions

- Is the project replaced by a new builder?
- Is the project obsolete?
- Is the project merged into another project?

## Guidance

Archiving is a deliberate decision, not a silent state.

## Archive Rules

- The final version is recorded.
- The final state is documented.
- The archive reason is recorded.
- The project remains readable.
- The project is removed from active development.

## Exit Criteria

The project is recorded as archived.

---

# Lifecycle and Framework Components

| Stage | Primary Component |
|-------|-------------------|
| Idea | `PROJECT_GENERATOR.md` |
| Blueprint | `PROJECT_GENERATOR.md`, `PROJECT_ADAPTER.md` |
| Builder | `FRAMEWORK.md` |
| Testing | Templates, `FRAMEWORK.md`, `BUILDER_PHASES.md` (Alpha) |
| Release | Version system, `BUILDER_PHASES.md` (Beta → General Release) |
| Maintenance | `BLUEPRINT_ENGINE.md` |
| Next Version | `BUILDER_EVOLUTION.md` |
| Archive | This document |

---

# Lifecycle Rules

1. No stage is skipped.
2. Every stage has an exit criterion.
3. A project cannot return to a previous stage without justification.
4. An archived project is never reactivated without a new idea stage.
5. The lifecycle applies to every builder project regardless of application.

---

# Lifecycle States

A project is always in exactly one state.

| State | Meaning |
|-------|---------|
| Idea | Concept only. |
| Blueprint | Planning. |
| Building | Implementation in progress. |
| Testing | Verification in progress. |
| Released | Current version released. |
| Maintained | Active use, small changes. |
| Evolving | Next version in progress. |
| Archived | End of life. |

The current state of a project is recorded in its project state document.

---

# Questions the Lifecycle Answers

- Where is this project?
- What stage comes next?
- What is the exit criterion for the current stage?
- What happens when a project ends?

---

**Document Version:** 1.0

**Status:** Active Framework Lifecycle
