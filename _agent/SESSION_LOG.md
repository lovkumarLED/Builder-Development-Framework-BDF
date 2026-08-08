# Session Log

> History of completed sessions in this documentation repository.

> Read AGENT.md for the full project context.

> Read _agent/SESSION_WORKFLOW.md for the session rules.

---

## Session History

### Aug 8, 2026 (session 29) - GUI App BUILT: AI Switcher (docs/app/) - backend done, end-to-end green ← recent session
Done:
- Built docs/app/ as a MODULAR FastAPI backend (server.py entry + app/ package: config, storage, discovery, providers, engine, testing, proxy, serve) implementing the FULL API contract from AI/BDF_GUI_APP_FRONTEND_SPEC.md: GET / (serves gui.html - built by Qwen 3.8 Max in parallel), GET /api/status, POST /api/discover + /api/scan, GET/POST /api/providers + PUT/DELETE /api/providers/<id> (apiKey NEVER returned - hasKey only), POST /api/test, POST /api/switch, POST /api/scaffold (calls the REAL scaffold-agent.ps1 -Agent <agent> -NonInteractive -Bootstrap engine - one engine, two surfaces), POST /api/build (runs build-<agent>.ps1 -Profile coding -NonInteractive), POST /v1/* local OpenAI-compatible proxy on 127.0.0.1:9090 to the ACTIVE provider (SSE streaming passthrough verified).
- Rules enforced: No-Secrets (keys only in the user's providers.json, never in GET responses, never in code), backup-first (providers.backup.json before every write), local-first 127.0.0.1 only.
- start.bat (double-click: python server.py + auto-open browser) + plain-language README.md (no dev jargon).
- Smoke-tested end-to-end on the REAL opencode agent: discover (opencode/kilo/claudecode/codex-cli found) -> scan (9 mcp, 1 plugin, 4 profiles) -> providers CRUD + test (OmniRoute live: green ~2s) + switch + delete -> scaffold ran the real engine (profiles user-owned, untouched; generated build-/test-/scaffold-opencode.ps1 adapted from v2.7; legacy build-opencode.ps1 + scaffold-opencode.ps1 backed up to backup/*.pre-gui-app first) -> build PASS (18 models, 9 mcp, provenance stamped) -> bootstrapped test-opencode.ps1 harness 31/31 -> /v1 proxy: /models (2582 models forwarded), chat completions replied "PONG", SSE chunks verified; auto/best-coding slowness traced to OmniRoute itself (direct curl identical), NOT the proxy.
- GUI checked against the contract statically (every fetch matches the contract exactly; no literal keys). Live browser walkthrough deferred: the parallel Qwen 3.8 Max window holds the shared Playwright browser.
- Docs synced (README Sync Rule): FOLDER_STRUCTURE.md (+docs/app tree + bullet), PROJECT_STATE.md (tree + scripts section + status), README.md (13/14 phases, AI Switcher row, badge, docs map), ROADMAP.md (Phase 14 COMPLETE + summary table + Out-of-Scope GUI removed), SESSION_LOG + JOURNEY updated.
Broken:
- None blocking. Notes: /api/chat (v1.1) intentionally not implemented (contract-optional); gui.html visual walkthrough pending browser availability.
Journey: Step 3 Universal Agent Framework core IN PROGRESS ~90%; Phase 14 GUI App COMPLETE.
Next: visual walkthrough of the wizard in a live browser once the Playwright browser frees up; then the launch ceremony (AFTER the app is user-approved).
Learned: Calling the real scaffold-agent.ps1 -Bootstrap engine from the app guarantees "performs exactly like BDF" - the same engine drives the GUI and the framework.

### Aug 8, 2026 (session 28f) - BDF GUI App plan finalized (UI spec + autonomous engine) - handoff ready
Done:
- User clarified the CORE PRINCIPLE: the app performs EXACTLY like BDF but AUTONOMOUSLY - a normal user never needs an AI agent. The app itself scans the main JSON, seeds profiles, GENERATES the .ps1 builder scripts (via the real scaffold-agent.ps1 -Bootstrap engine), and runs the build.
- Two-worlds model locked: World 1 = developers edit docs/bdf/*.md + ask AI; World 2 = normal users use the GUI app. Same engine, two surfaces.
- UI requirement captured: SIMPLE + CLEAN + COOL ANIMATIONS. Full UI/UX SPEC added to the plan (dark theme, accent color, provider cards, status dots, fade-up load, glowing active card, pulsing dots, button lift, wizard transitions, toasts, spinners, prefers-reduced-motion).
- User decision: build the full feature set first with a tasteful default look; colors/animations come later per their direction.
- App location confirmed: docs/app/ (user's explicit choice; research noted the mainstream apps/ convention + future extraction path).
- Plan MD finalized: AI/CONTINUE_BDF_GUI_APP.md (426 lines, 11 sections, resume prompt included).
Broken: None.
Journey: unchanged (Step 3 ~90%); GUI app = Phase 14 idea, V3 still not released.
Next: NEXT SESSION - build the app per AI/CONTINUE_BDF_GUI_APP.md (fresh context, full plan + UI spec + prompt ready).
Learned: This session hit its useful limit - the MD plan is the correct handoff for a big build; the app deserves fresh context.

### Aug 8, 2026 (session 28d) - Phase 8 Documentation Expansion complete: 4 guides + 4 templates
Done:
- Phase 8 (ROADMAP) COMPLETED - "Documentation Expansion" for onboarding:
  - DEVELOPER_GUIDE.md - working on the project: read order, workflow, source-of-truth rules, verification, common tasks.
  - PROVIDER_DEVELOPMENT_GUIDE.md - user-owned provider definitions + models, precedence, No-Secrets {env:VAR} policy, troubleshooting.
  - PROFILE_CREATION_GUIDE.md - the 3 default profiles, file contract, creating new profiles, P2 target.json.
  - BUILDER_EXTENSION_GUIDE.md - builder pipeline, adding features/tests/CLI flags/merge stages, extension boundaries, verification checklist.
  - All four mirrored as framework templates (bdf/templates/): template count 15 to 19.
- Registered everywhere: FOLDER_STRUCTURE.md, PROJECT_STATE.md, README.md (docs map + roadmap 13/13 + badge + framework 2.2.8), bdf/PROJECT_GENERATOR.md (Stage 4 + 5), bdf/templates/README.md (list + matrix, 19 templates).
- ROADMAP Phase 8 - + summary table 13/13 (only Phase 13 V3 release steps remain); template ROADMAP.template.md Phase 8 -.
- Framework bumped 2.2.7 to 2.2.8 (template change rule); placeholder audit 64/64, 0 orphans.
- README status corrected (12/13, V3 in progress - not released) + README Synchronization Rule added (AGENT.md + CONTRIBUTING Rule 11 + template; framework 2.2.9).
Broken: None blocking.
Journey: Phase 13 (BDF V3) is now the ONLY remaining phase - all 13 roadmap phases otherwise complete.
Next: Build the GUI app per AI/CONTINUE_BDF_GUI_APP.md.
Learned: Onboarding guides belong in the project docs AND as mirrored templates.

### Aug 8, 2026 (session 28c) - No-Secrets Rule (ULTIMATE) + kilo build fix + ROADMAP phase markers
Done:
- USER RULING clarified: the system CAN copy-paste API keys (scan - copy - paste is its job), the user protects their own files - but the SYSTEM's own artifacts (scripts, templates, docs, examples) NEVER contain a literal key, only {env:VAR} placeholders.
- Restored all user-owned files to their original state (they had been wrongly purged): kilo.json, kilo.jsonc, all kilo mcp.json files, kilo/providers/omniroute.json (literal key back), opencode.json + all opencode mcp.json files.
- Verified: system artifacts (all scripts + templates + docs) contain ZERO literal keys; user files keep theirs. Both builds re-run green; generated kilo.json/opencode.json carry the user's keys verbatim.
- KILO BUILD FIX: restored kilo/profiles/coding/omniroute-models.json (18 models from the last successful build backup). Real build now green: backup - 18 models merged - all stages PASS - kilo.json regenerated - provenance stamped - idempotent rerun. User's exact command build-kilo-v1.ps1 coding -DryRun -Verbose verified exit 0.
- ROADMAP phase markers: Phase 4 + 10.5 + 11 marked; summary table; template synced; framework 2.2.5 - 2.2.6.
Broken: None blocking. Real kilo build green with user's restored provider + models.
Journey: Step 3 universal core (~90%) - contract locked, no-secrets rule locked, kilo real build green.
Next: Only the kilo builder test remains per the handoff (already green); commit docs on request.
Learned: Two-world rule - user files may hold literal keys, system artifacts never do, system copies user content verbatim.

### Aug 8, 2026 (session 28b) - V3 scaffold contract finalized (user ruling) + kilo backup-first test
Done:
- USER RULING implemented: the framework creates the providers/ folder (like the profile folders) but NEVER writes provider or model JSON files inside it - the JSON files are 100% user-owned. ONE job: scan the agent's OWN main JSON (kilo.json for kilo - never another agent's config), split mcp/plugin sections, seed the profiles.
- scripts/scaffold-agent.ps1 rewritten: scans only the agent's primary main JSON; seeds coding/mcp.json + plugins.json once (user-owned after); EMPTY mcp/plugins for experimental/minimal; settings.json =  + activeProviders only; providers/ folder created but files never written; discovery/-List/-Bootstrap/error self-fix preserved.
- Kilo backup-first test: main kilo.json + kilo.jsonc + profiles backed up to %TEMP%\opencode\kilo-backup-20260808-071644; test-kilo-v1.ps1 - 30/30 exit 0; main kilo.json byte-identical after.
Broken: None blocking.
Journey: Step 3 universal core (~90%), scaffold contract locked.
Next: kilo builder test + commit docs on request.
Learned: The scaffold's value is scanning the agent's own main JSON and seeding the 3-profile structure without ever inventing content.

---