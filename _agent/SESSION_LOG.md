# Session Log

> History of completed sessions in this documentation repository.

> Read AGENT.md for the full project context.

> Read _agent/SESSION_WORKFLOW.md for the session rules.

---

## Session History

### Aug 5, 2026 (session 15) — Built and released Builder V2.5 Active-Provider Selector (registry 2.4.0) ← recent session
Done:
- Baseline fix: real `profiles/coding/models.json` was missing (removed during V2.5 prep), breaking V2.1 harness test 17 (16/17). Recreated it from the omniroute model set (18 models); V2.1 harness back to 17/17.
- Built `scripts/build-opencode-v2.5.ps1` (V2.1 copy + 3 new stages): Stage 0 Discover-Providers (all providers/*.json, malformed = fail naming files), active-provider selection (interactive menu / -Provider / -NonInteractive) with settings.json persistence (backed up to backup/settings_*.json, $schema preserved, rewritten only when list differs), profile-level <provider>-models.json with highest precedence (profile > providers/<p>/models.json > inline > global). Verification additions: every active provider must have a models source; Stage 8 settings.json round-trip check. V2.1 script + harness byte-for-byte untouched.
- Built `scripts/test-opencode-v2.5.ps1`: 12 tests, all passing. Test 12 Test-BuilderSpecCoversV25 greps BUILDER_SPEC.md for the 6 feature tokens (regeneration-guarantee sync test).
- Docs sync (regeneration source): BUILDER_SPEC.md full V2.5 section (CLI table, 9 stages, 6 function contracts with verbatim error text, precedence, file shapes, regeneration guarantee, Current Builder = V2.5); JSON_SCHEMAS.md, FOLDER_STRUCTURE.md, ADAPTER.md, ARCHITECTURE.md, TESTING.md (both-harness definition of complete), README.md, PROJECT_STATE.md updated.
- Real-world validation: coding profile build with -Provider modal,omniroute -> opencode.json has modal/kimi-k3 (from profile modal-models.json), omniroute 18 models, settings.json rewritten, backup created; interactive menu validated on the real profile (Enter keeps current).
- Release: release_registry.json 2.4.0 entry (Current, builderVersion V2.5) + 2.3.0 flipped to Previous; user reviewed and approved; release-manager.ps1 regenerated CHANGELOG.md, CURRENT_RELEASE.md, PROJECT_STATE.md version table, bdf/VERSION.md rows (Supported Builder Versions V2.5, V2.3, V2.1). Note: plan's verbatim empty "bugFixes": [] rejected by release-manager validation (empty array serializes as ""); used one real fix entry instead.
- Final sweep: 17/17 (V2.1) + 12/12 (V2.5), exit 0. JOURNEY_TO_V3.md side goal 1 ticked (registry 2.4.0), Next line updated to JSON Schema Validation side goal then Step 2.

Broken:
- None — clean session.

Journey: Step 1 BDF V2.5 — COMPLETE, 100%; side goal Active-Provider Selector Builder done (2.4.0); JSON Schema Validation side goal open.

Next: Next work: JSON Schema Validation side goal (schemas/), then Step 2 Claude Code Builder V1. Note: scripts/profiles/providers live outside the git repo (untracked by design); docs commits only.

Learned: The plan's verbatim empty "bugFixes": [] collides with release-manager required-field validation (empty array -> "" -> "missing required field"); registry entries must not use empty arrays.

### Aug 5, 2026 (session 14) — Reviewed V2.5 changes; added Builder Phases quality gates
Done:
- Reviewed the uncommitted V2.5 work (19 modified + 3 new bdf/ docs) via a sub-agent diff audit: release version 2.3.0 / builder V2.3 consistent across release_registry.json, CHANGELOG.md, CURRENT_RELEASE.md, PROJECT_STATE.md, ROADMAP.md; framework version 2.1.0 in bdf/VERSION.md confirmed as the separate intentional framework-numbering scale (not a mismatch).
- Re-verified the test harness on the uncommitted state: test-opencode-v2.ps1 17/17 PASSED, exit 0 (includes read-only real-docs consistency test).
- Created `bdf/BUILDER_PHASES.md` (v1.0): defines the three build phases every builder build must pass — Alpha (first working build), Beta (hardened, tests green), General Release (released, becomes the main builder). Evolution rule: a build passes Alpha + Beta → reaches General Release → only then does the main builder evolve to it; a build in Alpha/Beta is never the evolution starting point.
- Registered BUILDER_PHASES.md everywhere: FRAMEWORK.md (components 11 → 12 + Question 2 answer), bdf/README.md (components table + architecture tree + "How To Use"), BUILDER_EVOLUTION.md (framework reference table), FRAMEWORK_LIFECYCLE.md (Stage 4 Testing = Alpha, Stage 5 Release = Beta → General Release + component table), PROJECT_STATE.md (folder tree + bdf contents table), JOURNEY_TO_V3.md (phase-gates note for road-to-V3 builds).
- No release triggered — doc-level framework addition only; registry/CHANGELOG/CURRENT_RELEASE untouched this session.

Broken:
- None — clean session.

Journey: Step 1 BDF V2.5 — COMPLETE, 100%; we are here = Step 2 Claude Code Builder V1

Next: User reviews the V2.5 changes + BUILDER_PHASES.md, discusses planning/NEXT_PHASE_IMPLEMENTATION_PLAN.md, then commits the docs repository; then Step 2 — Claude Code Builder V1 (will pass Alpha → Beta → General Release gates per BUILDER_PHASES.md).

Learned: The phase-gate model (Alpha → Beta → General Release) ties the version workflow (BUILDER_EVOLUTION.md) to a definition of "ready to become the main builder" — tests gate Alpha→Beta, the release pipeline gates Beta→General Release.

### Aug 5, 2026 (session 13) — BDF V2.5 complete: framework generalization, released 2.3.0
Done:
- Built BDF V2.5 (Framework Generalization) per `AI/BUILD_BUILDER_V2.5.md`, following the Builder Evolution workflow (Impact Analysis record → architecture → docs → templates → version → release).
- Feature 1: created `bdf/NEW_PROJECT_GUIDE.md` (10-step onboarding, claude.json/opencode.json research examples, "project knowledge lives only in the adapter"); registered in FRAMEWORK.md (components + document table), AI_WORKFLOW.md (Branch B), PROJECT_GENERATOR.md, bdf/README.md.
- Feature 2: adapter field table now single source of truth in `templates/ADAPTER.template.md`; PROJECT_ADAPTER.md describes each field + refers to the template (duplication removed); prose validation replaced with a 9-criterion executable Adapter Validation Checklist; reference `ADAPTER.md` verified to pass it (model sources checked against `profiles/default/models.json`).
- Feature 3: `templates/README.md` — placeholder audit (added the missing `{{PLACEHOLDER_NAME}}` row; all listed placeholders used), cross-reference matrix (framework doc ↔ templates), provider placeholders confirmed generic (not OpenCode-shaped), template sync rule stated.
- Feature 4: `BLUEPRINT_ENGINE.md` now defines the Impact Analysis record (affected documents/components/tests + backwards compatibility), required before the next stage starts.
- Feature 5: OpenCode audit of `bdf/` — removed hardcoded `opencode.json` + "OpenCode-specific" label from MIGRATION.md and PROJECT_ADAPTER.md (Layer 1 no longer depends on Layer 2); created `bdf/RELEASE_MANAGER.md` (registry single source of truth, all-or-nothing writes, verify-before-write, marker policy, deterministic no-op); registered + reference ADAPTER.md now points to it.
- Feature 6: created `bdf/TESTING.md` (generic test-harness pattern, 3 test groups, headless + deterministic, harness part of a version's definition of complete); registered; `docs/TESTING.md` aligned as the project mirror.
- Release: bdf/VERSION.md framework 2.0.0 → 2.1.0 (change history entry + version rows); release_registry.json prepended 2.3.0 entry (builderVersion V2.3, status Current; 2.2.0 → Previous); release-manager.ps1 wrote CHANGELOG / CURRENT_RELEASE / PROJECT_STATE version table / VERSION.md rows ("Supported Builder Versions | V2.3, V2.1"); rerun = deterministic no-op.
- Reference sync: ROADMAP.md Phase 10 → Completed (✅), project status 2.3.0 / Framework Generalization, Phase 11 → Planned-next; PROJECT_STATE.md regenerated (folder tree + bdf contents + version 2.3.0 + framework 2.1.0 + sections 11/13); CHANGELOG manual Version History table updated (2.3.0 Current); JOURNEY_TO_V3.md Step 1 COMPLETE 100%, we-are-here moved to Step 2.
- Tests: harness 17/17 PASSED exit 0 (run twice — before and after the reference-doc sync); release manager no-op exit 0.

Broken:
- None — clean session.

Journey: Step 1 BDF V2.5 — COMPLETE, 100%

Next: Commit the docs repository (V2.5: 18 modified + 3 new bdf/ docs: NEW_PROJECT_GUIDE.md, RELEASE_MANAGER.md, TESTING.md); user review; then Step 2 — Claude Code Builder V1.

Learned: The generic/project boundary audit is executable — grep `bdf/` for concrete target names (opencode.json, .config/opencode, omniroute) and keep only frame-as-example hits; a single source of truth for adapter fields makes the reference adapter checkable against the template; the release pipeline proved deterministic no-op twice.

### Aug 4, 2026 (session 12) — Fixed backup timestamp bug in both builders; generated architecture maps
Done:
- Root-caused backup timestamp bug: backup filenames + CreationTime were correct (09:08) but "Date modified" (LastWriteTime) showed 07:37 — `Copy-Item` preserves the source file's LastWriteTime, so backups displayed the OLD opencode.json's write time (previous session), not backup creation time. Confirmed pattern across all 4 existing backups (LastWriteTime 1-3h behind CreationTime).
- Fixed both builders to stamp real time after copy: scripts/build-opencode-v2.ps1 (~line 810-817) and scripts/build-opencode.ps1 (~line 103-110) now set `$BackupFile.CreationTime`/`LastWriteTime = Get-Date` after Copy-Item.
- Verified: test-opencode-v2.ps1 17/17 PASSED; real build `-Profile default` regenerated opencode.json (09:24) and the new backup opencode_2026-08-04_09-24-05.json shows LastWriteTime = CreationTime = 09:24 (matches clock). Ran release-manager.ps1 → "All outputs already up to date - nothing written" (deterministic no-op confirmed).
- Reviewed PROJECT_STATE.md completeness for a ChatGPT handoff: it is a complete living snapshot + index (15 sections) but intentionally defers script internals / BDF content / registry structure to other docs; recommended handoff = PROJECT_STATE + README + ARCHITECTURE + BUILDER_SPEC + bdf/FRAMEWORK + bdf/BLUEPRINT_ENGINE + bdf/README.
- Generated architecture maps via Kroki (mmdc not installed): docs/system-architecture.mmd/.png (Layer 1 BDF → Layer 2 project docs → sources → scripts → generated artifacts → OpenCode app) and docs/build-release-pipeline.mmd/.png (builder 8-stage + release manager all-or-nothing + 17-test coverage). Both validated (Kroki HTTP 200, 2048px PNG).
- Used the sub-agent distribution workflow: 3 parallel reader sub-agents summarized PROJECT_STATE.md, all bdf/ docs, and all system docs (~150 KB) — only ~1.3k words entered main context.

Broken:
- None — clean session. Old backups (pre-fix) still show stale LastWriteTime (historical data, untouched; user may want them corrected).

Next: Commit the docs repository (standing instruction from session 7: nothing committed; untracked: AI/DISTRIBUTE_SUBAGENTS.md, system-architecture.mmd/.png, build-release-pipeline.mmd/.png, this log entry). User to review PROJECT_STATE.md handoff package for ChatGPT. Optional: correct stale LastWriteTime on the 3 pre-fix backups.

Learned: `Copy-Item` preserves the source's LastWriteTime — a backup's "Date modified" can show a time from a previous session while CreationTime/filename are correct. Debug fast: compare CreationTime vs LastWriteTime on backups; a stale LastWriteTime means copy-with-metadata, not a clock/timezone problem. Diagrams export fine via Kroki when mmdc isn't installed.

### Aug 4, 2026 (session 11) — Final full-repo test: 5-agent audit, 28 doc bugs fixed, 17/17 green
Done:
- Dispatched 5 parallel audit sub-agents covering all 60 files (root docs, bdf/, bdf/templates/, AI/, _agent/, SDD ledger); every finding personally verified against source files before fixing.
- Baseline + post-fix harness runs: test-opencode-v2.ps1 17/17 PASSED, exit 0 (9 builder + 8 Release Docs); release manager no-op exit 0 ("All outputs already up to date - nothing written").
- Fixed 28 doc bugs across 18 files: PROJECT_STATE.md AI/ tree completed (3 → 8 files); SESSION_LOG field count 13 → 14; BUILD_RELEASE_MANAGER.md spec example 9/9 → 17/17 + missing "and"; CONTINUE_RELEASE_MANAGER.md tasks 1/4/5 aligned to the amended plan (Task 3 absorbs markers, Tasks 4-5 verify-only); AI_WORKFLOW.md gained the missing Update Architecture stage (vs BLUEPRINT_ENGINE); BUILDER_EVOLUTION.md reordered Builder/Docs + added Template Changes stage (vs its own Rule 2); FRAMEWORK.md/PROJECT_GENERATOR.md/PROJECT_STATE.template.md PROJECT_STATE.md listing gaps; template path fixes (templates/README.md `../PROJECT_GENERATOR.md`, ADAPTER.template.md `bdf/FRAMEWORK.md`); ROADMAP.template.md `{{PROJECT_STATUS}}` + emoji removal; TESTING.md + TESTING.template.md `{{SCRIPTS_DIR}}` + duplicated-coverage dedup; CONTRIBUTING_FOR_AI.md + template read order aligned to AGENT.md; 4 template docs tables completed to the 15-doc set; JSON_SCHEMAS.md model precedence now matches BUILDER_SPEC.md; progress.md Task-10 duplicates removed; TESTING.md PowerShell 5.1 env note.
- Verified every fix in place (builder agents re-read each edit + main-thread greps); harness re-run 17/17 green after all fixes.
- Deliberately untouched: PLAN_RELEASE_MANAGER.md + task briefs/reports (historical execution records; ledger documents amendments), bdf/VERSION.md "V2.1" row (USER RULING), ROADMAP.md ✅ markers (consistent within the doc).

Broken:
- None — clean session.

Next: User reviews session-11 fixes, then commits the docs repo (standing instruction: nothing committed; 28 modified files + untracked AI/DISTRIBUTE_SUBAGENTS.md).

Learned: A final full-repo test with parallel sub-agent audits catches real drift (28 issues) that single-pass review misses — but every agent finding must be personally verified against the source before editing, since some "inconsistencies" are deliberate rulings or historical records.

