# Release Manager

> The generic release process of the Builder Development Framework.

---

# Purpose

This document defines how a builder project releases a new version.

Releases are deterministic.

The same registry produces the same release documents every time.

The human records release facts once. The release manager generates everything else.

---

# The Release Pipeline

```
release_registry.json   (the only hand-edited release artifact)
↓
release-manager script  (generates all release documents)
↓
CHANGELOG
CURRENT_RELEASE
PROJECT_STATE version table
VERSION.md rows
```

The registry is the single source of truth.

The script is the only generator.

The generated documents are never edited manually.

---

# Components

| Component | Definition |
|-----------|------------|
| Release Registry | The machine-readable release history. The only hand-edited release artifact. |
| Release Manager | The script that reads the registry and generates all release documents. |
| Generated Documents | The version documentation produced from the registry: changelog, quick reference, project-state version table, and framework version-compatibility rows. |

---

# Rules

## Rule 1 — The Registry Is the Single Source of Truth

All release facts are recorded in the release registry once.

Version sequence, status, dates, summaries, and testing results come from the registry.

No other file may define a release fact.

## Rule 2 — Generated Documents Are Never Edited Manually

The changelog marker section, the current-release page, the project-state version table, and
the framework version-compatibility rows are generated output.

Hand-editing them is a defect: the next generation overwrites the manual edit.

## Rule 3 — All-or-Nothing Writes

The release manager validates the complete registry before writing anything.

If any required field is missing, invalid, or the registry is malformed, the manager writes
NOTHING and reports the error.

A failed generation never leaves a partially updated document set.

## Rule 4 — Verify Generated Output Before Writing

Before writing, the manager verifies that every generated document is complete:

- Every release version appears in every document that lists versions.
- Exactly one release is marked Current.
- No marker is missing.

Only verified output is written.

## Rule 5 — Marker Policy

Generated sections are delimited by markers.

A document that is missing its markers is rejected: generation aborts and nothing is written.

Markers protect hand-written content from regeneration.

## Rule 6 — Deterministic No-Op

When the registry is unchanged, regenerating produces no changes.

The manager reports that all outputs are up to date and writes nothing.

This makes the release pipeline a deterministic no-op on unchanged input.

---

# Registry Fields

The registry records, for every release:

| Field | Definition |
|-------|------------|
| version | The project version. |
| builderVersion | The builder version delivered by this release. |
| date | The release date. |
| status | Current, Previous, or Legacy. Exactly one release is Current. |
| summary | One-sentence description of the release. |
| highlights | Key points of the release. |
| newFeatures | New functionality added. |
| improvements | Existing behavior improved. |
| bugFixes | Defects corrected. |
| breakingChanges | Whether existing projects must change. |
| migrationRequired | Whether migration notes exist. |
| testingSummary | The test result of the release. |
| knownIssues | Open issues at release time. |
| docsUpdated | The documents updated by the release. |

A registry entry missing any of these fields fails validation.

---

# The Release Workflow

```
AI records release facts in the registry
↓
Human reviews the release facts
↓
Run the release manager
↓
Run the test harness (Release Docs group must pass)
↓
Commit
```

## Step 1 — Record the Facts

The AI writes the release entry into the registry after implementation and testing.

New releases are prepended: the registry stores releases newest-first.

The previous `Current` release becomes `Previous`.

## Step 2 — Human Review

The human reviews the registry entry.

The registry is the only hand-edited release artifact, so this review is the last check
before generation.

## Step 3 — Run the Release Manager

The manager validates, generates, verifies, and writes.

On success it reports which outputs were written.

On unchanged input it reports a no-op.

## Step 4 — Test

The test harness Release Docs group verifies:

- Registry shape.
- Generated outputs.
- Determinism.
- Registry/document consistency.

A release is not complete until the Release Docs tests pass.

## Step 5 — Commit

The release is committed with the registry change and the generated output.

---

# Ownership

| Artifact | Owner |
|----------|-------|
| Release registry | Human (with AI assistance) — hand-edited. |
| Generated release documents | Release manager — never edited manually. |
| Migration notes | AI — written when a release declares breaking changes. |

---

# When a Release Declares Breaking Changes

A release with `breakingChanges` not equal to None:

- Requires `migrationRequired: Yes`.
- Ships migration documentation explaining what changed, what must be done, and what is no
  longer supported.
- Marks the change in the changelog under Migration Required.

---

**Document Version:** 1.0

**Status:** Active Release Manager