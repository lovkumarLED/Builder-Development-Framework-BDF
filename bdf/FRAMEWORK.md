# Builder Development Framework

> The complete engineering process for building configuration builders.

> Part of the Builder Development Framework (BDF).

---

# Purpose

This document defines the complete engineering process used to build a configuration builder.

A configuration builder is a small automation system that transforms modular source configuration into a single generated configuration artifact consumed by an application.

The process is independent of any specific application, scripting language, or AI assistant.

It can be reused by any builder project, including future builders for any application.

---

# What This Framework Is

- A process: how to design, build, test, and release a builder.
- A documentation architecture: which documents exist and what each one contains.
- An AI workflow: how AI coding agents collaborate safely with the project.
- A template set: a starting point for every project document.

---

# What This Framework Is Not

- Not an implementation: it contains no code.
- Not project-specific: it describes how to build builders, not how one specific application works.
- Not a replacement for project documentation: every project still owns its own documents.

---

# Knowledge Layers

All knowledge in a builder project belongs to exactly one layer.

## Layer 1 — Builder Development Framework

Generic engineering knowledge.

Reusable across every builder project.

Examples:

- Development workflow.
- AI collaboration rules.
- Documentation philosophy.
- Testing philosophy.
- Builder lifecycle.
- Validation philosophy.
- Version management.

## Layer 2 — Project Documentation

Project-specific knowledge.

Belongs to one project only.

Examples:

- The generated configuration artifact.
- The target application.
- Provider implementations.
- Project schemas.
- Project history.

## Layer Rule

Generic knowledge lives in the framework.

Project knowledge lives in the project.

If a project document duplicates framework knowledge, the framework remains the authority for the generic part.

---

# Framework Components

The framework is organized into twelve components.

| Component | Document | Purpose |
|-----------|----------|---------|
| Blueprint Engine | `BLUEPRINT_ENGINE.md` | The intelligence layer: determines what must change and in what order. |
| Project Adapter | `PROJECT_ADAPTER.md` | Makes the generic framework project-specific. |
| Builder Evolution | `BUILDER_EVOLUTION.md` | Creates future builder versions predictably. |
| Framework Lifecycle | `FRAMEWORK_LIFECYCLE.md` | The master lifecycle reference for every project. |
| Templates | `templates/` | Reusable documentation templates for new projects. |
| AI Workflow | `AI_WORKFLOW.md` | The workflow every AI coding agent follows. |
| Lessons Learned | `LESSONS_LEARNED.md` | Reusable engineering principles. |
| Version System | `VERSION.md` | Framework versioning and compatibility. |
| New Project Guide | `NEW_PROJECT_GUIDE.md` | The onboarding process for starting a new project with the framework. |
| Release Manager | `RELEASE_MANAGER.md` | The generic release process: registry, generator, and generated release documents. |
| Testing Framework | `TESTING.md` | The generic test-harness pattern every builder project follows. |
| Builder Phases | `BUILDER_PHASES.md` | The quality gates (Alpha → Beta → General Release) every builder build must pass. |

Every component answers part of the four framework questions.

---

# The Four Questions

The framework is complete when its documentation answers four questions.

## Question 1 — How Is This Builder Built?

Answered by this document, the templates, and the project specification.

## Question 2 — How Should This Builder Evolve?

Answered by `BUILDER_EVOLUTION.md` and `BUILDER_PHASES.md`.

`BUILDER_EVOLUTION.md` defines the version workflow; `BUILDER_PHASES.md` defines the Alpha → Beta → General Release gates every build must pass before it becomes the main builder.

## Question 3 — How Do I Create Another Builder?

Answered by `PROJECT_GENERATOR.md` and `PROJECT_ADAPTER.md`.

## Question 4 — How Do I Adapt This Framework to Another Project?

Answered by `PROJECT_ADAPTER.md`.

If these four questions are answered by the documentation, the framework is considered complete.

---

# Core Concepts

| Concept | Definition |
|---------|------------|
| Configuration Source | An editable file that defines part of the final configuration. |
| Provider | A definition of how the target application connects to an external service. |
| Builder | The automation that transforms sources into the generated artifact. |
| Validation | Checking the configuration before generation begins. |
| Backup | Preserving the previous working artifact before overwrite. |
| Merge | Combining independent sources into one configuration structure. |
| Generation | Writing the final configuration artifact. |
| Application | The program that consumes the generated artifact. |

Each concept has exactly one responsibility.

No concept performs the responsibility of another.

---

# Builder Lifecycle

Every builder follows the same lifecycle.

```
Configuration Sources

↓

Builder

↓

Validation

↓

Backup

↓

Merge

↓

Generation

↓

Generated Configuration

↓

Application
```

The order is fixed.

No stage may be skipped.

Dependencies always point downward.

Higher layers never depend on lower layers.

---

# Engineering Principles

Every builder project follows the same engineering principles.

1. Single Responsibility
2. Configuration Over Hardcoding
3. Source of Truth
4. Generated Files Are Never Edited
5. Separation of Configuration and Implementation
6. Fail Fast
7. Automation First
8. Modular Architecture
9. Backward Compatibility
10. Documentation First

