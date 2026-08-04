# Session Log

> History of completed sessions in this documentation repository.

> Read AGENT.md for the full project context.

> Read _agent/SESSION_WORKFLOW.md for the session rules.

---

## Session History

### Aug 4, 2026 (session 8) — Built the Release Manager V1 (registry, marker pipeline, 17-test harness, docs) ← recent session
Done:
- Built `scripts/release-manager.ps1` (outside git): registry → generator → CHANGELOG/CURRENT_RELEASE/PROJECT_STATE/VERSION.md artifacts; all-or-nothing writes; duplicate-key raw-text scan (PS 5.1 ConvertFrom-Json collapses duplicates); marker policy (abort if AUTO-GENERATED markers missing); Verify-Generated before any write; final run exit 0 "All outputs already up to date - nothing written."
- Created `docs/release_registry.json` (single 2.2.0 entry, 13 fields; the only hand-edited release artifact).
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

### Aug 3, 2026 (session 6) — Re-verified the system + validated PROJECT_STATE against the framework
Done:
- Rebuilt the verification harness (145 assertions): builder behavior, failure modes, PROJECT_STATE vs actual system, framework conformance.
- Harness iteration 1 found 0 system bugs but 4 harness bugs (plugin counted as object map instead of array-of-1, expression parens, version-table regex, example-doc threshold) — all fixed in the harness; final run 145 passed, 0 failed.
- Regression: default build exit 0; valid JSON; provider omniroute; 58 models (source round-trip); 9 MCP servers; 1 plugin; $schema preserved; deterministic output (hash-identical); reproducible after delete; backup created and equals the prior config.
- Failure modes all abort cleanly before writing output with clear errors: missing profile, missing/string/empty activeProviders, missing provider file, provider id mismatch, missing id, missing provider section, invalid JSON; minimal profile builds with warnings (provider only), then default restored.
- Verified PROJECT_STATE.md against the actual system and UPGRADE_BLUEPRINT_FRAMEWORK.md: folder structure, 4 profiles, providers/scripts/schemas, docs tree, bdf/ contents, 15 templates, versions 2.1.0 + framework 2.0.0, version-history tables equal to CHANGELOG, read order identical to AGENT.md, roadmap phases, adapter 9 fields, templates version-independent (0 opencode refs), four framework questions present, framework generic (PROJECT_ADAPTER.md mentions are examples only).
- No system or doc bugs found; docs repo left untouched (git status unchanged); final state: default config regenerated, no test fixtures left, temp harness removed.

Broken:
- None — clean session.

Next: Commit the docs repository (session 4 + 5 changes); user review of verification results.

Learned: PowerShell `$HOME` is read-only and not overridable via env vars — isolate builder tests with temp fixtures inside the real structure plus restore, not a fake $HOME; count-based facts can change type (plugin array of 1) — assert source-to-generated round-trip equality instead of type assumptions.

### Aug 3, 2026 (session 5) — Verified the system + fixed doc/consistency bugs
Done:
- Regression-tested Builder V2: build-opencode-v2.ps1 -Profile default exit 0; opencode.json valid JSON (provider omniroute, 58 models, 9 mcp servers, 1 plugin); backup created; minimal profile tested (exit 0, expected warnings) then default restored.
- Built a 4-section verification harness (builder behavior, generated config, PROJECT_STATE vs actual, doc consistency); first run 115 passed/9 failed (2 harness bugs + 7 real bugs); fixed all → final run 124 passed, 0 failed; harness removed.
- Fixed real bugs: CHANGELOG.md statuses 2.0.3/2.0.2 Current→Previous; PROJECT_STATE.md §6 all 4 profiles, schemas/ in folder structure + table, §11 multiple profiles, §13 roadmap cleanup; FOLDER_STRUCTURE.md schemas/ (structure, section, ownership, rules); ADAPTER.md schemas/ + additional-profiles note; ROADMAP.md Phase 3 "Multiple Profiles" Planned→Completed ✅.
- Verified actual model count is 58 (source round-trips generated); session 4 log claim of 57 left untouched (history is read-only).
- Final rebuild confirmed exit 0; nothing committed (user instruction).

