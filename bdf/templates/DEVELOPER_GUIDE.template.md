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

# How the Pieces Fit Together

The repository is organized into two layers.

## Layer 1 — Builder Development Framework

Generic, reusable engineering knowledge.

No project-specific content.

## Layer 2 — Project Implementation

The {{APP_NAME}}-specific implementation.

Every project-specific fact is defined by the project adapter.

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

> **Agent config warning:** the builders generate `{{GENERATED_ARTIFACT}}`
> (the agent's main config). Do NOT create a `.jsonc` next to it — the agent
> reads the `.jsonc` *instead of* the `.json` when both exist, and your built
> config silently disappears from its model list. Generating both formats is
> planned for a future update — not right now.

## Verify

Run the test harness:

```
powershell -File {{SCRIPTS_DIR}}/{{TEST_HARNESS}}
powershell -File {{SCRIPTS_DIR}}/{{V25_TEST_HARNESS}}
powershell -File {{SCRIPTS_DIR}}/{{V27_TEST_HARNESS}}
```

All must pass with exit code 0.

## Keep Documentation Synchronized

Update documentation when the implementation changes.

Update `CHANGELOG.md` for completed work.

Remove completed items from `ROADMAP.md`.

Regenerate `PROJECT_STATE.md` after every major refactor.

---

# Common Tasks

- Adding a provider → `PROVIDER_DEVELOPMENT_GUIDE.md`.
- Creating a profile → `PROFILE_CREATION_GUIDE.md`.
- Extending the builder → `BUILDER_EXTENSION_GUIDE.md`.
- Releasing a version → `{{RELEASE_MANAGER_SCRIPT}}` + `{{RELEASE_REGISTRY}}`.

## Adding a provider

Create the provider file in `{{PROVIDER_DIR}}/`.

See `PROVIDER_DEVELOPMENT_GUIDE.md`.

## Creating a profile

Create the profile directory under `{{CONFIG_SOURCE_DIR}}/`.

See `PROFILE_CREATION_GUIDE.md`.

## Extending the builder

Extend `{{BUILDER_SCRIPT}}`.

See `BUILDER_EXTENSION_GUIDE.md`.

## Releasing a version

1. Record the release facts in `{{RELEASE_REGISTRY}}`.
2. Run `{{RELEASE_MANAGER_SCRIPT}}`.
3. Run the test harness (Release Docs group must pass).
4. Commit.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Active Developer Guide
