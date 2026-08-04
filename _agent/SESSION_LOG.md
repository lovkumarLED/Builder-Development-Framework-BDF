# Session Log

> History of completed sessions in this documentation repository.

> Read AGENT.md for the full project context.

> Read _agent/SESSION_WORKFLOW.md for the session rules.

---

## Session History

### Aug 4, 2026 (session 12) — Fixed backup timestamp bug in both builders; generated architecture maps ← recent session
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

### Aug 4, 2026 (session 10) — Built the sub-agent distribution system; set 70% context ceiling
Done:
- Created the sub-agent distribution workflow: skill `~/.config/opencode/skills/subagent-distribution/SKILL.md` — plan (todowrite) → estimate S/M/L size + time + token cost → distribute to sub-agents → mandatory ≤300-word summaries → integrate from summaries.
- Created 6 custom sub-agents in `~/.config/opencode/agent/`: reader (read-only summaries), writer (edit per spec), builder (implement + test), terminal (PowerShell/git, destructive ops ask), planner (breakdown/estimates), researcher (web).
- Created the session prompt `docs/AI/DISTRIBUTE_SUBAGENTS.md` and registered it in opencode.json `instructions` so every session auto-loads the workflow (no pasting needed).
- Updated `_agent/SESSION_WORKFLOW.md` to v1.2: Context Window Budget section (triggers at 50% delegate / 65% wrap up / 70% hard stop) + session log entry now mandatory for EVERY session.
- Demonstrated the pattern: dispatched 5 parallel reader sub-agents to read all ~560 KB of docs; only compact summaries entered the main context.
- Verified: opencode.json still valid JSON; all agent/skill files present with valid frontmatter.

Broken:
- None — clean session.

Next: User restarts opencode and verifies the system loads (skill + 6 agents + DISTRIBUTE_SUBAGENTS.md instructions); review session 10 changes; standing instruction still open: commit the docs repository (sessions 7-10).

Learned: The docs repo (~560 KB) ≈ 140k tokens ≈ 70% of a 200k window when read directly — delegating reads to sub-agents (each with its own fresh context window) means only ~300-word summaries return, keeping the main window near-empty for actual work.

### Aug 4, 2026 (session 9) — Audited the whole docs repo; fixed stale template drift + stale release facts
Done:
- Read every MD file (root docs, bdf/, bdf/templates/, AI/, _agent/, .superpowers/sdd/) and cross-checked docs ↔ templates ↔ release pipeline (release_registry.json → release-manager.ps1 → CHANGELOG.md / CURRENT_RELEASE.md / PROJECT_STATE.md / bdf/VERSION.md).
- Baseline: test-opencode-v2.ps1 17/17 PASSED, exit 0 (test 17 read-only real-docs consistency green).
- Fixed stale release facts in release_registry.json (source of truth): testingSummary 9/9 → "17/17 tests passed, exit 0" (verified by an actual 17/17 harness run); harness feature description now "17 tests: 9 builder + 8 Release Docs". Regenerated via release-manager.ps1: CHANGELOG.md + CURRENT_RELEASE.md diffs show only the two intended lines changed (deterministic pipeline confirmed).
- Fixed BUILDER_SPEC.md Builder Status V2 → V2.1 (registry builderVersion is V2.1; the doc already described V2.1 features incl. Stage 7 Verification).
- Fixed stale templates (framework-level alignment with reference docs): BUILDER_SPEC.template.md V2 → V2.1; AGENT.template.md read order now includes PROJECT_STATE.md + ADAPTER.md and gained the Builder Development Framework / Session Continuity / Project State sections (mirrors AGENT.md 1.3); CONTRIBUTING_FOR_AI.template.md reading order now 8 docs (added PROJECT_STATE.md + ADAPTER.md); TESTING.template.md no longer says "future automated testing" — mirrors the 17-test harness (Purpose, JSON Validation Tests heading, Release Docs Test Group table, Manual Testing Procedure, Future Testing Expansion); bdf/templates/README.md gained the {{TEST_HARNESS}} placeholder and refreshed stale example values (2.0.0 → 2.2.0). Normalized LF → CRLF in edited files to match the working tree.
- Non-issues checked and cleared: no unreplaced {{placeholders}} outside bdf/templates/; PROJECT_STATE.md and its template both have exactly 15 numbered sections (AGENT.md "15-section" rule correct); no new bugs found in release-manager.ps1 or the harness.
- Verified: harness re-run 17/17 PASSED, exit 0; git diff reviewed line-by-line (9 files, only intended changes).

Broken:
- None — clean session.

Next: Commit the docs repository (sessions 7 + 8 + 9 changes; standing instruction: nothing committed); user review of session 9 fixes; decide whether to record the template alignment as a BDF framework patch (templates README requires "template changes are recorded in the framework version history").

Learned: Templates must mirror the reference implementation ("example values come from the reference implementation") — stale templates are real bugs, not decoration; the release pipeline proved deterministic (regeneration touched only the two registry-derived lines).

