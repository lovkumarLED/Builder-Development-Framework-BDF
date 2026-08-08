# NEXT PHASE IMPLEMENTATION PLAN
# Builder Development Framework (BDF)

Status: Active

Purpose:
This document defines the implementation plan for the next phase of the Builder Development Framework. The objective is to complete the evolution from Builder V2.5 to the first stable release of BDF V3.

---

# Current State

The OpenCode Builder has matured into a reusable engineering framework.

It now includes:

- Documentation-first development
- Blueprint-driven architecture
- Project adapters
- Templates
- Testing framework
- Release Manager
- Automated documentation generation
- Planning documents
- Project state tracking
- Version management

The framework has reached the point where it should begin proving itself on additional projects rather than continuing to evolve only through OpenCode.

---

# Primary Goal

The framework must become capable of producing builders for multiple supported CLI agents without redesigning its architecture.

The supported projects are:

- OpenCode
- KiloCode
- Any other open-source coding agent with the same architecture (universal scaffold mode)

Claude Code is NOT a supported target (see DECISIONS.md — 2026-08-08).

---

# Development Philosophy

The framework evolves through real implementations.

The process is always:

Improve Framework

↓

Build Real Project

↓

Discover Missing Abstractions

↓

Improve Framework Again

↓

Repeat

Never redesign the framework based purely on assumptions.

Real projects should drive evolution.

---

# Phase 1 — Complete Builder V2.5

Complete all remaining improvements planned for Builder V2.5.

Focus on engineering quality rather than adding unrelated features.

Objectives include:

- stronger validation
- modular merge pipeline
- provider-specific models
- better logging
- automated testing
- release management
- deterministic documentation
- adapter improvements

Builder V2.5 should become the strongest possible implementation of the current architecture.

---

# Phase 2 — Freeze OpenCode Builder

After Builder V2.5 is complete:

- stabilize documentation
- stabilize architecture
- ensure tests pass
- verify release pipeline
- update PROJECT_STATE

The OpenCode Builder becomes the reference implementation.

No unnecessary redesigns after this point.

---

# Phase 3 — Build KiloCode Builder V1

This is the first proof that BDF is reusable on a second project.

IMPORTANT:

Do NOT manually copy documentation.

The Builder Development Framework itself should create the KiloCode Builder project.

Note: Claude Code was originally planned as this second proof project. It was dropped on
2026-08-08 — Claude Code config format (huge single `~/.claude.json`) is entropic,
hard to maintain, and cannot support adding providers. KiloCode uses the same
architecture as OpenCode, so V3 stays universal. Full decision: `planning/DECISIONS.md`.

---

## KiloCode Builder Location

The KiloCode Builder lives alongside the real KiloCode configuration.

Example:

C:\Users\<user>\.config\kilo\

The framework should create all required builder folders inside this project.

Expected structure:

docs/
profiles/
providers/
schemas/
scripts/
backups/
tests/
adapter/

alongside the existing KiloCode configuration files.

---

## KiloCode Builder Responsibilities

KiloCode Builder V1 supports the core configuration plus the full KiloCode shape.

Delivered (2026-08-07):

- kilo.jsonc (main config)
- settings.json
- profiles (multiple, per-profile mcp.json / plugins.json / <provider>-models.json)
- schemas/ (JSON Schema validation, F1)
- backup retention, provenance sidecar, -Doctor / -WhatIf
- ~13 top-level kilo.jsonc sections modeled (skills, MCP, providers, plugins included)

The objective is to prove that the framework works.

---

## KiloCode Project Adapter

KiloCode should be implemented entirely through a Project Adapter.

The Builder itself should remain generic.

The adapter should define:

- output files
- merge rules
- validation rules
- schema expectations
- destination paths

---

# Phase 4 — Improve Framework

After KiloCode Builder V1 is working:

Review the framework.

Ask:

What assumptions were OpenCode-specific?

What became repetitive?

What should become generic?

Update BDF accordingly.

---

# Phase 5 — Universal Agent Support (V3 core)

The V3 core works for ANY open-source coding agent with a local JSON config
(Aider, Goose, Codex-Cli, ...), not only OpenCode/KiloCode-architecture agents:

- The scaffold discovers whatever open-source agents are installed; if none are
  found it asks the user for the location of their coding agents.
- The framework's ONE job per agent: scan the agent's OWN main JSON, split it
  into mcp / plugin sections, seed `profiles/{coding,experimental,minimal}`.
- The framework creates the `providers/` folder but NEVER writes provider or
  model files inside it — providers and models are 100% user-owned.
- Closed-source agents are never scanned or written.

Claude Code (entropic `~/.claude.json`, one provider at a time, provider configs
hard to maintain) does not fit this architecture and is NOT supported.

Universal scaffold compatibility is proven by real builders generated for OpenCode
and KiloCode. Any open-source agent with a local JSON config is a candidate.

# Phase 6 — Framework Stabilization

After two successful builders exist:

- OpenCode
- KiloCode

Review every framework document.

Simplify where possible.

Remove duplication.

Generalize project-independent knowledge.

Strengthen adapters.

Verify all generated documentation.

---

# Phase 7 — Release BDF V3

Builder Development Framework V3 is complete when:

The same framework can successfully generate and maintain:

✓ OpenCode Builder

✓ KiloCode Builder

✓ ANY open-source coding agent (scaffold mode — discovery, ask-for-location,
  own-main-JSON seeding, never writes providers/models)

without architectural redesign.

Only Project Adapters should differ.

Claude Code is permanently out of scope (entropic config design — see DECISIONS.md 2026-08-08).

---

# Architecture Goal

Final architecture should resemble:

Builder Development Framework

↓

Project Adapter

↓

Project Outputs

Where:

OpenCode Adapter

↓

opencode.json

Kilo Adapter

↓

kilo.jsonc

Any-agent Adapter (scaffold)

↓

agent-specific outputs

The Builder should never contain project-specific logic.

---

# Success Criteria

The framework should demonstrate:

- reusable architecture
- deterministic builders
- documentation-first workflow
- blueprint-driven evolution
- generic testing
- generic releases
- reusable templates
- project adapters
- stable engineering process

---

# Working Rules

During all future development:

Never manually copy documentation into new projects.

The framework should generate new builder projects.

Every improvement must benefit all supported builders whenever possible.

Always update:

- PROJECT_STATE
- CHANGELOG
- VERSION
- Registry
- Documentation

after meaningful architectural changes.

---

# Long-Term Objective

The Builder Development Framework should become a reusable engineering system capable of creating and maintaining builders for supported CLI agents.

The goal is not simply to automate configuration generation.

The goal is to automate disciplined software engineering while preserving human architectural control.

Every version should move the framework closer to that objective.

---

# End State

The project is considered successful when a new supported builder can be created by providing only:

- the project type
- destination path
- project adapter requirements

The Builder Development Framework should then generate the complete builder project with minimal human intervention while preserving the established engineering standards.