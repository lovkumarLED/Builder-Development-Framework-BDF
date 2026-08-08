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
- KiloCode
- Any open-source coding agent sharing their architecture

without redesigning the framework. Only Project Adapters should differ.

Claude Code is NOT supported (entropic `~/.claude.json`, no provider support —
decision 2026-08-08, `planning/DECISIONS.md`).

V3 turns the framework into a **Builder Generator**:

```
Create New Builder Project
↓
Discover installed open-source coding agents (OpenCode / KiloCode / same-architecture)
↓
Choose agent
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
Step 2 — KiloCode Builder V1 (first validation)                ✅ complete
       Claude Code V1 DROPPED (2026-08-08, entropic config)
↓
Step 3 — Universal Agent Framework core (scaffold-agent.ps1)   ← we are here
↓
Step 4 — Framework Improvements (learned from universal)
↓
Step 5 — BDF V3: Universal Builder Generator                    ← destination
```

Each step is built, tested, and validated before the next begins.
Real projects shape the framework — never assumptions.

---

# Current Position

Updated: Aug 8, 2026 (session 29: GUI App built — docs/app/ "AI Switcher", end-to-end green; Phase 14 COMPLETE)

```
Step 3 — Universal Agent Framework core
Status: IN PROGRESS (core built; bootstrap fix session 27; Claude dropped 2026-08-08; GUI app = BDF made autonomous, session 29)
Progress: ~90%
```

What was completed:

- [x] Step 1 — BDF V2.5: Framework Generalization (COMPLETE 100%).
- [x] Side goal: JSON Schema Validation (`schemas/`) — Builder V2.7 (F1-F7), P1 env-key
      policy + P2 dynamic target artifact. Battery 17/13/31 green, snapshot-22 pinned
      (FULL_SYSTEM_CHECK v1.1 all 7 parts PASS, sessions 22 + 26).
- [x] Step 2 — KiloCode Builder V1 (replaces dropped Claude V1): Kilo directory,
      `build-kilo-v1.ps1` / `test-kilo-v1.ps1` / `scaffold-kilo-v1.ps1`, harness 30/30,
      real `~/.config/kilo` verified (sessions 24-24b).
- [x] Step 3 core — `scaffold-agent.ps1` rebuilt as the V3 UNIVERSAL core:
      agent registry (opencode, kilo, claudecode, aider, goose, codex-cli; any
      open-source agent), discovery, -List, -Bootstrap (generates build-/test-/scaffold-
      per agent), scan-first contract, never writes provider/model files, never touches
      .jsonc without consent (session 24b).
- [x] Bootstrap fix (session 27): scaffold's generated `test-<agent>.ps1` copied raw
      (stale `build-opencode-v2.7.ps1`/kilo refs) → now token-replaced like the builder;
      sandbox `custom` agent bootstrap verified 30/30 harness.
- [x] Real-config scaffolds verified: kilo + opencode refreshed with backup, settings
      merged full-shape, harness 30/30 both, AGENTS.md relocation reverted (no AGENTS.md
      anywhere; session 26b claim corrected in session 28).
- [x] Session 28: FULL_SYSTEM_CHECK v1.1 rerun — all 7 parts PASS; V2.7 harness count
      corrected to 31/31 everywhere; framework 2.2.3 (template sync round 2); experimental/
      minimal omniroute-models.json restored (recurring async-deletion fix).
- [x] Session 28b: SCAFFOLD CONTRACT FINALIZED (per user ruling):
      - The framework creates the `providers/` folder (like the profile folders) but
        NEVER writes provider or model JSON files inside it — the JSON files are
        100% user-owned.
      - ONE job: scan the agent's OWN main JSON (kilo.json for kilo, never another
        agent's config), split mcp / plugin sections, seed `profiles/coding/mcp.json` +
        `plugins.json` (user-owned after creation), create `profiles/{coding,experimental,
        minimal}` with exactly settings/mcp/plugins three files each.
      - experimental/minimal mcp.json + plugins.json created EMPTY, never filled.
      - settings.json = `$schema` + `activeProviders` only (never copy-paste the config).
      - Removed framework-created model files: kilo coding omniroute-models.json,
        opencode experimental + minimal omniroute-models.json. User's own
        kilo/providers/omniroute.json restored (user-owned).
      - Kilo test re-run: backup made first, test-kilo-v1.ps1 30/30, main kilo.json
        byte-identical (backup policy verified). Real build correctly fails pre-flight
        without user-created providers (by design).
- [x] Session 28c: NO-SECRETS RULE (ULTIMATE) codified — the SYSTEM's own artifacts
      (scripts, templates, docs, examples) never contain literal API keys ({env:VAR}
      only); USER-owned files (main config, profiles, providers) may contain literal
      keys and the user protects them; the system copies user content verbatim
      (scan → copy → paste) so generated output carries whatever the user's files
      contain, keys included. Verified: system artifacts 0 leaks, user files restored,
      both builds green.
- [x] Session 28d: PHASE 8 COMPLETE — Documentation Expansion: 4 onboarding guides
      (DEVELOPER_GUIDE, PROVIDER_DEVELOPMENT_GUIDE, PROFILE_CREATION_GUIDE,
      BUILDER_EXTENSION_GUIDE) + 4 mirrored templates (15 → 19). ALL 13 roadmap
      phases now complete except the final V3 release steps.
- [x] Session 29: PHASE 14 COMPLETE — GUI App "AI Switcher" (docs/app/): the BDF made
      autonomous. Modular FastAPI backend (app/ package) + Qwen-built gui.html +
      start.bat; calls the REAL scaffold-agent.ps1 -Bootstrap engine (one engine, two
      surfaces) and the generated builders; local OpenAI-compatible /v1 proxy on
      127.0.0.1:9090 to the ACTIVE provider; No-Secrets + backup-first providers.json.
      Smoke-tested end-to-end green on the real opencode agent: discover → scan →
      scaffold (real engine) → build PASS → test harness 31/31 → switch → chat.

Dropped: Claude Code Builder V1 — 2026-08-08 decision (entropic `~/.claude.json`, no
provider support). See `planning/DECISIONS.md`.

Next: commit docs on request; then BUILDER_PHASES Alpha→Beta→General gates for the
universal framework, then Step 4 / Step 5.

Detailed plan: `planning/NEXT_PHASE_IMPLEMENTATION_PLAN.md` (Phase 3 = KiloCode Builder,
Phases 5-7 = universal V3).

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