### Aug 4, 2026 (session 8) — Built the Release Manager V1 (registry, marker pipeline, 17-test harness, docs) 
Done:
- Built `scripts/release-manager.ps1` (outside git): registry → generator → CHANGELOG/CURRENT_RELEASE/PROJECT_STATE/VERSION.md artifacts; all-or-nothing writes; duplicate-key raw-text scan (PS 5.1 ConvertFrom-Json collapses duplicates); marker policy (abort if AUTO-GENERATED markers missing); Verify-Generated before any write; final run exit 0 "All outputs already up to date - nothing written."
- Created `docs/release_registry.json` (single 2.2.0 entry, 14 fields; the only hand-edited release artifact).
- Converted CHANGELOG.md to a marker section: rich 2.2.0 entry generated from registry; legacy entries 2.1.0 → 1.0.0 and the manual Version History table untouched (byte-verified). PROJECT_STATE.md version table marker-wrapped; bdf/VERSION.md rows managed (Supported Builder Versions = V2.1 per user ruling; Last Updated).
- Added generated `docs/CURRENT_RELEASE.md`; deleted superseded `RELEASE_NOTES_V2.1.md`.
- Extended the harness to 17 tests (Release Docs group 10-17: registry shape, manager outputs, determinism, CURRENT_RELEASE match, registry↔CHANGELOG consistency with legacy preservation, VERSION rows, missing-marker abort, read-only real-docs consistency). Final run 17/17 PASSED, exit 0.
- Updated 12 docs to describe the release pipeline (marker policy, ownership rules, one-command release workflow); fixed the stale CHANGELOG manual Version History table (2.2.0 Current / 2.1.0 Previous).
- End-to-end release drill on a temp docs copy (simulated 2.3.0/V2.2 release): all outputs correct (CHANGELOG 2.3.0 above 2.2.0; VERSION.md row "V2.2, V2.1"), real docs byte-identical (5 SHA-256 unchanged), git status unchanged, temp root deleted. Drill exposed the registry array-order question → user ruling: newest-first (prepend); the spec already stated this at AI/BUILD_RELEASE_MANAGER.md.
- Release manager re-run + full harness re-run as final verification: manager exit 0 (nothing written); 17/17 PASSED exit 0. 6 parked review minors triaged (all inert or fails-safe; recorded in the SDD ledger). Nothing committed (standing instruction).

Broken:
- None — clean session.

Next: Commit the docs repository (all session 8 changes); user review of Release Manager V1 (registry, manager, harness, generated docs).

Learned: A temp-copy drill is the cheapest proof that a generator leaves the real tree untouched, and it surfaces spec decisions early — the drill's conflict (registry array order vs. per-output display order) was a user ruling, not a code bug; the manager's job is to follow the registry, one source of truth.

### Aug 4, 2026 (session 7) — Built Builder V2.1 (validation, merge pipeline, provider models, verification, tests)
Done:
- Followed the BDF spec (AI/BUILD_BUILDER_V2.1.md); evolved `scripts/build-opencode-v2.ps1` in place from V2.0 to V2.1 (user instruction: no versioned script files, git keeps history).
- Extended validation: duplicate model IDs/names, plugin IDs, provider IDs, malformed provider/profile definitions, missing required fields, invalid structure. Duplicate keys detected on raw JSON text because PS 5.1 ConvertFrom-Json silently collapses duplicates.
- Split merge into stages: Merge-Settings/Providers/Models/Plugins/Mcp/Final; provider-specific models with precedence `providers/<p>/models.json` > inline provider models > global `models.json` (global only when provider has none — preserves V2 behavior).
- Split verification: Verify-Json → Verify-Providers → Verify-Models → Verify-Plugins → Verify-MCP, orchestrated by Verify-FinalOutput, runs before writing; backup failure aborts before write.
- Concise count-based logging ("58 model(s) merged"); added -ConfigRoot param for isolated test builds; release summary with Validation/Merge/Verification/Generated PASS + build time.
- Created `scripts/test-opencode-v2.ps1` harness (9 tests): valid coding profile (real files, no manual editing), invalid JSON, missing provider, duplicate model IDs, duplicate model names, duplicate plugins, malformed provider, provider-specific models, backup failure safety. Final run 9/9 passed, exit 0.
- Fixed 3 real builder bugs found by tests: `$Section:` here-string parse errors, PSObject.Properties.Count unreliability (wrap with @()), plugin single-element array unrolling (`return ,$Plugins.plugin`).
- Backwards compatibility verified: default build output byte-identical to a V2.0-era backup (58 models, 1 plugin, 9 MCP servers); removed 2 corrupted backups created during intermediate buggy runs.
- Docs updated: BUILDER_SPEC.md (pipeline, validation list, merge stages, model precedence, Stage 7 Verification), CHANGELOG.md (2.2.0), PROJECT_STATE.md (2.2.0), TESTING.md (automated harness), ROADMAP.md (phases 5-7 Completed), FOLDER_STRUCTURE.md, ARCHITECTURE.md, ADAPTER.md, README.md, bdf/VERSION.md (supports V2 + V2.1).
- No migration needed (zero breaking changes); templates left untouched (version-independent).

Broken:
- None — clean session.

Next: Commit the docs repository (session 7 changes); user review of Builder V2.1 release.

Learned: PS 5.1 ConvertFrom-Json silently keeps the last duplicate key — duplicate detection must scan raw text; `.PSObject.Properties.Count` is unreliable (returns odd values) — wrap with `@()`; returning a single-element array from a function unrolls it — use `return ,$array` to keep array shape in JSON output.

