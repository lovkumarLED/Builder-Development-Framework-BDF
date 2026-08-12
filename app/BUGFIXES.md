# Bug Fix Log

Every bug or issue fixed in this app gets an entry here — written in the SAME
change that fixes it. If you fixed a bug, you log it here. No exceptions.

## Entry template

Copy this block into Entries when a fix lands:

```markdown
### YYYY-MM-DD — Short summary of the bug

- **Symptom:** What the user saw.
- **Root cause:** Why it happened (the actual reason, not the symptom).
- **Fix:** What was changed and where (file:line or module).
- **Verified:** How the fix was proven to work.
```

## Entries

### 2026-08-10 — Overview page showed invented demo data instead of real config/activity

- **Symptom:** The dashboard's Overview displayed hardcoded OpenAI/OpenRouter/Gemini providers ("1,284 API calls", "98.9% success", a fake May-2025 recent-calls list) regardless of the actual config — violating the design rule that the UI never invents production data.
- **Root cause:** `app/assets/js/pages/overview.js` was written around `DEMO_PROVIDERS`, `DEMO_KPIS`, `DEMO_USAGE`, `DEMO_CALLS` and a hardcoded chart; it never called the activity API.
- **Fix:** Rewrote `renderOverview` to consume real data: providers from `/api/providers` (relay deck ordered by active provider, real model/endpoint/SDK/key state), KPIs from `/api/activity/summary` (requests, success rate, median latency, failures), requests-over-time chart and provider-usage donut grouped from `/api/activity`, and the recent-calls table from real events. Honest empty states ("No proxy traffic yet", "No providers configured yet") replace invented numbers when there is no data. Added donut palette classes for arbitrary provider ids.
- **Verified:** Browser walkthrough on the real kilo config — relay front = active provider (real model + endpoint), KPIs 3 calls / 100% / 20ms / 0 failures, real recent rows; no console errors.

### 2026-08-10 — Sidebar theme and help buttons did nothing

- **Symptom:** The sidebar's "Toggle color theme" and "Help and support" buttons were inert.
- **Root cause:** No event handlers were ever bound to `.sidebar-tool` buttons.
- **Fix:** `main.js` bindShell wires them: theme toggles `data-theme="dark"` on `<html>` (new dark palette in `tokens.css` for workspace tokens), persists the choice in localStorage; help opens `/docs` in a new tab.
- **Verified:** Clicking the theme button flips the workspace to dark (`rgb(14,20,27)` background) and back; help opens the docs tab.

### 2026-08-10 — Welcome page had a scrollbar (fixed-width mobile layout overflow)

- **Symptom:** The Welcome page showed vertical (and at narrow widths horizontal) scrollbars; the startup grid overflowed the window.
- **Root cause:** The mobile layout (`responsive.css` ≤899px) switched `.startup-grid` to static/full-width but never overrode the base `width: 1586px; height: 992px`, so the frame rendered 1586×992 in any narrow window; at ≥900px the scale-to-fit formula otherwise keeps the frame exactly viewport-sized.
- **Fix:** Added `width: 100%; height: auto` to the mobile `.startup-grid` rule (prevents horizontal overflow); the frame then follows the fluid grid. The design's mobile stacked layout itself remains (restored after an earlier experiment), so narrow windows keep the intended responsive behavior.
- **Verified:** No horizontal overflow at any tested size; vertical scroll only where the mobile stacked layout is intentionally taller than the window.

### 2026-08-10 — Browser served stale cached JS/CSS; refreshes showed old versions

- **Symptom:** After code changes, a plain refresh kept showing the previous version of the page (e.g. the old auto-jump-to-dashboard boot), making fixes look broken.
- **Root cause:** The FastAPI server sent no `Cache-Control` headers for the GUI HTML or `/assets`, so browsers heuristically cached them indefinitely.
- **Fix:** `server.py` mounts `/lib` and `/assets` through a `NoCacheStaticFiles` subclass that appends `Cache-Control: no-cache`; `serve.py` sets the same header on the `/` HTML response. Static files now revalidate on every refresh.
- **Verified:** Response headers show `Cache-Control: no-cache` for `/`, JS, and CSS; plain F5 picks up edits.

