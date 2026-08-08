# Session Log

> History of completed sessions in this documentation repository.

> Read AGENT.md for the full project context.

> Read _agent/SESSION_WORKFLOW.md for the session rules.

---

## Session History
### Aug 8, 2026 (session 32) - Real-provider story COMPLETE: builder parity (dual-key merge normalization), harness fixes, docs overhaul, committed ← recent session
Done:
- USER ACCEPTANCE PASSED: Kilo chat with TokenRouter works (no 401) - the options.apiKey fix proven live.
- Fixed the SECOND agent issue: OpenCode /models hid tokenrouter because a user-created opencode.jsonc (with disabled_providers:["tokenrouter"]) SHADOWED the built opencode.json (OpenCode reads .jsonc INSTEAD of .json when both exist). Backed up + removed the jsonc; /models now shows tokenrouter + omniroute. User rule documented: never create opencode.jsonc next to opencode.json.
- USER SCOPED + APPROVED the feature design (brainstorming): real providers (TokenRouter, Modal, OpenAI, Google Gemini, OpenRouter, NVIDIA NIM) added via the app, used THROUGH the agents; proxy switching untouched. Real-provider presets with SDK auto-fill shipped in the Add-provider form (gui.html PRESETS {url,npm}, onchange fills URL+SDK+name; backend config.py PRESETS synced).
- BDF BUILDER PARITY (the 'no ups and downs' ask): builders now normalize the dual key at MERGE time - if a provider file carries only apiKey, the builder mirrors options.apiKey automatically (K1 + V2.7 builders + wizard copies; scaffold-agent.ps1 bootstraps from K1 so future agents inherit it). PS 5.1 quirk caught by the harness: Add-Member required for a missing options property on parsed JSON (Set-ObjectProperty/ordered-dict-in-Add-Member pattern).
- HARNESSES: kilo 31/31 (was failing 19/30 - 10 tests used the REMOVED global profiles/<profile>/models.json fixture; fixtures updated to per-provider <id>-models.json + new dedicated 'Dual-key options mirror' test 31st), opencode 31/31. Stale exact-name test-kilo.ps1 (OpenCode V2.7 harness copy) replaced with the real K1 harness (backed up) - same trap as the old build-kilo.ps1.
- REAL CONFIG VERIFIED: kilo rebuild via /api/build now dual-keys omniroute too (was the only single-key provider - would have 401'd in Kilo as well); tokenrouter intact; 17 models merged. Hash-verified: only intended files changed.
- DOCS OVERHAUL (every MD updated): root README (dual-key data model + real-provider presets + user rules + builder parity + test counts 34/31/31 + doc version 2.5), app README (Rules: what NOT to do - no hand-edits, jsonc warning, 'we will generate both opencode.json and opencode.jsonc in the future, not right now'), PROVIDER_DEVELOPMENT_GUIDE v1.1 (dual-key contract + jsonc warning + 401 troubleshooting row) + template mirror, DEVELOPER_GUIDE (dual-key in Adding a provider), CHANGELOG 2.5.1, PROJECT_STATE (status + next), FOLDER_STRUCTURE (34 tests + presets), ROADMAP Phase 14 extended.
- COMMITTED: session 31+32 work (app fix + presets + builder parity + docs + harness updates). Repo visibility checked and reported.
Broken:
- None - clean session. Notes: modal not yet added to any agent config (user may add via the app when ready - Modal preset + endpoint + wk-...ws-... key are documented); opencode.jsonc generation for the future.
Journey: Step 3 IN PROGRESS ~93%; Phase 14 COMPLETE (extended with real-provider presets + builder parity); Phase 15 PLANNED.
Next: user adds more real providers via the app (e.g. Modal/OpenAI/OpenRouter) when wanted; future app update to generate both opencode.json + opencode.jsonc; then BUILDER_PHASES gates + Step 4/5.
Learned: True agent-agnostic compatibility = satisfying EVERY agent's config contract in one write (dual key) AND making the builder normalize legacy single-key files at merge - then the app, hand-written configs, and builder-only users all converge on identical output; also: a shadowing sibling config file (.jsonc vs .json) silently wins in some agents - the docs must warn users.

### Aug 8, 2026 (session 31) - Real-provider fix IMPLEMENTED: dual key placement + real-provider presets - acceptance pending user's Kilo chat test
Done:
- IMPLEMENTED the root-cause fix from AI/CONTINUE_REAL_PROVIDERS.md: app/agentstore.py write_provider now writes the key to BOTH provider.<id>.apiKey (OpenCode reads) AND provider.<id>.options.apiKey (Kilo reads), preserving any extra options keys. 3 new unit tests (dual placement, options preserved, sync on update) - suite 34/34 green.
- Applied the fix to the real config: re-created providers/tokenrouter.json through the app's own write_provider (key read from the app's own backup, never echoed - No-Secrets), restored tokenrouter-models.json (kimi-k3-free, 4 thinking levels) from backup, activeProviders=[omniroute, tokenrouter]. Hash-verified kilo snapshot first; after rebuild only the 4 intended files changed (kilo.json, kilo.provenance.json, settings.json, + 2 restored provider/model files) - kilo.jsonc/omniroute/scripts byte-identical.
- Rebuilt kilo via POST /api/build (real K1 builder, 2 providers / 17 models merged); verified built kilo.json tokenrouter entry now carries options.apiKey + top-level apiKey, models merged. App server restarted to load the fixed agentstore code; /api/status + GUI verified.
- USER SCOPED THE FEATURE (brainstorm): real providers (TokenRouter, Modal, OpenAI, Google Gemini, OpenRouter, NVIDIA NIM) added via the app and used THROUGH THE AGENTS (Kilo/OpenCode) - no in-app chat panel. Added real-provider presets to the Add-provider form: gui.html PRESETS now {url, npm} with SDK auto-fill on preset pick (+ name auto-fill, openAdd resets preset to Custom); backend config.py PRESETS synced; app README updated (preset table, Modal endpoint+key notes, real-providers paragraph, 401/restart troubleshooting row, stale privacy line fixed).
- MODAL RESEARCH (web-verified, user-requested): Modal = OpenAI-compatible endpoint; the API key is a combined proxy token wk-<id>.ws-<secret> (exactly the format already in the user's auth.json); shared base https://inference.us-west.modal.direct/v1, dedicated endpoints have per-account URLs (user's own: lovebh505-com--ep-kimi-k3-server.us-west.modal.direct/v1). NO modal API calls made and NO kilo config changes beyond tokenrouter (per user's 'don't do it' on the modal endpoint test).
- Verification: JS syntax checked via node --check (1 block OK); unit tests 34/34; served GUI confirmed to carry the new presets.
Broken:
- ACCEPTANCE TEST PENDING (user action): restart Kilo and chat with TokenRouter (kimi-k3) - the 401 fix is in the built kilo.json but unproven in Kilo's runtime. auth.json fallback (research step 6 of the MD) NOT started - not needed unless the chat still 401s.
- Uncommitted: app/agentstore.py + tests + config.py + gui.html + README changes (repo rule: commits only on request).
Journey: Step 3 IN PROGRESS ~92%; Phase 14 COMPLETE (+ real-provider presets); Phase 15 PLANNED.
Next: user tests Kilo chat with TokenRouter (restart Kilo first - it caches the old config); if still 401, research ~/.local/share/kilo/auth.json + kilo auth login and design auth.json integration; commit on request.
Learned: Writing the key in BOTH top-level apiKey and options.apiKey costs one duplicated field and makes the same provider file work in OpenCode AND Kilo - agent compatibility is about each agent's config contract, and the app can satisfy several contracts at once.

