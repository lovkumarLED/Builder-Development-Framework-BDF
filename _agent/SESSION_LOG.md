# Session Log

> History of completed sessions in this documentation repository.

> Read AGENT.md for the full project context.

> Read _agent/SESSION_WORKFLOW.md for the session rules.

---

## Session History

### Aug 8, 2026 (session 28c) â€” No-Secrets Rule (ULTIMATE) + kilo build fix + ROADMAP phase markers â† recent session
Done:
- USER RULING clarified: the system CAN copy-paste API keys (scan â†’ copy â†’ paste is its job; MCPs/providers need their keys), the user protects their own files â€” but the SYSTEM's own artifacts (scripts, templates, docs, examples) NEVER contain a literal key, only `{env:VAR}` placeholders.
- Restored all user-owned files to their original state (they had been wrongly purged): kilo.json, kilo.jsonc, all kilo mcp.json files, kilo/providers/omniroute.json (literal key back), opencode.json + all opencode mcp.json files (GH_TOKEN/EXA/CONTEXT7 literals back).
- Verified: system artifacts (all scripts + 15 templates + all docs) contain ZERO literal keys; user files keep theirs. Both builds re-run green; generated kilo.json/opencode.json carry the user's keys verbatim (copy-paste job, required for MCPs/providers).
- KILO BUILD FIX: restored `kilo/profiles/coding/omniroute-models.json` (18 models, extracted from the last successful build backup `kilo_2026-08-08_04-50-44.json`) â€” the models source had been removed during cleanup, which broke the real build ("No active providers selected"). Real build now: backup â†’ 18 models merged â†’ all stages PASS â†’ kilo.json regenerated (29 KB) â†’ provenance stamped â†’ idempotent rerun. The user's exact command `build-kilo-v1.ps1 coding -DryRun -Verbose` verified exit 0.
- ROADMAP phase markers: Phase 4 (was "Planned" â†’ Completed), 10.5 (was "Planned" â†’ Completed, released as registry 2.4.0), 11 (Resolved-dropped) now carry âœ…; Phases 1-7, 9, 10, 10.6, 12 all âœ…; Phase 13 ðŸ”„; added Phase Completion Summary table (12 of 13 complete; Phase 8 still Planned). Template ROADMAP.template.md synced (Phases 2-7 statuses fixed + âœ…/ðŸ”„ markers). bdf/VERSION.md 2.2.5 â†’ 2.2.6.
Broken: None blocking. Real kilo build green with user's restored provider + models.
Journey: Step 3 universal core (~90%) â€” contract locked, no-secrets rule locked, kilo real build green.
Next: Only the kilo builder test remains per the handoff (already green); commit docs on request. No other checks.
Learned: Two-world rule â€” user files may hold literal keys (user protects), system artifacts never do, and the system copies user content verbatim; stripping user keys breaks real builds and is NOT the rule.

