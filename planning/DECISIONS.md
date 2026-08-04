# DECISIONS

> Permanent record of architectural and project decisions. Newest first.
> Each entry records what was decided, why, and the context.

---

# Format

```
### (date) — (title)

Decision: (one sentence — what we decided)

Why: (the reasoning that justifies it)

Context: (what led to the decision / alternatives considered)

Reversal: (only if superseded — which entry reversed this one, or "None")
```

---

# Decisions

### 2026-08-04 — V3 is a milestone, not "the final version"

Decision: BDF V3 is the first stable public version, not the end of development.

Why: Software never truly has a final version; calling V3 "final" freezes growth and
misleads planning. V3.1, V4, etc. will follow.

Context: User originally treated V3 as the final version; the vision doc
(`planning/BDF_ROAD_TO_V3.md`) records the corrected framing.

Reversal: None.

### 2026-08-04 — Only three supported targets

Decision: BDF generates builders only for OpenCode, Claude Code, and KiloCode.

Why: Supporting three tools extremely well beats supporting dozens poorly. These are
the three most-used CLI agents.

Context: Explicit user ruling. New targets are admitted only if they naturally fit.

Reversal: None.

### 2026-08-04 — Keep the roadmap and vision inside docs/

Decision: No top-level `vision/` folder. Long-term documents live under `docs/planning/`.

Why: `docs/` is the brain of the repository; splitting the vision out of it fragments
project knowledge. A dedicated `planning/` section separates future work from current
implementation while staying centralized.

Context: Alternative (root `vision/` folder) was considered and rejected. A full
category restructure (architecture/, framework/, release/, templates/ as top-level
docs folders) was also considered and rejected: it would break the release pipeline,
the test harness, framework templates, and immutable session history for zero
new capability.

Reversal: None.

### 2026-08-04 — The architecture is frozen until V3 validation demands change

Decision: Stop redesigning. Preserve the two-layer architecture (generic framework /
project implementation) and evolve only through the road-to-V3 steps.

Why: The architecture reached a stable state; redesign churn is waste. Real projects
(Claude, KiloCode) are the only justified source of architectural feedback.

Context: Repeatedly stated in reviews ("Stop redesigning"). Matches the
"Evolution Instead of Rewrite" principle in `planning/BDF_ROAD_TO_V3.md`.

Reversal: None.

### 2026-08-04 — Builders never contain project knowledge

Decision: Project-specific knowledge lives only in Project Adapters; builders contain
generic engineering process.

Why: That separation is what makes the framework reusable across projects. Builders
know HOW to build; adapters know WHAT to build.

Context: Core abstraction validated across OpenCode; foundation of V3.

Reversal: None.

### 2026-08-04 — Release registry is the single source of release truth

Decision: `release_registry.json` is the only hand-edited release artifact; all release
docs are generated from it by `release-manager.ps1`.

Why: One source of truth keeps CHANGELOG, CURRENT_RELEASE, PROJECT_STATE version
tables, and bdf/VERSION.md consistent and deterministic.

Context: Built in session 8; registry arrays are newest-first (user ruling).

Reversal: None.

### 2026-08-04 — Journey progress is tracked continuously

Decision: Every session ends with a `Journey:` line in the session log and an update
to `_agent/JOURNEY_TO_V3.md` Current Position.

Why: The V3 goal is long; sessions are short. The tracker answers "where are we now
toward V3?" at any moment without re-reading the project.

Context: Session rules v1.3; integrates with the checkpoint/resume rule
(`AI/CONTINUE_PROJECT_BUILD.md`).

Reversal: None.

### 2026-08-04 — Large builds checkpoint instead of forcing

Decision: If a version cannot be completed within 70-80% of the 200k-token context
window, the agent stops at a clean checkpoint, writes an AI checkpoint file, and
hands the user a resume prompt.

Why: A full context window loses all work; a checkpoint preserves it and lets any
agent (OpenCode, Claude Code, KiloCode) continue the same build.

Context: Rule in `AI/CONTINUE_PROJECT_BUILD.md`; context budget in
`_agent/SESSION_WORKFLOW.md`.

Reversal: None.

---

**Document Version:** 1.0

**Status:** Active Decision Record
