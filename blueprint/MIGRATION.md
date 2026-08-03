# Migration Guide

> Adopting the Blueprint Framework in an existing project.

---

# Purpose

This document explains how an existing builder project adopts the Blueprint Framework.

It also explains how a project migrates between blueprint versions.

The goal is to adopt the framework without losing documentation and without breaking the working implementation.

---

# When To Migrate

Migrate when:

- The project already has documentation that mixes generic and project-specific knowledge.
- Future builders will reuse the same engineering process.
- The project documentation is difficult to copy to a new project.

Do not migrate when:

- The project has no documentation.
- The project is a prototype.
- The project is about to be replaced.

---

# Migration Rules

- Do not redesign the working implementation.
- Do not remove existing documentation.
- Refactor the documentation architecture only.
- Preserve backwards compatibility whenever possible.
- If moving files is required, explain why.

---

# Migration Workflow

## Stage 1 — Read the Framework

Read:

```
FRAMEWORK.md
```

Understand the two knowledge layers before changing anything.

---

## Stage 2 — Inventory Existing Documentation

List every documentation file.

For each file, classify its knowledge:

| Classification | Meaning |
|----------------|---------|
| Generic | Applies to every builder project. |
| Project-specific | Applies only to this project. |
| Mixed | Contains both. |

---

## Stage 3 — Separate the Layers

Move generic knowledge into blueprint documentation.

Keep project-specific knowledge in the project documentation.

For mixed documents:

- Keep the project-specific parts in the project document.
- Move the generic parts to the relevant blueprint document.
- Leave a reference in the project document pointing to the blueprint.

---

## Stage 4 — Replace Hardcoded Names

Replace project-specific names in reusable content with generic descriptions or placeholders.

Example

```
Before: The builder generates opencode.json.

After:  The builder generates the project's final configuration artifact.
```

Project documents later specify the concrete artifact.

---

## Stage 5 — Align Documents With Templates

Compare every project document with the corresponding template.

```
templates/
```

Bring the project documents in line with the template structure.

Keep the project-specific content.

---

## Stage 6 — Update Entry Points

Update the project entry documents:

- README: describe the two-layer documentation architecture.
- Agent entry: point to the blueprint for generic knowledge.

---

## Stage 7 — Update the Folder Structure Document

Add the blueprint folder to the project's folder structure documentation.

---

## Stage 8 — Verify Consistency

Check that:

- Every generic statement is project-neutral.
- Every project document still describes the current implementation.
- No documentation was removed.
- All cross-references are valid.

---

## Stage 9 — Record the Migration

Record the documentation architecture change in the project changelog.

---

# Migrating Between Blueprint Versions

When a new blueprint version is released:

1. Read the new version's breaking changes in `VERSION.md`.
2. Read the migration section of the updated documents.
3. Compare the changed templates with the project documents.
4. Apply the changes described.
5. Update the blueprint version reference used by the project.
6. Verify consistency.

If the new version declares no breaking changes, the migration is optional.

---

# Reference Migration

The OpenCode Configuration Manager was the first project to adopt the blueprint.

Its documentation was restructured into two layers:

```
Layer 1  blueprint/   Reusable engineering knowledge.
Layer 2  project docs OpenCode-specific documentation.
```

Existing project documentation was preserved.

No documentation was removed.

The working Builder V2 implementation was not modified.

---

# Lessons

- Migrations succeed when the working implementation is never touched.
- Documentation is easier to migrate when it is already structured.
- A migration is an opportunity to fix inconsistencies, not to rewrite history.
- Preserving backwards compatibility keeps existing readers working.

---

**Document Version:** 1.0

**Status:** Active Migration Guide