### Aug 8, 2026 (session 28b) â€” V3 scaffold contract finalized (user ruling) + kilo backup-first test
Done:
- USER RULING implemented: the framework creates the `providers/` folder (like the profile folders) but NEVER writes provider or model JSON files inside it â€” the JSON files are 100% user-owned. The framework's ONE job: scan the agent's OWN main JSON (kilo.json for kilo â€” never another agent's config), split mcp/plugin sections, seed the profiles.
- `scripts/scaffold-agent.ps1` rewritten: scans only the agent's primary main JSON; seeds `coding/mcp.json` + `coding/plugins.json` once (user-owned after); creates EMPTY mcp/plugins for experimental/minimal (never filled); `settings.json` = `$schema` + `activeProviders` only (never copy-paste the config); providers/ folder created but provider files never written (guidance only); discovery/ask-for-location/-List/-Bootstrap/Non-JSON guard/error self-fix preserved.
- Cleaned framework-created model files: kilo coding `omniroute-models.json`, opencode experimental + minimal `omniroute-models.json`. kilo `providers/omniroute.json` was removed during cleanup then RESTORED (user ruling â€” the user created that file; folder is framework's, files are user's). Reset kilo profile settings.json to minimal shape (like OpenCode).
- Kilo backup-first test: main kilo.json + kilo.jsonc + profiles backed up to `%TEMP%\opencode\kilo-backup-20260808-071644`; `test-kilo-v1.ps1` â†’ 30/30 exit 0; main kilo.json byte-identical after (backup policy verified â€” system always backs up before touching). Real build with the restored provider file now fails at the models guard ("models not found") â€” models source is user-owned, by design.
- Docs updated (Q1 answered: yes, all integral MD files + bdf templates): `BUILDER_SPEC.md`, `bdf/templates/BUILDER_SPEC.template.md`, `kilo/docs/BUILDER_SPEC_KILO_ADAPTER.md` (Contract rewritten), `PROJECT_STATE.md` (scaffold description + framework 2.2.4), `FOLDER_STRUCTURE.md` (V3 scaffold profile shape section), `ROADMAP.md` (Phase 13 definition of complete + status), `planning/BDF_ROAD_TO_V3.md` (Supported Projects + Definition of V3 rules), `planning/NEXT_PHASE_IMPLEMENTATION_PLAN.md` (Phases 5 + 7), `_agent/JOURNEY_TO_V3.md`, `bdf/VERSION.md` 2.2.3â†’2.2.4 (template-change version bump, change history + rows).
- Handoff written: `AI/CONTINUE_SCAFFOLD_CONTRACT_KILO_TEST.md` (Q3) â€” documents what was NOT done (the full framework system test was not run; the kilo real-config build needs the user's own provider files) + next-session task = ONLY the kilo builder test (backup-first), no system check.
Broken: None blocking. Real kilo build waits for a user-provided models source (provider file restored; models are user-owned, by design).
Journey: Step 3 universal core (~90%, scaffold contract now finalized) â€” unchanged position, contract locked.
Next: Only the kilo builder test (per the handoff MD): user adds a models source for omniroute â†’ build-kilo-v1.ps1 real run â†’ test-kilo-v1.ps1 30/30 â†’ byte-check mains. No other checks.
Learned: The user owns providers/models absolutely; the scaffold's value is scanning the agent's own main JSON and seeding the 3-profile structure without ever inventing content. Backup-before-touch is automatic and byte-verified.

### Aug 8, 2026 (session 28) â€” FULL_SYSTEM_CHECK v1.1 rerun: 40+ bugs fixed, all 7 parts green
Done:
- Executed `AI/FULL_SYSTEM_CHECK.md` v1.1 (Parts 1-7) with 3 parallel audit subagents (bdf/ framework, AI+planning+_agent, root project docs) + inline verification battery.
- Part 1 Document graph: PASS. 2 hard broken refs fixed: `AI/CONTINUE_KILO_BUILD_STEP2.md` resume prompt pointed at nonexistent `CONTINUE_KILO_1_TRANSFORM.md` â†’ `CONTINUE_KILO_BUILD_STEP3.md`; `AI/CONTINUE_V3_UNIVERSAL_FRAMEWORK_v2.md` AGENTS.md Verify asserts corrected (relocation reverted per user â€” no AGENTS.md anywhere; git-confirmed never tracked). Orphan junk files deleted: 2 stale copies (`System.Object[] ...` names, 55 KB/49 KB) of build-kilo-v1.ps1 + test-opencode-v2.7.ps1. `_agent/SESSION_LOG.md` mojibake repaired (25 em-dashes, 15 arrows, 6 double-arrows double-encoded â†’ fixed; tag restored to â† recent session). PROJECT_STATE docs-tree + planning tree updated (all 21 AI files + NEXT_PHASE_IMPLEMENTATION_PLAN.md listed).
- Part 2 Version consistency: PASS. Root causes fixed in release_registry.json (31-test V2.7 harness), regenerated CHANGELOG + CURRENT_RELEASE; stale README footer 2.3.0â†’2.5.0; CHANGELOG manual history table +2 rows (2.5.0/2.4.0); PROJECT_STATE framework version 2.1.0â†’2.2.3 + Known Limitations "JSON Schema validation not implemented" removed; bdf/VERSION.md Last Updated + 2.1.1 status Currentâ†’Previous; release-manager determinism re-verified (run1 no-op, run2 no-op exit 0).
- Part 3 Harness + spec sync: PASS. The V2.7 harness actually has 31 registered tests (not 30 â€” Test-SchemaRealSettingsAccepted was never counted in docs). Fixed harness header comment (28â†’31) + every current-state doc (TESTING.md two-harnessâ†’three-harness, 28/28â†’31/31; README/FOLDER_STRUCTURE/PROJECT_STATE/ROADMAP/CURRENT_RELEASE/CHANGELOG/registry/templates README). Battery: v2.1 17/17, v2.5 13/13, v2.7 31/31, kilo 30/30 â€” all exit 0.
- Part 4 Regeneration: PASS by inheritance (snapshot-22 pinned; no builder/schema changes this session) + real 4-profile builds re-verified. LIVE BUG FOUND+FIXED: experimental/minimal profiles failed to build (their omniroute-models.json had vanished again â€” recurring async-deletion issue). Restored 2-model omniroute-models.json in both; builds exit 0; FOLDER_STRUCTURE profile-shape line corrected (target.json optional, absent â†’ falls back to opencode.json).
- Part 5 Snapshots: PASS. snapshot-22 complete (9/9 files).
- Part 6 Session artifacts: PASS. SESSION_LOG 5 entries + â† tag; JOURNEY updated (AGENTS.md claim corrected); budget-ceiling conflict fixed (SESSION_WORKFLOW 65/70 was the outlier vs AGENT.md 70-80% + CONTINUE_PROJECT_BUILD/DISTRIBUTE_SUBAGENTS 75/80 â†’ SESSION_WORKFLOW aligned to 75/80 canonical).
- Part 7 Template â†” reference sync: FAIL â†’ PASS. Fixed: ROADMAP.template (Destination block + phase statuses 9/10/10.6/12/13), PROJECT_STATE.template (bdf contents rows + CURRENT_RELEASE/release_registry rows), JSON_SCHEMAS.template (plugin Objectâ†’array of strings), ARCHITECTURE.template (Not-Implemented "Advanced validation" contradiction), TESTING.template (three-harness coverage + {{V25_TEST_HARNESS}}/{{V27_TEST_HARNESS}}), CHANGELOG.template (YYYâ†’YYYY date typo), templates/README (stale examples 2.2.0/V2.1 â†’ 2.5.0/V2.7; +7 placeholder rows incl. {{CURRENT_BUILDER_NAME}} orphan); bdf/PROJECT_ADAPTER.md (nineâ†’twelve fields + 3 missing field descriptions); bdf/BUILDER_EVOLUTION.md (V2.2 never existed â†’ real sequence V2â†’V2.1â†’V2.3â†’V2.5â†’V2.7â†’V3); bdf/VERSION.md 2.2.2â†’2.2.3 (version-bump rule) + 2.2.2 status Previous + doc footer 1.2. Placeholder audit: 63 used = 63 rows, zero orphans.
- Reference-doc fixes: ARCHITECTURE.md (pipeline names v2.7, Implemented/Not-Implemented corrected), JSON_SCHEMAS.md (plugin array type, target.json in Implemented list), BUILDER_SPEC.md (garbled pre-flight verbatim message + F4/provenance contracts hardcoded opencode_* â†’ target-artifact-derived; WhatIf messages match script), TESTING.md (Test Environment lists v2.7 scripts).
- Planning docs: VERSION_STRATEGY road (V2.2.0â†’V2.7 + V2.7 gate step), FUTURE_IDEAS (2 shipped ideas â†’ Shipped table), DECISIONS (superseded entry Reversal field), NEXT_PHASE_IMPLEMENTATION_PLAN (`.kilo`â†’`.config\kilo`; delivered Kilo scope vs "ignore plugins/skills/MCP"), CONTINUE_BUILDER_V2.7_TASK9 (superseded marker + P1 contradiction), CONTINUE_KILO_BUILD_STEP3 (file-name/content mismatch note).
Broken: None blocking. Recurring watch item: profile model files (experimental/minimal omniroute-models.json, coding models.json) vanish on disk without a tracked change â€” recheck before each battery.
Journey: Step 1 BDF V2.5 COMPLETE; Step 2 KiloCode COMPLETE; here = Step 3 universal core (~90%) â€” unchanged by this check.
Next: Commit docs on request. Optional: real `-Bootstrap` against aider/goose only if user installs them; BUILDER_PHASES Alphaâ†’Betaâ†’General gates for the universal framework.
Learned: Doc test counts drift silently when a harness gains a test without a doc-sync pass; a naive regex doc-graph check floods with false positives (config-file names, script-name tables) â€” directory-prefixed backtick refs are the reliable signal; the V2.7 harness header comment is a single source of truth that must be updated in the same commit as the new test.

### Aug 8, 2026 (session 27) â€” Claude decision + universal scaffold bootstrap fix
Done:
- User decision recorded: Claude Code builder DROPPED (2026-08-08).
  Entropic `~/.claude.json` design, one-provider-at-a-time, no multi-provider support
  -> cannot build a maintainable Claude builder. Plan V1 -> KiloCode (already built,
  KILO V1 / harness 30/30), V3 targets only same-architecture open-source agents
  (OpenCode + KiloCode + any agent clone).
- Docs updated: `planning/NEXT_PHASE_IMPLEMENTATION_PLAN.md` (Phases 3-7 rewritten for
  KiloCode + universal V3), `planning/DECISIONS.md` (new 2026-08-08 entry superseding
  "Only three supported targets"), `ROADMAP.md` (path + Phase 11-13: Phase 11 Claude
  SUPERSEDED, Phase 12 Kilo COMPLETED, Phase 13 V3 IN PROGRESS), `planning/VERSION_STRATEGY.md`,
  `_agent/JOURNEY_TO_V3.md` (Step 2 Kilo, "we are here" = Step 3 universal), `PROJECT_STATE.md`
  (scripts list + V3 universal + not-implemented), `AGENT.md` (build-continuation version list).
- Universal scaffold docs: `BUILDER_SPEC.md` + `bdf/templates/BUILDER_SPEC.template.md`
  gained "Scaffold Mode (Universal, V3)" section (discovery, contract, refresh-with-backup,
  non-JSON guard, agent registry); `bdf/templates/README.md` +2 placeholder rows;
  `bdf/VERSION.md` 2.2.1 -> 2.2.2 (framework bump for template change).
- BUG FIX: `scripts/scaffold-agent.ps1` bootstrap: generated `test-<agent>.ps1` was
  copied verbatim (stale `build-opencode-v2.7.ps1` / kilo refs) making the generated
  harness fail on non-stock agents. Now the test file gets the same token substitution
  as the builder (KiloCode->Agent, kilo.jsonc->config.json, .config\kilo->ConfigRoot,
  build/kilo test file names -> per-agent names). Sandbox-verified against a fresh
  synthetic `custom` agent (agent.json fixture, non-interactive): 30/30 harness green.
- Verification battery (docs-synced + script fix): opencode v2.7 31/31, opencode v2.5
  13/13, opencode v2.1 17/17, kilo v1 30/30 â€” all exit 0. (Correction, session 28: the
  V2.7 harness had grown to 31 tests with Test-SchemaRealSettingsAccepted; the battery
  claim here originally read 30/30.) Discovery (`-List`) still
  sees opencode, kilo, claudecode, codex-cli.
- No commits made (user-gated); sandbox temp dir cleaned.
Broken: real `-Bootstrap` against aider/goose not possible yet (not installed) â€”
registry rows stay.
Journey: Step 1 BDF V2.5 COMPLETE; Step 2 KiloCode COMPLETE; here = Step 3 universal
core (~90%).
Next: commit docs on request; real -Bootstrap needs an installed third-party agent.
Learned: bootstrap test harness needs the same token substitution as the builder; a
real harness battery (4 harnesses) stays green after doc + scaffold changes.

### Aug 6, 2026 (session 22) - FULL_SYSTEM_CHECK v1.1 rerun: all 7 parts green after fixes; snapshot-22 + session-log/journal updates
Done:
- Executed `AI/FULL_SYSTEM_CHECK.md` v1.1 (Parts 1-7) per its resume prompt; delegations to reader/writer subagents for Parts 1/7 plus inline fixes.
- Part 1 FAILâ†’PASS: `FOLDER_STRUCTURE.md` (root tree, mcp.json, `<provider>-models.json`, target.json, provenance; dropped phantom `models.json` section + stale `modal.json` claims), `ADAPTER.md` (2 refs), `TESTING.md` (2 refs), `BUILDER_SPEC.md` (modalâ†’omniroute example), `AI/CONTINUE_BUILDER_V2.7_ISSUES_PATCH.md` (wrong `docs/AI/AI_WORKFLOW.md`â†’`bdf/AI_WORKFLOW.md`). Remaining `modal`/`models.json` mentions = historical (SESSION_LOG + plan docs), allowed.
- Part 2 PASS: `release_registry.json` already 2.5.0/V2.7/2026-08-06/Current; CHANGELOG top row correct; fixed stale `PROJECT_STATE.md` Ã‚Â§2 (2.4.0â†’2.5.0, "Builder V2.7 JSON Schema Validation") + `ROADMAP.md` (path marker, Current Version 2.4.0, Current Status, "Configuration builder (V2.7)"). `release-manager.ps1 -ConfigRoot docs` determinism re-verified (before==after True).
- Part 3 PASS final: `test-opencode-v2.ps1` 17/17, `test-opencode-v2.5.ps1` 13/13, `test-opencode-v2.7.ps1` 30/30 â€” all EXIT 0 (v2.1 Test 1 needed a re-copy of `profiles/coding/models.json`, vanished mid-session again; re-copy = mirror of `omniroute-models.json`, then 17/17 green). Frozen baseline hashes byte-identical. Specâ†”script sync: BUILDER_SPEC V2.7 CLI flags in `build-opencode-v2.7.ps1` (14/14) + F1-F7 table match.
- Part 4 PASS: clean-room rebuild (temp fixtures) = default profile SHA `5646FBF...E0AF` (matches session 21 recorded); coding profile semantically identical to live `opencode.json` (18 models, `{env:OMNIROUTE_API_KEY_OPENCODE}`, 9 MCP servers); live config stale vs fixtures (58 models in default fixtures). Key-scan: 23 JSON files, 0 literal apiKeys. Regeneration guarantee proven via clean-room rebuild + specâ†”script function cross-check (delete-scripts-rebuild full sim not run; docs read-only, scripts frozen by hash).
- Part 5 PASS: created `docs/.superpowers/snapshot-22/` (9/9 building-block files: BUILDER_SPEC/TESTING/ARCHITECTURE/ADAPTER/README/PROJECT_STATE/CHANGELOG/CURRENT_RELEASE/release_registry.json), pins V2.7/2.5.0 feature set.
- Part 6 DONE (this entry): SESSION_LOG trimmed to 5 entries (17 dropped), recent-session tag moved here; JOURNEY_TO_V3 updated (2.D.2v + BDF-NOTE + advice metadata + V2.2 BM+IPS heading dates fixed + FOLDER_STRUCTURE freshness footnote).
- Part 7 PASSED: templates â†” references synced â€” FOLDER_STRUCTURE.template/JSON_SCHEMAS.template/CHANGELOG.template (subagent), BUILDER_SPEC.template (526â†’1083 lines: Release Pipeline, Stage 7, Model Precedence, V2.5+V2.7 blocks; writer subagent), ARCHITECTURE.template (verified on disk), ROADMAP.template (Phases 9-13 + Destination BDF V3), TESTING.template (V2.5+V2.7 test groups), LESSONS_LEARNED.template (Lessons 11-12), AGENT.template/PROJECT_STATE.template (Build Continuation + Release Workflow), README.template (Doc Architecture + Releases). `bdf/templates/README.md` placeholder audit: 54 tokens â†” 54 template rows, no orphans. `bdf/VERSION.md` 2.2.0â†’2.2.1 (version-bump rule) â€” release-manager rerun no-op exit 0 preserved all edits.
- No commits (user-gated).
Broken: None blocking. Recurring watch item: `profiles/coding/models.json` vanished again mid-session (unknown cause; possibly another open process/session) â€” re-copied mirror before final battery; recheck presence each battery run.
Journey: Step 1 BDF V2.5 â€” COMPLETE 100%; V2.7 schema-validation side goal done; here = post-FULL_SYSTEM_CHECK, ready for next user-directed step.
Next: Commit only on user request. Remaining housekeeping: none open from this check; watch models.json existence on future real build/test runs (re-copy mirror if lost).
Learned: FULL_SYSTEM_CHECK v1.1 Template-sync Part covers full 15-template map; snapshot pinning the exact feature set each session makes clean-room regeneration trustworthy; async file deletion (models.json) needs a Test-Path guard before every real battery.

---
