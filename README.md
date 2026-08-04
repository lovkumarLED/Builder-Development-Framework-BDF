# OpenCode Configuration Manager

> A modular configuration management system for OpenCode.

---

## Overview

The OpenCode Configuration Manager is a modular configuration system designed to simplify the management of OpenCode.

Instead of manually maintaining a large `opencode.json` file, the project separates configuration into smaller, independent files and automatically generates the final configuration through a builder script.

This approach makes the configuration easier to maintain, easier to extend, and significantly reduces the risk of configuration errors.

---

## Current Features

- Modular configuration architecture
- OmniRoute provider integration
- Profile-based configuration
- Dynamic profile selection
- Dynamic provider loading
- Separate model management
- Separate plugin management
- Separate MCP management
- Automatic configuration generation
- Automatic backup creation
- Extended configuration validation
- Provider-specific models
- Output verification
- Automated test harness
- Registry-driven release automation
- Structured project documentation

---

## Project Structure

The project is organized into several independent components.

| Component | Purpose |
|-----------|---------|
| `providers/` | Provider definitions |
| `profiles/` | Profile-specific configuration |
| `backup/` | Automatic configuration backups |
| `scripts/` | Builder scripts |
| `docs/` | Project documentation |

---

## Documentation Architecture

The documentation is organized into two layers.

### Layer 1 — Builder Development Framework

Reusable engineering knowledge shared by every builder project.

```
bdf/
```

This layer contains the engineering process, the blueprint engine, the project adapter concept, the builder evolution workflow, the framework lifecycle, the AI workflow, the project generation workflow, the migration guide, reusable lessons, and documentation templates.

See `bdf/README.md` for the full overview.

### Layer 2 — Project Documentation

OpenCode-specific documentation.

This layer describes the current implementation only.

The project-specific facts are defined in the project adapter:

```
ADAPTER.md
```

---

## Documentation

The project documentation is split into multiple files.

| Document | Description |
|----------|-------------|
| `AGENT.md` | AI agent entry guide |
| `ARCHITECTURE.md` | Overall system architecture |
| `DESIGN_PRINCIPLES.md` | Core engineering principles |
| `FOLDER_STRUCTURE.md` | Directory and file responsibilities |
| `JSON_SCHEMAS.md` | Configuration file schemas |
| `BUILDER_SPEC.md` | Builder implementation specification |
| `CONTRIBUTING_FOR_AI.md` | AI contribution rules |
| `TESTING.md` | Testing procedures |
| `TROUBLESHOOTING.md` | Common issues and fixes |
| `ROADMAP.md` | Planned future improvements |
| `CHANGELOG.md` | Project version history |
| `PROJECT_STATE.md` | Living state snapshot |
| `ADAPTER.md` | Project-specific facts |

---

## Current Status

### Implemented

- OpenCode configuration management
- OmniRoute provider
- Profile-based configuration
- Dynamic profile selection
- Dynamic provider loading
- Automatic configuration builder
- Backup system
- Project documentation

### Not Yet Implemented

The following features are planned but **are not currently part of the project**:

- Additional providers
- Advanced validation
- Extended CLI features

These planned features are documented only in `ROADMAP.md`.
---

## Source of Truth

The project follows a strict source-of-truth policy.

### Source Files

These files are intended to be edited manually.

- Provider definitions
- Profile configuration
- Documentation
- Builder scripts

### Generated Files

Generated files are never edited manually.

Current generated files:

- `opencode.json`
- `CURRENT_RELEASE.md`
- The marker sections in `CHANGELOG.md` and `PROJECT_STATE.md`
- The compatibility rows in `bdf/VERSION.md`

All changes should always be made to the source files and regenerated using the builder or the release manager.

---

## Releases

Releases follow a single automated workflow:

1. The AI records the release facts in `docs/release_registry.json`.
2. The user reviews the release facts.
3. The release manager generates all release documentation.

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/release-manager.ps1
```

4. Run the test harness (Release Docs group must pass).
5. Commit.

The registry is the only hand-edited release artifact.

Generated release files are never edited manually.

---

## Project Philosophy

This project follows a few simple principles:

- Keep configuration modular.
- Avoid duplicated configuration.
- Separate implementation from configuration.
- Prefer automation over manual editing.
- Document everything that exists.
- Keep future ideas separate from completed features.

---

## Project Status

The project is currently under active development.

All documentation describes the current implementation only.

Future features are intentionally excluded from the architecture and implementation documents until they are fully designed, implemented, and tested.

Planned work is documented separately in `ROADMAP.md`.

Generic engineering knowledge shared with other builder projects is documented separately in `bdf/`.

---

**Version:** 2.2.0

**Document Version:** 1.0

Documentation Status: Current Implementation