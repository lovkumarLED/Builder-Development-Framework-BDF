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
- Claude Code
- Kilo Code
- Cursor
- Continue
- Codex
- Future applications

Every application follows the same process:

```
Framework + Adapter = Builder Project
```

---

# Adapter Contents

Every adapter describes the following items.

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

The adapter is complete only when every field is defined.

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

Adapter:   The output artifact is opencode.json.
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

Fill in every field from the adapter contents table.

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

An adapter passes validation when:

- Every field in the contents table is defined.
- Every placeholder is replaced.
- The project name matches the project.
- The output artifact matches the builder output.
- The builder entry point matches the actual script or command.
- The folder structure matches the project folders.
- Supported providers, models, plugins, and MCP match the project configuration.

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
- Claude Builder → Claude Adapter
- Kilo Builder → Kilo Adapter
- Future Builder → Future Adapter

The framework never requires rewriting.

Only a new adapter is needed.

---

**Document Version:** 1.0

**Status:** Active Project Adapter
