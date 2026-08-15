# Edit Provider on Provider Cards — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an "Edit provider" button to every provider card on the Providers & agents page that opens the existing pre-filled edit wizard, and remove the buried edit button from the Details dialog.

**Architecture:** Frontend-only change in the AI Switcher app (`app/`). The card actions row in `provider-workspace.js` gains a button wired to `data-provider-action="edit"`; `providers.js` `handleAction()` routes that action to the existing `openProviderDialog(provider, trigger)` wizard. The Details dialog in `providers.js` loses its "Edit provider" button and becomes read-only. Backend `PUT /api/providers/{id}` already supports updates (blank API key keeps the existing key) — no backend changes.

**Tech Stack:** Vanilla JS (ES modules), static HTML templates, node:test contract tests, Python FastAPI backend (untouched), Windows PowerShell runtime.

## Global Constraints

- Do NOT change the UI/UX design — reuse existing classes (`button button--quiet button--small`), markup patterns, and the existing wizard exactly.
- Provider ID is never exposed or editable in the edit flow (it is the file name + `settings.json` reference).
- The edit wizard (Choose → Configure → Models → Test → Save) stays byte-for-byte identical.
- Models stay editable inside the wizard (unchanged behavior); do not touch `settings.js`/`settings-model-editor.js`.
- Claude Code (scalar-route) page (`claude-routes.js`) is out of scope.
- Spec: `superpowers/specs/2026-08-15-edit-provider-on-cards-design.md`

---

### Task 1: Add "Edit provider" button to provider cards and remove it from Details dialog

**Files:**
- Modify: `app/assets/js/pages/provider-workspace.js` — `card()` actions row (~line 73-78)
- Modify: `app/assets/js/pages/providers.js` — `handleAction()` (~line 110) and `details()` (~line 68-70)
- Test: `app/tests/providers_visual_contract.test.mjs`

**Interfaces:**
- Consumes: `openProviderDialog(provider, trigger)` (already exported from `providers.js:78`; pre-fills the wizard, title "Edit {name}", submits via `api.updateProvider(provider.id, value)`).
- Consumes: `onAction(provider, action, trigger)` wiring in `provider-workspace.js:256` — any `[data-provider-action]` button on a card dispatches to `handleAction`.
- Produces: `data-provider-action="edit"` buttons on all provider cards; no new exports.

- [ ] **Step 1: Write the failing tests**

Append these tests to `app/tests/providers_visual_contract.test.mjs` (after the last test, before file end):

```js
test("provider cards expose an edit entry point", () => {
  assert.match(workspaceSource, /data-provider-action="edit">Edit provider/);
});

test("edit action opens the pre-filled edit wizard", () => {
  assert.match(providersSource, /action === "edit"/);
  assert.match(providersSource, /openProviderDialog\(provider, trigger\)/);
});

test("details dialog is read-only without an edit button", () => {
  assert.doesNotMatch(providersSource, /data-edit-provider/);
  assert.match(providersSource, /data-dialog-close>Close<\/button>/);
});
```

- [ ] **Step 2: Run the tests to verify they fail**

Run (from the repo root): `node --test app\tests\providers_visual_contract.test.mjs`
Expected: FAIL — `data-provider-action="edit"` not found in source; `data-edit-provider` still present.

- [ ] **Step 3: Add the card button**

In `app/assets/js/pages/provider-workspace.js`, inside `card()`'s `<div class="provider-deck-card__actions">`, insert the edit button between "Test connection" and "Remove provider":

```js
      <button class="button button--quiet button--small" type="button" data-provider-action="details">Details</button>
      <button class="button button--quiet button--small" type="button" data-provider-action="test">Test connection</button>
      <button class="button button--quiet button--small" type="button" data-provider-action="edit">Edit provider</button>
      <button class="button button--danger button--small" type="button" data-provider-action="remove">Remove provider</button>
```

(Exact string to insert: `<button class="button button--quiet button--small" type="button" data-provider-action="edit">Edit provider</button>`)