### Aug 8, 2026 (session 30) - Real-provider root cause found: Kilo reads options.apiKey, app wrote top-level apiKey - plan written, not yet implemented
Done:
- RESEARCH COMPLETED (web-verified): TokenRouter auth = Authorization: Bearer (the app's proxy already works - HTTP 200 chat with kimi-k3).
- KEY FINDING - KiloCode stores provider API keys in provider.<id>.options.apiKey (config) or ~/.local/share/kilo/auth.json (data dir, via /connect or kilo auth login) - NOT top-level provider.<id>.apiKey. OpenCode reads top-level apiKey (works); Kilo reads options.apiKey (finds nothing -> sends no token -> TokenRouter 401 'Token not provided').
- Also fixed during the session: build-kilo.ps1 was a stale OpenCode builder copy (app picked it by exact name) - finder now prefers the HIGHEST versioned builder (semantic sort, v2.7 > v2.5 > v1); stale build-kilo.ps1 replaced with the real K1 builder (backed up). OpenCode picked build-opencode-v2.5.ps1 before the semantic fix - verified both agents now build with their real builders. Provenance sidecar question answered (kilo.provenance.json exists, K1 stamps it).
- Plan written: AI/CONTINUE_REAL_PROVIDERS.md - dual key placement fix (apiKey + options.apiKey), rebuild, verify, auth.json fallback research, acceptance test = user chats in Kilo with TokenRouter.
Broken:
- The 401 itself is NOT yet fixed - implementation is the next session's job. Untested: whether options.apiKey alone satisfies Kilo or auth.json is also needed.
Journey: Step 3 IN PROGRESS ~90%; Phase 14 COMPLETE; Phase 15 PLANNED.
Next: implement AI/CONTINUE_REAL_PROVIDERS.md - dual key placement, rebuild kilo, verify, acceptance test in Kilo chat.
Learned: Same provider config works in OpenCode but not Kilo because the two agents read the key from DIFFERENT fields - agent compatibility means knowing each agent's config contract, not just writing one shape.

### Aug 8, 2026 (session 29) - AI Switcher app COMPLETE: BDF made autonomous - backend, env, theme, BDF-exact data model, kilo live
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

---
