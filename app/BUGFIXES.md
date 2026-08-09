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

### 2026-08-09 — `max` reasoning level rejected by OpenAI GPT-5.x providers

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
