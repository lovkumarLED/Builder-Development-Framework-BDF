# ADAPTER Template

> Template: project adapter. Becomes `ADAPTER.md`.

---

# Project Adapter

> Project-specific facts for {{PROJECT_NAME}}.

---

# Purpose

This document defines how the Builder Development Framework applies to {{PROJECT_NAME}}.

The framework is generic.

This adapter makes the framework project-specific.

Every field in this document defines a project-specific fact.

---

# Adapter Contents

The adapter is complete only when every field in the following table is defined.

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

This table is the single source of truth for the adapter fields.

The framework document `PROJECT_ADAPTER.md` describes each field and refers to this table;
it does not duplicate it.

Every section below defines one field.

## Project Name

```
{{PROJECT_NAME}}
```

---

## Configuration File

The source configuration files and their format.

```
{{CONFIG_FILE}}
```

---

## Folder Structure

The project folders and their responsibilities.

```
{{FOLDER_TREE}}
```

---

## Supported Providers

The providers the project supports.

```
{{SUPPORTED_PROVIDERS}}
```

---

## Supported Models

The models the project exposes.

```
{{SUPPORTED_MODELS}}
```

---

## Supported Plugins

The plugins the project enables.

```
{{SUPPORTED_PLUGINS}}
```

---

## Supported MCP

The MCP servers the project configures.

```
{{SUPPORTED_MCP}}
```

---

## Output Artifact

The final generated configuration file.

```
{{GENERATED_ARTIFACT}}
```

The builder generates this artifact from the source configuration.

It is never edited manually.

---

## Builder Entry Point

The script or command that runs the builder.

```
{{BUILDER_SCRIPT}}
```

---

# Adapter Rules

- The framework stays generic.
- This adapter contains all project-specific knowledge.
- This adapter is the single source of project-specific facts.
- Every field must be defined.
- No placeholder may remain.
- The adapter changes with the project.

---

# Framework Reference

The generic framework lives in:

```
bdf/FRAMEWORK.md
```

When the framework references a project-specific value, this adapter defines it.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Active Project Adapter
