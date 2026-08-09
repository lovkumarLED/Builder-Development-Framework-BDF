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

Updated: Aug 9, 2026 (session 34: LAUNCH DAY - repo PUBLIC on GitHub, promo pack + algorithm-optimized messages ready; README storefront (story + demo GIF + install.bat); next: Claude Code + more agents)

```
Step 3 — Universal Agent Framework core
Status: IN PROGRESS (core built; bootstrap fix session 27; Claude dropped 2026-08-08; GUI app = BDF made autonomous, session 29; real-provider fix + presets + builder parity, sessions 31-32)
Progress: ~93%
```

Phase map (roadmap): Phase 14 GUI App COMPLETE; Phase 15 More Coding Agents PLANNED — the app + universal scaffold are expected to work with additional open-source coding agents, but only OpenCode + KiloCode are verified so far; the rest is untested until tried.

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
- [x] Session 29 (continued): BDF-EXACT data model — the app reads/writes the AGENT's own
      files (providers/, <provider>-models.json, plugins.json, mcp.json, settings.json
      activeProviders list), backup-first; models with thinking levels; plugins + MCP
      cards; SDK type selector (15 npm packages verified); MULTI-AGENT management
      (Agents card, instant switch, ready detection skips the wizard for set-up agents);
      active hero shows every active provider; flame startup banner; self-contained
      Python env; rule.md live theme + rulebook; kilo live (omniroute + tokenrouter,
      19 models in kilo.json); full E2E click-through battery with hash-verified
      restore; commits 459d407 + b3a0bdb.
- [x] SESSION 30 RESEARCH: real-provider root cause found (web-verified) — Kilo reads
      provider.<id>.options.apiKey, the app wrote only top-level apiKey → Kilo sent no
      token → TokenRouter 401; plan written (AI/CONTINUE_REAL_PROVIDERS.md). Also fixed:
      build-kilo.ps1 stale-copy trap (finder prefers highest versioned builder) and
      semantic builder-version selection.
- [x] SESSION 31: REAL-PROVIDER FIX IMPLEMENTED — app/agentstore.py write_provider now
      writes the key to BOTH top-level apiKey and options.apiKey (options preserved);
      3 new tests (34/34 green); real tokenrouter provider re-created via the app's own
      write_provider (key from the app's backup, never echoed) + models restored +
      activeProviders=[omniroute, tokenrouter]; kilo rebuilt via /api/build; built
      kilo.json tokenrouter verified to carry options.apiKey; hash-verified snapshot
      (only intended files changed); app server restarted with the fix. USER-SCOPED
      feature: real providers (TokenRouter, Modal, OpenAI, Google Gemini, OpenRouter,
      NVIDIA NIM) added via the app and used through agents — real-provider presets with
      SDK auto-fill added to the Add-provider form (gui.html + config.py synced);
      Modal researched (OpenAI-compatible; combined proxy token wk-<id>.ws-<secret>);
      app README updated.
- [x] SESSION 32: ACCEPTANCE PASSED (Kilo chat with TokenRouter answers, no 401) +
      OpenCode /models fixed (stray opencode.jsonc with disabled_providers shadowed the
      built opencode.json — removed, backed up; user rule documented) + BUILDER PARITY:
      builders mirror the dual key at merge time (K1 + V2.7 + wizard copies; scaffold
      bootstraps from K1) — hand-written provider files now converge with app-written
      ones; kilo harness fixed to per-provider models fixtures + new 'Dual-key options
      mirror' test (31/31), opencode harness 31/31; stale test-kilo.ps1 (OpenCode copy)
      replaced with the real K1 harness; real kilo rebuild dual-keys omniroute too;
      docs overhaul (root README, app README rules, PROVIDER_DEVELOPMENT_GUIDE +
      template, DEVELOPER_GUIDE, CHANGELOG 2.5.1, PROJECT_STATE, FOLDER_STRUCTURE,
      ROADMAP); committed.
- [x] SESSION 33 (COMPLETE, 2026-08-08): FINAL FULL SYSTEM CHECK (pre-public gate) per
      AI/CONTINUE_FULL_SYSTEM_CHECK_SESSION_33.md — docs coherence audit
      (FSC v1.1 parts 1-7 + dual-key/jsonc/app-docs truth), builder testing
      (kilo 31/31, opencode 31/31, legacy, real builds, sandbox bootstrap),
      adversarial app code review (path traversal, CORS, proxy SSRF, XSS,
      theme injection, secrets/PII leak scan), full GUI click-through on the
      real kilo config with snapshot + hash-verified restore, fix loop until
      green, report + commit — then the repo goes public.
- [ ] FUTURE: app update to generate BOTH opencode.json and opencode.jsonc (planned,
      not yet — documented); add Modal/other real providers via the app when wanted.
- [ ] FUTURE (Phase 15): extend the app + universal scaffold to MORE coding agents
      (OpenCode + KiloCode verified; others expected to work — untested yet).

Dropped: Claude Code Builder V1 — 2026-08-08 decision (entropic `~/.claude.json`, no
provider support). See `planning/DECISIONS.md`.

Next: Phase 15 - make the app + universal scaffold work for Claude Code and more open-source coding agents; commit session-34 updates on the owner's request.
after the gate: BUILDER_PHASES Alpha→Beta→General + Step 4 / Step 5.

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
- PART F: FULL SYSTEM CHECK 2026-08-09 (pre-public gate) - all harnesses green (17/17 + 13/13 + 33/33 + 31/31), 56/56 app tests, full GUI click-through PASS; fixed scaffold-bootstrap harness spec paths (relative + skip-if-absent), stale exact-name builder/harness copies re-synced, dead config.PRESETS removed, release-doc counts updated to reasoning-formats state; report: AI/FULL_SYSTEM_CHECK_REPORT_2026-08-09.md
