# ROADMAP

> Planned evolution of the OpenCode Configuration Manager toward the Builder Development Framework (BDF) V3.

---

# Purpose

This document describes the planned direction of the project.

Only planned or proposed features should appear here.

Completed features belong in:

```
CHANGELOG.md
```

Implementation details belong in:

```
BUILDER_SPEC.md
```

The long-term vision and version philosophy live in:

```
planning/BDF_ROAD_TO_V3.md
```

The live tracker of our position on the road to V3 lives in:

```
_agent/JOURNEY_TO_V3.md
```

This roadmap is intended to guide future development while keeping the overall project vision clear.

---

# Destination — BDF V3

Every phase below serves one destination:

> **BDF V3 — the first stable public version of the Builder Development Framework.**

V3 is complete when the same engineering framework can successfully create and maintain
builders for **OpenCode**, **Claude Code**, and **KiloCode** without redesigning the framework.

Only Project Adapters should differ between supported projects.

The path is:

```
Current (Builder V2.7 JSON Schema Validation) ✅
↓
Claude Code Builder V1
↓
KiloCode Builder V1
↓
BDF V3 (Builder Generator)
```

Each step is built, tested, and validated before the next begins.

Real projects shape the framework — never assumptions.

---

# Project Status

Current Version

```
2.5.0
```

Current Status

```
Builder V2.7 JSON Schema Validation
```

Journey Position

```
BDF V2.5 — Completed; next step: Claude Code Builder V1
```

The project currently provides:

- Modular configuration
- Provider abstraction
- Profile abstraction
- Configuration builder (V2.7)
- Dynamic profile selection
- Dynamic provider loading
- Backup system
- Automated release pipeline (registry + release manager)
- Documentation framework

The next development phases focus on expanding flexibility while preserving the existing architecture.

---

# Development Phases

## Phase 1 — Foundation ✅

Status

```
Completed
```

Completed work includes:

- Project architecture
- Builder
- Provider abstraction
- Profile abstraction
- Backup system
- Documentation
- Manual testing framework

---

## Phase 2 — Builder Improvements ✅

Status

```
Completed
```

Completed work includes:

- Dynamic provider loading.
- Dynamic profile selection.
- Improved configuration validation.
- Better console output.
- Improved error reporting.
- Cleaner internal builder architecture.

The implementation is documented in:

```
BUILDER_SPEC.md
```

---

## Phase 3 — Multiple Profiles ✅

Status

```
Completed
```

Completed work includes:

- Multiple profiles: `default`, `coding`, `experimental`, `minimal`.
- The `default` profile is fully configured.
- Additional profiles contribute their provider selection to the build.

---

## Phase 4 — Additional Providers

Status

```
Planned
```

Objectives

Support additional provider definitions.

Examples

```
providers/

omniroute.json

cliproxy.json

future-provider.json
```

Goals

- Builder automatically discovers providers.
- No builder modifications required for new providers.
- Provider configuration remains modular.

---

## Phase 5 — Validation Framework

Status

```
Completed
```

Completed work includes:

- Duplicate provider identifier detection.
- Duplicate model identifier detection (raw text, not collapsed by parsing).
- Duplicate model name detection.
- Duplicate plugin identifier detection.
- Duplicate MCP identifier detection.
- Malformed provider definition rejection.
- Malformed profile definition rejection.
- Missing required field rejection.
- Invalid configuration structure rejection.

Remaining (possible additions)

- Unknown key detection.
- JSON Schema validation.

Goal

Catch configuration errors before generation begins.

---

## Phase 6 — Automated Testing

Status

```
Completed
```

Completed work includes:

- Reusable test harness (`scripts/test-opencode-v2.ps1`).
- Valid profile testing against the real coding profile.
- Failure-mode testing (invalid JSON, missing provider, duplicates, malformed definitions).
- Backup failure safety testing.
- Provider-specific models testing.

Remaining (possible additions)

- Configuration comparison across builds.
- Integration testing with a running provider.

Goal

Reduce manual testing effort.

---

## Phase 7 — Builder Refactoring

Status

```
Completed
```

Completed work includes:

- Modular merge pipeline (settings, providers, models, plugins, MCP).
- Split verification stages (JSON, providers, models, plugins, MCP).
- Concise count-based logging.
- Clearer diagnostics.
- Independent, maintainable functions.

Remaining (possible additions)

- Easier future extension.

Goal

Keep the builder simple even as functionality grows.

---

## Phase 8 — Documentation Expansion

Status

```
Planned
```

Possible additions

- Developer Guide.
- Provider Development Guide.
- Profile Creation Guide.
- Builder Extension Guide.

Goal

Make onboarding easier for future contributors.

---

## Phase 9 — Release Manager V1 ✅

Status

```
Completed
```

Completed on

```
2026-08-04
```

Completed work includes:

- `docs/release_registry.json` — machine-readable release history (the only hand-edited release artifact).
- `scripts/release-manager.ps1` — generates all release documentation from the registry.
- Rich CHANGELOG marker section, `CURRENT_RELEASE.md`, `bdf/VERSION.md` compatibility rows, and the PROJECT_STATE version history table.
- Marker policy: the manager rewrites only generated sections; manual prose is preserved.
- All-or-nothing failure policy: nothing is written when validation fails.
- Release Docs test group (tests 10-17) added to the test harness; test 17 is the only read-only real-docs test.

