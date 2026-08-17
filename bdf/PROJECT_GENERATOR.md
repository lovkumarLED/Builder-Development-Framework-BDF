# Project Generator

> Creating a new builder project using the Builder Development Framework.

---

# Purpose

This document explains how a completely new builder project is created.

The workflow is generic.

It applies to any target application, any scripting language, and any future builder project.

The human-facing onboarding process (what to do, and why) is documented separately:

```
NEW_PROJECT_GUIDE.md
```

This document is the machine of the same workflow: the stages in order.

Read the guide first, then follow the stages below.

---

# Overview

```
Idea

↓

Create Repository

↓

Define Project Adapter

↓

Copy Framework Templates

↓

Rename Templates

↓

Customize Schemas

↓

Implement Builder

↓

Testing

↓

Release
```

Every stage must be completed in order.

Do not skip stages.

---

# Stage 1 — Idea

Define the project before creating anything.

## Decide

- What configuration does the target application need?
- Where does the configuration come from?
- What is the generated configuration artifact?
- Who maintains the source configuration?

## Check the Framework

Read:

```
FRAMEWORK.md
```

Confirm that the builder lifecycle matches the idea:

```
Sources → Validate → Backup → Merge → Generate → Application
```

If the idea does not fit the lifecycle, reconsider the idea before starting.

---

# Stage 2 — Create Repository

Create a repository for the new project.

## Structure

The repository contains:

```
README.md

AGENT.md

ARCHITECTURE.md

BUILDER_SPEC.md

DESIGN_PRINCIPLES.md

FOLDER_STRUCTURE.md

JSON_SCHEMAS.md

CONTRIBUTING_FOR_AI.md

TESTING.md

TROUBLESHOOTING.md

ROADMAP.md

CHANGELOG.md

PROJECT_STATE.md

LESSONS_LEARNED.md

source configuration directories
```

## Rules

- The Builder Development Framework is shared knowledge; projects reference it.
- Do not copy the framework into the repository unless the project needs an independent copy.
- Never commit generated files.

---

# Stage 3 — Define Project Adapter

Every new builder project begins by defining its adapter.

## Procedure

1. Read `PROJECT_ADAPTER.md`.
2. Copy `templates/ADAPTER.template.md` into the repository documentation as `ADAPTER.md`.
3. Define every field.
4. Replace every placeholder.

## Adapter Fields

| Field | Definition |
|-------|------------|
| Project Name | The name of the builder project. |
| Configuration File | The source configuration files and their format. |
| Folder Structure | The project folders and their responsibilities. |
| Supported Providers | The providers the project supports. |
| Supported Models | The models the project exposes. |
| Supported Plugins | The plugins the project enables. |
| Supported MCP | The MCP servers the project configures. |
| Output Artifact | The final generated configuration file. |
| Builder Entry Point | The script or command that runs the builder. |

## Rules

- The framework remains generic.
- The adapter contains all project-specific knowledge.
- The adapter is complete before templates are customized.
- The scaffold seeds `lsp.json` (disabled by default, user-owned after creation)
  in every profile alongside `mcp.json`/`plugins.json`.

---

# Stage 4 — Copy Framework Templates

Copy every template from the framework templates folder into the repository documentation folder.

```
templates/
```

Copy:

- `README.template.md`
- `AGENT.template.md`
- `ARCHITECTURE.template.md`
- `DESIGN_PRINCIPLES.template.md`
- `BUILDER_SPEC.template.md`
- `FOLDER_STRUCTURE.template.md`
- `JSON_SCHEMAS.template.md`
- `CONTRIBUTING_FOR_AI.template.md`
- `DEVELOPER_GUIDE.template.md`
- `PROVIDER_DEVELOPMENT_GUIDE.template.md`
- `PROFILE_CREATION_GUIDE.template.md`
- `BUILDER_EXTENSION_GUIDE.template.md`
- `TESTING.template.md`
- `TROUBLESHOOTING.template.md`
- `ROADMAP.template.md`
- `CHANGELOG.template.md`
- `LESSONS_LEARNED.template.md`
- `PROJECT_STATE.template.md`

The `ADAPTER.template.md` is copied in Stage 3.

---

# Stage 5 — Rename Templates

