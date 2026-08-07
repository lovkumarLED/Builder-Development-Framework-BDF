# AGENT Template

> Template: AI agent entry point. Becomes `AGENT.md`.

---

# AGENT

> Entry point for all AI agents working on {{PROJECT_NAME}}.

---

# Purpose

This document defines how AI agents should interact with this repository.

It acts as the primary entry point before reading or modifying any project files.

The goal is to ensure that all AI assistants work consistently, preserve the project architecture, and avoid introducing unnecessary changes.

Every AI agent should read this document first.

---

# Project Overview

{{PROJECT_NAME}} is a modular configuration generation system.

Its purpose is to generate a valid `{{GENERATED_ARTIFACT}}` from a set of smaller configuration files.

The architecture separates:

- Source configuration
- Builder implementation
- Generated configuration
- Documentation

The generated configuration should never become the source of truth.

---

# Builder Development Framework

Generic engineering knowledge shared by every builder project lives in:

```
bdf/
```

Start with:

```
bdf/FRAMEWORK.md
```

The framework describes the reusable engineering process.

The AI workflow is defined in:

```
bdf/AI_WORKFLOW.md
```

This documentation describes the {{APP_NAME}}-specific implementation.

The project-specific facts are defined in:

```
ADAPTER.md
```

When a concept appears in both, the project document defines the {{APP_NAME}}-specific behavior and the framework defines the generic principle.

---

# Session Continuity

Work spans multiple sessions.

Context windows reset between sessions; the session files preserve memory.

At session start:

- Read `_agent/SESSION_WORKFLOW.md`.
- Read `_agent/SESSION_LOG.md`.
- Check the `Next:` line of the most recent entry.

At session end:

- Follow `_agent/SESSION_WORKFLOW.md`.
- Write the session summary to `_agent/SESSION_LOG.md`.
- Never delete or overwrite existing entries.

---

# Build Continuation

Every version build must be built, tested, and validated completely before the next begins.

If a version build is too large to finish within the context window budget, the agent must NOT push through. Instead:

1. Stop at a clean checkpoint.
2. Write `AI/CONTINUE_BUILD_<VERSION>_<STEP>.md` with what was done, what is next, how to verify, and the resume prompt.
3. Update `_agent/SESSION_LOG.md` and `_agent/JOURNEY_TO_V3.md`.
4. Hand the user the resume prompt for the next session.

Resume from the latest checkpoint file - never restart a version from scratch.

---

# Project State

`PROJECT_STATE.md` is the living snapshot of the repository.

It must always reflect the current repository state.

## Major Refactor Definition

A major refactor is any change that:

- Adds, removes, moves, or renames files or folders.
- Changes the architecture or documentation structure.
- Changes how components connect to one another.
- Introduces or removes an entire system.

Minor documentation fixes and small updates do not count as major refactors.

## Regeneration Rule

After every major refactor:

1. Regenerate `PROJECT_STATE.md` from the current repository state.
2. Keep the 15-section structure exactly as defined in the template.
3. Do not ask for confirmation before regenerating.
4. Confirm the update with: Project state updated.
5. Never leave `PROJECT_STATE.md` stale.

## Template

The generic template lives in:

```
bdf/templates/PROJECT_STATE.template.md
```

When the template changes, the framework version must be updated.

---

# Read Order

Before making any modification, read the documentation in the following order.

```
README.md

↓

PROJECT_STATE.md

↓

ADAPTER.md

↓

ARCHITECTURE.md

↓

BUILDER_SPEC.md

↓

DESIGN_PRINCIPLES.md

↓

FOLDER_STRUCTURE.md

↓

JSON_SCHEMAS.md

↓

CONTRIBUTING_FOR_AI.md
```

Only after understanding these documents should an AI modify code or configuration.

---

# Source of Truth

The following files are the authoritative project sources.

```
{{CONFIG_SOURCE_DIR}}/

{{PROVIDER_DIR}}/

{{SCRIPTS_DIR}}/

{{DOCS_DIR}}/
```

The following file is generated automatically.

```
{{GENERATED_ARTIFACT}}
```

Never edit generated files manually.

---

# AI Responsibilities

An AI agent SHOULD:

- Preserve the documented architecture.
- Follow the builder specification.
- Keep configuration modular.
- Prefer extending existing components instead of replacing them.
- Keep documentation synchronized with implementation.
- Explain architectural decisions before making significant changes.

---

# AI Must NOT

An AI agent MUST NOT:

- Edit `{{GENERATED_ARTIFACT}}` manually.
- Introduce undocumented architecture.
- Hardcode configuration values that belong in configuration files.
- Modify unrelated files.
- Remove documentation without justification.
- Implement features that are only listed in `ROADMAP.md`.

---

# Development Philosophy

The project follows several principles.

- Documentation First
- Configuration over Hardcoding
- Modular Design
- Single Responsibility
- Predictable Automation
- Fail Fast
- Preserve Existing Behavior

Every change should support these principles.

---

# Collaboration Preference

The repository owner prefers iterative development.

When implementing changes:

- Work one step at a time.
- Explain the reasoning before major architectural changes.
- Avoid large code dumps unless explicitly requested.
- Preserve existing project style and documentation.
- Treat completed documentation as authoritative unless instructed otherwise.

The goal is collaborative learning rather than autonomous implementation.

---

# Builder Rules

The builder is responsible only for automation.

It should:

- Read configuration.
- Validate configuration.
- Create backups.
- Merge configuration.
- Generate output.

It should never become responsible for maintaining configuration data.

---

# Documentation Rules

Documentation is considered part of the project.

Whenever implementation changes:

- Update documentation if necessary.
- Update the changelog for completed work.
- Remove completed items from the roadmap.
- Keep documents consistent with one another.

---

# Working Style

When implementing a new feature:

1. Understand the architecture.
2. Explain the proposed approach.
3. Make the smallest reasonable change.
4. Verify the result.
5. Update documentation if required.

Avoid large, unrelated refactors.

---

# Future Features

Planned functionality appears only in:

```
ROADMAP.md
```

Do not implement roadmap items unless explicitly requested.

---

# Repository Goal

The long-term objective is to build a configuration management system that is:

- Modular
- Extensible
- Predictable
- Well documented
- Easy for both humans and AI agents to maintain

Every contribution should move the project closer to that goal.

---

# Session Workflow

For every new task:

1. Read AGENT.md.
2. Follow the required documentation reading order.
3. Summarize your understanding of the project.
4. Explain your implementation plan.
5. Wait for approval before modifying code.
6. Implement in small, reviewable steps unless explicitly asked for a complete implementation.

---

# Final Rule

If documentation and implementation disagree:

1. Do not guess.
2. Identify the inconsistency.
3. Ask for clarification or update the documentation before proceeding.

Consistency is more important than speed.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Active AI Entry Guide
