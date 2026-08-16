# Testing Framework

> The generic testing philosophy of the Builder Development Framework.

---

# Purpose

This document defines how a builder project is tested.

Testing is part of development, not an optional step.

A version is not complete until its test harness passes.

The reference implementation (`docs/TESTING.md` and its harness) mirrors this framework
document; the framework document is the pattern, the project document is the concrete
implementation.

---

# The Test-Harness Pattern

Every builder project gets a reusable test harness script.

The harness:

- Runs headlessly (no interactive steps).
- Is deterministic (same input, same result, every run).
- Exits non-zero on any failure.
- Reports each test individually and a final summary.

The harness lives in the project's scripts directory.

The harness entry point is recorded in the project adapter.

---

# Test Groups

Every harness covers the same three groups.

## 1 — Valid Build

The builder succeeds on valid input.

Tests verify:

- The configuration sources are read.
- The builder executes successfully.
- The backup is created.
- The generated artifact is valid (parseable by the target application's format).
- The target application can consume the artifact.

## 2 — Failure Modes

The builder fails safely on invalid input.

Tests verify:

- Invalid JSON is rejected.
- Missing required sources are rejected.
- Duplicate or malformed definitions are rejected.
- A backup failure aborts the build before writing.
- No partial output is produced on failure.

## 3 — Release Docs

The release system produces consistent, deterministic documents.

Tests verify:

- The registry is well formed.
- The release manager generates all outputs.
- Generation is deterministic (two runs produce identical output).
- The generated documents match the registry.
- The release manager aborts when markers are missing.

## JSON Schema (Builder V2.7)

The V2.7 harness group follows the same pattern for the JSON Schema builder.

- Schema Validation: valid sources pass; settings missing `required` fails; wrong `type` fails; `additionalProperties` fails; provider violation fails; models violation fails; missing `schemas/` directory warns and continues.
- Pre-flight: missing provider file aborts with "Pre-flight failed".
- WhatIf: nothing written, exit 0.
- Doctor: clean exits 0, corrupt exits 1.
- Backup retention: `-KeepBackups` honored.
- Provenance: sidecar fields and SHA correct.
- Diff summary: Added/Removed lines; identical input silent.

---

# Testing Principles

- Validate before generating.
- Never trust generated output without verification.
- Every successful build should be reproducible.
- Changes should never break previously working functionality.
- Tests run headlessly and deterministically.

---

# Definition of Complete

The harness and its results are part of a version's definition of complete.

A version is complete only when ALL of these hold:

- The planned features exist and are documented.
- Every test group passes.
- A real end-to-end run confirms the builder works.
- The release manager runs cleanly on the new registry entry.

A version whose tests fail is not released.

---

# Adding Tests

When a feature changes the builder:

- Tests are updated to verify the new behavior.
- Existing tests are re-run to verify nothing broke.
- New failure modes become new tests in the Failure Modes group.

Tests change in the same change as the implementation (Blueprint Engine, Testing Update
stage).

---

# Relationship to the Framework

| Component | Uses the Testing Framework For |
|-----------|--------------------------------|
| Blueprint Engine | The Testing Update stage. |
| Builder Evolution | Rule: tests define done. |
| Framework Lifecycle | Verifying each lifecycle stage. |
| Release Manager | The Release Docs test group. |

---

## Adapter Test Groups (Framework 2.3.0)

Unique bounded adapters add generic test groups without target-specific
commands:

- Fixture group: isolated behavior on repository fixtures, no real target.
- Compatibility group: versioned evidence ledger entries at the evidence level
  actually reached.
- Integration group: app wiring on temporary targets only.
- Live-validation group: authorized only after the live gate; never assumed.

A passing group proves behavior at its gate. It never converts to a support
claim; lifecycle status vocabulary governs the wording.

---

**Document Version:** 1.0

**Status:** Active Testing Framework