Each principle is defined in detail in the design principles template in the templates folder.

Every future change to a project should respect these principles.

---

# Documentation Architecture

A builder project uses a standard set of documents.

| Document | Purpose |
|----------|---------|
| `README.md` | Project entry point and overview. |
| `AGENT.md` | Entry point for AI coding agents. |
| `ARCHITECTURE.md` | How the project is organized. |
| `DESIGN_PRINCIPLES.md` | Why the project is organized that way. |
| `BUILDER_SPEC.md` | What the builder does and how it behaves. |
| `FOLDER_STRUCTURE.md` | Where everything lives. |
| `JSON_SCHEMAS.md` | Format of every configuration file. |
| `CONTRIBUTING_FOR_AI.md` | Rules for AI coding agents. |
| `TESTING.md` | How the project is verified. |
| `TROUBLESHOOTING.md` | How failures are diagnosed. |
| `ROADMAP.md` | Planned future work only. |
| `CHANGELOG.md` | Completed work only. |
| `PROJECT_STATE.md` | Living state snapshot. |
| `LESSONS_LEARNED.md` | Reusable engineering lessons. |
| `ADAPTER.md` | Project-specific facts. |

## Framework Process Documents

The framework also includes process documents that are never generated into a project.

| Document | Purpose |
|----------|---------|
| `NEW_PROJECT_GUIDE.md` | The onboarding process for starting a NEW project with the framework. |
| `RELEASE_MANAGER.md` | The generic release process: registry, generator, generated release documents. |
| `TESTING.md` | The generic test-harness pattern. Each project generates its own project `TESTING.md` from `templates/TESTING.template.md`; the framework document defines the pattern both mirror. |

## Documentation Rules

- Documentation is part of the project.
- Documentation describes only implemented functionality.
- Future ideas belong exclusively in the roadmap.
- The roadmap and the changelog never overlap.
- Whenever implementation changes, documentation is updated.
- All documents remain consistent with one another.
- Generated documentation never replaces source documentation.

---

# AI Workflow

The process is designed to work with any AI coding assistant.

The master AI workflow is defined in:

```
AI_WORKFLOW.md
```

## Before Any Change

1. Read the agent entry document.
2. Follow the required documentation reading order.
3. Understand the architecture first.
4. Summarize the understanding.
5. Explain the proposed approach.

## While Working

- Preserve the project philosophy.
- Extend existing systems instead of replacing them.
- Avoid unnecessary redesign.
- Make the smallest reasonable change.
- Work one step at a time.

## After Finishing

- Verify the result.
- Update documentation if required.
- Update the changelog for completed work.
- Remove completed items from the roadmap.

## AI Must Not

- Edit generated files manually.
- Introduce undocumented architecture.
- Hardcode configuration values that belong in configuration files.
- Modify unrelated files.
- Remove documentation without justification.
- Implement features that exist only in the roadmap.
- Guess when documentation and implementation disagree.

When documentation and implementation disagree, the assistant identifies the inconsistency and asks for clarification before proceeding.

Consistency is more important than speed.

---

# Versioning

Versioning exists on two independent tracks.

## Framework Versioning

Tracks the evolution of this framework.

Recorded in `VERSION.md`.

## Project Versioning

Tracks the evolution of a specific builder project.

Recorded in the project changelog.

Framework evolution is tracked independently from builder evolution.

---

# Testing Philosophy

- Validate before generating.
- Never trust generated output without verification.
- Every successful build should be reproducible.
- Changes should never break previously working functionality.
- Testing is part of development, not an optional step.

---

# Troubleshooting Philosophy

- Observe the problem before touching anything.
- Read the error message first.
- Identify the failed stage.
- Determine the root cause before applying a fix.
- Make one change at a time.
- Verify the resolution.

Do not apply random fixes without first identifying the root cause.

---

# Starting a New Project

Follow the project generation workflow.

```
PROJECT_GENERATOR.md
```

The workflow covers idea, repository creation, template copying, customization, implementation, testing, and release.

The human-facing onboarding process is documented in:

```
NEW_PROJECT_GUIDE.md
```

It defines the numbered steps and teaches where project-specific knowledge lives: only in the project adapter.

---

# Migrating an Existing Project

Follow the migration guide.

```
MIGRATION.md
```

The guide explains how an existing project adopts the framework without losing documentation.

---

# Maintaining the Framework

The framework itself evolves over time.

## When To Change

- New lessons are learned.
- Templates need improvement.
- The process changes.
- A new reusable concept is identified.

## How To Change

1. Update the relevant framework document or template.
2. Update `VERSION.md`.
3. Record the change in the framework change history.
4. Update `MIGRATION.md` if existing projects are affected.
5. Keep the framework free of project-specific knowledge.

## Breaking Changes

A breaking change is any change that requires existing projects to restructure their documentation or process.

Breaking changes require a major version bump.

---

# Reference Implementation

The first implementation built using this framework is the OpenCode Configuration Manager.

Its documentation set demonstrates how the framework is applied to a real project.

The OpenCode Builder V2 is the first builder built using the Builder Development Framework.

Future builders may use the same framework without rewriting it.

---

**Document Version:** 1.1

**Status:** Active Builder Development Framework
