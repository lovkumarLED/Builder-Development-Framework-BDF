# LESSONS_LEARNED Template

> Template: engineering lessons. Becomes `LESSONS_LEARNED.md`.

---

# Lessons Learned

> Reusable engineering principles for {{PROJECT_NAME}}.

---

# Purpose

This document stores engineering principles learned while building this project.

Lessons are stored as principles, not as project history.

Every lesson here should apply to this project and to future projects.

---

# Lesson 1 — Never Hardcode Configuration

## Principle

Configuration belongs inside configuration files.

Implementation belongs inside the builder.

## Why

Hardcoded values make the builder specific to one configuration.

## Application

- The builder always reads configuration from source files.
- No provider names or connection details inside implementation.

---

# Lesson 2 — Generated Files Are Not Source Files

## Principle

Generated files are disposable artifacts.

Source files are the only authority.

## Why

Editing generated files makes output unreproducible.

## Application

- Never edit generated files manually.
- Regenerate from source after every change.

---

# Lesson 3 — Documentation Is Architecture

## Principle

Documentation is part of the project.

## Why

Undocumented systems grow inconsistently.

## Application

- Keep documentation synchronized with implementation.
- Treat completed documentation as authoritative.

---

# Lesson 4 — Small Changes Reduce Risk

## Principle

Make the smallest reasonable change.

## Why

Large changes combine multiple risks.

## Application

- Work one step at a time.
- Verify after every change.

---

# Lesson 5 — Testing Protects Future Development

## Principle

Every successful build should be reproducible.

## Why

Untested systems break silently.

## Application

- Validate before generating.
- Re-run the builder after every change.

---

# Lesson 6 — Backup Before Overwrite

## Principle

Never destroy the last known working configuration.

## Why

Recovery is only possible when the previous state exists.

## Application

- Create a timestamped backup before overwriting the artifact.

---

# Lesson 7 — Fail Fast, Fail Early

## Principle

Stop at the first unrecoverable error.

## Why

Errors are easiest to fix at the point where they occur.

## Application

- Validate everything before generation.
- Never generate partial output.

---

# Lesson 8 — One Responsibility Per Component

## Principle

Every component performs exactly one responsibility.

## Why

Components with multiple responsibilities become unpredictable.

## Application

- Separate configuration, providers, builder, backup, and documentation.

---

# Lesson 9 — Consistency Is More Important Than Speed

## Principle

When documentation and implementation disagree, do not guess.

## Why

Guessing produces inconsistent systems.

## Application

- Identify the inconsistency.
- Ask for clarification.

---

# Lesson 10 — The Roadmap Is Not the Changelog

## Principle

Future work and completed work never share a document.

## Why

Mixed history makes it impossible to know what exists today.

## Application

- Completed work belongs in the changelog.
- Planned work belongs in the roadmap.

---

# Lesson 11 - A Framework Is Judged by Its Questions

## Principle

A reusable framework is complete when its documentation answers four questions:

- How is this builder built?
- How should this builder evolve?
- How do I create another builder?
- How do I adapt this framework to another project?

## Why

Documentation that describes facts without answering questions cannot guide future work.

An unanswered question forces every future agent to guess.

## Application

- Design every framework document to answer at least one question.
- Test the framework by asking the four questions.
- When a question cannot be answered, the framework is incomplete.

---

# Lesson 12 - Adapters Separate Generic From Specific

## Principle

A generic framework plus a project adapter equals a project-specific builder.

## Why

Embedding project details in a framework makes it unreusable.

Keeping the framework generic and the adapter specific allows any number of projects to reuse the same engineering process.

## Application

- Keep the framework free of project-specific knowledge.
- Define every project-specific fact in the project adapter.
- Create a new project by writing a new adapter, never by rewriting the framework.

---

# Contributing a New Lesson

A new lesson should be added when:

- The same problem occurred more than once.
- The solution is reusable.

New lessons follow the same format:

- Principle.
- Why.
- Application.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Active Lessons
