# DEVELOPER GUIDE Template

> Template: how to work on the project. Becomes `DEVELOPER_GUIDE.md`.

---

# {{PROJECT_NAME}}

> How to work on {{PROJECT_NAME}} as a human developer.

---

# Purpose

This guide explains how to work on this repository: what to read first, how the
pieces fit together, how to make changes safely, and how to verify your work.

---

# Audience

Anyone who wants to contribute to {{PROJECT_NAME}} or to the framework it is
built on.

---

# Read This First

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

---

# The Development Workflow

```
Idea
↓
Architecture Discussion (for significant changes)
↓
Documentation Update
↓
Implementation
↓
Testing
↓
Validation
↓
Release (for versions)
↓
Reflection
```

Never skip steps.

---

# Making a Change Safely

## Source of Truth

Edit only source files. Never edit generated files ({{GENERATED_ARTIFACT}},
release documentation, version-table rows).

## The Rules

- Providers and models are 100% user-owned; the framework creates the
  `providers/` folder but never writes files inside it.
- No-Secrets Rule: system artifacts never contain literal API keys — only
  `{env:VAR}` placeholders.
- `mcp.json` / `plugins.json` are user-owned after creation.
- Backup-first: the system backs up before touching anything.
- Never touch `.jsonc` without user consent.

## Verify

Run the test harness:

```
powershell -File {{SCRIPTS_DIR}}/{{TEST_HARNESS}}
powershell -File {{SCRIPTS_DIR}}/{{V25_TEST_HARNESS}}
powershell -File {{SCRIPTS_DIR}}/{{V27_TEST_HARNESS}}
```

All must pass with exit code 0.

---

# Common Tasks

- Adding a provider → `PROVIDER_DEVELOPMENT_GUIDE.md`.
- Creating a profile → `PROFILE_CREATION_GUIDE.md`.
- Extending the builder → `BUILDER_EXTENSION_GUIDE.md`.
- Releasing a version → `{{RELEASE_MANAGER_SCRIPT}}` + `{{RELEASE_REGISTRY}}`.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Active Developer Guide