Remaining (possible additions)

- Release channels and support status in the registry.

Goal

Make every version release one command instead of a manual 10-file edit.

---

## Phase 10 — BDF V2.5: Framework Generalization ✅

Status

```
Completed (2026-08-04)
```

Objective

Strengthen the framework. Not redesign it.

Purpose

```
Prepare the framework for becoming V3.
```

Planned work includes:

- `NEW_PROJECT_GUIDE.md` — documented process for onboarding a new project.
- Better `PROJECT_ADAPTER.md` — cleaner generic/project boundary.
- More generic templates.
- Better Blueprint Engine.
- Cleaner framework boundaries.
- Improved validation, testing, adapters, templates, documentation, provider handling, and release system.

Not included

- Automatic project generation. That arrives with V3.

Goal

Make the framework reusable across OpenCode, Claude Code, and KiloCode without redesign.

---

## Phase 10.5 — Active-Provider Selector Builder (V2.5 Builder)

Status

```
Planned — first build of this feature set
```

Objective

Extend the builder so it:

- Considers every `provider` definition in `providers/` (all `*.json` files, not just the ones already listed in `settings.json`).
- Lets the user pick which providers are active via an interactive selection menu, and persists the chosen list back into `profiles/<profile>/settings.json`.
- Attaches the chosen provider's model list from profile-level `<provider>-models.json` files (`modal-models.json`, `omniroute-models.json`, ...) into the final `opencode.json`.

Resilience rule (regeneration guarantee)

The builder must be fully reproducible from documentation. If `scripts/*` are deleted, an
agent must be able to regenerate `build-opencode-v2.5.ps1` with every feature by reading
`BUILDER_SPEC.md` and `AI/BUILD_BUILDER_V2.5_SELECTOR.md`. The spec must describe every
stage, function contract, CLI switch, precedence rule, and file shape exactly.

Expected release

```
registry 2.4.0
```

---

## Phase 10.6 — JSON Schema Validation (schemas/)

Status

```
Planned — gate before Claude Code Builder V1
```

Objective

Implement JSON Schema validation for configuration files before the builder's own
validation runs:

```
profiles/<profile>/settings.json
providers/*.json
models.json
<provider>-models.json   (new in Phase 10.5)
plugins.json
mcp.json
```

Reserved location and workflow

`schemas/README.md` describes the future flow:

```

Configuration Files

↓

JSON Schema Validation

↓

Builder Validation

↓

Configuration Merge

↓

Generate opencode.json

```

Required before

Claude Code Builder V1 (Phase 11). Not built yet — record only.

---

## Phase 11 — Claude Code Builder V1

Status

```
Planned — after gates (Phases 10.5, 10.6)
```

Objective

Use the generalized framework (V2.5) to build the first Claude Code builder.

Do not redesign anything. Use the framework as-is.

This is the first real validation of the framework against a second project.

Discoveries made here (config format, provider system, validation differences) shape V3.

Per-project work is limited to:

```
ADAPTER.md

PROJECT_STATE.md

README.md

Folder Structure

Schema docs
```

Everything else is reused from the framework.

---

## Phase 12 — KiloCode Builder V1

Status

```
Planned
```

Objective

Use the same framework to build the KiloCode builder.

Second real validation of the framework against a third project.

---

## Phase 13 — BDF V3: Builder Generator

Status

```
Destination
```

Objective

Turn the framework into a generator of builder projects.

One command flow:

```
Create New Builder Project

↓

What software? (OpenCode / Claude Code / KiloCode)

↓

Read project schema

↓

Generate adapter

↓

Generate docs

↓

Generate folder structure

↓

Generate builder

↓

Generate tests

↓

Done
```

Definition of complete

- The same framework creates and maintains builders for OpenCode, Claude Code, and KiloCode.
- Only Project Adapters differ.
- No framework redesign is required per project.

V3 is the first stable public milestone — not the end of development.

---

# Long-Term Vision

The long-term objective is to build a configuration management system that is:

- Modular
- Extensible
- Predictable
- Well documented
- Easy for both humans and AI agents to maintain

The framework's destination is BDF V3 — the first stable public version that generates
builders for OpenCode, Claude Code, and KiloCode from a single reusable engineering
framework. Future features should extend the existing architecture rather than replacing it.

---

# Out of Scope

The following items are intentionally excluded until explicitly planned.

- GUI applications.
- Cloud synchronization.
- Automatic internet downloads.
- Features unrelated to configuration management.

Keeping the project focused is considered a design goal.

---

# Roadmap Maintenance

The roadmap should be reviewed whenever a major milestone is completed.

When a planned feature is implemented:

1. Remove it from this document.
2. Record it in `CHANGELOG.md`.
3. Update the relevant documentation.

Position on the road to V3 is tracked separately in:

```
_agent/JOURNEY_TO_V3.md
```

Update it whenever a roadmap phase advances.

This ensures that the roadmap always reflects future work rather than project history.

---

**Document Version:** 1.0

**Status:** Active Development Roadmap