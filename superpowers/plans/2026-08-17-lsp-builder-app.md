# LSP Support in BDF Builders + Switcher App — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add LSP support (a `profiles/coding/lsp.json` file + interactive toggle in the builders + an LSP block with on/off toggle on the app's Integrations page) for **both OpenCode and KiloCode**, so the generated main JSON includes `lsp` when enabled and omits it when disabled.

**Architecture:** The BDF engine's modular profile pipeline (scaffold splits main config → `profiles/coding/*.json`; builders merge sources → main JSON) gains one more source: `lsp.json` with shape `{ "lsp": <bool|object>, "enabled": <bool> }`. Both builders (`build-opencode-v2.7.ps1`, `build-kilo-v1.ps1`) get identical changes: read/merge/persist/verify LSP, plus an interactive 1/2 prompt when not `-NonInteractive`. The app gets `agentstore` LSP functions, an `/api/lsp` router, and an LSP card (toggle + value display + expert JSON) between Plugins and MCP on the Integrations page.

**Tech Stack:** PowerShell 5.1 (builders + harnesses), Python 3.14/FastAPI (app backend), vanilla JS modules (app frontend), node:test (frontend contracts), unittest (app Python).

## Global Constraints

- **Claude Code is COMPLETELY untouched** — no scaffold, builder, schema, app block, or test change for Claude. Gate 2/Gate 3 suites must stay 65/65 + OVERALL PASS.
- `lsp.json` shape is exactly `{ "lsp": <value>, "enabled": <bool> }` (owner-approved toggle-safe form; `lsp` value never lost when toggling off).
- `lsp` accepts `true` (built-ins), `false` (explicit off), or an object keyed by server name (OpenCode schema: `command` string[], optional `extensions`/`disabled`/`env`/`initialization`). Kilo passes the value through unchanged.
- Behavior contract: `enabled=true` → generated JSON contains `lsp`; `enabled=false` or no `lsp.json` → generated JSON has NO `lsp` key.
- The app drives builds with `-NonInteractive` (engine.py) — the builder prompt must be skipped then and use the stored `enabled`.
- No commits, staging, or pushes without the owner's explicit approval (repository rule). Commit steps below are replaced by `git diff --check` + working-tree verification.
- Backups before every write (backup-first, same as mcp/plugins/settings writers). Never overwrite a user-owned `lsp.json` (V3 rule 6, Seed-IfMissing semantics).
- Schema file name: `app/engine/schemas/lsp.schema.json` (Draft-07).

---

### Task 1: `lsp.schema.json` + scaffold split/seed (`scaffold-agent.ps1`)

**Files:**
- Create: `app/engine/schemas/lsp.schema.json`
- Modify: `app/engine/scaffold-agent.ps1` (scan loop ~line 224-246; seed section ~line 316-340)
- Test: `app/engine/scaffold-agent.ps1` dry run in a temp dir (manual), plus harness Task 2/3 indirectly

