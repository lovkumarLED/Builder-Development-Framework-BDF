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
- Claude Code
- KiloCode

No additional targets are planned until these three are fully supported.

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

# Phase 3 — Build Claude Builder V1

This is the first proof that BDF is reusable.

IMPORTANT:

Do NOT manually copy documentation.

The Builder Development Framework itself should create the Claude Builder project.

---

## Claude Builder Location

The Claude Builder should live alongside the real Claude configuration.

Example:

C:\Users\<user>\.claude\

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

alongside the existing Claude configuration files.

---

## Claude Builder Responsibilities

Claude Builder V1 should support only the core configuration.

Initial targets:

- .claude.json
- settings.json

Ignore advanced Claude features during V1.

Plugins, hooks, skills, MCP extensions, and other advanced functionality can be added later.

The objective is to prove that the framework works.

---

## Claude Project Adapter

Claude should be implemented entirely through a Project Adapter.

The Builder itself should remain generic.

The adapter should define:

- output files
- merge rules
- validation rules
- schema expectations
- destination paths

---

# Phase 4 — Improve Framework

After Claude Builder V1 is working:

Review the framework.

Ask:

What assumptions were OpenCode-specific?

What became repetitive?

What should become generic?

Update BDF accordingly.

---

# Phase 5 — Build KiloCode Builder V1

Repeat exactly the same process.

Do not redesign the framework.

Only improve it where necessary.

KiloCode should become the third validation project.

---

# Phase 6 — Framework Stabilization

After three successful builders exist:

- OpenCode
- Claude Code
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

✓ Claude Builder

✓ KiloCode Builder

without architectural redesign.

Only Project Adapters should differ.

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

Claude Adapter

↓

.claude.json

↓

settings.json

Kilo Adapter

↓

(kilo-specific outputs)

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