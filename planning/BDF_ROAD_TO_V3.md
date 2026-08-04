# Builder Development Framework (BDF)
# Road to V3

Version: Draft 1.0

Status: Living Document

---

# Purpose

This document defines the long-term vision of the Builder Development Framework (BDF).

Unlike implementation documents, this file does not describe the current state of the project.

Instead, it defines:

- where the framework is going
- why architectural decisions are made
- how future versions should evolve
- when a version is considered complete
- how new builders should be created

This document should guide every major decision made during framework development.

---

# Vision

The Builder Development Framework (BDF) exists to create a reusable engineering framework for building configuration builders.

The framework should make it possible to create high-quality builders without redesigning architecture for every project.

The long-term objective is:

> Learn the engineering process once.
> Reuse it forever.

---

# Supported Projects

BDF is intentionally specialized.

It is **not** intended to generate builders for every AI tool.

The official supported targets are:

- OpenCode
- Claude Code
- KiloCode

Supporting these three extremely well is more valuable than supporting dozens of unrelated tools.

Future support for additional projects should only happen if they naturally fit the framework.

---

# Philosophy

The framework follows several permanent engineering principles.

---

## Documentation First

Documentation defines the system.

Implementation follows documentation.

Never reverse this process.

---

## Blueprint Driven Development

Architecture should evolve from blueprints rather than ad-hoc implementation.

Blueprints are the source of engineering decisions.

---

## Human Guided

Humans decide:

- goals
- features
- priorities
- architecture

AI assists implementation.

The AI should never silently redesign the framework.

---

## Deterministic Engineering

Running the same inputs twice should produce identical outputs.

Documentation generation, builders, releases, and testing should all be deterministic.

---

## Evolution Instead of Rewrite

Every version builds on the previous version.

Avoid rewriting systems unless architectural limitations require it.

Small continuous improvements are preferred.

---

## Separation of Knowledge

The framework distinguishes between:

### Generic Knowledge

Engineering concepts reusable across projects.

Examples:

- blueprint engine
- testing
- releases
- templates
- workflow

---

### Project Knowledge

Information unique to one project.

Examples:

- OpenCode configuration
- Claude configuration
- folder layouts
- provider schemas

Project-specific knowledge belongs inside Project Adapters.

---

# Framework Layers

The framework consists of two major layers.

```
Layer 1

Builder Development Framework

↓

Layer 2

Project Implementation
```

Layer 1 never depends on Layer 2.

Layer 2 depends on Layer 1.

---

# Core Components

The Builder Development Framework is composed of:

- Framework
- Blueprint Engine
- Builder Evolution
- Lifecycle
- Templates
- Project Adapter
- AI Workflow
- Release Manager
- Testing Framework
- Migration Guides

These components should remain reusable across supported projects.

---

# Builder Philosophy

A Builder should never contain project knowledge directly.

Instead:

```
Builder

↓

Project Adapter

↓

Configuration

↓

Generated Output
```

Builders know **how** to build.

Adapters know **what** to build.

---

# Development Cycle

Every version should follow the same engineering workflow.

```
Idea

↓

Architecture Discussion

↓

Blueprint Update

↓

Documentation Update

↓

Implementation

↓

Testing

↓

Validation

↓

Release

↓

Reflection

↓

Repeat
```

Skipping steps weakens the framework.

---

# Continuous Improvement

After every completed version ask:

1. What improved?

2. What limitations remain?

3. What became repetitive?

4. What should become generic?

5. What should become automated?

The answers define the next version.

---

# Current Direction

Current development focuses on:

Builder V2.5

Purpose:

Strengthen the framework.

Not redesign it.

---

Builder V2.5 should improve:

- validation
- testing
- adapters
- templates
- documentation
- framework boundaries
- provider handling
- release system

without changing the overall architecture.

---

# Road to V3

The path to V3 is intentional.

```
Current

↓

Builder V2.5

↓

Framework Improvements

↓

OpenCode Validation

↓

Claude Builder

↓

Framework Improvements

↓

KiloCode Builder

↓

Framework Improvements

↓

Builder Development Framework V3
```

Real projects should shape the framework.

The framework should never evolve from assumptions alone.

---

# Definition of V3

Builder Development Framework V3 is considered complete when:

The same engineering framework can successfully create and maintain builders for:

- OpenCode
- Claude Code
- KiloCode

without redesigning the framework.

Only project adapters should differ.

---

# Characteristics of V3

V3 should provide:

✓ Documentation-first workflow

✓ Blueprint Engine

✓ Project Adapter abstraction

✓ Generic Builder workflow

✓ Generic Testing Framework

✓ Generic Release Manager

✓ Deterministic documentation generation

✓ Repeatable engineering workflow

✓ Stable architecture

---

# AI Responsibilities

Every AI working on the project should:

1. Read framework documents.

2. Read blueprint documents.

3. Read project adapter.

4. Read project state.

5. Understand architecture.

6. Plan before implementation.

7. Explain major architectural changes.

8. Implement incrementally.

9. Run validation.

10. Update documentation.

11. Prepare the next evolution.

---

# Human Responsibilities

The repository owner defines:

- priorities
- architecture
- project direction
- supported targets
- engineering philosophy

The AI assists implementation.

---

# Decision Rule

Whenever multiple solutions exist:

Choose the one that:

- improves reuse
- reduces duplication
- simplifies maintenance
- increases clarity
- benefits future builders

rather than solving only today's problem.

---

# Success Criteria

The Builder Development Framework is successful when:

- the framework is trusted
- architecture remains stable
- documentation stays synchronized
- releases remain deterministic
- builders evolve without redesign
- new supported builders require only a Project Adapter

At that point BDF becomes a reusable engineering framework rather than a single software project.

---

# Beyond V3

V3 is **not** the end of development.

It is the first stable public milestone.

Future versions may include:

- improved automation
- additional validation
- richer templates
- smarter adapters
- performance improvements
- developer tooling

These improvements should preserve the core architecture established by V3.

---

# Guiding Principle

The goal of BDF is not to automate coding.

The goal of BDF is to automate engineering discipline.

Every improvement should move the framework closer to that objective.