### 2026-08-10 — settings.json UTF-8 BOM broke active-provider detection

- **Symptom:** `/api/providers` reported every provider `active: false` and `activeProvider: null` even though the config listed them.
- **Root cause:** A PowerShell `Set-Content -Encoding UTF8` restore wrote a UTF-8 BOM (`EF BB BF`) into `profiles/coding/settings.json`; `json.loads` rejects the BOM, so `get_active_providers` read an empty dict.
- **Fix:** Rewrote the file with a BOM-less UTF-8 writer (`.NET UTF8Encoding($false)`); the API immediately reported the real active providers.
- **Verified:** `/api/providers` shows `active: true` for both providers and the correct `activeProvider`; bytes start with `7B` (`{`).

### 2026-08-10 — App crashed at boot: "Invalid left-hand side in assignment"

- **Symptom:** The wizard preview didn't render and the console showed a SyntaxError; only the static Welcome markup appeared.
- **Root cause:** `main.js` used optional chaining on an assignment target (`document.querySelector(...)?.textContent = value`), which is invalid JS and failed module parsing.
- **Fix:** Guarded the element lookup with a variable + `if` before assigning.
- **Verified:** `node --check` passes; full wizard → dashboard flow renders with no console errors.

### 2026-08-10 — Provider relay showed mismatched brand marks and had no browsing animation

- **Symptom:** The relay (and recent calls) displayed the OpenAI/OpenRouter/Gemini brand marks for arbitrary providers (e.g. OmniRoute, tokenrouter), and the deck couldn't be browsed.
- **Root cause:** `brandMark()` mapped every unknown provider name to one of three hardcoded brand SVGs; the relay was static.
- **Fix:** Known providers (OmniRoute, LiteLLM, CLI Proxy, TokenRouter, OpenRouter) now use downloaded official logos (`assets/brands/`); anything else (custom providers) gets a deterministic generated logo — a gradient tile with the provider's initials from an 8-color palette. The relay is scrollable (mouse wheel and arrow keys): the deck cycles through providers with a depth animation (front card scales forward/fades out, the next card scales up from behind; backward reverses it), with a reduced-motion fast path.
- **Verified:** Relay cycles OmniRoute ↔ tokenrouter both directions; wizard provider cards show litellm.png / cli-proxy.svg; custom keeps its ＋ mark; no console errors.

- **Symptom:** Selecting an agent always produced the same fake scan counts (3/6/2/1), agent cards showed invented paths (`C:\Users\you\...`), and the wizard offered providers regardless of what was actually configured. Clicking "Set up your workspace" on the Welcome page did nothing.
- **Root cause:** The wizard's preview mode hardcoded sample agents, scan results, and presets and gated every real API call behind `previewOnly`; the Welcome page was only reachable through `?preview=welcome`, where the button is intentionally inert.
- **Fix:** `app/assets/js/pages/onboarding.js` now always drives the real API — live `/api/discover` (OpenCode/Kilo only), real `/api/scan` on agent selection (with a summary line on the agent step), real `/api/scaffold` when the agent isn't split, real `/api/test` and `/api/providers`. Fake data removed; `main.js` shows the Welcome page on every boot.
- **Verified:** Browser walkthrough — OpenCode scan = 3 providers/9 MCP/1 plugin, Kilo = 2 providers/7 MCP/0 plugins (matches the real folders); both agents detected with real paths; provider test/save hit the live API.

### 2026-08-10 — Review screen always showed 0 (or fake) providers

