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
| Release Registry | The machine-readable release history. |
| Release Artifacts | The generated release documentation. |
| Builder Entry Point | The script or command that runs the builder. |
| Release Manager Entry Point | The script that generates the release documentation. |

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

The configuration file list includes an optional `profiles/<profile>/lsp.json`
(LSP servers, disabled by default).

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

### Reasoning formats

Providers may declare an optional `reasoningFormat` field
(`opencode` | `openai` | `claude` | `gemini` | `none`, default `opencode`).
It selects the valid reasoning levels and the variant JSON shape written for
that provider's models:

- `opencode` / `openai` → `reasoningEffort`
- `claude` → `thinking.type` + `thinking.budgetTokens`
- `gemini` → `thinkingConfig.thinkingBudget`
- `none` → no variants

The builder passes `variants` through verbatim; interactive builds ask the
developer for the format when it is missing or invalid levels are present,
then persist it (backup-first) and filter the generated output. See
`PROVIDER_DEVELOPMENT_GUIDE.md` for full examples.

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

## Release Registry

The machine-readable release history.

```
{{RELEASE_REGISTRY}}
```

The only hand-edited release artifact.

The AI records the release facts after implementation and testing.

The user reviews the facts before the release manager runs.

---

## Release Artifacts

The generated release documentation.

```
{{RELEASE_ARTIFACTS}}
```

Generated from the release registry by the release manager.

It is never edited manually.

---

## Builder Entry Point

The script or command that runs the builder.

```
{{BUILDER_SCRIPT}}
```

---

## Release Manager Entry Point

The script that generates the release documentation.

```
{{RELEASE_MANAGER_SCRIPT}}
```

Generated release files are never edited manually.

The generic release process (registry, all-or-nothing writes, marker policy) is defined in:

```
bdf/RELEASE_MANAGER.md
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

## Unique Agent Adapter Namespaces (generic)

A project may carry unique bounded adapters in addition to its project
adapter. Each unique adapter owns `adapters/<agent>/` with a fixed five-file
documentation contract (README, ADAPTER, BUILDER_SPEC, TESTING,
COMPATIBILITY) and an approved implementation mapping. Generic templates carry
only the reusable structure; target-specific paths, settings, environment
variables, versions, and support claims belong in the adapter documents.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Active Project Adapter
