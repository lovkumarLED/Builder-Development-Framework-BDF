# AGENT

> Entry point for all AI agents working on the OpenCode Configuration Manager.

---

# Purpose

This document defines how AI agents should interact with this repository.

It acts as the primary entry point before reading or modifying any project files.

The goal is to ensure that all AI assistants work consistently, preserve the project architecture, and avoid introducing unnecessary changes.

Every AI agent should read this document first.

---

# Project Overview

The OpenCode Configuration Manager is a modular configuration generation system.

Its purpose is to generate a valid `opencode.json` from a set of smaller configuration files.

The architecture separates:

- Source configuration
- Builder implementation
- Generated configuration
- Documentation

The generated configuration should never become the source of truth.

---

# Read Order

Before making any modification, read the documentation in the following order.

```
README.md

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
profiles/

providers/

scripts/

docs/
```

The following file is generated automatically.

```
opencode.json
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

- Edit `opencode.json` manually.
- Introduce undocumented architecture.
- Hardcode configuration values that belong in JSON.
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

# Final Rule

If documentation and implementation disagree:

1. Do not guess.
2. Identify the inconsistency.
3. Ask for clarification or update the documentation before proceeding.

Consistency is more important than speed.

---

**Document Version:** 1.0

**Status:** Active AI Entry Guide