- **Symptom:** "Review your workspace" never reflected the providers in the config — the Providers card showed a hardcoded 1 or 0 for every agent.
- **Root cause:** `POST /api/scan` never returned provider data; it read MCP/plugins/profiles from the main JSON and profiles folder but ignored `providers/`. The wizard had no way to count or name real providers.
- **Fix:** `app/app/discovery.py` scan now returns `providers` (stems of `providers/*.json`), `activeProviders` (from `profiles/coding/settings.json`), and `split` (whether the agent has the framework structure). Review and provider steps consume them.
- **Verified:** Review shows Providers 3 for OpenCode and 2 for Kilo, matching the on-disk `providers/` folders; chips show active/not-active from the agent's own settings.

### 2026-08-10 — Wizard offered providers the user already has (e.g. CLI Proxy with cli-proxy-api present)

- **Symptom:** OpenCode already had `cli-proxy-api` active, but the wizard still showed a CLI Proxy card asking for URL + key again.
- **Root cause:** The provider cards were rendered from a static preset list with no awareness of the scanned config.
- **Fix:** `providerScreenMarkup()` filters preset cards against the scanned `providers` (name-containment match, case-insensitive); existing providers render as status chips (name + active/not-active) instead. Custom is always available.
- **Verified:** OpenCode shows only LiteLLM + Custom cards (CLI Proxy hidden); Kilo (omniroute + tokenrouter only) still shows LiteLLM + CLI Proxy + Custom.

### 2026-08-10 — Custom provider couldn't set provider ID, display name, or structured models

- **Symptom:** The Custom form only had Base URL + SDK + key + a free-text models input; the owner's expected fields (Provider ID `myprovider`, Display name `My AI Provider`, models as ID + Name rows) were missing, and the created provider file was named from a slug of the display name.
- **Root cause:** The form was minimal and `POST /api/providers` derived the provider id via `slugify(name)` with no way to pass an explicit id.
- **Fix:** Custom now shows Provider ID (validated `^[a-z0-9_-]+$`), Display name, Base URL, SDK, reasoning format, API key, and a models section with add/remove rows of (model ID, display name). `app/app/providers.py` accepts an optional `id` on create (validated, else 400).
- **Verified:** Invalid id ("My Provider!") rejected with a clear toast; valid `myprovider` saved as `providers/myprovider.json` with the typed id; model rows saved as `{model, name}` pairs (test provider deleted and settings restored afterwards).

### 2026-08-10 — Wizard layout: scrollbars on every step, toast/field overlapping the footer

- **Symptom:** Every onboarding step showed a vertical scrollbar; the manual-folder field crossed the footer separator line; the "Connection successful." message overlapped the Back button.
- **Root cause:** The 790px design window was too narrow for wide screens and the content was taller than the fixed 503px window; the status message was positioned at the content's bottom-left, inside the footer zone; scroll-container padding created a phantom scrollbar.
- **Fix:** Window design widened to 1130px (scale formula in `main.js` updated); all steps compacted (card heights 54→50/44px, form rows to 38px, tightened headings) so nothing scrolls; the message became a toast (slides in from the right, auto-dismisses after 3.5s, anchored to the stage) and the manual folder moved into a proper dialog.
- **Verified:** All four steps measure `scrollHeight - clientHeight = 0` for every provider state; toast appears top-right and auto-hides; manual dialog validates the folder against the backend.

### 2026-08-10 — App auto-jumped to the dashboard instead of showing the Welcome page

- **Symptom:** Launching the app with an already-set-up agent skipped the Welcome screen and went straight to the dashboard.
- **Root cause:** `main.js` boot() called `showWorkspace()` whenever `status.ready` was true.
- **Fix:** Boot always shows the Welcome page; status is fetched only for context. Navigation to the dashboard happens exclusively through the wizard ("Open dashboard").
- **Verified:** Fresh load lands on `http://127.0.0.1:9090/` showing "Welcome to Switcher" with the app shell hidden; no auto-navigation to `?view=overview`.

### 2026-08-10 — Agent selection allowed multiple choices and Continue with none