- [ ] **Step 4: Wire the edit action**

In `app/assets/js/pages/providers.js`, `handleAction()`, add as the first branch:

```js
async function handleAction(workspace, provider, action, trigger) {
  if (action === "edit") { openProviderDialog(provider, trigger); return; }
  if (action === "details") { details(provider, trigger); return; }
```

- [ ] **Step 5: Make the Details dialog read-only**

In `app/assets/js/pages/providers.js`, `details()`, replace the current `actions:` + `onOpen` with Close-only:

```js
function details(provider, trigger) {
  openDialog({ title: provider.name, trigger, content: `<dl class="stack">…</dl>`, actions: `<button class="button button--quiet" type="button" data-dialog-close>Close</button>` });
}
```

Keep the `content` template exactly as-is; only delete the trailing `, actions: <…data-edit-provider…>…onOpen(dialog) {…}` and replace with the Close-only actions. Result: no `data-edit-provider`, no `onOpen` callback in the file.

- [ ] **Step 6: Run the tests to verify they pass**

Run: `node --test app\tests\providers_visual_contract.test.mjs`
Expected: PASS, all tests green.

- [ ] **Step 7: Commit**

```bash
git add app/assets/js/pages/provider-workspace.js app/assets/js/pages/providers.js app/tests/providers_visual_contract.test.mjs
git commit -m "feat: add Edit provider button to provider cards"
```

---

### Task 2: Run full regression suites

**Files:** none (verification only)

- [ ] **Step 1: Run all frontend contract tests**

Run (from `app/` directory): `node --test ".\tests\*.test.mjs"`
Expected: all pass except the established unrelated baseline failure (onboarding-copy), if it still exists. Report the pass count.

- [ ] **Step 2: Run all Python tests**

Run (from `app/` directory): `& .\env\Scripts\python.exe -m unittest discover -s tests`
Expected: all pass.

- [ ] **Step 3: Verify no leftover references**

