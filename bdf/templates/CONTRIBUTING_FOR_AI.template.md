# CONTRIBUTING_FOR_AI Template

> Template: AI coding agent instructions. Becomes `CONTRIBUTING_FOR_AI.md`.

---

# CONTRIBUTING_FOR_AI

> Instructions for AI coding agents working on {{PROJECT_NAME}}.

---

# Purpose

This document defines the rules that every AI coding agent must follow when contributing to this project.

The goal is to ensure consistency, maintainability, and architectural integrity regardless of which AI model is used.

This document supplements the project documentation and should be read before making any changes.

---

# Required Reading Order

Before making any modification, read the documentation in the following order.

1. README.md
2. PROJECT_STATE.md
3. ADAPTER.md
4. ARCHITECTURE.md
5. BUILDER_SPEC.md
6. DESIGN_PRINCIPLES.md
7. FOLDER_STRUCTURE.md
8. JSON_SCHEMAS.md

Do not begin implementation before understanding the project architecture.

---

# Core Rules

## Rule 1 — Respect the Source of Truth

Never edit generated files.

Current generated file:

```
{{GENERATED_ARTIFACT}}
```

If configuration changes are required:

1. Modify the source configuration.
2. Run the builder.
3. Generate a new configuration.

---

## Rule 2 — Never Hardcode Configuration

Configuration belongs in configuration files.

Implementation belongs in the builder language.

Do not hardcode:

- provider names
- model identifiers
- credentials
- plugin configuration
- service configuration

The builder should always read configuration from the source files.

---

## Rule 3 — Preserve Architecture

Do not change the project architecture unless explicitly requested.

Current architecture separates:

- Providers
- Profiles
- Builder
- Documentation
- Generated Output

Maintain this separation.

---

## Rule 4 — Preserve Single Responsibility

Every component should have exactly one responsibility.

Avoid adding unrelated functionality to an existing module.

If a new responsibility is introduced, create a new module instead of extending an unrelated one.

---

## Rule 5 — Preserve Documentation

Whenever an implemented feature changes:

Update the relevant documentation.

Do not leave documentation inconsistent with the implementation.

---

## Rule 6 — Do Not Document Future Features

Only document features that currently exist.

Future ideas belong exclusively in:

```
ROADMAP.md
```

Do not describe planned functionality as if it has already been implemented.

---

## Rule 7 — Validation First

Never bypass validation.

If configuration is invalid:

Stop the build.

Report the error.

Do not generate partial output.

---

## Rule 8 — Preserve Backward Compatibility

Whenever possible:

Extend existing functionality.

Avoid breaking existing configuration.

Prefer additive changes over destructive changes.

---

## Rule 9 — Create Backups

Before overwriting generated configuration:

Create a backup.

Backups are considered mandatory.

---

## Rule 10 — Keep Generated Files Disposable

Generated files should never become the primary source of information.

Every generated file must be reproducible from the source configuration.

---

## Rule 11 — Keep README Current (README Synchronization Rule)

`README.md` is the public face of the project and must never go stale.

Whenever something is added, changed, or fixed:

1. Check whether `README.md` mentions the affected area.
2. If it does, update the corresponding section in the SAME change — never in a later commit.
3. User-visible changes (new features, scripts, rules, status changes) MUST be reflected in `README.md` before the work is considered done.
4. Keep the README footer versions in sync.
5. Never claim a status the project has not reached.

---

# Preferred Development Workflow

The expected workflow is:

```
Understand

↓

Read Documentation

↓

Plan

↓

Implement

↓

Validate

↓

Test

↓

Update Documentation
```

Do not skip any stage.

---

# Modification Checklist

Before completing a task, verify the following.

- Source files remain unchanged except where intended.
- Generated files were regenerated.
- Validation succeeds.
- Documentation reflects the implementation.
- Architecture remains consistent.
- No unnecessary hardcoding was introduced.

---

# When Unsure

If a requested change conflicts with the documented architecture:

Do not guess.

Explain the conflict.

Recommend an architectural solution instead of introducing an inconsistent implementation.

---

# Project Philosophy

This project values:

- Simplicity over complexity.
- Automation over manual work.
- Configuration over hardcoding.
- Documentation over assumptions.
- Stable architecture over rapid expansion.

All future contributions should preserve these principles.

---

# AI Contributor Goal

The objective of every AI contribution is not only to make the project work, but also to leave the project:

- Cleaner
- Better documented
- Easier to maintain
- More predictable

than before the contribution began.

---

## Adapter Status and Gate Checks (generic)

Before editing an adapter namespace or its implementation: read the adapter
documents and governing gate reports; check the lifecycle status and never
claim a stronger phrase than the evidence gate allows; keep target-specific
facts inside adapter documents, never in generic templates; follow the README
synchronization rule.

---

**Document Version:** {{DOC_VERSION}}

**Status:** AI Contribution Guide