Broken:
- None — clean session.

Next: Commit the docs repository (session 4 + 5 changes: CHANGELOG, PROJECT_STATE, FOLDER_STRUCTURE, ADAPTER, ROADMAP, SESSION_LOG; blueprint/ deleted; ADAPTER.md + bdf/ untracked); user review of verification results.

Learned: Count-based facts in session logs can drift (57 vs 58 models) — verify numbers against source files, not history; dynamic source-vs-generated assertions beat hardcoded counts.

### Aug 3, 2026 (session 4) — Upgraded Blueprint Framework to Builder Development Framework
Done:
- Renamed blueprint/ → bdf/; upgraded the framework to the Builder Development Framework (BDF), framework version 2.0.0 (breaking: rename), project version 2.1.0.
- Created component docs: BLUEPRINT_ENGINE.md (9-stage change pipeline), PROJECT_ADAPTER.md (9 adapter fields + 6 example apps), BUILDER_EVOLUTION.md, FRAMEWORK_LIFECYCLE.md, AI_WORKFLOW.md (master workflow + Workflow A/B), templates/ADAPTER.template.md; created ADAPTER.md (OpenCode adapter, first implementation).
- Updated FRAMEWORK.md, README.md, VERSION.md, MIGRATION.md (Stage 8 — Define the Project Adapter), PROJECT_GENERATOR.md (Stage 3), LESSONS_LEARNED.md (lessons 11-12), templates README + PROJECT_STATE.template.
- Updated project docs to 2.1.0: README.md, AGENT.md, FOLDER_STRUCTURE.md, CONTRIBUTING_FOR_AI.md, ROADMAP.md, CHANGELOG.md, PROJECT_STATE.md (regenerated).
- Built a 16-section verification harness (1087 assertions): first run 5 failures — history records misasserted as stale branding, live example naming, literal placeholder example, placeholder-scan gap; fixed docs + made harness history-aware (e.g. "Blueprint Framework only in 2.0.1 history row") → final run 1083 passed, 0 failed, exit 0; harness removed.
- Ran Builder V2 regression test: build-opencode-v2.ps1 -Profile default exit 0; opencode.json valid JSON (provider omniroute, 57 models, 9 mcp servers); backup created.

Broken:
- None — clean session.

Next: Commit the docs repository (8 modified, blueprint/ deleted, ADAPTER.md + bdf/ untracked); user review of the BDF.

Learned: History records in living docs should be asserted as "allowed exactly once", not "absent"; a framework rename is complete only when docs, templates, harness, and history-aware assertions agree.

### Aug 3, 2026 (session 3) — Built the project state system
Done:
- Created PROJECT_STATE.md (15-section living snapshot, version 2.0.3) and blueprint/templates/PROJECT_STATE.template.md.
- Added the regeneration system: Project State rules in AGENT.md (major-refactor definition + regeneration rule) and a session-end checkpoint in _agent/SESSION_WORKFLOW.md.
- Updated README.md, FOLDER_STRUCTURE.md, ROADMAP.md, CHANGELOG.md (2.0.3), blueprint/VERSION.md (1.1.0), blueprint/templates/README.md (new placeholders).
- Built a 46-assertion consistency harness; found and fixed 5 real bugs (undocumented placeholders, two malformed table rows, one template placeholder row, one changelog omission); final run 46/46 passed, exit 0; harness removed.

Broken:
- None — clean session.

Next: Commit the docs repository (5 modified + PROJECT_STATE.md + AI/ + _agent/ + blueprint/ untracked).

Learned: Table-shape and changelog-completeness checks catch bugs content assertions miss; adversarial review beyond the harness still matters.

