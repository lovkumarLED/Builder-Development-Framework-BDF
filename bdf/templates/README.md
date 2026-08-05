# Framework Templates

> Reusable documentation templates for builder projects.

---

# Purpose

The templates folder contains a complete set of documentation templates.

Every template becomes one project document when a new builder project is created.

Templates are generic.

They contain no project-specific knowledge.

Project-specific values appear only as placeholders.

---

# Placeholder Convention

Placeholders use the following format.

```
{{PLACEHOLDER_NAME}}
```

Every placeholder must be replaced before a project document is released.

---

# Placeholder Table

| Placeholder | Meaning | Example Value |
|-------------|---------|---------------|
| `{{PROJECT_NAME}}` | The name of the builder project. | OpenCode Configuration Manager |
| `{{APP_NAME}}` | The application that consumes the generated configuration. | OpenCode |
| `{{GENERATED_ARTIFACT}}` | The final generated configuration file. | opencode.json |
| `{{BUILDER_SCRIPT}}` | The builder entry script. | build-opencode-v2.ps1 |
| `{{TEST_HARNESS}}` | The automated test harness script. | test-opencode-v2.ps1 |
| `{{DEFAULT_PROFILE}}` | The default profile name. | default |
| `{{CURRENT_PROVIDER}}` | The current provider identifier. | omniroute |
| `{{CONFIG_SOURCE_DIR}}` | The source configuration directory. | profiles |
| `{{PROVIDER_DIR}}` | The provider definitions directory. | providers |
| `{{SCRIPTS_DIR}}` | The automation scripts directory. | scripts |
| `{{DOCS_DIR}}` | The documentation directory. | docs |
| `{{BACKUP_DIR}}` | The backup directory. | backup |
| `{{SHELL}}` | The scripting language used by the builder. | PowerShell |
| `{{OS}}` | The supported operating system. | Windows 11 |
| `{{CURRENT_VERSION}}` | The current project version. | 2.2.0 |
| `{{PROJECT_STATUS}}` | The current project status. | Stable Foundation |
| `{{VERSION_DESCRIPTION}}` | The summary of the current version. | Builder V2.1: extended validation, modular merge pipeline, provider-specific models, output verification, and automated testing |
| `{{PROJECT_ROOT}}` | The root directory of the project. | .config/opencode |
| `{{CONFIG_FILE}}` | The source configuration files and their format. | profiles/*/settings.json, models.json |
| `{{SUPPORTED_PROVIDERS}}` | The providers the project supports. | omniroute |
| `{{SUPPORTED_MODELS}}` | The models the project exposes. | gemini-3.6-flash, ... |
| `{{SUPPORTED_PLUGINS}}` | The plugins the project enables. | superpowers |
| `{{SUPPORTED_MCP}}` | The MCP servers the project configures. | github, filesystem |
| `{{FOLDER_TREE}}` | The current folder tree of the project. | (tree diagram) |
| `{{FOLDER_PURPOSE_TABLE}}` | The purpose of each project folder. | profiles/ (Profile configuration) |
| `{{IMPLEMENTED_FEATURES}}` | The list of implemented features. | Modular configuration |
| `{{PLANNED_FEATURES}}` | The list of planned features. | Additional providers |
| `{{KNOWN_LIMITATIONS}}` | The list of known limitations. | One active profile |
| `{{IMMEDIATE_NEXT_STEPS}}` | The immediate next steps. | Commit the repository |
| `{{ROADMAP_PHASES}}` | The planned roadmap phases. | Phase 1 — Foundation |
| `{{FILE_RELATIONSHIP_MAP}}` | The map of file relationships. | AGENT.md → read order docs |
| `{{DOC_VERSION}}` | The document version footer. | 1.0 |
| `{{PLACEHOLDER_NAME}}` | Example placeholder used in the convention illustration. | (not a project value) |

The example values come from the reference implementation.

New projects replace them with their own values.

## Provider Placeholders

Provider-related placeholders are generic — none is shaped by a specific target.

- `{{CURRENT_PROVIDER}}` and `{{SUPPORTED_PROVIDERS}}` name the abstract concepts.
- Their Example Values come from the reference implementation, like every example value.
- The adapter substitutes the target's provider identifiers.

---

# Template Sync Rule

Templates mirror the reference implementation.

Example values in this table come from the reference implementation.

When the reference implementation changes a value or structure, the corresponding template
and example value are re-checked.

When a template changes, every framework document that references it is re-checked (see the
cross-reference matrix below).

---

# Cross-Reference Matrix

A template change is a framework change. The matrix shows which framework documents
reference which templates, so a change to one document always shows what must be re-checked.

| Framework document | Templates referenced |
|--------------------|----------------------|
| `FRAMEWORK.md` | The template set as a component; `DESIGN_PRINCIPLES.template.md` (principles). |
| `PROJECT_ADAPTER.md` | `ADAPTER.template.md` (adapter contents, field table, creating an adapter). |
| `PROJECT_GENERATOR.md` | All 15 templates (Stage 4 copy list + Stage 5 rename map). |
| `NEW_PROJECT_GUIDE.md` | `ADAPTER.template.md`, `PROJECT_STATE.template.md`, `FOLDER_STRUCTURE.template.md`, `JSON_SCHEMAS.template.md`, `BUILDER_SPEC.template.md`. |
| `AI_WORKFLOW.md` | This document (`templates/README.md`) in the agent reading order. |
| `BLUEPRINT_ENGINE.md` | The template set (the engine updates templates when a change is reusable). |
| `BUILDER_EVOLUTION.md` | The template set (templates change when affected). |
| `MIGRATION.md` | The template set (Stage 5 aligns project documents with templates). |
| `VERSION.md` | `PROJECT_STATE.template.md` (recorded in framework change history). |
| `FRAMEWORK_LIFECYCLE.md` | The template set (as a framework component). |

## How to Use the Matrix

- A template changed → check every row that references it and re-verify those documents.
- A framework document changed → check its row: every template it lists must stay consistent.

---

# Template List

| Template | Becomes |
|----------|---------|
| `README.template.md` | README.md |
| `AGENT.template.md` | AGENT.md |
| `ARCHITECTURE.template.md` | ARCHITECTURE.md |
| `DESIGN_PRINCIPLES.template.md` | DESIGN_PRINCIPLES.md |
| `BUILDER_SPEC.template.md` | BUILDER_SPEC.md |
| `FOLDER_STRUCTURE.template.md` | FOLDER_STRUCTURE.md |
| `JSON_SCHEMAS.template.md` | JSON_SCHEMAS.md |
| `CONTRIBUTING_FOR_AI.template.md` | CONTRIBUTING_FOR_AI.md |
| `TESTING.template.md` | TESTING.md |
| `TROUBLESHOOTING.template.md` | TROUBLESHOOTING.md |
| `ROADMAP.template.md` | ROADMAP.md |
| `CHANGELOG.template.md` | CHANGELOG.md |
| `LESSONS_LEARNED.template.md` | LESSONS_LEARNED.md |
| `PROJECT_STATE.template.md` | PROJECT_STATE.md |
| `ADAPTER.template.md` | ADAPTER.md |

---

# Usage Workflow

```
Copy Templates

↓

Rename Templates

↓

Replace Placeholders

↓

Customize Schemas

↓

Review Consistency
```

See `../PROJECT_GENERATOR.md` for the complete workflow.

---

# Template Rules

- Never edit a template to fix a single project.
- Template improvements are framework changes.
- Template changes are recorded in the framework version history.
- Placeholders never describe project history.
- Every template is project-neutral.

---

# Consistency Rules

All templates follow the same conventions:

- Same title style.
- Same section style.
- Same footer format.

This keeps every project documentation set consistent with the framework.

---

**Document Version:** 1.1

**Status:** Active Template Guide
