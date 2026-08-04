# Blueprint Engine

> The intelligence layer of the Builder Development Framework.

---

# Purpose

The Blueprint Engine is the decision-making layer of the Builder Development Framework.

It defines:

- How builders evolve.
- What happens when a feature changes.
- Which documentation must be updated.
- Which templates must be updated.
- Which version files must be updated.

The engine prevents AI agents from updating only the implementation while forgetting the documentation, templates, tests, and version records.

The engine answers the question:

> What must change, and in what order, when something changes?

---

# What the Engine Is

The Blueprint Engine is not code.

It is a decision procedure expressed in documentation.

Every builder change passes through the engine before any file is modified.

The engine guarantees that:

- Every affected document is updated.
- Every affected template is updated.
- Every affected version file is updated.
- No change reaches release with missing impact analysis.

---

# The Change Pipeline

Every feature request follows the same pipeline.

```
Feature Request

↓

Impact Analysis

↓

Architecture Update

↓

Documentation Update

↓

Template Update

↓

Builder Update

↓

Testing Update

↓

Version Update

↓

Release
```

No stage may be skipped.

A feature is not complete when the builder works.

It is complete when every stage of the pipeline is finished.

---

# Stage Definitions

## Feature Request

The input. Describes what the builder should do differently.

The request may come from a human or from a future AI agent.

The request describes the desired behavior, not the implementation.

---

## Impact Analysis

The engine determines what the request affects.

For every request, the engine identifies:

- Which builder stages change.
- Which documentation describes those stages.
- Which templates generate that documentation.
- Which tests verify that behavior.
- Which version files record the change.

Impact analysis happens before any file is modified.

---

## Architecture Update

If the change alters how components connect, the architecture documents change first.

Architecture changes are documented before implementation.

---

## Documentation Update

Every document that describes the changed behavior is updated.

Documentation is updated in the same change as the implementation.

A change that ships documentation and implementation together is a single, complete change.

---

## Template Update

If the change introduces a reusable pattern, the relevant template is updated.

Template changes are framework changes.

They are recorded in the framework version history.

---

## Builder Update

The implementation changes.

The builder is modified only after the impact is understood and the documentation plan exists.

---

## Testing Update

Tests are updated to verify the new behavior.

Existing tests are re-run to verify nothing broke.

---

## Version Update

The project version changes according to the versioning policy.

If the framework itself changed, the framework version changes too.

---

## Release

The change is released only after every previous stage is complete.

A release consists of:

- Implementation.
- Documentation.
- Templates (when affected).
- Tests.
- Version records.
- Migration notes (when required).

---

# Change Types

The engine classifies every change into one type.

| Change Type | Description | Required Updates |
|-------------|-------------|------------------|
| Feature Addition | New behavior in the builder. | Documentation, builder, tests, version. |
| Behavior Change | Existing behavior is modified. | Documentation, builder, tests, migration notes, version. |
| Bug Fix | Behavior is corrected. | Builder, tests, changelog. |
| Documentation Fix | Documentation is corrected. | Documentation only. |
| Template Change | A template is improved. | Template, framework version, affected projects. |
| Process Change | The framework process changes. | Framework documentation, framework version, migration notes. |
| Project Creation | A new builder project starts. | Project adapter, project documents, project version. |
| Project Archive | A project reaches end of life. | Lifecycle record, project status. |

Each change type defines the minimum set of updates.

The engine requires at least that set.

---

# Impact Analysis Rules

## Rule 1 — Analyze Before Modifying

No file is modified before the impact analysis is written.

The impact analysis states what changes and why.

---

## Rule 2 — Follow the Documentation

The documentation is the authority on what the change affects.

The engine reads the affected documents before the implementation.

---

## Rule 3 — Update Every Affected Layer

A change affects at least one of:

- Documentation.
- Templates.
- Builder.
- Tests.
- Version files.

An update that touches only one layer is incomplete.

---

## Rule 4 — No Code-Only Changes

A code-only change is a defect in process, not a feature.

Every implementation change ships with its documentation and test updates.

---

## Rule 5 — Record the Result

After the change, the version files record:

- What changed.
- Which documentation changed.
- Which templates changed.
- Which migration notes are required.

---

# Engine Inputs

The engine consumes four inputs.

| Input | Source | Purpose |
|-------|--------|---------|
| Current Builder | The existing project implementation. | Defines what exists today. |
| Requested Improvements | The feature request. | Defines what should change. |
| Project Adapter | `ADAPTER.md` of the project. | Defines the project-specific details. |
| Current Version | The version file of the project. | Defines where evolution continues. |

With these four inputs the engine can determine the remaining work.

The user only describes the requested improvements.

The engine determines the rest.

---

# Engine Outputs

The engine produces:

| Output | Purpose |
|--------|---------|
| Impact Analysis | What changes and why. |
| Architecture Changes | How components connect after the change. |
| Documentation Changes | Which documents are updated. |
| Template Changes | Which templates are updated. |
| Builder Changes | What the implementation does differently. |
| Testing Changes | Which tests are added or modified. |
| Version Update | The new project version. |
| Migration Notes | What existing users must do. |

A change that produces all eight outputs is complete.

---

# Preventing Incomplete Changes

The engine uses the following guard.

```
Is the request a code-only change?

No  → Continue.
Yes → Stop. Documentation, templates, tests, and version must be included.
```

An agent that cannot identify the affected documentation must ask before proceeding.

---

# Relationship to the Framework

The Blueprint Engine works with the other framework components.

| Component | Relationship |
|-----------|--------------|
| `FRAMEWORK.md` | The engine applies the process defined here. |
| `PROJECT_ADAPTER.md` | The engine reads the project adapter for project-specific details. |
| `BUILDER_EVOLUTION.md` | The engine drives the evolution workflow. |
| `FRAMEWORK_LIFECYCLE.md` | The engine tracks which lifecycle stage a project is in. |
| `AI_WORKFLOW.md` | The engine defines the impact-analysis step of the AI workflow. |
| `VERSION.md` | The engine records framework changes here. |
| `templates/` | The engine updates templates when a change is reusable. |

---

# Engine Guarantees

When the engine is followed, the framework guarantees:

- Documentation never falls behind implementation.
- Templates stay aligned with the process.
- Tests cover changed behavior.
- Versions reflect actual change.
- Future agents can understand any past change.
- No change is released without a complete impact analysis.

---

**Document Version:** 1.0

**Status:** Active Blueprint Engine