Run: `grep -rn "data-edit-provider" app/assets app/tests`
Expected: no matches in `app/assets/js` (only the test's `doesNotMatch` string, which lives in the test file itself and is fine).

---

### Task 3: End-to-end verification in a temp environment + cleanup

**Files:** none (runtime verification; temp files only)

**Purpose:** Prove the button appears on every provider card and editing actually persists — without touching the user's real `state.json`, real `C:\Users\loveb\.config\opencode`, or `C:\Users\loveb\.config\kilo` configs.

- [ ] **Step 1: Back up the app's live state**

Copy `app/state.json` and `app/preferences.json` to the temp dir:
`C:\Users\loveb\AppData\Local\Temp\opencode\edit-provider-test\backup\`
(They will be restored in Step 9.)

- [ ] **Step 2: Create a temp agent config with 3 providers**

Create `C:\Users\loveb\AppData\Local\Temp\opencode\edit-provider-test\agent\providers\` and write 3 BDF provider files (mirror the real format from agentstore.py):

`omniroute-test.json`:
```json
{
  "id": "omniroute-test",
  "provider": {
    "omniroute-test": {
      "name": "OmniRoute Test",
      "baseUrl": "http://localhost:20128/v1",
      "apiKey": "test-key-111",
      "npm": "@ai-sdk/openai-compatible",
      "reasoningFormat": "opencode"
    }
  }
}
```

`openrouter-test.json`:
```json
{
  "id": "openrouter-test",
  "provider": {
    "openrouter-test": {
      "name": "OpenRouter Test",
      "baseUrl": "https://openrouter.ai/api/v1",
      "apiKey": "test-key-222",
      "npm": "@openrouter/ai-sdk-provider",
      "reasoningFormat": "opencode"
    }
  }
}
```

`cli-proxy-test.json`:
```json
{
  "id": "cli-proxy-test",
  "provider": {
    "cli-proxy-test": {
      "name": "CLI Proxy Test",
      "baseUrl": "http://localhost:PORT/v1",
      "apiKey": "",
      "npm": "@ai-sdk/openai-compatible",
      "reasoningFormat": "openai"
    }
  }
}
```

Also create `settings.json` in the temp agent dir:
```json
{
  "activeProviders": ["omniroute-test"]
}
```

- [ ] **Step 3: Point the app at the temp agent (server on port 9099)**

Start the server from `app/` (PowerShell, background job or separate terminal):
```
& .\env\Scripts\python.exe -m uvicorn server:app --host 127.0.0.1 --port 9099
```
Then register the temp agent and switch to it:
```
Invoke-RestMethod -Uri http://127.0.0.1:9099/api/agents -Method Post -ContentType application/json -Body '{"name":"edit-provider-test","dir":"C:\\Users\\loveb\\AppData\\Local\\Temp\\opencode\\edit-provider-test\\agent"}'
```
Verify: `Invoke-RestMethod -Uri http://127.0.0.1:9099/api/providers` returns 3 providers.

- [ ] **Step 4: Open the app and check every card has the Edit button**

Open `http://127.0.0.1:9099` in the browser (Playwright MCP). Navigate to the Providers page. For each of the 3 provider cards (front, middle, back deck positions — use the deck arrows to bring each to front), verify:
- The card shows an **Edit provider** button (next to Test connection).
- Clicking **Details** opens a dialog with Close only — **no** Edit provider button inside.

- [ ] **Step 5: Edit a provider end-to-end (OmniRoute Test)**

On the OmniRoute card, click **Edit provider**. In the wizard:
- Change the **Base URL** to `http://localhost:20128/v2`
- Change the **SDK package** to `@ai-sdk/openai`
- Change the **Reasoning format** to `OpenAI`
- Leave the **API key** empty (must keep existing key)
- Save.

Then verify via API: `Invoke-RestMethod -Uri http://127.0.0.1:9099/api/providers`
Expected for `omniroute-test`: `baseUrl == "http://localhost:20128/v2"`, `npm == "@ai-sdk/openai"`, `reasoningFormat == "openai"`, `hasKey == true` (key preserved).

Also re-read the file `C:\Users\loveb\AppData\Local\Temp\opencode\edit-provider-test\agent\providers\omniroute-test.json` and confirm `baseUrl`/`npm`/`reasoningFormat` persisted with the key intact.

- [ ] **Step 6: Replace the API key (OpenRouter Test)**

On the OpenRouter card, click **Edit provider**, type a new key `test-key-333` in the API key field, save. Verify via API: `hasKey == true` and the file now contains `test-key-333`.

- [ ] **Step 7: Edit the provider with no key (CLI Proxy Test)**

On the CLI Proxy card, click **Edit provider**, leave API key empty, change the reasoning format to `OpenCode`, save. Verify: `reasoningFormat == "opencode"`, `hasKey == false`.

- [ ] **Step 8: Verify the deck/refresh state**

After saving, confirm the cards re-render with updated data (base URL shown on the card) and the app stays on the Providers page without errors (no console errors).

- [ ] **Step 9: Clean up — revert test data only**

Stop the uvicorn process. Delete the temp agent dir and temp workspace:
```
Remove-Item -Recurse -Force "C:\Users\loveb\AppData\Local\Temp\opencode\edit-provider-test"
```
Restore live state from backup (copy back `app/state.json`, `app/preferences.json`). Confirm the app's real agent (`opencode`) and its providers are untouched: `Get-Content app/state.json` shows `activeAgent: opencode`, and `C:\Users\loveb\.config\opencode\providers` has no test files.

**The code changes from Task 1/2 are NOT reverted.**

---

## Self-Review Notes

- Spec coverage: card button (Task 1 Step 3), edit wiring (Task 1 Step 4), Details cleanup (Task 1 Step 5), tests (Task 1 Steps 1-2, 6), full suites (Task 2), temp E2E + data-only cleanup (Task 3). All spec items covered.
- No placeholders — every step has exact strings/paths.
- Type/name consistency: `data-provider-action="edit"` used identically in card markup and the dispatcher; `openProviderDialog(provider, trigger)` matches the existing export signature.
