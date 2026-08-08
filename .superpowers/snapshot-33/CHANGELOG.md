# CHANGELOG

> Chronological history of the OpenCode Configuration Manager.

---

# Purpose

This document records the history of significant project changes.

Only completed work should appear in this document.

Future plans belong exclusively in:

```
ROADMAP.md
```

The changelog should provide enough information for a developer to understand how the project evolved over time.

---

# Versioning Policy

The project follows a simple versioning strategy.

Major Version

Large architectural changes.

Minor Version

New functionality.

Patch Version

Bug fixes and documentation improvements.

Example

```
1.0.0

1.1.0

1.1.1
```

---

<!-- AUTO-GENERATED START -->

# Version 2.5.1

## Status

Current

---

## Date

```
2026-08-08
```

---

## Summary

Real-provider compatibility: the app and the builders now write the API key in both places agents read it (provider.<id>.apiKey for OpenCode, provider.<id>.options.apiKey for Kilo), fixing the TokenRouter 401 in Kilo. The AI Switcher gains real-provider presets (TokenRouter, Modal, OpenAI, Google Gemini, OpenRouter, NVIDIA NIM) with SDK auto-fill. Builders mirror the dual key automatically at merge time, so builder-only users get the same result as app users. 34 app unit tests, kilo harness 31/31, opencode harness 31/31.

---

## Highlights

- Dual key placement in app/app/agentstore.py write_provider (top-level apiKey + options.apiKey), options preserved on write
- Builder merge-stage dual-key normalization (K1 + V2.7 builders) — fixes hand-written provider files on the next build; kilo harness grows a dedicated test (31/31)
- Real-provider presets in the Add-provider form (URL + SDK auto-filled), presets kept in sync in app/app/config.py
- Kilo harness fixtures updated to per-provider models (the global models.json lookup was removed earlier; the fixtures still used it)
- Stale exact-name harness copy (test-kilo.ps1) replaced with the real K1 harness (backed up)
- User rules documented: never hand-edit the generated main config, never create opencode.jsonc next to opencode.json (it shadows the built config); generating both formats planned for a future update

---

## New Features

- Add-provider presets: TokenRouter, Modal, OpenAI, Google (Gemini), OpenRouter, NVIDIA NIM (SDK auto-fill on preset pick)
- Builder dual-key normalization with a "Dual-key: options.apiKey mirrored" build-log line

---

## Improvements

- OpenCode and Kilo both work from one provider file (no more "works in OpenCode, 401 in Kilo")
- Builder-only workflow produces identical output to the app workflow

---

## Bug Fixes

- Kilo 401 "Token not provided": key now lands in options.apiKey for runtime reading
- OpenCode /models not showing a provider: a stray opencode.jsonc (with disabled_providers) was shadowing the built opencode.json
- Kilo harness: 10 tests used the removed global-models fixture and failed after the model guard change — fixtures now use per-provider models
- PS 5.1: Add-Member required when creating a missing options object on parsed JSON

---

## Breaking Changes

None

---

## Migration Required

No

---

## Testing Summary

17/17 (V2.1) + 13/13 (V2.5) + 31/31 (V2.7) + 31/31 (Kilo K1) tests passed, exit code 0; 34 app unit tests

---

## Known Issues

None

---

## Documentation

Updated

- README.md
- app/README.md
- app/rule.md
- PROVIDER_DEVELOPMENT_GUIDE.md
- CHANGELOG.md
- PROJECT_STATE.md
- CURRENT_RELEASE.md
- release_registry.json
- ROADMAP.md
- bdf/VERSION.md
- _agent/JOURNEY_TO_V3.md

---

# Version 2.5.0

## Status

Previous

---

## Date

```
2026-08-06
```

---

## Summary

