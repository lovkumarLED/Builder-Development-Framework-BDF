# New Project Guide

> The onboarding process for starting a NEW project with the Builder Development Framework.

---

# Purpose

This document is the human-facing onboarding process for starting a new builder project.

It is read by the human maintainer and their AI together.

It answers the question:

> How do I turn a target application into a builder project?

The framework already knows how to build builders.

A new project is mostly one thing: researching the target software and writing it down in
the Project Adapter.

Everything else is assembly.

---

# Audience

This document is a framework process document.

It is NOT generated into a project (there is no `NEW_PROJECT_GUIDE.template.md`).

It is the companion to the generator workflow:

```
NEW_PROJECT_GUIDE.md   (this guide: what to do, and why)
PROJECT_GENERATOR.md   (the generator: the stages in order)
```

---

# The One Principle

Project-specific knowledge lives ONLY in the adapter.

```
bdf/   →  generic engineering knowledge (Layer 1)
ADAPTER.md  →  every project-specific fact (Layer 2)
```

The framework stays generic.

Every fact about the target software is written into the Project Adapter.

If a fact is not in the adapter, it does not exist for the framework.

---

# The Numbered Steps

Every new project follows these steps in order.

```
1. Study the target software.
2. Create ADAPTER.md.
3. Create PROJECT_STATE.md.
4. Define folder structure.
5. Document configuration schema.
6. Run Blueprint Engine.
7. Generate Builder.
8. Generate Tests.
9. Generate Release Manager.
10. Commit.
```

No step may be skipped.

---

## Step 1 — Study the Target Software

The entire project begins with research.

Answer these questions about the target:

- What is the software? (OpenCode, KiloCode, or another same-architecture supported target)
- Where does the software store its configuration?
- What is the configuration file called?
- What fields exist in that configuration?
- Which fields are required and which are optional?
- What is the configuration's JSON schema or format?
- How does the software read the configuration at startup?

### Example — KiloCode

KiloCode stores its configuration in:

```
kilo.jsonc
```

The file lives in the configuration root directory, for example:

```
Windows:   %USERPROFILE%\.config\kilo\kilo.jsonc
macOS:     ~/.config/kilo/kilo.jsonc
Linux:     ~/.config/kilo/kilo.jsonc
```

KiloCode also reads project-adjacent files in specific locations, for example:

```
kilo/        config root with schemas, providers, profiles
AGENTS.md    project instructions
```

The exact file name, location, and fields are the research output of this step.

> Note: Claude Code was the original second-target example. It was dropped on 2026-08-08 — its config (`~/.claude.json`) is entropic and cannot support multiple providers (see `planning/DECISIONS.md`).

### Example — OpenCode

OpenCode stores its configuration in:

```
opencode.json
```

The file lives in the user configuration directory, for example:

```
Windows:   %USERPROFILE%\.config\opencode\opencode.json
macOS:     ~/.config/opencode/opencode.json
Linux:     ~/.config/opencode/opencode.json
```

### The Research Rule

Do not copy these examples.

Research the target software before writing anything.

Each target has its own file name, location, and fields.

Document the facts you verified — never facts you assume.

---

## Step 2 — Create ADAPTER.md

The adapter is the single source of project-specific facts.

Procedure:

1. Read `PROJECT_ADAPTER.md`.
2. Read `templates/ADAPTER.template.md`.
3. Copy the template into the project as `ADAPTER.md`.
4. Define every field from the field table in the template.
5. Replace every placeholder.

The adapter is complete when every field is defined and no placeholder remains.

---

## Step 3 — Create PROJECT_STATE.md

Copy `templates/PROJECT_STATE.template.md` into the project.

Fill in:

- The project name.
- The current folder structure.
- The current version.
- The components and their responsibilities.

The project state is the living snapshot of the repository.

It is regenerated after every major refactor.

---

## Step 4 — Define Folder Structure

Decide where every file lives.

Copy `templates/FOLDER_STRUCTURE.template.md`.

Define:

- The configuration source directory.
- The provider definitions directory (if the target has providers).
- The scripts directory.
- The backup directory.
- The documentation directory.
- The generated artifact location.

---

## Step 5 — Document Configuration Schema

Describe the format of every configuration file.

Copy `templates/JSON_SCHEMAS.template.md`.

Document only files that exist in the project.

The schema describes implemented configuration — never planned configuration.

---

## Step 6 — Run Blueprint Engine

The Blueprint Engine determines what must change and in what order.

Read:

```
BLUEPRINT_ENGINE.md
```

For a new project, the engine output is the complete new-project plan:

- Which documents are created.
- Which templates are copied.
- Which builder stages are implemented.
- Which tests verify the builder.
- Which version records are created.

---

## Step 7 — Generate Builder

Implement the builder following the builder specification.

Copy `templates/BUILDER_SPEC.template.md` first.

The builder must:

- Read configuration.
- Validate configuration.
- Create backups.
- Merge configuration.
- Generate the artifact.
- Stop on validation failure.

---

## Step 8 — Generate Tests

Create the automated test harness.

The generic test-harness pattern is defined in:

```
TESTING.md
```

Every builder project gets a reusable test harness script.

Test groups:

- Valid build.
- Failure modes.
- Release docs.

Tests must run headlessly and deterministically.

---

## Step 9 — Generate Release Manager

Set up the release system.

The generic release process is defined in:

```
RELEASE_MANAGER.md
```

Create the release registry and the release-manager script.

The registry is the only hand-edited release artifact.

The release manager generates all release documentation.

---

## Step 10 — Commit

Commit the complete project.

Before committing:

- All placeholders are replaced.
- All tests pass.
- The documentation describes only implemented functionality.
- The roadmap contains only future work.
- The changelog records the initial release.
- The release manager runs without errors.

---

# What Is the Target Config File?

The question "What is `kilo.jsonc`?" is a research question, not a framework question.

`kilo.jsonc` is the configuration artifact of KiloCode, just as `opencode.json` is the
configuration artifact of OpenCode.

The framework does not define either file.

The framework defines the process:

```
target software
↓
study it (Step 1)
↓
write the facts into ADAPTER.md (Step 2)
↓
build from the adapter (Steps 3-9)
```

Where a target stores config, what fields exist, and how they are shaped are project
knowledge.

That knowledge belongs in that project's `ADAPTER.md` — never in the framework.

The same rule applies to any target:

- OpenCode knowledge → the OpenCode adapter.
- KiloCode knowledge → the KiloCode adapter.

(Claude Code is out of scope — dropped 2026-08-08, see `planning/DECISIONS.md`.)

---

# Research Sources

To study a target, look at:

1. The software's official documentation.
2. The software's configuration files on your machine.
3. The software's source repository (configuration schema).
4. Community documentation and examples.

Verify everything you find.

A wrong fact in the adapter produces a broken builder.

---

# Checklist

- [ ] Target software studied and verified.
- [ ] ADAPTER.md created from the template with every field defined.
- [ ] PROJECT_STATE.md created.
- [ ] Folder structure defined.
- [ ] Configuration schema documented.
- [ ] Blueprint Engine run for the new-project plan.
- [ ] Builder generated and working.
- [ ] Tests generated and passing.
- [ ] Release manager generated and running.
- [ ] Project committed.

---

**Document Version:** 1.0

**Status:** Active New Project Guide
