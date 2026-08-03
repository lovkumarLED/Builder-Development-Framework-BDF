# Blueprint Framework

> The reusable engineering knowledge for building configuration builders.

---

# Purpose

The Blueprint Framework is a collection of reusable engineering knowledge for designing, building, documenting, and maintaining configuration builders.

A configuration builder is a small automation system that:

- Reads configuration from modular source files.
- Validates the configuration.
- Creates backups.
- Merges the configuration.
- Generates a single final configuration artifact consumed by an application.

The framework does not contain implementation code.

It contains the process, the principles, the documentation architecture, and the templates that make builder projects predictable and maintainable — for humans and for AI coding agents.

---

# Two Layers

The framework separates all knowledge into two layers.

## Layer 1 — Blueprint Framework

Reusable engineering knowledge.

This folder.

## Layer 2 — Project Documentation

Project-specific implementation.

Example: the OpenCode Configuration Manager documentation, which lives in this same documentation repository.

The OpenCode Configuration Manager is the first implementation built using this framework.

---

# Contents

| Document | Purpose |
|----------|---------|
| `FRAMEWORK.md` | The complete engineering process |
| `VERSION.md` | Blueprint versioning |
| `MIGRATION.md` | Adopting the framework in an existing project |
| `PROJECT_GENERATOR.md` | Creating a new builder project |
| `LESSONS_LEARNED.md` | Reusable engineering lessons |
| `templates/` | Reusable documentation templates |

---

# How To Use

Understand the framework:

```
Read FRAMEWORK.md
```

New project:

```
Read PROJECT_GENERATOR.md
```

Existing project:

```
Read MIGRATION.md
```

---

# Rules

The blueprint contains no project-specific knowledge.

Project names appear only as examples.

Templates are changed only through the blueprint change process, never to satisfy a single project.

---

**Document Version:** 1.0

**Status:** Active Blueprint