Builder V2.7 JSON Schema Validation: config sources validated against schemas/*.schema.json before builder validation (F1), pre-flight dependency check (F2), -WhatIf dry run (F3), backup retention (F4), provenance sidecar (F5), -Doctor diagnostics (F6), merge diff summary (F7), 9-stage pipeline. P2 dynamic target artifact (profiles/<profile>/target.json) + P1 env-key policy.

---

## Highlights

- F1 JSON Schema validation (seven live schemas under schemas/)
- F2 pre-flight dependency check catches missing provider files before any merge
- F3 -WhatIf dry run (validate + merge, write nothing)
- F4 backup retention via -KeepBackups (default 10), artifact-prefix aware
- F5 provenance sidecar opencode.provenance.json
- F6 -Doctor read-only diagnostics (exit 0 clean / 1 issues)
- F7 merge diff summary vs previous backup
- P2 dynamic target artifact: optional profiles/<profile>/target.json -> {artifact} drives output, backup prefix, provenance, WhatIf; default opencode.json
- P1 env-key policy: builder never carries/restores/invents API keys; providers carry {env:VAR} placeholders only
- 31-test V2.7 harness in addition to 17/17 (V2.1) + 13/13 (V2.5)

---

## New Features

- scripts/build-opencode-v2.7.ps1
- scripts/test-opencode-v2.7.ps1 (31 tests)
- schemas/schema.json, settings.schema.json, provider.schema.json, models.schema.json, plugins.schema.json, mcp.schema.json, targets.schema.json
- -SchemaDir, -WhatIf, -KeepBackups, -Doctor, -ProvenancePath CLI flags
- profiles/<profile>/target.json (P2 dynamic artifact)

---

## Improvements

- Schema validation powers an entry gate before any merge
- Backups pruned to the newest N per prefix
- Provenance stamping without touching opencode.json
- Real-world build reproducibility (identical output + silent diff on rerun)

---

## Bug Fixes

- F7 diff summary correctly enumerates IDictionary backup properties (OrderedDictionary)
- Doctor no longer faults on missing settings file path
- Empty active-provider lists no longer produce a phantom '' provider reference

---

## Breaking Changes

None

---

## Migration Required

No

---

## Testing Summary

17/17 (V2.1) + 13/13 (V2.5) + 31/31 (V2.7) tests passed, exit code 0

---

## Known Issues

None

---

## Documentation

Updated

- BUILDER_SPEC.md
- JSON_SCHEMAS.md
- TESTING.md
- ARCHITECTURE.md
- FOLDER_STRUCTURE.md
- ADAPTER.md
- README.md
- bdf/TESTING.md
- bdf/VERSION.md
- schemas/README.md
- release_registry.json

---

# Version 2.4.0

## Status

Previous

---

## Date

```
2026-08-05
```

---

## Summary

Builder V2.5 Active-Provider Selector: discovers all providers, interactive active-provider selection persisted to settings.json, profile-level <provider>-models.json with highest precedence.

---

## Highlights

- All-provider discovery (providers/*.json)
- Interactive active-provider selection persisted to profile settings.json
- Profile-level per-provider model files (<provider>-models.json)
- -Provider / -NonInteractive CLI switches
- Active providers without a models source are dropped (with a warning) instead of failing the build
- 13-test V2.5 harness + builder-regeneration guarantee in docs

---

## New Features

- scripts/build-opencode-v2.5.ps1
- scripts/test-opencode-v2.5.ps1
- profiles/<profile>/<provider>-models.json

---

## Improvements

- Model precedence: profile <provider>-models.json > providers/<p>/models.json > inline > global
- settings.json backed up before activeProviders write

---

## Bug Fixes

- settings.json no longer rewritten when the active-provider list is unchanged (no-op runs keep the file byte-identical)

---

## Breaking Changes

None

---

## Migration Required

No

---

## Testing Summary

17/17 (V2.1) + 13/13 (V2.5) tests passed, exit code 0

---

## Known Issues

None

---

## Documentation

Updated

- BUILDER_SPEC.md
- JSON_SCHEMAS.md
- FOLDER_STRUCTURE.md
- ADAPTER.md
- ARCHITECTURE.md
- TESTING.md
- README.md
- PROJECT_STATE.md
- CHANGELOG.md
- CURRENT_RELEASE.md
- bdf/VERSION.md
- _agent/JOURNEY_TO_V3.md

---

# Version 2.3.0

## Status

Previous

---

## Date

```
2026-08-04
```

---

## Summary

BDF V2.5 framework generalization: generalized the framework for reuse across OpenCode, Claude Code, and KiloCode targets.

---

## Highlights

- Framework generalization (first step to BDF V3)
- Single source of truth for adapter fields
- Testable adapter validation checklist
- Impact Analysis record for the Blueprint Engine
- Generic release process documented (RELEASE_MANAGER.md)
- Generic test-harness pattern documented (TESTING.md)

---

## New Features

- bdf/NEW_PROJECT_GUIDE.md - the onboarding process for starting a new project with the framework
- bdf/RELEASE_MANAGER.md - the generic release process document (registry, generator, generated documents)
- bdf/TESTING.md - the generic test-harness pattern document
- Adapter field table now lives only in templates/ADAPTER.template.md (single source of truth)
- Adapter validation checklist (executable yes/no criteria) in PROJECT_ADAPTER.md
- Impact Analysis record required output of the Blueprint Engine Impact Analysis stage

---

## Improvements

- Framework boundaries audited: OpenCode-specific file names removed from bdf/ (Layer 1 no longer depends on Layer 2)
- templates/README.md: placeholder audit ({{PLACEHOLDER_NAME}} row added), cross-reference matrix, provider placeholders confirmed generic, template sync rule stated
- FRAMEWORK.md and bdf/README.md register the three new framework documents
- Reference ADAPTER.md passes the new adapter validation checklist
- docs/TESTING.md aligned with bdf/TESTING.md (test groups + definition of complete)

---

## Bug Fixes

- Removed OpenCode-specific file names from bdf/MIGRATION.md and bdf/PROJECT_ADAPTER.md examples
- Generalized a Layer 2 description in bdf/MIGRATION.md from OpenCode-specific to project-specific

---

## Breaking Changes

None

---

## Migration Required

No

---

## Testing Summary

17/17 tests passed, exit code 0

---

## Known Issues

None

---

## Documentation

Updated

- bdf/NEW_PROJECT_GUIDE.md (new)
- bdf/RELEASE_MANAGER.md (new)
- bdf/TESTING.md (new)
- bdf/FRAMEWORK.md
- bdf/PROJECT_ADAPTER.md
- bdf/AI_WORKFLOW.md
- bdf/PROJECT_GENERATOR.md
- bdf/BLUEPRINT_ENGINE.md
- bdf/MIGRATION.md
- bdf/README.md
- bdf/VERSION.md
- bdf/templates/README.md
- bdf/templates/ADAPTER.template.md
- ADAPTER.md
- PROJECT_STATE.md
- ROADMAP.md
- TESTING.md
- CHANGELOG.md
- CURRENT_RELEASE.md
- _agent/JOURNEY_TO_V3.md

---

# Version 2.2.0

## Status

Previous

---

## Date

```
2026-08-04
```

---

## Summary

Builder V2.1: extended validation, modular merge pipeline, provider-specific models, output verification, and automated testing.

---

## Highlights

- Provider-specific models
- Modular merge pipeline
- Extended validation
- Pre-write output verification
- Automated test harness

---

## New Features

- scripts/test-opencode-v2.ps1 - automated test harness (17 tests: 9 builder + 8 Release Docs)
- Provider-specific models: providers/<provider>/models.json takes precedence over inline provider models and global models.json
- -ConfigRoot parameter on the builder for isolated test builds
- Output verification stage (JSON round-trip, providers, models, plugins, MCP) before writing

---

## Improvements

- Validation extended: duplicate provider/model/plugin/MCP identifiers, duplicate model names, malformed provider and profile definitions, missing required fields, invalid configuration structure
- Duplicate-key detection scans raw JSON text (PowerShell 5.1 ConvertFrom-Json silently drops duplicates)
- Merge logic split into independent stages: settings, providers, models, plugins, MCP, final
- Concise count-based logging (e.g. Provider 'omniroute': 58 model(s))

---

## Bug Fixes

- Fixed $Section: here-string parse errors
- Fixed unreliable PSObject.Properties.Count checks (wrapped with @())
- Fixed plugin single-element array unrolling in output (return ,$Plugins.plugin)
- Removed 2 corrupted backups created during intermediate buggy runs

---

## Breaking Changes

None

---

## Migration Required

No

---

## Testing Summary

17/17 tests passed, exit code 0

---

## Known Issues

None

---

## Documentation

Updated

- BUILDER_SPEC.md
- CHANGELOG.md
- PROJECT_STATE.md
- TESTING.md
- ROADMAP.md
- FOLDER_STRUCTURE.md
- ARCHITECTURE.md
- ADAPTER.md
- README.md
- bdf/VERSION.md
<!-- AUTO-GENERATED END -->

# Version 2.1.0

## Status

Previous

## Date

```
2026-08-03
```

## Summary

Documentation architecture: adopted the Builder Development Framework (BDF) upgrade.

---

## Added

- `bdf/BLUEPRINT_ENGINE.md` — the intelligence layer and change pipeline.
- `bdf/PROJECT_ADAPTER.md` — the project adapter concept.
- `bdf/BUILDER_EVOLUTION.md` — predictable builder evolution workflow.
- `bdf/FRAMEWORK_LIFECYCLE.md` — master lifecycle reference.
- `bdf/AI_WORKFLOW.md` — the master AI agent workflow.
- `bdf/templates/ADAPTER.template.md` — project adapter template.
- `ADAPTER.md` — the OpenCode project adapter (first implementation).

---

## Changed

- Framework renamed from Blueprint Framework to Builder Development Framework (BDF).
- Framework folder renamed from `blueprint/` to `bdf/`.
- `AGENT.md` read order now includes `ADAPTER.md`.
- `README.md`, `AGENT.md`, and `FOLDER_STRUCTURE.md` updated to reference `bdf/`.
- Framework version bumped to 2.0.0 (breaking change, migration in `bdf/MIGRATION.md`).

---

## Documentation

Updated

- README.md
- AGENT.md
- FOLDER_STRUCTURE.md
- CHANGELOG.md
- PROJECT_STATE.md
- bdf/README.md
- bdf/FRAMEWORK.md
- bdf/VERSION.md
- bdf/MIGRATION.md
- bdf/PROJECT_GENERATOR.md
- bdf/LESSONS_LEARNED.md
- bdf/templates/README.md
- bdf/templates/PROJECT_STATE.template.md

---

## Breaking Changes

None

---

# Version 2.0.3

## Status

Previous

## Date

```
2026-08-03
```

## Summary

Documentation infrastructure: added the project state system.

---

## Added

- `PROJECT_STATE.md` with the 15-section living state snapshot.
- `blueprint/templates/PROJECT_STATE.template.md` generic template.
- Project state section in AGENT.md.
- Project state regeneration rules.

---

## Changed

- AGENT.md now requires `PROJECT_STATE.md` regeneration after every major refactor.
- AGENT.md read order now includes `PROJECT_STATE.md`.
- `_agent/SESSION_WORKFLOW.md` now reads `PROJECT_STATE.md` at session start and regenerates it at session end after a major refactor.

---

## Documentation

Updated

- AGENT.md
- README.md
- FOLDER_STRUCTURE.md
- ROADMAP.md
- CHANGELOG.md
- _agent/SESSION_WORKFLOW.md
- blueprint/VERSION.md
- blueprint/templates/README.md

---

## Breaking Changes

None

---

# Version 2.0.2

## Status

Previous

## Date

```
2026-08-03
```

## Summary

Documentation infrastructure: added the session continuity system.

---

## Added

- `_agent/SESSION_WORKFLOW.md` with session start, end, and log rules.
- `_agent/SESSION_LOG.md` with the session history.
- Session continuity section in AGENT.md.

---

## Changed

- AGENT.md now guides agents to read session files at session start and write them at session end.

---

## Documentation

Updated

- AGENT.md
- FOLDER_STRUCTURE.md
- CHANGELOG.md

---

## Breaking Changes

None

---

# Version 2.0.1

## Status

Previous

## Date

```
2026-08-03
```

## Summary

Documentation architecture: added the reusable Blueprint Framework.

---

## Added

- `blueprint/` folder containing the reusable engineering process.
- Blueprint documentation templates.
- Blueprint versioning.
- Project generation workflow.
- Migration guide.
- Reusable lessons document.

---

## Changed

- README.md now describes the two-layer documentation architecture.
- AGENT.md points to the Blueprint Framework for generic engineering knowledge.
- FOLDER_STRUCTURE.md documents the `blueprint/` and `AI/` folders.

---

## Documentation

Updated

- README.md
- AGENT.md
- FOLDER_STRUCTURE.md
- CHANGELOG.md

---

## Breaking Changes

None

---

# Version 2.0.0

## Status

Previous

## Date

```
2026-08-03
```

## Summary

Builder V2 implementation.

---

## Added

- Dynamic profile selection.
- Dynamic provider loading.
- Optional profile sections.
- Improved validation.
- Better console output.
- Improved error reporting.

---

## Changed

- The current builder is now `build-opencode-v2.ps1`.
- The previous builder is retained as a legacy script.
- Models are injected into every active provider.
- Optional profile sections are merged only when present.

---

## Documentation

Updated

- BUILDER_SPEC.md
- ARCHITECTURE.md
- FOLDER_STRUCTURE.md
- TESTING.md
- ROADMAP.md
- CHANGELOG.md

---

## Breaking Changes

None

---

# Version 1.0.0

## Status

Legacy

## Summary

Initial implementation of the OpenCode Configuration Manager.

---

## Added

- Modular project structure.
- Provider configuration.
- Profile configuration.
- Builder implementation.
- Backup system.
- Documentation framework.

---

## Documentation

Created

- README.md
- ARCHITECTURE.md
- FOLDER_STRUCTURE.md
- JSON_SCHEMAS.md
- BUILDER_SPEC.md
- DESIGN_PRINCIPLES.md
- CONTRIBUTING_FOR_AI.md
- TESTING.md
- TROUBLESHOOTING.md
- CHANGELOG.md

---

## Architecture

Implemented

- Source configuration.
- Generated configuration.
- Configuration builder.
- Provider abstraction.
- Profile abstraction.

---

## Builder

Implemented

- Configuration loading.
- Validation.
- Configuration merging.
- Backup creation.
- Configuration generation.

---

## Testing

Implemented

- Manual testing guide.
- Verification procedures.
- Regression testing procedures.

---

## Known Limitations

Current implementation supports:

- One provider.
- One active profile.
- Manual testing.

Future enhancements will be tracked separately in

```
ROADMAP.md
```

---

# Version History

| Version | Status | Description |
|----------|--------|-------------|
| 2.5.1 | Current | Real-provider compatibility: dual-key placement (apiKey + options.apiKey), real-provider presets, builder dual-key normalization |
| 2.4.0 | Previous | Builder V2.5 Active-Provider Selector |
| 2.3.0 | Previous | BDF V2.5 framework generalization |
| 2.2.0 | Previous | Builder V2.1 (validation, merge pipeline, provider-specific models, verification, automated tests) |
| 2.1.0 | Previous | Builder Development Framework adoption |
| 2.0.3 | Previous | Project state system |
| 2.0.2 | Previous | Session continuity system |
| 2.0.1 | Previous | Blueprint Framework documentation architecture |
| 2.0.0 | Previous | Builder V2 implementation |
| 1.0.0 | Legacy | Initial project implementation |

---

# Recording Future Changes

Every new version should include:

- Version number
- Date
- Summary
- Added
- Changed
- Fixed
- Removed
- Documentation updates
- Breaking changes (if any)

---

# Example

## Version 1.1.0

Date

```
YYYY-MM-DD
```

### Added

- New feature

### Changed

- Existing behavior

### Fixed

- Bug fixes

### Removed

- Removed functionality

### Documentation

- Updated documentation

### Breaking Changes

None

---

# Guidelines

Do not record:

- Planned features.
- Experimental work.
- Incomplete implementations.

Only completed and verified changes should appear in this document.

---

**Document Version:** 1.0

**Status:** Active Changelog