Rename every template to its project document name.

```
README.template.md          →  README.md

AGENT.template.md           →  AGENT.md

ARCHITECTURE.template.md    →  ARCHITECTURE.md

DESIGN_PRINCIPLES.template.md → DESIGN_PRINCIPLES.md

BUILDER_SPEC.template.md    →  BUILDER_SPEC.md

FOLDER_STRUCTURE.template.md → FOLDER_STRUCTURE.md

JSON_SCHEMAS.template.md    →  JSON_SCHEMAS.md

CONTRIBUTING_FOR_AI.template.md → CONTRIBUTING_FOR_AI.md

DEVELOPER_GUIDE.template.md    →  DEVELOPER_GUIDE.md

PROVIDER_DEVELOPMENT_GUIDE.template.md → PROVIDER_DEVELOPMENT_GUIDE.md

PROFILE_CREATION_GUIDE.template.md → PROFILE_CREATION_GUIDE.md

BUILDER_EXTENSION_GUIDE.template.md → BUILDER_EXTENSION_GUIDE.md

TESTING.template.md         →  TESTING.md

TROUBLESHOOTING.template.md →  TROUBLESHOOTING.md

ROADMAP.template.md         →  ROADMAP.md

CHANGELOG.template.md       →  CHANGELOG.md

PROJECT_STATE.template.md   →  PROJECT_STATE.md

LESSONS_LEARNED.template.md →  LESSONS_LEARNED.md
```

---

# Stage 6 — Customize Schemas

Replace every placeholder with project-specific values.

See the placeholder table in the templates readme.

## Decisions To Make

| Decision | Example |
|----------|---------|
| Project name | Configuration Manager |
| Target application | The program that consumes the artifact |
| Generated artifact | The final configuration file |
| Builder script name | The automation entry point |
| Source configuration directory | Where configuration lives |
| Provider directory | Where provider definitions live |
| Default profile | The default configuration set |
| Scripting language | The builder implementation language |
| Supported operating system | The development platform |

## Rules

- Never leave a placeholder in a project document.
- Never hardcode configuration inside implementation.
- Schemas describe only implemented configuration files.

---

# Stage 7 — Implement Builder

Implement the builder following the specification.

```
BUILDER_SPEC.md
```

## Builder Requirements

The builder MUST:

- Read configuration.
- Validate configuration.
- Create backups.
- Merge configuration.
- Generate the artifact.
- Report errors clearly.
- Stop on validation failure.

The builder MUST NOT:

- Modify source files.
- Modify documentation.
- Continue after validation failure.
- Generate partial output.

## Implementation Rules

- Configuration belongs in configuration files.
- Implementation belongs in the builder.
- The builder never defines configuration.
- Every component has one responsibility.

---

# Stage 8 — Testing

Test the project following the testing guide.

```
TESTING.md
```

## Verify

- Folder structure exists.
- Configuration files are valid.
- Builder executes successfully.
- Backup is created.
- Generated artifact is valid.
- Target application starts.
- Configured functionality is available.
- Existing functionality is not broken.

Every test must pass before release.

---

# Stage 9 — Release

Release the project.

## Before Release

- All tests pass.
- Documentation describes the current implementation only.
- The roadmap contains only future work.
- The changelog records completed work.
- No placeholders remain.
- Generated files are reproducible.

## Versioning

Follow the project versioning policy in the changelog template.

## Record

- Set the initial project version.
- Record the release in the changelog.
- Update the roadmap if completed phases exist.

---

# After Release

The project is now an implementation of the Builder Development Framework.

Future maintenance follows the framework process:

- Small changes.
- Documentation synchronized with implementation.
- Changelog for completed work.
- Roadmap for future work.
- Lessons returned to the framework when they become reusable.

---

# Checklist

- [ ] Idea fits the builder lifecycle.
- [ ] Repository created.
- [ ] Project adapter defined.
- [ ] Templates copied.
- [ ] Templates renamed.
- [ ] All placeholders replaced.
- [ ] Schemas describe only implemented files.
- [ ] Builder implemented per specification.
- [ ] All tests pass.
- [ ] Documentation consistent.
- [ ] Release recorded in changelog.

---

**Document Version:** 1.1

**Status:** Active Project Generator
