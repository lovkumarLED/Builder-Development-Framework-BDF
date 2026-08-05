# Builder Phases

> The staged delivery of every builder build: Alpha → Beta → General Release.

> Part of the Builder Development Framework (BDF).

---

# Purpose

This document defines the phases every builder build passes through before it can take over as the main builder.

It answers a single question:

```
When is a build ready to become the builder?
```

The answer is governed by three phases:

1. Alpha Phase
2. Beta Phase
3. General Release

A build advances through the phases only when its exit criteria are met.

Nothing is promoted to the main builder before it reaches General Release.

---

# The Three Phases

```
Alpha Phase
    ↓
Beta Phase
    ↓
General Release
```

The order is fixed.

No phase may be skipped.

---

## Alpha Phase

The first working build.

Purpose: prove the architecture works.

### Characteristics

- All planned components exist.
- Core behavior is implemented.
- Known failures and missing edge cases are accepted and recorded.
- Documentation of the new design exists.
- The build runs end to end in a controlled environment.

### Exit Criteria

- [ ] End-to-end run succeeds.
- [ ] Known issues are recorded (not necessarily fixed).
- [ ] Architecture and design are documented.
- [ ] A decision is made that the design should continue.

### Status In Practice

The build is usable by the development team only.

It is not introduced to regular use.

---

## Beta Phase

The hardened build.

Purpose: prove the build is safe for real use.

### Characteristics

- Alpha known issues are resolved or explicitly accepted.
- The test suite covers the new behavior.
- Previous behavior still passes.
- Migration notes exist for every behavior change.
- A release candidate exists and is exercised.

### Exit Criteria

- [ ] Full test suite passes.
- [ ] Backward compatibility verified (or a breaking change is explicitly accepted).
- [ ] Migration notes written.
- [ ] Release candidate validated end to end.
- [ ] Documentation updated with implemented behavior.

### Status In Practice

The build is usable by early adopters.

It is not yet the main builder.

---

## General Release

The accepted build.

Purpose: become the main builder for regular use.

### Characteristics

- All Beta exit criteria are met.
- The release pipeline produced the version.
- The release registry records the version.
- Generated release documents exist.
- The journey log marks the step complete.

### Exit Criteria

- [ ] Released through the project's release manager.
- [ ] Registry entry added.
- [ ] CHANGELOG, CURRENT_RELEASE, VERSION, PROJECT_STATE updated.
- [ ] Journey log updated.

### Status In Practice

The build becomes the main builder.

It is the starting point of the next evolution.

---

# The Evolution Rule

A builder evolves only from the General Release of the current build.

```
Builder Build
    ↓
passes Alpha Phase
    ↓
passes Beta Phase
    ↓
reaches General Release
    ↓
evolve the main builder
```

When a build passes the Alpha Phase and the Beta Phase, it reaches General Release.

When it reaches General Release, the main builder evolves to it.

The previous build becomes the prior version.

A build still in Alpha or Beta is never the starting point of an evolution.

---

# Relationship to the Framework

## Builder Evolution

`BUILDER_EVOLUTION.md` defines how a builder version is created.

This document defines the quality gates that version must pass.

The phases are the gate: a builder version created by the evolution workflow must pass Alpha and Beta before it is released and becomes the main builder.

## Framework Lifecycle

`FRAMEWORK_LIFECYCLE.md` tracks the lifecycle of a builder project.

The phases describe the maturity of a single build inside that lifecycle:

- Alpha belongs to the early testing stage.
- Beta belongs to the validation stage.
- General Release belongs to the release stage.

## Definition of Complete

A build counts as General Release only when it is:

- Built.
- Tested.
- Validated end to end.
- Released through the release manager.
- Tracked in the journey documentation.

---

# Rules

1. No phase may be skipped.
2. A build in Alpha or Beta is never the main builder.
3. The main builder evolves only from a General Release.
4. Tests define the move from Alpha to Beta.
5. The release pipeline defines the move from Beta to General Release.
6. The previous build always remains restorable.

---

**Document Version:** 1.0

**Status:** Active Builder Phases