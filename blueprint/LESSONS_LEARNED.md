# Lessons Learned

> Reusable engineering principles for every builder project.

---

# Purpose

This document stores engineering principles learned while building configuration builders.

Lessons are stored as principles, not as project history.

Every lesson here should apply to every builder project.

---

# Lesson 1 — Never Hardcode Configuration

## Principle

Configuration belongs inside configuration files.

Implementation belongs inside the builder.

## Why

Hardcoded values make the builder specific to one project.

They force code changes when configuration changes.

## Application

- The builder always reads configuration from source files.
- No provider names, model identifiers, or connection details inside implementation.
- New projects reuse the same builder without code changes.

---

# Lesson 2 — Generated Files Are Not Source Files

## Principle

Generated files are disposable artifacts.

Source files are the only authority.

## Why

Editing generated files creates confusion and makes output unreproducible.

## Application

- Never edit generated files manually.
- Regenerate from source after every change.
- Treat generated files as replaceable.

---

# Lesson 3 — Documentation Is Architecture

## Principle

Documentation is part of the project.

It describes the architecture and guides every future change.

## Why

Undocumented systems grow inconsistently.

Documented systems can be extended predictably.

## Application

- Keep documentation synchronized with implementation.
- Update documentation when implementation changes.
- Treat completed documentation as authoritative.

---

# Lesson 4 — Small Changes Reduce Risk

## Principle

Make the smallest reasonable change.

## Why

Large changes combine multiple risks.

Failures become harder to diagnose when many things change at once.

## Application

- Work one step at a time.
- Avoid large unrelated refactors.
- Verify after every change.

---

# Lesson 5 — Testing Protects Future Development

## Principle

Every successful build should be reproducible.

Changes should never break previously working functionality.

## Why

Untested systems break silently.

Tested systems fail loudly and predictably.

## Application

- Validate before generating.
- Never trust generated output without verification.
- Re-run the builder after every change.
- Keep backups as recovery points.

---

# Lesson 6 — Backup Before Overwrite

## Principle

Never destroy the last known working configuration.

## Why

Configuration changes can introduce errors.

Recovery is only possible when the previous state exists.

## Application

- Create a timestamped backup before overwriting the artifact.
- Never modify backups after creation.
- Treat backup failure as a build failure.

---

# Lesson 7 — Fail Fast, Fail Early

## Principle

Stop at the first unrecoverable error.

Never generate partial output.

## Why

Errors are easiest to fix at the point where they occur.

Invalid output reaching the application is the most expensive failure.

## Application

- Validate everything before generation.
- Terminate the build immediately on validation failure.
- Report what failed, where it failed, and why.

---

# Lesson 8 — One Responsibility Per Component

## Principle

Every component performs exactly one responsibility.

## Why

Components with multiple responsibilities become coupled and unpredictable.

## Application

- Separate configuration, providers, builder, backup, and documentation.
- Add new modules instead of extending unrelated ones.
- No component performs another component's responsibility.

---

# Lesson 9 — Consistency Is More Important Than Speed

## Principle

When documentation and implementation disagree, do not guess.

## Why

Guessing produces inconsistent systems.

Consistency keeps humans and AI agents working from the same model.

## Application

- Identify the inconsistency.
- Ask for clarification.
- Update the documentation before proceeding.

---

# Lesson 10 — The Roadmap Is Not the Changelog

## Principle

Future work and completed work never share a document.

## Why

Mixed history makes it impossible to know what exists today.

## Application

- Completed work belongs in the changelog.
- Planned work belongs in the roadmap.
- When work is completed, move it from the roadmap to the changelog.

---

# Contributing a New Lesson

A new lesson should be added when:

- The same problem occurred more than once.
- The solution is reusable.
- The lesson is not project-specific.

New lessons follow the same format:

- Principle.
- Why.
- Application.

---

**Document Version:** 1.0

**Status:** Active Lessons
