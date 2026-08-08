# Project Adapter

> Making the Builder Development Framework project-specific.

---

# Purpose

The Builder Development Framework never assumes a specific application.

It remains generic.

Every builder project begins by defining its Project Adapter.

The adapter makes the framework project-specific.

```
BDF Framework (generic)

↓

Project Adapter (project-specific)

↓

Builder Project (concrete)
```

A new builder project requires only a new adapter.

The framework is never rewritten for a new project.

---

# What an Adapter Is

A Project Adapter is a document that describes how a builder project maps onto the framework.

It defines the project-specific values that the generic framework references.

The adapter lives inside the project documentation.

It is created from the adapter template when the project starts.

---

# Example Applications

The framework can be adapted to any application.

Examples:

- OpenCode
- KiloCode
- any open-source coding agent sharing their architecture
- Future applications

Claude Code is not a target (dropped 2026-08-08 — see `planning/DECISIONS.md`).

Every application follows the same process:

```
Framework + Adapter = Builder Project
```

---

# Adapter Contents

The adapter field table lives in exactly ONE place:

```
templates/ADAPTER.template.md
```

The template defines the twelve adapter fields and their definitions.

This document describes each field and refers to the template; it does not duplicate the
table.

Every adapter is complete only when every field listed in the template is defined.

## Field Descriptions

### Project Name

The name of the builder project.

The name appears in the project documentation and in the changelog.

### Configuration File

The source configuration files and their format.

This field defines what the builder reads.

### Folder Structure

The project folders and their responsibilities.

This field defines where every file lives.

### Supported Providers

The providers the project supports.

If the target application has no provider concept, the value states that explicitly.

### Supported Models

The models the project exposes.

### Supported Plugins

The plugins the project enables.

### Supported MCP

The MCP servers the project configures.

If the target application has no MCP concept, the value states that explicitly.

### Output Artifact

The final generated configuration file.

The builder generates this artifact.

It is never edited manually.

### Release Registry

The machine-readable release history file.

The only hand-edited release artifact.

### Release Artifacts

The generated release documentation files.

Never edited manually; generated from the registry.

### Release Manager Entry Point

The script or command that generates the release documentation from the registry.

### Builder Entry Point

The script or command that runs the builder.

The value must match a real script or command in the project.

---

# Adapter Rules

## Rule 1 — The Framework Stays Generic

The adapter contains all project-specific knowledge.

The framework contains none.

A project-specific statement belongs in the adapter, not in the framework.

---

## Rule 2 — One Adapter Per Project

Every builder project defines exactly one adapter.

The adapter is the single source of project-specific facts.

---

## Rule 3 — The Adapter Is Authoritative

When the framework references a project-specific value, the adapter defines it.

Example

```
Framework: The builder generates the project's final configuration artifact.

Adapter:   The output artifact is {{GENERATED_ARTIFACT}} in the reference implementation.
```

---

## Rule 4 — The Adapter Changes With the Project

When the project changes, the adapter changes.

Adapter changes follow the change pipeline defined by the Blueprint Engine.

---

## Rule 5 — No Placeholders in a Released Adapter

An adapter is released only when every placeholder is replaced.

A placeholder in a released adapter is a defect.

---

# Creating an Adapter

Follow the adapter workflow.

```
Read the Framework

↓

Read the Adapter Template

↓

Copy the Adapter Template

↓

Define Every Field

↓

Replace Every Placeholder

↓

Verify Consistency

↓

Release
```

---

## Step 1 — Read the Framework

Read:

```
FRAMEWORK.md
```

Understand the generic process before defining the project details.

---

## Step 2 — Read the Adapter Template

Read:

```
templates/ADAPTER.template.md
```

The template defines the required structure and placeholders.

---

## Step 3 — Copy the Adapter Template

Copy the template into the project documentation as:

```
ADAPTER.md
```

---

## Step 4 — Define Every Field

Fill in every field from the adapter field table in the template.

Use only facts about the target application.

---

## Step 5 — Replace Every Placeholder

Replace every placeholder with the project-specific value.

Never leave a placeholder.

---

## Step 6 — Verify Consistency

Check that:

- Every field is defined.
- Every placeholder is replaced.
- The adapter matches the project documentation.
- The adapter matches the current implementation.

---

## Step 7 — Release

Record the adapter in the project changelog.

The adapter is part of the project release.

---

# How the Framework Uses the Adapter

Every framework component reads the adapter when it needs project-specific knowledge.

| Component | Uses the Adapter For |
|-----------|----------------------|
| Blueprint Engine | Determining what a change affects. |
| Builder Evolution | Knowing the current builder state. |
| Framework Lifecycle | Knowing which stage the project is in. |
| Project Generator | Generating a new project's documents. |
| Templates | Replacing generic references with project values. |
| AI Workflow | Reading the correct entry points. |

---

# Validating an Adapter

Adapter validation is a yes/no checklist.

Every criterion is checkable against the adapter file and the project.

An adapter passes validation only when EVERY criterion below answers yes.

## Adapter Validation Checklist

| # | Criterion | How to check |
|---|-----------|--------------|
| 1 | Every field listed in `templates/ADAPTER.template.md` exists in `ADAPTER.md`. | Compare the field table in the template against the sections in the adapter. |
| 2 | Every field is defined with a real value, not left blank. | Read every field section in the adapter. |
| 3 | No `{{PLACEHOLDER}}` remains in a released adapter. | Search the released adapter for `{{`. |
| 4 | The project name matches the project. | Compare the Project Name field to the repository name. |
| 5 | The output artifact matches the generated builder output. | Run the builder and compare the artifact name. |
| 6 | The builder entry point matches an actual script or command in the project. | Check the referenced path exists in the project. |
| 7 | The folder structure matches the project folders. | Walk the project folders and compare. |
| 8 | Supported providers, models, plugins, and MCP match the project configuration. | Compare the lists against the source configuration files. |
| 9 | No builder behavior is referenced that the framework does not define. | Every behavior named in the adapter maps to a framework lifecycle stage. |

## Point of Failure

If any criterion answers no, the adapter is released only after the mismatch is fixed.

A placeholder in a released adapter is a defect (Rule 5).

An adapter that references behavior the framework does not define signals a framework gap:
decide whether to add a generic stage or move the fact into the adapter.

---

# Adapters and Future Builders

Creating a future builder is a two-input operation.

```
BDF Framework

+

New Project Adapter

↓

New Builder Project
```

Examples:

- OpenCode Builder → OpenCode Adapter
- Kilo Builder → Kilo Adapter
- Future Builder → Future Adapter

(Claude Builder was dropped 2026-08-08 — see `planning/DECISIONS.md`.)

The framework never requires rewriting.

Only a new adapter is needed.

---

**Document Version:** 1.0

**Status:** Active Project Adapter
