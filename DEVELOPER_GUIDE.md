# DEVELOPER GUIDE

> How to work on the OpenCode Configuration Manager and its Builder Development
> Framework (BDF) as a human developer.

---

# Purpose

This guide explains how to work on this repository: what to read first, how the
pieces fit together, how to make changes safely, and how to verify your work.

It complements `CONTRIBUTING_FOR_AI.md` (rules for AI agents) and
`bdf/NEW_PROJECT_GUIDE.md` (onboarding a brand-new project into the framework).

---

# Audience

Anyone who wants to contribute to:

- the OpenCode Configuration Manager (this project), or
- the Builder Development Framework (`bdf/`), or
- a new builder project built on the framework.

---

# Read This First

Before touching anything, read in this order:

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

If you are working on the framework itself (not this project), also read:

```
bdf/FRAMEWORK.md
bdf/README.md
```

---

# How the Pieces Fit Together

The repository is organized into two layers.

## Layer 1 — Builder Development Framework (`bdf/`)

Generic, reusable engineering knowledge. No project-specific content.

Key documents:

- `FRAMEWORK.md` — the complete engineering process.
- `BLUEPRINT_ENGINE.md` — the intelligence layer.
- `PROJECT_ADAPTER.md` — how projects are made framework-specific.
- `BUILDER_EVOLUTION.md` — how builder versions evolve.
- `BUILDER_PHASES.md` — Alpha → Beta → General Release quality gates.
- `templates/` — 19 reusable documentation templates.

## Layer 2 — Project Implementation (this repository's root docs)

OpenCode-specific implementation. The project adapter defines every
project-specific fact:

```
ADAPTER.md
```

---

# The Development Workflow

Every change follows the same cycle.

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

Never skip steps. Skipping steps weakens the framework.

---

# Making a Change Safely

## 1. Understand the Source of Truth

Edit only source files. Never edit generated files:

| Edit manually | Never edit (regenerate) |
|---------------|-------------------------|
| Provider definitions | `opencode.json` / `kilo.json` |
| Profile configuration | `CURRENT_RELEASE.md` |
| Documentation | CHANGELOG marker sections |
| Builder scripts | PROJECT_STATE version table |
| `release_registry.json` | `bdf/VERSION.md` compatibility rows |

## 2. Follow the Rules

- Providers and models are 100% user-owned. The framework creates the
  `providers/` folder but never writes files inside it.
- No-Secrets Rule: system artifacts (scripts, templates, docs, examples) never
  contain literal API keys — only `{env:VAR}` placeholders.
- mcp.json / plugins.json are user-owned after creation — never overwritten.
- Backup-first: the system backs up before touching anything.
- Never touch `.jsonc` without user consent.

> **Agent config warning:** the builders generate `opencode.json` (OpenCode) /
> `kilo.json` (Kilo). Do NOT create `opencode.jsonc` next to `opencode.json` —
> OpenCode reads the `.jsonc` *instead of* the `.json` when both exist, and your
> built config silently disappears from `/models`. Generating both formats is
> planned for a future update — not right now.

## 3. Verify Your Work

Run the test harnesses:

```
powershell -File scripts/test-opencode-v2.ps1       # 17 tests
powershell -File scripts/test-opencode-v2.5.ps1     # 13 tests
powershell -File scripts/test-opencode-v2.7.ps1     # 31 tests
```

KiloCode project:

```
powershell -File ~/.config/kilo/scripts/test-kilo-v1.ps1   # 30 tests
```

All must pass with exit code 0.

## 4. Keep Documentation Synchronized

- Update documentation when implementation changes.
- Update `CHANGELOG.md` for completed work.
- Remove completed items from `ROADMAP.md`.
- Regenerate `PROJECT_STATE.md` after every major refactor.
- If a template changes, bump the framework version in `bdf/VERSION.md`.

---

# Common Tasks

## Adding a provider

Providers are user-owned. Create the file yourself:

```
providers/<id>.json
```

Write the API key in **both** places — `apiKey` (OpenCode) and
`options.apiKey` (Kilo). If you write only one, the builder mirrors it
automatically at merge time, so builder-only work and app work produce the
same output. (The Switcher app does the same when you save a provider
through the GUI.)

See `PROVIDER_DEVELOPMENT_GUIDE.md`.

## Creating a profile

See `PROFILE_CREATION_GUIDE.md`.

## Extending the builder

See `BUILDER_EXTENSION_GUIDE.md`.

## Releasing a version

1. Record the release facts in `docs/release_registry.json`.
2. Run the release manager:

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/release-manager.ps1
```

3. Run the test harness (Release Docs group must pass).
4. Commit.

---

# The Four Framework Questions

The framework is complete when its documentation answers:

1. How is this builder built?
2. How should this builder evolve?
3. How do I create another builder?
4. How do I adapt this framework to another project?

Every contribution should help answer at least one of them.

---

**Document Version:** 1.0

**Status:** Active Developer Guide