- **Symptom:** A detected agent and the manual folder could look selected at once; Continue was enabled with no selection.
- **Root cause:** Cards toggled independently and `chosenAgent` defaulted to the first mock agent.
- **Fix:** Selection is one-or-none (clicking a card clears the manual state and vice versa); no default selection; Continue is disabled until a card or a validated manual folder is chosen.
- **Verified:** Clicking OpenCode leaves only it pressed (Continue enabled); opening the manual dialog clears card presses; cancel restores the previous selection; Continue stays disabled until a choice exists.

- **Symptom:** Using a GPT-5.x model (e.g. gpt-5.6-luna via CLI Proxy) with the
  `max` variant failed: `level "max" not supported, valid levels: low, medium,
  high, xhigh`.
- **Root cause:** The app hardcoded one level set (`default/minimal/high/max`)
  and one variant shape (`{"reasoningEffort": "<level>"}`) for every provider.
  GPT-5.x only accepts `none/low/medium/high/xhigh` (ChatGPT app: Light /
  Medium / High / Extra High); `max` exists only on gpt-5.6 via the Responses
  API. Claude and Gemini don't speak `reasoningEffort` at all — Claude uses a
  thinking token budget, Gemini a thinking budget.
- **Fix:** Per-provider reasoning formats. `agentstore.py` now owns a
  `REASONING_FORMATS` registry (opencode / openai / claude / gemini / none)
  with each format's valid levels and variant JSON templates. Provider files
  carry an optional `reasoningFormat`; `write_models` writes variants from the
  format's templates (openai → `reasoningEffort`, claude →
  `thinking.budgetTokens` 8000/16000/32000, gemini →
  `thinkingConfig.thinkingBudget` 4096/8192/16384/32768) and drops levels
  invalid for the format; `read_models` filters shown levels to the format.
  `providers.py` exposes `GET /api/formats`, accepts `reasoningFormat` on
  create/update (unknown id → 400), and threads it through model reads/writes.
  `gui.html` gained a "Reasoning format" dropdown in the provider modal and the
  Models card; presets pre-pick it (CLI Proxy/OpenAI → openai, Google →
  gemini). Framework: `models.schema.json` documents the accepted variant
  settings keys (still permissive); `test-opencode-v2.7.ps1` gained a test
  proving OpenAI/Claude/Gemini variant shapes pass schema validation and merge.
- **Verified:** 56/56 app unit tests (8 new: format templates, level dropping,
  filtering, round-trip); 32/32 builder harness tests; browser UI test in a
  temp agent — CLI Proxy preset auto-picked `openai`, saving gpt-5.6-luna with
  low/medium/high/xhigh wrote exactly the reference config; switching the
  Models card format to `claude` rewrote variants to `thinking.budgetTokens`.

### 2026-08-09 — Models dropdown doesn't show newly added providers

- **Symptom:** A provider added through "Add a provider" never appeared in the
  Models section's Provider dropdown (which shows per-provider model counts and
  lets you manage them) until the browser was fully reloaded. Same for deleted
  providers — they stayed in the dropdown.
- **Root cause:** The Models dropdown is populated by `Models.load()`, which
  was only called at page boot and when switching agents. `Providers.save()`
  and `Providers.del()` re-rendered the provider grid after a write, but never
  refreshed the Models dropdown, so it kept showing the provider list from page
  load.
- **Fix:** `app/gui.html` — added `Models.load()` right after `await load()` in
  `Providers.save()` (covers add + edit) and in `Providers.del()` (covers
  delete), so the dropdown re-fetches the provider list after every
  add/edit/delete. All other mutation paths (switch agent, add/remove agent,
  boot) already refreshed the dropdown.
- **Verified:** Browser test against the running app — added a temporary
  provider via the modal and it appeared in the Models dropdown instantly with
  no reload; deleted it and it vanished instantly. The live API
  (`/api/providers`) was used to confirm on-disk state matched the UI.

### 2026-08-09 — Bootstrapped builder harnesses fail 2 tests (hardcoded spec paths)

- **Symptom:** `scaffold-agent.ps1 -Bootstrap` produced a working builder but
  its test harness failed 2 tests ("Builder spec covers V2.5/V2.7"):
  `BUILDER_SPEC.md not found at C:\Users\loveb\C:\Users\loveb\...` (doubled
  path prefix).
