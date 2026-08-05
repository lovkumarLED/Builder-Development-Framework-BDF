# JOURNEY_TO_V3

> The live tracker of our position on the road to BDF V3.

---

# Purpose

This document answers one question at any moment:

> "Where are we right now on the road to V3, and what is the next step?"

It is the single source of truth for journey progress. It is NOT documentation of the
current implementation (that is `PROJECT_STATE.md`) and NOT the vision (that is
`planning/BDF_ROAD_TO_V3.md`). This file is the map + the compass.

Every session reads it at start and updates it at end.

---

# The Destination

> **BDF V3 — the first stable public version of the Builder Development Framework.**

V3 is complete when the same engineering framework can successfully create and maintain
builders for:

- OpenCode
- Claude Code
- KiloCode

without redesigning the framework. Only Project Adapters should differ.

V3 turns the framework into a **Builder Generator**:

```
Create New Builder Project
↓
What software? (OpenCode / Claude Code / KiloCode)
↓
Read project schema
↓
Generate adapter
↓
Generate docs
↓
Generate folder structure
↓
Generate builder
↓
Generate tests
↓
Done
```

---

# The Journey Map

```
Step 0 — Current (Builder V2.2.0, Release Manager V1)          ✅ complete
↓
Step 1 — BDF V2.5: Framework Generalization                    ✅ complete
↓
Step 2 — Claude Code Builder V1 (first validation)             ← we are here
↓
Step 3 — Framework Improvements (learned from Claude)
↓
Step 4 — KiloCode Builder V1 (second validation)
↓
Step 5 — Framework Improvements (learned from KiloCode)
↓
Step 6 — BDF V3: Builder Generator                             ← destination
```

Each step is built, tested, and validated before the next begins.
Real projects shape the framework — never assumptions.

---

# Current Position

Updated: Aug 5, 2026 (session 14 end)

```
Step 1 — BDF V2.5: Framework Generalization
Status: COMPLETE
Progress: 100%
```

What was completed in V2.5:

- [x] `NEW_PROJECT_GUIDE.md` — documented onboarding process for new projects.
- [x] Better `PROJECT_ADAPTER.md` — cleaner generic/project boundary (single source of truth + validation checklist).
- [x] More generic templates (placeholder audit, cross-reference matrix, sync rule).
- [x] Better Blueprint Engine (Impact Analysis record).
- [x] Cleaner framework boundaries (OpenCode-specific knowledge removed from `bdf/`).
- [x] Improved validation, testing, adapters, templates, documentation,
      provider handling, and release system (bdf/TESTING.md, bdf/RELEASE_MANAGER.md).
- [x] V2.5 released (registry entry 2.3.0 + release pipeline run + 17/17 tests green).

Next: Step 2 — build the Claude Code Builder V1 (first validation of the generalized
framework), then KiloCode Builder V1, then V3.

Detailed plan: `planning/NEXT_PHASE_IMPLEMENTATION_PLAN.md` (Phase 3 = Claude Builder V1).

Phase gates: every builder build on the road to V3 must pass the Alpha → Beta →
General Release gates in `bdf/BUILDER_PHASES.md` before it becomes the main builder
and the journey advances to the next step.

---

# How to Update This File

## On session start

Read the `Current Position` section. It tells you the step, the progress, and the
remaining work. The session then continues from the most recent `Next:` line in
`SESSION_LOG.md`.

## On session end (every session — including "end session")

1. Read `planning/BDF_ROAD_TO_V3.md` (destination rules).
2. Compare where the session left the project against the Journey Map.
3. Update the `Current Position` section:
   - Step name and status (NOT STARTED / IN PROGRESS / COMPLETE).
   - Progress percentage.
   - Tick or add checkboxes in the remaining-work list.
   - Update the "Updated:" line.
4. Write the `Journey:` line in the new `SESSION_LOG.md` entry (format in
   `SESSION_WORKFLOW.md`) so the log and this tracker never disagree.

## Rules

- Keep it short — this is a compass, not a journal.
- Never rewrite history here: move forward only. If a step regresses, describe the
  regression in the session log, not by erasing this file.
- Never delete the Journey Map or the Destination sections.
- `SESSION_WORKFLOW.md` defines when and how this file is updated. Keep them consistent.

---

# Version Continuation

If a version build is too large to finish inside the context budget, the agent stops at a
clean checkpoint, writes `AI/CONTINUE_BUILD_<VERSION>_<STEP>.md`, and hands you a resume
prompt. That checkpoint file + this Current Position section are how the next session
continues exactly where the build stopped. Rules: `AI/CONTINUE_PROJECT_BUILD.md`.

---

**Document Version:** 1.0

**Status:** Active Journey Tracker
