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
- Separate model management
- Separate plugin management
- Separate MCP management
- Automatic configuration generation
- Automatic backup creation
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

## Documentation

The documentation is split into multiple files.

| Document | Description |
|----------|-------------|
| `ARCHITECTURE.md` | Overall system architecture |
| `FOLDER_STRUCTURE.md` | Directory and file responsibilities |
| `JSON_SCHEMAS.md` | Configuration file schemas |
| `BUILDER_SPEC.md` | Builder implementation specification |
| `TESTING.md` | Testing procedures |
| `TROUBLESHOOTING.md` | Common issues and fixes |
| `ROADMAP.md` | Planned future improvements |
| `CHANGELOG.md` | Project version history |

---

## Current Status

### Implemented

- OpenCode configuration management
- OmniRoute provider
- Profile-based configuration
- Automatic configuration builder
- Backup system
- Project documentation

### Not Yet Implemented

The following features are planned but **are not currently part of the project**:

- Additional providers
- Multiple profile selection
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

Current generated file:

- `opencode.json`

All changes should always be made to the source files and regenerated using the builder.

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

---

**Version:** 1.0

Documentation Status: Current Implementation