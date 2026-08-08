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
builders for **OpenCode**, **KiloCode**, and any open-source coding agent sharing their
architecture, without redesigning the framework.

Only Project Adapters should differ between supported projects.

The path is:

```
Current (Builder V2.7 JSON Schema Validation) ✅
↓
KiloCode Builder V1 ✅ (Kilo V1, harness 30/30)
↓
BDF V3 (Universal Builder Generator) — in progress
```

Claude Code is NOT on this path (entropic config, no provider support — DECISIONS.md 2026-08-08).

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
Step 3 Universal Agent Framework core — IN PROGRESS (~90%); BDF V2.5 ✅, V2.7 gate ✅, KiloCode V1 COMPLETE ✅; next: BUILDER_PHASES gates for the universal framework, then Step 4 / Step 5
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

## Phase 4 — Additional Providers ✅

Status

```
Completed — dynamic provider loading (V2.2) + all-provider discovery (V2.5)
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

## Phase 5 — Validation Framework ✅

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

## Phase 6 — Automated Testing ✅

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

## Phase 7 — Builder Refactoring ✅

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

Make the framework reusable across OpenCode, KiloCode, and any same-architecture
open-source coding agent without redesign.

---

## Phase 10.5 — Active-Provider Selector Builder (V2.5 Builder) ✅

Status

```
Completed — released as registry 2.4.0 (2026-08-05)
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

## Phase 10.6 — JSON Schema Validation (schemas/) ✅

Status

```
Completed — gate before KiloCode Builder V1 (V2.7, F1-F7, harness 31/31)
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

KiloCode Builder V1 (Phase 12 — COMPLETED 2026-08-07, harness 30/30).

Note: Claude Code Builder V1 (Phase 11) is DROPPED — decision 2026-08-08,
see `planning/DECISIONS.md`. Claude config (`~/.claude.json`) is entropic and does not
support adding providers; it will never work with this framework.

---

## Phase 11 — Claude Code Builder V1 — SUPERSEDED ✅

Status

```
RESOLVED — DROPPED, replaced by KiloCode (Phase 12) + universal scaffold (Phase 13)
```

Decision: 2026-08-08. Claude Code config is a huge entropic `~/.claude.json` with no way
to add providers (one provider at a time) — building a maintainable Claude builder from
BDF is not feasible. Record kept for history.

---

## Phase 12 — KiloCode Builder V1 ✅

Status

```
COMPLETED 2026-08-07 — Kilo V1: build-kilo-v1.ps1, test-kilo-v1.ps1, scaffold-kilo-v1.ps1; harness 30/30 (KILO_ADAPTER + real ~/.config/kilo)
```

Objective

Use the same framework to build the KiloCode builder.

Second real validation of the framework against a second project.

---

## Phase 13 — BDF V3: Universal Builder Generator 🔄

Status

```
IN PROGRESS — core built (session 24b) + scaffold contract finalized (session 28):
scaffold-agent.ps1 universal, registry opencode/kilo/other, -Bootstrap generates per-agent builders
```

Objective

Turn the framework into a generator of builder projects.

One command flow:

```
Create New Builder Project

↓

Discover installed open-source coding agents (OpenCode / Kilo / any same-architecture)

↓

Choose agent

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

- The same framework creates and maintains builders for OpenCode, KiloCode, and ANY
  open-source coding agent (Aider, Goose, Codex-Cli, ...) — discovery finds whatever
  open-source agents are installed; if none are found, the framework asks the user for
  the location of their coding agents.
- Only Project Adapters differ.
- No framework redesign is required per project — main configs (JSON), profiles, MCP,
  plugin-splitting, per-agent generated build/test/scaffold scripts.
- The scaffold's ONE job for any agent: scan the agent's OWN main JSON, split it into
  mcp / plugin sections, and seed the profiles — `coding` (always the main profile) +
  `experimental` + `minimal`, each with `settings.json`, `mcp.json`, `plugins.json`.
- The framework creates the `providers/` folder but NEVER writes provider or model
  files inside it — providers and models are 100% user-owned. The framework never
  copies another agent's config into a project; each agent's profiles are seeded
  from its own main JSON.
- Claude Code is NOT supported (DECISIONS.md 2026-08-08).

V3 is the first stable public milestone — not the end of development.

---

# Phase Completion Summary

| Phase | Status |
|-------|--------|
| Phase 1 — Foundation | ✅ Completed |
| Phase 2 — Builder Improvements | ✅ Completed |
| Phase 3 — Multiple Profiles | ✅ Completed |
| Phase 4 — Additional Providers | ✅ Completed |
| Phase 5 — Validation Framework | ✅ Completed |
| Phase 6 — Automated Testing | ✅ Completed |
| Phase 7 — Builder Refactoring | ✅ Completed |
| Phase 8 — Documentation Expansion | ⬜ Planned |
| Phase 9 — Release Manager V1 | ✅ Completed |
| Phase 10 — BDF V2.5 Framework Generalization | ✅ Completed |
| Phase 10.5 — Active-Provider Selector Builder | ✅ Completed |
| Phase 10.6 — JSON Schema Validation | ✅ Completed |
| Phase 11 — Claude Code Builder V1 | ✅ Resolved (dropped → KiloCode) |
| Phase 12 — KiloCode Builder V1 | ✅ Completed |
| Phase 13 — BDF V3 Universal Builder Generator | 🔄 In Progress |

**12 of 13 phases complete. Remaining: Phase 8 (documentation expansion guides) and
the final V3 release steps (Phase 13).**

---

# Long-Term Vision

The long-term objective is to build a configuration management system that is:

- Modular
- Extensible
- Predictable
- Well documented
- Easy for both humans and AI agents to maintain

The framework's destination is BDF V3 — the first stable public version that generates
builders for OpenCode, KiloCode, and any same-architecture open-source coding agent from
a single reusable engineering framework. Future features should extend the existing
architecture rather than replacing it.

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