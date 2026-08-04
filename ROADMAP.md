# ROADMAP

> Planned evolution of the OpenCode Configuration Manager.

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

This roadmap is intended to guide future development while keeping the overall project vision clear.

---

# Project Status

Current Version

```
2.2.0
```

Current Status

```
Stable Foundation
```

The project currently provides:

- Modular configuration
- Provider abstraction
- Profile abstraction
- Configuration builder (V2.1)
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

# Long-Term Vision

The long-term objective is to build a configuration management system that is:

- Modular
- Extensible
- Predictable
- Well documented
- Easy for both humans and AI agents to maintain

Future features should extend the existing architecture rather than replacing it.

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

This ensures that the roadmap always reflects future work rather than project history.

---

**Document Version:** 1.0

**Status:** Active Development Roadmap