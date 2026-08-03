# ROADMAP Template

> Template: planned evolution. Becomes `ROADMAP.md`.

---

# ROADMAP

> Planned evolution of {{PROJECT_NAME}}.

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
{{CURRENT_VERSION}}
```

Current Status

```
Stable Foundation
```

The project currently provides:

- Modular configuration
- Provider abstraction
- Profile abstraction
- Configuration builder
- Dynamic profile selection
- Dynamic provider loading
- Backup system
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

---

## Phase 2 — Builder Improvements

Status

```
Planned
```

Objectives

- Dynamic provider loading.
- Dynamic profile selection.
- Improved configuration validation.
- Better console output.
- Improved error reporting.
- Cleaner internal builder architecture.

---

## Phase 3 — Additional Profiles

Status

```
Planned
```

Objectives

Support multiple configuration profiles.

Example

```
{{CONFIG_SOURCE_DIR}}/

default/

minimal/

coding/

testing/
```

Possible Benefits

- Separate development environments.
- Faster startup configurations.
- Experimental configurations.
- Task-specific profiles.

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
{{PROVIDER_DIR}}/

{{CURRENT_PROVIDER}}.json

second-provider.json

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
Planned
```

Objectives

Introduce stronger configuration validation.

Possible additions

- Required key validation.
- Unknown key detection.
- Duplicate model detection.
- Duplicate provider detection.
- Schema validation.

Goal

Catch configuration errors before generation begins.

---

## Phase 6 — Automated Testing

Status

```
Planned
```

Objectives

Introduce automated verification.

Possible additions

- Builder unit tests.
- Configuration validation tests.
- Regression testing.
- Integration testing.
- Configuration comparison.

Goal

Reduce manual testing effort.

---

## Phase 7 — Builder Refactoring

Status

```
Planned
```

Objectives

Improve maintainability.

Possible improvements

- Smaller internal functions.
- Better logging.
- Improved diagnostics.
- Cleaner merge pipeline.
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
- Release Process.

Goal

Make onboarding easier for future contributors.

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

**Document Version:** {{DOC_VERSION}}

**Status:** Active Development Roadmap