- **Root cause:** Test 12 and Test 28 in `test-opencode-v2.7.ps1` and
  `test-kilo-v1.ps1` hardcoded `C:\Users\loveb\.config\...\docs\BUILDER_SPEC*.md`.
  The scaffold's string replacement of `.config\kilo` → `$ConfigRoot` mangled
  that absolute path into a doubled prefix, and a fresh project has no docs
  folder at all — the token-coverage tests could never pass for scaffolded
  agents (framework tests passed only on the author's machine).
- **Fix:** Both harnesses now resolve the spec path relative to
  `$PSScriptRoot` (`..\docs\BUILDER_SPEC*.md`) and SKIP the token coverage
  check with a notice when the project doc is absent (it is project-owned and
  optional). Real harnesses still assert when the doc exists.
- **Verified:** Re-bootstrapped a sandbox agent — harness now passes; real
  kilo (31/31) and opencode (33/33) harnesses still green.

### 2026-08-09 — Dead `config.PRESETS` duplicate removed

- **Symptom:** `app/app/config.py` carried a `PRESETS` dict that nothing
  imported — the live preset list (URL + SDK + reasoning format) lives in
  `gui.html` and had already drifted from it (missing reasoning formats).
- **Root cause:** Leftover from an earlier design; a "keep in sync" comment
  with no enforcement.
- **Fix:** Removed `PRESETS` from `config.py` (gui.html is the single source
  of truth).
- **Verified:** 56/56 app unit tests green; no imports reference it.

### 2026-08-09 — App depended on scripts outside the repo (not self-contained)

- **Symptom:** A fresh download of the repo could not generate builders. The
  wizard's "Generate my builder" failed with "The engine script
  (scaffold-agent.ps1) was not found" unless the machine happened to have a
  copy in `~/.config/opencode/scripts/`.
- **Root cause:** `config.py` defaulted `SCRIPT_DIR` to the user's own config
  folder (`CONFIG_ROOT/scripts`), outside the repo. The scaffold's builder
  templates also resolved to a machine-specific path
  (`..\kilo\scripts\build-kilo-v1.ps1`). The app worked on the author's PC and
  nowhere else — a public-repo blocker.
- **Fix:** The app is now self-contained. `app/engine/` bundles the full BDF
  engine: `scaffold-agent.ps1` (generator), `build-opencode-v2.7.ps1` +
  `test-opencode-v2.7.ps1`, `kilo/build-kilo-v1.ps1` + `test-kilo-v1.ps1`
  (K1 adapter), and `schemas/` (7 schemas). `config.py` defaults to the
  bundled engine (`BDF_SCRIPTS_DIR` remains an escape hatch). The bundled
  scaffold resolves the builder source per agent (opencode → V2.7 builder,
  kilo → K1 adapter) instead of a hardcoded path, and `engine.py` seeds the
  agent's `schemas/` folder from the bundle on scaffold.
- **Verified:** Fresh temp agents end-to-end — opencode agent: wizard
  generated profiles (3) + providers/ + schemas/ (8 files) +
  build/test/scaffold-opencode.ps1, build → `opencode.json` (BUILD COMPLETE,
  schema validation on). kilo agent: build/test/scaffold-kilo.ps1 (K1
  adapter with reasoning formats), build → `kilo.json` + provenance; generated
  kilo tester harness passes. Real configs untouched (state restored).

### 2026-08-09 — PowerShell: new properties on parsed JSON throw in PS 5.1

- **Symptom:** `$obj.newProp = value` on a PSCustomObject from
  `ConvertFrom-Json` threw `The property 'newProp' cannot be found on this
  object` (also plain `[pscustomobject]` literals).
- **Root cause:** This environment's PowerShell 5.1 refuses member-assignment
  for NEW properties; only existing properties are settable that way.
- **Fix:** Use `Add-Member -NotePropertyName ... -NotePropertyValue ... -Force`
  when persisting `reasoningFormat` into provider files
  (`Set-ProviderReasoningFormat` in both builders + the merged provider
  entry).
- **Verified:** Interactive builder prompt test — provider file gains
  `reasoningFormat` with backup; harnesses green.

### 2026-08-12 - Provider endpoint (base URL) missing on the Overview relay card

- **Symptom:** In the Overview page's "Your provider relay" block, the OmniRoute card showed no endpoint (and on opencode the TokenRouter card showed a double-slash URL like `https://api.tokenrouter.com//v1`). Kilo was affected; opencode was not - which made the bug look agent-specific.
- **Root cause (two parts):**
  1. The real providers/omniroute.json had been emptied during earlier session testing (empty `baseURL` and `apiKey`), so the API returned a blank endpoint.
  2. Editing the provider file with PowerShell `Set-Content -Encoding UTF8` wrote a UTF-8 BOM (`EF BB BF`) at the start of the file. The app's JSON readers used `encoding="utf-8"`, which rejects a BOM - so the whole file failed to parse and `baseUrl` came back empty. Any provider file touched by a BOM-writing editor would silently lose its endpoint.
- **Fix:**
  1. Restored providers/omniroute.json from the backup (real endpoint http://localhost:20128/v1 + key), and fixed opencode's TokenRouter double slash to https://api.tokenrouter.com/v1.
  2. Hardened every JSON read in the app to be BOM-tolerant: pp/app/agentstore.py `_read_json`, pp/app/discovery.py (main-config scan), and pp/app/storage.py `_read` now use `encoding="utf-8-sig"`, which transparently strips a BOM. Writes remain BOM-less UTF-8.
- **Verified:** All 5 provider files across both agents parse with correct `baseURL` (BOM-free); the Overview relay card on kilo shows both endpoints (https://api.tokenrouter.com/v1 and http://localhost:20128/v1); opencode's TokenRouter shows the single-slash URL; 79 unit tests pass (1 pre-existing unrelated gui.html cache-param failure).

### 2026-08-12 - Returning users got "Checking everything works" + auto-revert errors on every open

- **Symptom:** Opening the Kilo app (already set up) showed "Checking everything works…" and a "Setup was rolled back automatically… fix them" error after pressing "Use this workspace". The app seemed broken for any returning user; OpenCode appeared to work.
- **Root cause:** useWorkspace ran the post-setup verification (/api/setup/verify) and auto-revert **unconditionally** on every connect - including when the agent already had a builder. Returning users have real providers with real keys; the verify's connection tests (and the import-time empty baseURL/key cases) made it fail and the auto-revert wrongly fired, rolling back kilo.json and blocking entry.
- **Fix:** useWorkspace now only runs verify + auto-revert + the setup guide when reshSetup is true (i.e. !scanResult?.hasBuilder - the scaffold actually ran). Already-set-up agents connect directly to the provider step with no checks, no revert, no guide.
- **Verified:** Browser walkthrough as a returning user on real kilo: goes straight to "Add your first provider" - no "Checking everything", no errors. The first-time setup path (verify + revert + guide) is unchanged and still triggers only when a builder is actually generated.

### 2026-08-12 - "LiteLLM is active" shown on the ready screen when nothing was configured

- **Symptom:** After onboarding, the ready screen claimed "LiteLLM is active" even though the user never added a provider (or used a workspace with existing providers).
- **Root cause:** The ready screen rendered providerPresets[selectedProvider].name with selectedProvider defaulting to "litellm" (the first preset), and skippedProvider was false when the ready screen was reached via the verify-success path - so the line "LiteLLM active" appeared by default.
- **Fix:** The ready screen now only claims a provider is active when one was actually added in this onboarding session (selectedKind === "provider-added", set in saveFirstProvider). Otherwise it shows "Your providers stay as configured - manage them from the dashboard".
- **Verified:** Skipping the provider step shows the neutral line, no fake "LiteLLM active"; adding a provider shows the real name.
