# Migration Guide

> Adopting the Builder Development Framework in an existing project.

---

# Purpose

This document explains how an existing builder project adopts the Builder Development Framework.

It also explains how a project migrates between framework versions.

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

Move generic knowledge into framework documentation.

Keep project-specific knowledge in the project documentation.

For mixed documents:

- Keep the project-specific parts in the project document.
- Move the generic parts to the relevant framework document.
- Leave a reference in the project document pointing to the framework.

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
- Agent entry: point to the framework for generic knowledge.

---

## Stage 7 — Update the Folder Structure Document

Add the framework folder to the project's folder structure documentation.

---

## Stage 8 — Define the Project Adapter

Every migrated project defines its adapter.

Read:

```
PROJECT_ADAPTER.md
```

Create:

```
ADAPTER.md
```

from:

```
templates/ADAPTER.template.md
```

The adapter defines every project-specific field.

The project is not migrated until the adapter is complete.

---

## Stage 9 — Verify Consistency

Check that:

- Every generic statement is project-neutral.
- Every project document still describes the current implementation.
- No documentation was removed.
- All cross-references are valid.
- The adapter matches the project.

---

## Stage 10 — Record the Migration

Record the documentation architecture change in the project changelog.

---

# Migrating Between Framework Versions

When a new framework version is released:

1. Read the new version's breaking changes in `VERSION.md`.
2. Read the migration section of the updated documents.
3. Compare the changed templates with the project documents.
4. Apply the changes described.
5. Update the framework version reference used by the project.
6. Verify consistency.

If the new version declares no breaking changes, the migration is optional.

---

# Migrating From Blueprint Framework 1.x

Framework 2.0.0 renamed the Blueprint Framework to the Builder Development Framework (BDF).

The following steps migrate an existing project.

## Step 1 — Rename the Framework Folder

The framework folder is renamed:

```
blueprint/  →  bdf/
```

Update every reference to the folder in project documentation.

## Step 2 — Rename the Framework

Replace the name "Blueprint Framework" with "Builder Development Framework" in active project documentation.

Historical records keep their original wording.

## Step 3 — Define the Project Adapter

Create `ADAPTER.md` from `bdf/templates/ADAPTER.template.md`.

Define every field.

## Step 4 — Update the Read Order

Add the adapter and the new framework components to the agent reading order.

## Step 5 — Verify Consistency

Check that:

- No active document references `blueprint/`.
- Every active document references `bdf/`.
- The adapter is complete.
- All cross-references are valid.

---

# Reference Migration

The OpenCode Configuration Manager was the first project to adopt the framework.

Its documentation was restructured into two layers:

```
Layer 1  bdf/          Reusable engineering knowledge.
Layer 2  project docs  OpenCode-specific documentation.
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
- An adapter makes a generic framework usable by a specific project.

---

**Document Version:** 1.1

**Status:** Active Migration Guide
