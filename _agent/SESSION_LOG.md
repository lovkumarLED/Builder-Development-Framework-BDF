# Session Log

> History of completed sessions in this documentation repository.

> Read AGENT.md for the full project context.

> Read _agent/SESSION_WORKFLOW.md for the session rules.

---

## Session History

### Aug 8, 2026 (session 29) - AI Switcher app COMPLETE: BDF made autonomous - backend, env, theme, BDF-exact data model, kilo live ← recent session
Done:
- Built docs/app/ as a MODULAR FastAPI backend (server.py + app/ package: config, storage, discovery, providers, agentstore, engine, testing, plugins, proxy, serve, rules) implementing the FULL API contract from AI/BDF_GUI_APP_FRONTEND_SPEC.md: GET / (serves gui.html), GET /api/status, POST /api/discover + /api/scan, GET/POST /api/providers + PUT/DELETE /api/providers/<id> (apiKey NEVER returned - hasKey only), POST /api/test, POST /api/switch, POST /api/scaffold (calls the REAL scaffold-agent.ps1 -Agent <agent> -NonInteractive -Bootstrap engine - one engine, two surfaces), POST /api/build (runs the agent's real builder), POST /v1/* local OpenAI-compatible proxy on 127.0.0.1:9090 to the active provider (SSE streaming verified).
- Frontend gui.html delivered by Qwen 3.8 Max; later redesigned by this session: real logo image (assets/logo.jpg + favicon), fiery navy theme from logo pixels, local Anime.js (lib/ - no CDN), ember particle background, block-by-block staggered UI, flame-glow active card, always-visible scrollbars (page + popups).
- Self-contained Python environment: env/ venv auto-created by start.bat on first run (requirements.txt + SHA256 hash marker - reinstall only when requirements change); second launch ~2s. start.bat: python check -> venv -> pip -> server; friendly errors.
- rule.md dual-purpose: YAML front-matter = live theme (serve-time <style> injection, GET /api/rules, defaults on invalid/missing, BOM-tolerant parser in app/rules.py) + markdown rulebook for AI agents. Em-dash mojibake corruption caught in review and fixed (byte-level regression check added).
- BDF-EXACT DATA MODEL (user-directed): the app reads/writes the AGENT's own config - providers/<id>.json, profiles/coding/<provider>-models.json, profiles/coding/plugins.json, settings.json activeProviders - all backup-first into the agent's backup/. App-local providers.json retired and deleted. activeProviders is a LIST: the builder merges ALL listed providers; "Switch to this" moves one to the front (primary for the proxy). New providers auto-activate.
- Models feature: add model names with thinking levels (default/minimal/high/max) in the provider screen; the app writes the exact variants/reasoningEffort shape the builder expects. No hand-editing JSON.
- Plugins feature: Plugins card on the dashboard - add/remove plugin ids, writes profiles/coding/plugins.json, dedupe, backup-first.
- SDK type selector: 15 verified npm packages (@ai-sdk/openai-compatible default, openai, anthropic, google, mistral, xai, deepseek, groq, perplexity, togetherai, cerebras, azure, amazon-bedrock, cohere, @openrouter/ai-sdk-provider) + "Other" free-text; each verified against the npm registry.
- Kilo builder discovery: app finds build-<agent>*.ps1 (build-kilo-v1.ps1) so ready agents show as built. Removed the global models.json lookup from build-kilo-v1.ps1 per user (only <provider>-models.json counts; providers without models are skipped by the model guard); backup kept at kilo/backup/build-kilo-v1.ps1.pre-global-models-removal.
- KILO LIVE: app switched to kilo (state.json); kilo.json builds green with omniroute (18 models) + tokenrouter (1 model, Kimi-K3 with all 4 thinking levels) - 2 providers / 19 models merged; settings activeProviders=[omniroute, tokenrouter].
- TokenRouter 401 diagnosed: key verified working (chat HTTP 200 via proxy with Bearer); kilo.json has the entry with key; the 401 request predates the provider-merge fix - kilo's runtime held stale config. Fix = restart kilo.
- Commits (repo rule: commits only on request; done): 459d407 docs (sessions 28b-28f batch: guides, no-secrets, roadmap markers) + b3a0bdb feat(app) (full app + env/theme + superpowers plan/spec + all synced docs).
- Docs synced: FOLDER_STRUCTURE (+app tree/bullet), PROJECT_STATE (tree, scripts, status), README (13/14 phases, AI Switcher row, badge, docs map), ROADMAP (Phase 14 COMPLETE + summary + Out-of-Scope GUI removed), SESSION_LOG, JOURNEY; app README (plain language, env, models, plugins, SDK types, data table).
- Testing: 28/28 unittest green (rules/serve/agentstore incl. agents registry, models, plugins, MCP roundtrips); every feature live-verified on real configs with throwaway providers and full restore (hashes checked); JS syntax checked via node --check.
- Session 29 (extended, user-directed): MULTI-AGENT management - Agents card registers ANY agent's config folder (name + path), switches the managed agent instantly, and already-set-up folders load directly (ready detection via builder script - no wizard forced for existing agents; wizard only for genuinely new ones). The active hero now shows EVERY active provider side-by-side (🔥 Active cards + note below). Added MCP servers card, Models card, SDK type selector (15 npm packages verified on the registry), flame ASCII-art startup banner with Local/Network lines. Full E2E click-through battery on the real kilo config (every button: test, edit, delete+re-add tokenrouter with real key, duplicate rejection, models save, plugins add/remove, MCP add with invalid-JSON error path, build, advanced, proxy, switch) with snapshot backup + hash-verified restore (32/32 files byte-identical). 2 real GUI bugs found by the click-through and fixed: Providers.PRESETS not exported (preset dropdown dead) and plugins add/remove sent a raw string body (422).
Broken:
- None blocking. Notes: /api/chat (v1.1) intentionally not implemented (contract-optional); TokenRouter 401 needs kilo restart to confirm; more coding agents (beyond opencode/kilo) NOT tested yet - expected to work with the universal scaffold, to be verified in the future.
Journey: Step 3 Universal Agent Framework core IN PROGRESS ~90%; Phase 14 GUI App COMPLETE; Phase 15 (More Coding Agents) PLANNED - untested.
Next: verify kilo API after restart; extend the app/framework to more coding agents when directed.
Learned: activeProviders is a LIST - the builder merges EVERY provider in it (each with its own models file); only listed providers merge, and providers without any models are dropped by the model guard. The GUI app + MD framework are the same engine with two surfaces - the app just calls scaffold-agent.ps1 and the generated builders.

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