**Interfaces:**
- Produces: profile file `profiles/coding/lsp.json` with `{ "lsp": <value>, "enabled": true }` (value from main config's `lsp`, or `true` when absent); experimental/minimal get `{ "lsp": true, "enabled": true }` defaults. `$MergedLsp` variable holds the scanned value.

- [ ] **Step 1: Create the schema**

Create `app/engine/schemas/lsp.schema.json`:

```json
{
  "$schema": "https://json-schema.org/draft-07/schema#",
  "title": "LSP Configuration",
  "description": "Modular LSP source for the generated agent config. 'enabled' controls whether the builder emits the top-level 'lsp' key; 'lsp' is the value emitted (boolean or object keyed by server name).",
  "type": "object",
  "properties": {
    "lsp": {
      "type": ["boolean", "object"],
      "additionalProperties": {
        "type": "object",
        "properties": {
          "command": { "type": "array", "items": { "type": "string" } },
          "extensions": { "type": "array", "items": { "type": "string" } },
          "disabled": { "type": "boolean" },
          "env": { "type": "object" },
          "initialization": { "type": "object" }
        },
        "additionalProperties": true
      }
    },
    "enabled": { "type": "boolean" }
  },
  "required": ["lsp", "enabled"]
}
```

- [ ] **Step 2: Add LSP to the scaffold scan loop**

In `app/engine/scaffold-agent.ps1`, in the `foreach ($TF in $MainFiles)` scan loop (around line 224-246, after the `# plugin section` block), add:

```powershell
    # lsp section (boolean true/false or object keyed by server name)
    if ($Main.PSObject.Properties['lsp']) { $MergedLsp = $Main.lsp }
```

And declare `$MergedLsp = $true` next to the other merged declarations at the top of section 2 (around line 219-222):

```powershell
$MergedLsp      = $true
```

- [ ] **Step 3: Seed `lsp.json` in the profile creation loop**

In the `foreach ($Profile in $Profiles)` seed loop (around line 317-340), add after the `plugins.json` block in BOTH branches (coding AND experimental/minimal):

For the `coding` branch (inside the `if ($Profile -eq "coding")` block, after the plugins Seed-IfMissing):

```powershell
        $LspJson = @{ lsp = $MergedLsp; enabled = $false } | ConvertTo-Json -Depth 10
        Seed-IfMissing (Join-Path $Dir "lsp.json") "lsp.json" $LspJson
```

For the `else` branch (experimental/minimal, after the plugins seed):

```powershell
        Seed-IfMissing (Join-Path $Dir "lsp.json") "lsp.json" '{ "lsp": true, "enabled": false }'
```

> **Owner directive (session 46): LSP is DISABLED BY DEFAULT in every profile** — `enabled: false` in coding/experimental/minimal. The app's Integrations toggle turns it on; until then the builder emits no `lsp` key.

- [ ] **Step 4: Sanity-check the scaffold in a temp dir**

Run (temp root, no real config):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\app\engine\scaffold-agent.ps1 -Agent opencode -ConfigRoot <temp>\agent -NonInteractive -Bootstrap
```

Expected: `profiles/coding/lsp.json` created with `{ "lsp": true, "enabled": true }`; re-run leaves it untouched (Seed-IfMissing).

- [ ] **Step 5: Diff hygiene (no commit — owner rule)**

```powershell
git diff --check
```
Expected: exit 0, no whitespace errors.

---

### Task 2: OpenCode V2.7 builder LSP (merge + prompt + persist + verify) + harness tests

**Files:**
- Modify: `app/engine/build-opencode-v2.7.ps1` (Merge-Mcp ~line 1278, Merge-Final ~line 1292, main pipeline merge section ~line 2228-2251, verification ~line 1393-1408, pre-flight ~line 458-482)
- Modify: `app/engine/test-opencode-v2.7.ps1` (new LSP tests, register in Run-Test list ~line 1814)
- Test: `app/engine/test-opencode-v2.7.ps1`

**Interfaces:**
- Consumes: `profiles/coding/lsp.json` (`{ "lsp": <value>, "enabled": <bool> }`)
- Produces: `Merge-Lsp` → returns `$Lsp` value when enabled else `$null`; `Merge-Final` signature gains `[object]$Lsp`; final JSON key `lsp` emitted only when non-null. Prompt writes back `enabled` to `lsp.json` (backup-first).

- [ ] **Step 1: Add `Merge-Lsp` after `Merge-Mcp` (~line 1290)**

```powershell
function Merge-Lsp {

    param(
        [object]$Lsp
    )

    if ($Lsp -and $Lsp.enabled -and ($null -ne $Lsp.lsp)) {

        return $Lsp.lsp
    }

    return $null
}
```

- [ ] **Step 2: Extend `Merge-Final` (~line 1292-1309)**

```powershell
function Merge-Final {

    param(
        [object]$Settings,
        [object]$ProviderRoot,
        [object]$Plugins,
        [object]$MCP,
        [object]$Lsp
    )

    $Final = Merge-Settings $Settings

    $Final.provider = $ProviderRoot

    if ($Plugins) { $Final.plugin = $Plugins }
    if ($Lsp)     { $Final.lsp     = $Lsp }
    if ($MCP)     { $Final.mcp     = $MCP }

    return $Final
}
```

- [ ] **Step 3: Load + prompt + merge in the main pipeline**

In the main pipeline (around line 2228-2251, after `Write-Step "Merging plugins..."` and before `Merging mcp`), add an LSP step. Also load `lsp.json` into `$Lsp` near the other profile source loads (`$Plugins`/`$MCP` are loaded earlier, around line 2043-2084):

```powershell
$LspFile = Join-Path $ProfilePath "lsp.json"
$Lsp = $null
if (Test-Path $LspFile) {
    Assert-NoDuplicateKeys $LspFile "lsp"
    $Lsp = Load-Json $LspFile
}
if ($Lsp) {
    Write-Step "LSP..."
    if (-not $NonInteractive) {
        $Prompt = "LSP servers: [1] enabled  [2] disabled  (Enter keeps current)"
        $Answer = Read-Host $Prompt
        if ($Answer -eq "1") { $Lsp.enabled = $true }
        elseif ($Answer -eq "2") { $Lsp.enabled = $false }
        if ($Answer -eq "1" -or $Answer -eq "2") {
            $LspJson = @{ lsp = $Lsp.lsp; enabled = $Lsp.enabled } | ConvertTo-Json -Depth 10
            [System.IO.File]::WriteAllText($LspFile, $LspJson, (New-Object System.Text.UTF8Encoding($false)))
            Write-Success "lsp.json updated (enabled: $($Lsp.enabled))"
        }
    }
    Write-Success "lsp $((Merge-Lsp $Lsp))"
} else {
    Write-Detail "No lsp.json - lsp section will be skipped"
}
```

Then in the merge section replace:

```powershell
$Final = Merge-Final $Settings $ProviderRoot $PluginList $McpList
```

with:

```powershell
$LspList = Merge-Lsp $Lsp
$Final = Merge-Final $Settings $ProviderRoot $PluginList $McpList $LspList
```

- [ ] **Step 4: Verification + pre-flight + diff**

Verification (after the existing mcp verification ~line 1406-1408) add:

```powershell
    if ($Lsp -and $Lsp.enabled -and ($null -ne $Lsp.lsp) -and -not $Final.lsp) {
        throw "Verification failed: lsp section is missing from the generated configuration."
    }
```

Pre-flight dependency check (near `$McpFile` check ~line 458-482) add:

```powershell
        if (Test-Path $LspFile) { $RequiredSchemas += (Join-Path $SchemaDir "lsp.schema.json") }
```

Source list (near `$McpFile` source add ~line 481-482) add:

```powershell
    if (Test-Path $LspFile)     { [void]$Sources.Add(@{ File = $LspFile;     Schema = "lsp.schema.json";     Required = $false }) }
```

Diff summary (near the mcp/plugin diff ~line 1646-1669) add an LSP toggle line:

```powershell
    $CurrentLspEnabled = if ($Final.PSObject.Properties['lsp']) { $true } else { $false }
    $PriorLspEnabled   = if ($Prior.PSObject.Properties['lsp']) { $true } else { $false }
    if ($CurrentLspEnabled -ne $PriorLspEnabled) {
        [void]$Lines.Add("$(if ($CurrentLspEnabled) { "Added" } else { "Removed" }) LSP servers")
    }
```

Note: `$Lsp`, `$LspFile`, `$ProfilePath`, `$SchemaDir` must be in scope at each site — verify the pipeline's existing variable scope for `$Plugins`/`$MCP` and mirror it exactly.

- [ ] **Step 5: Harness — write 5 new LSP tests**

In `app/engine/test-opencode-v2.7.ps1`, add (mirroring existing test helpers like `New-Root`/`Invoke-Builder`; look at `Test-McpMerge` style for fixture setup — write `profiles/coding/lsp.json` before invoking the builder):

```powershell
function Test-LspEnabledTrue {
    $Root = New-Root
    Set-Content (Join-Path $Root "profiles\coding\lsp.json") '{ "lsp": true, "enabled": true }'
    $Run = Invoke-Builder $Root -NonInteractive
    Assert-True ($Run.ExitCode -eq 0) "builder failed"
    $Out = Get-Content (Join-Path $Root "opencode.json") -Raw | ConvertFrom-Json
    Assert-True ($Out.lsp -eq $true) "lsp true not emitted"
}

function Test-LspEnabledObject {
    $Root = New-Root
    Set-Content (Join-Path $Root "profiles\coding\lsp.json") '{ "lsp": { "typescript": { "command": ["typescript-language-server","--stdio"], "extensions": [".ts"] } }, "enabled": true }'
    $Run = Invoke-Builder $Root -NonInteractive
    Assert-True ($Run.ExitCode -eq 0) "builder failed"
    $Out = Get-Content (Join-Path $Root "opencode.json") -Raw | ConvertFrom-Json
    Assert-True ($Out.lsp.typescript.command -join " " -eq "typescript-language-server --stdio") "lsp object not round-tripped"
}

function Test-LspDisabled {
    $Root = New-Root
    Set-Content (Join-Path $Root "profiles\coding\lsp.json") '{ "lsp": true, "enabled": false }'
    $Run = Invoke-Builder $Root -NonInteractive
    Assert-True ($Run.ExitCode -eq 0) "builder failed"
    $Out = Get-Content (Join-Path $Root "opencode.json") -Raw | ConvertFrom-Json
    Assert-True ($null -eq $Out.PSObject.Properties['lsp']) "lsp emitted while disabled"
}

function Test-LspFileAbsent {
    $Root = New-Root
    $Run = Invoke-Builder $Root -NonInteractive
    Assert-True ($Run.ExitCode -eq 0) "builder failed"
    $Out = Get-Content (Join-Path $Root "opencode.json") -Raw | ConvertFrom-Json
    Assert-True ($null -eq $Out.PSObject.Properties['lsp']) "lsp emitted without lsp.json"
}

function Test-LspFalseValue {
    $Root = New-Root
    Set-Content (Join-Path $Root "profiles\coding\lsp.json") '{ "lsp": false, "enabled": true }'
    $Run = Invoke-Builder $Root -NonInteractive
    Assert-True ($Run.ExitCode -eq 0) "builder failed"
    $Out = Get-Content (Join-Path $Root "opencode.json") -Raw | ConvertFrom-Json
    Assert-True ($null -eq $Out.PSObject.Properties['lsp']) "explicit false value must not emit lsp"
}
```

Register in the Run-Test list (near line 1814):

```powershell
Run-Test "LSP enabled true"                   { Test-LspEnabledTrue }
Run-Test "LSP enabled object round-trip"      { Test-LspEnabledObject }
Run-Test "LSP disabled omits section"         { Test-LspDisabled }
Run-Test "No lsp.json omits section"          { Test-LspFileAbsent }
Run-Test "LSP false value omits section"      { Test-LspFalseValue }
```

- [ ] **Step 6: Run the harness**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\app\engine\test-opencode-v2.7.ps1
```
Expected: `Tests: 40/40 Passed` (35 + 5), exit 0.

- [ ] **Step 7: Diff hygiene (no commit)**

```powershell
git diff --check
```
Expected: exit 0.

---

### Task 3: Kilo K1 builder LSP (identical changes) + harness tests

**Files:**
- Modify: `app/engine/kilo/build-kilo-v1.ps1` (Merge-Mcp ~line 1229, Merge-Final ~line 1243, pipeline merge ~line 2185-2213, verification ~line 1229-1245, pre-flight ~line 504-505)
- Modify: `app/engine/kilo/test-kilo-v1.ps1` (new LSP tests, register in Run-Test list)
- Test: `app/engine/kilo/test-kilo-v1.ps1`

**Interfaces:**
- Consumes/Produces: same as Task 2 — identical `Merge-Lsp`, `Merge-Final` extension, prompt, verification, pre-flight, diff, and the five harness tests. Kilo's `Merge-Settings` already passes every non-`$schema`/`activeProviders` key through, so `lsp` from settings.json is untouched by design; the dedicated `lsp.json` source is the only LSP input.

- [ ] **Step 1: Apply the identical builder edits**

Apply every edit from Task 2 Steps 1-4 to `app/engine/kilo/build-kilo-v1.ps1` at the corresponding line anchors (`Merge-Mcp` ~1229, `Merge-Final` ~1243, pipeline `Merging plugins`/`mcp` ~2185-2213, verification after mcp, pre-flight near `$McpFile`, diff summary near mcp/plugin diff). Verify `$ProfilePath`/`$SchemaDir`/`$Lsp` scoping matches how `$Plugins`/`$MCP` are loaded in the Kilo pipeline (search `$McpFile  = Join-Path $ProfilePath "mcp.json"`).

- [ ] **Step 2: Add the identical five harness tests + registration**

Copy `Test-LspEnabledTrue` / `Test-LspEnabledObject` / `Test-LspDisabled` / `Test-LspFileAbsent` / `Test-LspFalseValue` into `app/engine/kilo/test-kilo-v1.ps1` (output file `kilo.json` instead of `opencode.json`), register in its Run-Test list.

- [ ] **Step 3: Run the harness**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\app\engine\kilo\test-kilo-v1.ps1
```
Expected: `Tests: 37/37 Passed` (32 + 5), exit 0.

- [ ] **Step 4: Diff hygiene (no commit)**

```powershell
git diff --check
```
Expected: exit 0.

---

### Task 4: App backend — agentstore LSP + `/api/lsp` router + tests

**Files:**
- Modify: `app/app/agentstore.py` (add `lsp_file`, `read_lsp`, `write_lsp` near `mcp_file`/`read_mcp`/`write_mcp` ~line 419-441)
- Create: `app/app/lsp.py`
- Modify: `app/server.py` (register router)
- Create: `app/tests/test_lsp.py`
- Test: `app/tests/test_lsp.py`

**Interfaces:**
- Produces: `agentstore.read_lsp(agent_dir, profile="coding") -> dict {"lsp": <bool|object>, "enabled": <bool>}`; `agentstore.write_lsp(agent_dir, value, enabled, profile="coding") -> dict`; router `GET /api/lsp` → `{"lsp": ..., "enabled": ...}`; `PUT /api/lsp` body `{"lsp": <bool|object>, "enabled": <bool>}` → updated state (400 on invalid shape).

- [ ] **Step 1: Add agentstore functions** (after `write_mcp`, ~line 439)

```python
def lsp_file(agent_dir, profile=MODEL_PROFILE):
    return agent_dir / "profiles" / profile / "lsp.json"


def read_lsp(agent_dir, profile=MODEL_PROFILE):
    data = _read_json(lsp_file(agent_dir, profile), {})
    value = data.get("lsp", True)
    enabled = data.get("enabled", False)
    if not isinstance(value, (bool, dict)):
        value = True
    return {"lsp": value, "enabled": bool(enabled)}


def write_lsp(agent_dir, value, enabled, profile=MODEL_PROFILE):
    path = lsp_file(agent_dir, profile)
    path.parent.mkdir(parents=True, exist_ok=True)
    data = _read_json(path, {})
    _backup(path)
    if not isinstance(value, (bool, dict)):
        raise ValueError("lsp must be a boolean or an object.")
    data["lsp"] = value
    data["enabled"] = bool(enabled)
    _write_json(path, data)
    return read_lsp(agent_dir, profile)
```

- [ ] **Step 2: Create `app/app/lsp.py`** (mirror `mcp.py`)

```python
"""LSP endpoints (profile-level LSP toggle + value for the agent's coding profile)."""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from . import agentstore

router = APIRouter(prefix="/api")


class LspBody(BaseModel):
    lsp: bool | dict = True
    enabled: bool = True


@router.get("/lsp")
def list_lsp():
    agent_dir = agentstore.require_agent_dir()
    return agentstore.read_lsp(agent_dir)


@router.put("/lsp")
def set_lsp(body: LspBody):
    if not isinstance(body.lsp, (bool, dict)):
        raise HTTPException(400, "lsp must be a boolean or an object.")
    agent_dir = agentstore.require_agent_dir()
    try:
        return agentstore.write_lsp(agent_dir, body.lsp, body.enabled)
    except ValueError as exc:
        raise HTTPException(400, str(exc))
```

- [ ] **Step 3: Register in `app/server.py`** (after mcp_router, ~line 60)

```python
from app.lsp import router as lsp_router
...
app.include_router(lsp_router)
```

- [ ] **Step 4: Write `app/tests/test_lsp.py`** (mirror `test_plugins.py`/`test_mcp.py` style — inspect those files for the fixture pattern: temp agent dir + `agentstore.require_agent_dir` patched or via `testing` helpers)

```python
"""Behavior tests for the LSP profile toggle (lsp.json)."""

import tempfile
import unittest
from pathlib import Path

from fastapi import HTTPException

from app import agentstore
from app.lsp import LspBody, list_lsp, set_lsp


class LspTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.agent_dir = Path(self.tmp.name) / "agent"
        (self.agent_dir / "profiles" / "coding").mkdir(parents=True)

    def tearDown(self):
        self.tmp.cleanup()

    def _activate(self):
        agentstore.add_agent("lsp-test", str(self.agent_dir))
        agentstore.switch_agent("lsp-test")

    def test_read_defaults_when_missing(self):
        self._activate()
        state = list_lsp()
        self.assertEqual(state["lsp"], True)
        self.assertEqual(state["enabled"], False)

    def test_write_round_trip(self):
        self._activate()
        state = set_lsp(LspBody(lsp=True, enabled=False))
        self.assertEqual(state["enabled"], False)
        state = set_lsp(LspBody(lsp={"typescript": {"command": ["ts-server", "--stdio"]}}, enabled=True))
        self.assertEqual(state["lsp"]["typescript"]["command"][0], "ts-server")
        self.assertEqual(state["enabled"], True)

    def test_backup_first_preserves_previous(self):
        self._activate()
        set_lsp(LspBody(lsp=True, enabled=True))
        set_lsp(LspBody(lsp=False, enabled=False))
        backups = list((self.agent_dir / "profiles" / "coding").glob("lsp.json.backup*"))
        self.assertTrue(backups, "no backup created")
        self.assertEqual(agentstore.read_lsp(self.agent_dir)["enabled"], False)

    def test_invalid_value_rejected(self):
        self._activate()
        with self.assertRaises(HTTPException) as ctx:
            set_lsp(LspBody(lsp="nope", enabled=True))
        self.assertEqual(ctx.exception.status_code, 400)
```

Note: check how existing `test_mcp.py` sets up the active agent and mirror it — if `require_agent_dir` needs the app's state machinery, use the same helper they use (e.g. `_activate` equivalents).

- [ ] **Step 5: Run the app Python tests**

```powershell
& .\env\Scripts\python.exe -W error::DeprecationWarning -m unittest tests.test_lsp
```
Expected: `Ran 4 tests ... OK`, exit 0. Then full suite:

```powershell
& .\env\Scripts\python.exe -W error::DeprecationWarning -m unittest discover -s tests -p "test_*.py"
```
Expected: previous total + 4 (213), only the 2 accepted `test_preferences` baselines fail.

- [ ] **Step 6: Diff hygiene (no commit)**

```powershell
git diff --check
```
Expected: exit 0.

---

### Task 5: App frontend — LSP block on Integrations page + contract tests

**Files:**
- Modify: `app/assets/js/core/api.js` (add `lsp`/`setLsp` after `removeMcp`, ~line 53)
- Modify: `app/assets/js/pages/integration-workspace.js` (`lspCard` markup + export; place card between plugins and MCP cards ~line 50-58)
- Modify: `app/assets/js/pages/integrations.js` (fetch `/api/lsp`, render toggle, wire change handler)
- Modify: `app/assets/css/integration-workspace.css` (LSP card + toggle styles, reusing existing classes where possible)
- Modify: `app/tests/integrations_visual_contract.test.mjs` (assert LSP block + toggle wiring)
- Test: focused frontend suite + full frontend

**Interfaces:**
- Consumes: `GET /api/lsp` → `{lsp, enabled}`; `PUT /api/lsp` body `{lsp, enabled}` → `{lsp, enabled}`. `integrationWorkspaceMarkup` gains `lsp` param.
- Produces: `api.lsp()` / `api.setLsp({lsp, enabled})`; LSP card with toggle; `id="lspToggle"`; server-name chips when `lsp` is an object; "Edit JSON" dialog (reuse `openDialog` expert pattern from MCP).

- [ ] **Step 1: api.js methods** (after `removeMcp`)

```js
  lsp: () => request("/api/lsp"),
  setLsp: (lsp, enabled) => request("/api/lsp", send("PUT", { lsp, enabled })),
```

- [ ] **Step 2: Markup — `lspCard` in integration-workspace.js**

Add (before the MCP card in the main column):

```js
function lspRows(lsp) {
  if (typeof lsp.lsp === "object" && lsp.lsp !== null) {
    const names = Object.keys(lsp.lsp);
    if (!names.length) return `<div class="integration-empty"><strong>No LSP servers configured</strong><span>Add a server with the expert JSON editor or set LSP to true for built-ins.</span></div>`;
    return `<div class="integration-chips">${names.map(name => `<span class="integration-chip">${escapeHtml(name)}</span>`).join("")}</div>`;
  }
  if (lsp.lsp === false) return `<div class="integration-empty"><strong>LSP explicitly disabled</strong><span>Set the value to true (built-ins) or an object (custom servers).</span></div>`;
  return `<div class="integration-empty"><strong>Built-in servers enabled</strong><span>opencode.json will carry "lsp": true.</span></div>`;
}

export function lspCard(lsp) {
  return `<article class="card integration-card integration-lsp"><div class="integration-card-head"><div><h2>LSP servers</h2><p>Controls whether language servers are included when building your agent config.</p></div><button id="editLspJson" class="button integration-outline-button" type="button">Edit JSON</button></div><div class="integration-lsp-toggle"><span class="integration-toggle-label">Include LSP when building</span><label class="integration-toggle"><input id="lspToggle" type="checkbox" ${lsp.enabled ? "checked" : ""}><span class="integration-toggle-track"></span></label></div>${lspRows(lsp)}</article>`;
}
```

Call `lspCard(lsp)` inside `integrationWorkspaceMarkup` between the plugins and MCP `<article>` elements (add `lsp` to the function's destructured params and the caller in integrations.js).

- [ ] **Step 3: integrations.js — fetch + wire toggle**

In `renderIntegrations`, add `api.lsp()` to the `Promise.all`, pass `lsp` into `integrationWorkspaceMarkup`, and after render:

```js
  workspace.querySelector("#lspToggle").addEventListener("change", async event => {
    try { await api.setLsp(currentLsp.lsp, event.target.checked); notify(`LSP ${event.target.checked ? "enabled" : "disabled"} for the next build.`, "success"); refresh(); }
    catch (error) { notify(error.message, "error"); event.target.checked = !event.target.checked; }
  });
  workspace.querySelector("#editLspJson").addEventListener("click", event => openLspJsonDialog(currentLsp, refresh));
```

Add `openLspJsonDialog` mirroring `openMcpDialog`'s expert mode: a textarea prefilled with `JSON.stringify(lsp.lsp, null, 2)`, on submit `JSON.parse` → `api.setLsp(parsed, enabled)`; show parse errors inline.

- [ ] **Step 4: CSS** — add `.integration-lsp-toggle`, `.integration-toggle-label`, `.integration-toggle`, `.integration-toggle-track`, `.integration-chips`, `.integration-chip` to `app/assets/css/integration-workspace.css` (reuse the design tokens; toggle = simple checkbox hidden + styled track/knob).

- [ ] **Step 5: Contract tests** — extend `app/tests/integrations_visual_contract.test.mjs`:

```js
test("integrations carries an LSP block with a build toggle between plugins and mcp", () => {
  assert.match(view, /integration-lsp/);
  assert.match(view, /LSP servers/);
  assert.match(view, /lspToggle/);
  assert.match(view, /editLspJson/);
  const plugins = view.indexOf("integration-plugins");
  const lsp = view.indexOf("integration-lsp");
  const mcp = view.indexOf("integration-mcp");
  assert.ok(plugins < lsp && lsp < mcp, "LSP card must sit between Plugins and MCP");
  assert.match(page, /api\.setLsp/);
});

test("lsp expert json dialog is wired", () => {
  assert.match(page, /openLspJsonDialog/);
  assert.match(page, /JSON\.parse/);
});
```

- [ ] **Step 6: Run frontend suites**

```powershell
node --test tests/integrations_visual_contract.test.mjs
node --test tests/claude_routes_contract.test.mjs tests/capability_ui_contract.test.mjs
node --test ".\tests\*.test.mjs"
```
Expected: focused 2 new tests pass; claude_routes/capability unchanged 46/46; full suite 131+2=133 with only the 1 accepted onboarding-copy baseline.

- [ ] **Step 7: Diff hygiene (no commit)**

```powershell
git diff --check
```
Expected: exit 0.

---

### Task 6: Full verification + live rebuild on real configs

**Files:**
- Test: all suites + real configs (snapshot + hash-verified restore)

**Interfaces:**
- Consumes: Tasks 1-5 outputs. Real configs: `C:\Users\loveb\.config\opencode` + `C:\Users\loveb\.config\kilo`.

- [ ] **Step 1: Full engine + app suites**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\app\engine\claude-code\test-claude-code.ps1            # Gate 2: 65/65 unchanged
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\app\engine\claude-code\test-provider-model.ps1 -PythonExe .\app\env\Scripts\python.exe   # Gate 3 OVERALL PASS unchanged
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\app\engine\test-opencode-v2.7.ps1                       # 40/40
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\app\engine\kilo\test-kilo-v1.ps1                        # 37/37
& .\env\Scripts\python.exe -W error::DeprecationWarning -m unittest discover -s tests -p "test_*.py"              # 213 (2 accepted baselines)
node --test ".\tests\*.test.mjs"                                                                                  # 133 (1 accepted baseline)
```

- [ ] **Step 2: Live rebuild with LSP (real configs, snapshot first)**

1. Snapshot: copy `opencode.json`, `kilo.json`, both `profiles/coding/*.json` + settings.json + state.json to a temp snapshot dir with SHA-256 hashes.
2. Resync the real builders from the engine (the agent `scripts/` copies are generated by `-Bootstrap`): run `scaffold-agent.ps1 -Agent opencode -ConfigRoot C:\Users\loveb\.config\opencode -NonInteractive -Bootstrap` and the kilo equivalent, OR copy `app/engine/build-opencode-v2.7.ps1` → `~/.config/opencode/scripts/build-opencode.ps1` and `app/engine/kilo/build-kilo-v1.ps1` → `~/.config/kilo/scripts/build-kilo.ps1` (verify `find_builder_script` target names first).
3. Scaffold-reseed or hand-write `profiles/coding/lsp.json` = `{ "lsp": true, "enabled": true }` for both agents (backup-first; if the file already exists from a prior run, use it).
4. Build opencode: `& .\scripts\build-opencode.ps1 -Profile coding -NonInteractive -ConfigRoot C:\Users\loveb\.config\opencode` (or via the app's `/api/build` after server restart).
5. Verify `opencode.json` contains a top-level `lsp` key; hash the output.
6. Build kilo the same way; verify `kilo.json` contains `lsp`.
7. Toggle OFF via `PUT /api/lsp {lsp: true, enabled: false}` (app server on 127.0.0.1:9090), rebuild both, verify NO `lsp` key in either output.
8. Toggle ON again, rebuild, verify `lsp` present.
9. Restore every snapshot file byte-identical (hash-verify); leave the final real configs in their pre-test state.
10. Restart the app server; `GET /api/lsp` shows the restored state.

- [ ] **Step 3: Regression gates**

```powershell
git diff --check                      # 0
# secrets scan (no real keys in repo), locks closed (ALLOW_REAL_CLAUDE_TARGET = False)
```
Expected: all green; Claude Code files untouched.

- [ ] **Step 4: Update session files** — add a session log entry + Journey Current Position update (same format as prior sessions; no commit).

---

## Self-review notes

- Spec coverage: §3.1 → Task 1 (scaffold split/seed); §3.2 → Tasks 2+3 (prompt/merge/verify in BOTH builders — user explicitly required both, not just one); §3.3 → Tasks 2/3 harness tests; §4.1 → Task 4 (agentstore + router); §4.2 → Task 5 (Integrations LSP block between Plugins and MCP + toggle); §4.3 → Tasks 4/5 tests; §5 behavior contract → Tasks 2/3/5; §6 testing plan → Task 6; §7 non-goals (Claude untouched) → every task keeps Claude files out of scope.
- Type consistency: `Merge-Final $Settings $ProviderRoot $PluginList $McpList $LspList` (5 params) is used identically in both builders; `agentstore.read_lsp/write_lsp` signatures match router usage; `api.setLsp(lsp, enabled)` matches `send("PUT", { lsp, enabled })` and the `LspBody` fields.
- Placeholder scan: no TBD/TODO; every code step contains concrete code.
