# Project Adapter

> Project-specific facts for the OpenCode Configuration Manager.

---

# Purpose

This document defines how the Builder Development Framework applies to the OpenCode Configuration Manager.

The framework is generic.

This adapter makes the framework project-specific.

Every field in this document defines a project-specific fact.

---

# Adapter Contents

## Project Name

```
OpenCode Configuration Manager
```

---

## Configuration File

The source configuration files and their format.

```
profiles/default/settings.json     (required)
profiles/default/omniroute-models.json   (optional, per-provider models)
profiles/default/plugins.json    (optional)
profiles/default/mcp.json        (optional)
providers/omniroute.json         (provider definition)
```

Additional profiles (`coding`, `experimental`, `minimal`) contain `settings.json` (+ `<provider>-models.json` model files and `target.json` as needed) and contribute their provider selection to the build.

Format:

```
JSON
```

---

## Folder Structure

The project folders and their responsibilities.

```
opencode/

├── backup/
├── docs/
├── profiles/
├── providers/
├── schemas/
├── scripts/
└── opencode.json
```

| Folder | Responsibility |
|--------|----------------|
| `profiles/` | Profile-specific configuration |
| `providers/` | Provider definitions (optionally with provider-specific `models.json`) |
| `schemas/` | Reserved for future JSON Schema validation |
| `scripts/` | Builder, test, and release manager scripts |
| `backup/` | Automatic configuration backups |
| `docs/` | Project documentation |

---

## Supported Providers

```
omniroute
```

---

## Supported Models

The models exposed by the `default` profile.

Sources include:

- opencode-zen models
- cloudflare-ai models
- groq models
- ollamacloud models
- gemini models
- nvidia models
- openrouter models

The complete model list is defined per active provider in the profile:

```
profiles/<profile>/<provider>-models.json
```

Providers may also own provider-specific models:

```
providers/<provider>/models.json
```

Profile-level provider models are loaded per active provider:

```
profiles/<profile>/<provider>-models.json
```

This source carries the highest precedence.

Model-source precedence (highest first):

```
profiles/<profile>/<provider>-models.json
providers/<provider>/models.json
inline provider models
profiles/<profile>/models.json
```

---

## Supported Plugins

```
superpowers (superpowers@git+https://github.com/obra/superpowers.git)
```

The complete plugin list is defined in:

```
profiles/default/plugins.json
```

---

## Supported MCP

MCP servers configured by the `default` profile:

- github
- browser-playwright
- shell
- filesystem
- pyright
- Remote MCP
- Sequential Thinking
- Exa Search
- context7

The complete MCP configuration is defined in:

```
profiles/default/mcp.json
```

---

## Output Artifact

The final generated configuration file.

```
opencode.json
```

The builder generates this artifact from the source configuration.

It is never edited manually.

> **Agent config warning:** the builders generate `opencode.json` (OpenCode) /
> `kilo.json` (Kilo). Do NOT create `opencode.jsonc` next to `opencode.json` —
> OpenCode reads the `.jsonc` *instead of* the `.json` when both exist, and your
> built config silently disappears from `/models`. Generating both formats is
> planned for a future update — not right now.

---

## Release Registry

The machine-readable release history.

```
docs/release_registry.json
```

The only hand-edited release artifact.

The AI records the release facts after implementation and testing.

The user reviews the facts before the release manager runs.

The generic release process is defined in:

```
bdf/RELEASE_MANAGER.md
```

---

## Release Artifacts

The generated release documentation.

```
CURRENT_RELEASE.md
```

Generated from the release registry by the release manager.

It is never edited manually.

---

## Builder Entry Point

The script that runs the builder.

```
scripts/build-opencode-v2.7.ps1
```

Builder V2.1 (`scripts/build-opencode-v2.ps1`) remains the legacy entry point.

Invocation example:

```
.\build-opencode-v2.7.ps1 -Profile default
```

Extra V2.7 CLI flags documented by the builder spec: `-SchemaDir`, `-WhatIf`, `-KeepBackups`, `-Doctor`, `-ProvenancePath` (defaults in `docs/BUILDER_SPEC.md`).

---

## Release Manager Entry Point

The script that generates the release documentation.

```
scripts/release-manager.ps1
```

Invocation example:

```
.\release-manager.ps1 -ConfigRoot C:\Users\loveb\.config\opencode\docs
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

**Document Version:** 1.1

**Status:** Active Project Adapter
