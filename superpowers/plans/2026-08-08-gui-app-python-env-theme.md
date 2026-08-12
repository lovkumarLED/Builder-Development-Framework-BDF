# GUI App: Python Environment + rule.md Theme Engine — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `docs/app/` self-contained (own Python venv + requirements, bootstrapped by start.bat) and turn `docs/app/rule.md` into the app's live theme (applied via serve-time CSS injection) plus the agent rulebook.

**Architecture:** start.bat owns the venv lifecycle (create on first run, reinstall when requirements.txt changes via a SHA256 hash marker). A new stdlib-only module `app/rules.py` parses rule.md's YAML front-matter into CSS variables with validation and defaults; `app/serve.py` injects a `:root` override into gui.html before `</head>` and exposes `GET /api/rules`. `gui.html` is NOT touched.

**Tech Stack:** Python 3.10+ (stdlib only for new code), batch (`start.bat`), PowerShell for verification, unittest for tests (no new pip dependency).

## Global Constraints

- Do NOT run `git commit` — this repo commits only on explicit user request (skip the template's commit steps).
- Windows-only app; `start.bat` must run under cmd.exe; use `python` (not `py`).
- `gui.html` is the parallel agent's deliverable — NEVER modify it.
- `providers.json`, `providers.backup.json`, `state.json` are user data — never create/delete/alter them outside the API.
- No-Secrets rule: no API keys in code, examples, or rule.md.
- Local-first: everything on 127.0.0.1.
- CSS variable names in rule.md must map 1:1 to the `:root` variables already in gui.html (`--bg`, `--card`, `--border`, `--border-hi`, `--text`, `--muted`, `--accent`, `--accent-hi`, `--green`, `--red`, `--amber`, `--radius`, `--radius-sm`). NOTE: gui.html has NO `--font` variable (body font is hardcoded) — `--font` exists in DEFAULT_THEME as an INERT forward-compatible key and must NOT appear in rule.md (final-review finding: it promised a behavior gui.html cannot deliver).
- PS 5.1 trap (caused a real corruption bug in Task 4): `Get-Content` without `-Encoding UTF8` decodes UTF-8 files as the machine's ANSI codepage (here: GBK) — reading AND re-writing rule.md that way double-encodes every non-ASCII character. EVERY `Get-Content 'rule.md'` in verification snippets MUST use `-Encoding UTF8`; every write must be BOM-free (Set-FileUtf8NoBom).
- Workdir for all Python/test commands: `C:\Users\loveb\.config\opencode\docs\app`.

---

### Task 1: Self-contained environment — requirements.txt, .gitignore, start.bat bootstrap

**Files:**
- Create: `docs/app/requirements.txt`
- Create: `docs/app/.gitignore`
- Rewrite: `docs/app/start.bat`

**Interfaces:**
- Consumes: nothing (first task).
- Produces: `env\Scripts\python.exe` (the venv interpreter all later tasks use to run tests and the server), `env\.requirements.hash` (SHA256 marker of requirements.txt).

- [ ] **Step 1: Create `requirements.txt`**

```
fastapi
uvicorn
```

- [ ] **Step 2: Create `.gitignore`**

```
env/
__pycache__/
*.pyc
providers.json
providers.backup.json
state.json
```

- [ ] **Step 3: Rewrite `start.bat`**

Replace the entire file with (note: CRLF line endings required — cmd.exe fails to parse LF-only batch blocks; parentheses inside `if (...)` blocks must be caret-escaped `^(` — both verified empirically on cmd.exe during Task 1):

```bat
@echo off
title Switcher
cd /d "%~dp0"

set "VENV_PY=env\Scripts\python.exe"

where python >nul 2>nul
if errorlevel 1 (
    echo.
    echo Python was not found on this computer.
    echo Install it from https://www.python.org/downloads/
    echo ^(tick "Add python.exe to PATH" during installation^), then try again.
    echo.
    pause
    exit /b 1
)

if not exist "%VENV_PY%" (
    echo.
    echo First run: creating the app's own Python environment ^(one-time^)...
    python -m venv env
    if errorlevel 1 (
        echo.
        echo Could not create the Python environment.
        echo Reinstall Python from https://www.python.org/downloads/ and try again.
        echo.
        pause
        exit /b 1
    )
)

set "HASH_FILE=env\.requirements.hash"
set "CUR_HASH="
for /f %%h in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 'requirements.txt').Hash"') do set "CUR_HASH=%%h"
set "OLD_HASH="
if exist "%HASH_FILE%" set /p OLD_HASH=<"%HASH_FILE%"
if not "%CUR_HASH%"=="%OLD_HASH%" (
    echo Installing app packages ^(first run or requirements changed^)...
    "%VENV_PY%" -m pip install --upgrade pip >nul 2>nul
    "%VENV_PY%" -m pip install -r requirements.txt
    if errorlevel 1 (
        echo.
        echo Package install failed. Check your internet connection and try again.
        echo.
        pause
        exit /b 1
    )
    echo %CUR_HASH%> "%HASH_FILE%"
)

echo.
echo Starting Switcher... your browser will open in a moment.
echo Close this window to stop the app.
echo.
"%VENV_PY%" server.py
pause
```

- [ ] **Step 4: Verify the bootstrap end-to-end**

Run from `C:\Users\loveb\.config\opencode\docs\app`:

```powershell
Remove-Item -Recurse -Force env -ErrorAction SilentlyContinue
$p = Start-Process cmd -ArgumentList '/c start.bat' -PassThru -WindowStyle Minimized
$ok = $false
for ($i = 0; $i -lt 30; $i++) { Start-Sleep -Seconds 2; try { Invoke-RestMethod 'http://127.0.0.1:9090/api/status' -TimeoutSec 3 | Out-Null; $ok = $true; break } catch {} }
"server up after bootstrap: $ok"
Test-Path 'env\Scripts\python.exe'
& 'env\Scripts\python.exe' -m pip list | Select-String 'fastapi|uvicorn'
Get-Content 'env\.requirements.hash'
```

Expected: `server up after bootstrap: True`, venv exists, fastapi + uvicorn installed, hash marker written.

- [ ] **Step 5: Stop the test server and verify second-run path**

```powershell
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'server.py' -and $_.CommandLine -match 'docs\\app' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
Start-Sleep -Seconds 2
$p = Start-Process cmd -ArgumentList '/c start.bat' -PassThru -WindowStyle Minimized
Start-Sleep -Seconds 6
try { Invoke-RestMethod 'http://127.0.0.1:9090/api/status' -TimeoutSec 5 | Out-Null; "second launch: server up (no reinstall expected)" } catch { "second launch FAILED: $_" }
```

Then stop the server again (same kill command).

---

### Task 2: Create `rule.md` — theme front-matter + rulebook

**Files:**
- Create: `docs/app/rule.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the exact front-matter keys Task 3's parser reads (`theme:` → `colors:` with keys `bg, card, border, border-hi, text, muted, accent, accent-hi, green, red, amber`; `radius`, `radius-sm`, `font`).

- [ ] **Step 1: Write the file**

Create `docs/app/rule.md` with EXACTLY this content (note: the YAML front-matter MUST be the very first lines of the file — the parser and the verification command both require `lines[0] == "---"`):

```markdown
---
theme:
  colors:
    bg: "#0d1117"
    card: "#161b22"
    border: "#30363d"
    border-hi: "#4a5261"
    text: "#e6edf3"
    muted: "#8b949e"
    accent: "#6366f1"
    accent-hi: "#818cf8"
    green: "#3fb950"
    red: "#f85149"
    amber: "#d29922"
  radius: "14px"
  radius-sm: "10px"
---

# Switcher — App Rules

> This file has two jobs:
> 1. The YAML front-matter above is the app's **theme** — the app reads it at
>    serve time and applies it to the interface. Edit a color, save, refresh
>    the browser — the app updates.
> 2. The sections below are the **rulebook** for humans and AI agents working
>    on this app — read them before changing anything.

## Design rules (colors)

- Dark theme only — near-black backgrounds, subtle borders.
- ONE accent color for actions. Everything else stays muted.
- Green / red / amber are STATUS ONLY (success / error / testing) — never
  decoration.
- Big friendly cards for providers — no tables, no jargon, no raw JSON.
- Plain words everywhere: "Connect", "Switch to this", "Build my config".
- Large click targets (≥44px), rounded corners, soft shadows, generous
  spacing. System font stack — no webfont downloads.
- `prefers-reduced-motion` must be respected — heavy animations disabled.

## Feature rules

- The app must let a normal person, alone: discover their coding agent, scan
  it, generate their builder scripts, add providers, test connections, switch
  the active provider, and build — WITHOUT an AI agent.
- The app must never: phone home, require an account, or send anything
  anywhere except the user's own requests to the provider they chose
  (local-first, 127.0.0.1).

## Architecture rules

- Modular backend: `app/` package, one responsibility per module.
- No-Secrets rule: API keys live ONLY in the user's `providers.json` — never
  in code, logs, examples, or API responses.
- Backup-first: `providers.json` is backed up before every write.
- Local-first: the server binds 127.0.0.1 only.

## Rules for AI agents

- Read this file BEFORE changing the app.
- Every user-visible change must be reflected here and in the app README in
  the same change.
```

- [ ] **Step 2: Verify structure**

Run: `python -c "import re; t=open('rule.md',encoding='utf-8').read(); print('starts with ---:', t.startswith('---')); print('has closing ---:', t.count('---')>=2); print('has theme/colors:', 'theme:' in t and 'colors:' in t)"` (from `docs/app`).
Expected: all three print `True`.

---

### Task 3: `app/rules.py` — rule.md parser with validation, defaults, and caching

**Files:**
- Create: `docs/app/app/rules.py`
- Test: `docs/app/tests/test_rules.py`

**Interfaces:**
- Consumes: `app.config.APP_DIR` (already exists).
- Produces (used by Task 4):
  - `DEFAULT_THEME: dict[str, str]` — CSS var → default value (copy of gui.html `:root`).
  - `get_theme() -> dict[str, str]` — full theme; never raises; defaults for missing/invalid keys.
  - `get_rulebook() -> str` — markdown body; `""` if rule.md unusable.
  - `theme_problem() -> str | None` — human-readable problem description, `None` when all good.
  - `_parse_rule_file(text: str) -> tuple[dict, str, str | None]` — pure function (theme, rulebook, problem).

- [ ] **Step 1: Write the failing tests**

Create `docs/app/tests/test_rules.py`:

```python
import unittest

from app import rules


class RuleParsingTests(unittest.TestCase):
    def test_valid_front_matter(self):
        text = (
            "---\n"
            "theme:\n"
            "  colors:\n"
            "    bg: \"#112233\"\n"
            "    accent: \"#ff00ff\"\n"
            "  radius: \"16px\"\n"
            "---\n"
            "\n"
            "# Rulebook\n"
            "body text\n"
        )
        theme, body, problem = rules._parse_rule_file(text)
        self.assertEqual(theme["--bg"], "#112233")
        self.assertEqual(theme["--accent"], "#ff00ff")
        self.assertEqual(theme["--radius"], "16px")
        self.assertEqual(theme["--green"], rules.DEFAULT_THEME["--green"])
        self.assertEqual(body, "# Rulebook\nbody text")
        self.assertIsNone(problem)

    def test_invalid_color_keeps_default(self):
        theme, _, problem = rules._parse_rule_file(
            "---\ntheme:\n  colors:\n    bg: \"notacolor\"\n---\n"
        )
        self.assertEqual(theme["--bg"], rules.DEFAULT_THEME["--bg"])
        self.assertIsNotNone(problem)

    def test_unknown_key_ignored(self):
        theme, _, _ = rules._parse_rule_file(
            "---\ntheme:\n  colors:\n    hotpink: \"#ff0000\"\n---\n"
        )
        self.assertEqual(theme, rules.DEFAULT_THEME)

    def test_no_front_matter(self):
        _, _, problem = rules._parse_rule_file("# no front matter\n")
        self.assertIsNotNone(problem)

    def test_unclosed_front_matter(self):
        _, _, problem = rules._parse_rule_file("---\ntheme:\n")
        self.assertIsNotNone(problem)

    def test_font_quotes_unescaped(self):
        theme, _, _ = rules._parse_rule_file(
            "---\ntheme:\n  colors:\n    font: \"-apple-system, \\\"Segoe UI\\\", sans-serif\"\n---\n"
        )
        self.assertEqual(theme["--font"], '-apple-system, "Segoe UI", sans-serif')
```

- [ ] **Step 2: Run tests to verify they fail**

Run (from `docs/app`, venv from Task 1): `& 'env\Scripts\python.exe' -m unittest discover -s tests -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'app.rules'`.

- [ ] **Step 3: Write the implementation**

Create `docs/app/app/rules.py`:

```python
"""rule.md parser, validator, and theme provider."""

import re
from pathlib import Path

from .config import APP_DIR

RULE_FILE = APP_DIR / "rule.md"

DEFAULT_THEME = {
    "--bg": "#0d1117",
    "--card": "#161b22",
    "--border": "#30363d",
    "--border-hi": "#4a5261",
    "--text": "#e6edf3",
    "--muted": "#8b949e",
    "--accent": "#6366f1",
    "--accent-hi": "#818cf8",
    "--green": "#3fb950",
    "--red": "#f85149",
    "--amber": "#d29922",
    "--radius": "14px",
    "--radius-sm": "10px",
    "--font": '-apple-system, "Segoe UI", system-ui, sans-serif',
}

KEY_MAP = {name[2:]: name for name in DEFAULT_THEME}

_COLOR_RE = re.compile(r"^#[0-9a-fA-F]{6}$")
_SIZE_RE = re.compile(r"^\d+(px|rem|%|em)?$")

_cache = {"mtime": None, "theme": None, "rulebook": None, "problem": None}


def _parse_rule_file(text):
    """Return (theme, rulebook, problem) from raw rule.md text."""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return dict(DEFAULT_THEME), text.strip(), "rule.md must start with --- (front-matter missing)."
    end = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end = i
            break
    if end is None:
        return dict(DEFAULT_THEME), text.strip(), "rule.md front-matter is never closed."
    body = "\n".join(lines[end + 1:]).strip()
    theme = dict(DEFAULT_THEME)
    section = None
    problems = []
    for line in lines[1:end]:
        stripped = line.strip()
        if not stripped or stripped.startswith("- "):
            continue
        if stripped == "theme:":
            section = "theme"
        elif stripped == "colors:":
            section = "colors"
        elif section == "colors" and ":" in stripped:
            key, _, raw_value = stripped.partition(":")
            css_key = KEY_MAP.get(key.strip())
            if css_key is None:
                problems.append(f"unknown color key '{key.strip()}' ignored")
                continue
            value = raw_value.strip().strip('"').replace('\\"', '"')
            if css_key in ("--radius", "--radius-sm"):
                if _SIZE_RE.match(value):
                    theme[css_key] = value
                else:
                    problems.append(f"invalid size '{value}' for {key}")
            elif css_key == "--font":
                if value:
                    theme[css_key] = value
            elif _COLOR_RE.match(value):
                theme[css_key] = value
            else:
                problems.append(f"invalid color '{value}' for {key}")
    problem = problems[0] if problems else None
    return theme, body, problem


def _load():
    try:
        mtime = RULE_FILE.stat().st_mtime
    except OSError:
        mtime = None
    if _cache["mtime"] == mtime and _cache["theme"] is not None:
        return _cache
    if mtime is None:
        _cache.update(
            mtime=None,
            theme=dict(DEFAULT_THEME),
            rulebook="",
            problem="rule.md not found - using default theme.",
        )
        return _cache
    try:
        text = RULE_FILE.read_text(encoding="utf-8")
    except OSError as exc:
        _cache.update(mtime=mtime, theme=dict(DEFAULT_THEME), rulebook="", problem=f"rule.md unreadable: {exc}")
        return _cache
    theme, body, problem = _parse_rule_file(text)
    _cache.update(mtime=mtime, theme=theme, rulebook=body, problem=problem)
    return _cache


def get_theme():
    return dict(_load()["theme"])


def get_rulebook():
    return _load()["rulebook"]


def theme_problem():
    return _load()["problem"]
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `& 'env\Scripts\python.exe' -m unittest discover -s tests -v`
Expected: `OK (6 tests)`.

- [ ] **Step 5: Verify against the real rule.md**

Run: `& 'env\Scripts\python.exe' -c "import sys; sys.path.insert(0,'.'); from app import rules; print(rules.theme_problem()); print(rules.get_theme()['--accent']); print(len(rules.get_rulebook()))"` (from `docs/app`).
Expected: `None`, `#6366f1`, a rulebook length > 100.

---

### Task 4: Theme injection into gui.html + `GET /api/rules`

**Files:**
- Modify: `docs/app/app/serve.py`
- Test: `docs/app/tests/test_serve.py`

**Interfaces:**
- Consumes: `rules.get_theme()`, `rules.theme_problem()`, `rules.get_rulebook()` from Task 3.
- Produces:
  - `build_theme_style(theme: dict[str, str]) -> str` — `<style>:root{--bg:#0d1117;...}</style>`.
  - `inject_before_head(html: str, injection: str) -> str` — returns html with `injection` inserted just before `</head>` (case-insensitive); unchanged if no `</head>`.
  - `GET /api/rules` → `{"theme": {...}, "rulebook": "..."}`.

- [ ] **Step 1: Write the failing tests**

Create `docs/app/tests/test_serve.py`:

```python
import unittest

from app.serve import build_theme_style, inject_before_head


class ThemeInjectionTests(unittest.TestCase):
    def test_build_theme_style_contains_variables(self):
        style = build_theme_style({"--bg": "#0d1117", "--accent": "#6366f1"})
        self.assertIn("--bg:#0d1117", style)
        self.assertIn("--accent:#6366f1", style)
        self.assertTrue(style.startswith("<style>:root{"))

    def test_inject_before_head_places_style_inside_head(self):
        html = "<html><head><title>t</title></head><body>x</body></html>"
        result = inject_before_head(html, "<style></style>")
        self.assertEqual(result, "<html><head><title>t</title><style></style></head><body>x</body></html>")

    def test_no_head_returns_unchanged(self):
        html = "<html><body>x</body></html>"
        self.assertEqual(inject_before_head(html, "<style></style>"), html)
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `& 'env\Scripts\python.exe' -m unittest discover -s tests -v`
Expected: FAIL with `ImportError: cannot import name 'build_theme_style'`.

- [ ] **Step 3: Modify `serve.py`**

Add the two pure functions and change `index()` + add the rules endpoint. Final file content (replace `app/serve.py` entirely):

```python
"""Serves the GUI (gui.html) with a built-in placeholder fallback."""

from fastapi import APIRouter
from fastapi.responses import HTMLResponse

from . import rules
from .config import APP_DIR

router = APIRouter()

PLACEHOLDER = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Switcher</title>
<style>
  body{margin:0;font-family:"Segoe UI",system-ui,sans-serif;background:#0d1117;color:#e6edf3;display:flex;align-items:center;justify-content:center;min-height:100vh}
  .card{background:#161b22;border:1px solid #30363d;border-radius:16px;padding:40px 48px;max-width:520px;text-align:center}
  h1{margin:0 0 8px;font-size:28px}
  p{color:#8b949e;line-height:1.6}
  .dot{display:inline-block;width:10px;height:10px;border-radius:50%;background:#3fb950;margin-right:8px;animation:pulse 2s infinite}
  @keyframes pulse{0%,100%{opacity:1}50%{opacity:.4}}
  code{background:#21262d;padding:2px 6px;border-radius:6px;font-size:13px}
  .status{margin-top:16px;font-size:14px;color:#3fb950}
</style>
</head>
<body>
<div class="card">
  <h1>Switcher</h1>
  <p>The backend is running on <code>127.0.0.1:9090</code>.<br>
  The full interface (<code>gui.html</code>) is not here yet —<br>
  drop it into the <code>docs\\app</code> folder and refresh this page.</p>
  <div class="status"><span class="dot"></span>Backend running</div>
</div>
</body>
</html>
"""


def build_theme_style(theme):
    declarations = ";".join(f"{key}:{value}" for key, value in theme.items())
    return f"<style>:root{{{declarations}}}</style>"


def inject_before_head(html, injection):
    marker = "</head>"
    position = html.lower().find(marker)
    if position == -1:
        return html
    return html[:position] + injection + html[position:]


@router.get("/")
def index():
    gui = APP_DIR / "gui.html"
    if gui.is_file():
        html = gui.read_text(encoding="utf-8")
        problem = rules.theme_problem()
        if problem:
            print(f"[rules] {problem}")
        return HTMLResponse(inject_before_head(html, build_theme_style(rules.get_theme())))
    return HTMLResponse(PLACEHOLDER)


@router.get("/api/rules")
def rules_endpoint():
    return {"theme": rules.get_theme(), "rulebook": rules.get_rulebook()}
```

- [ ] **Step 4: Run all tests to verify they pass**

Run: `& 'env\Scripts\python.exe' -m unittest discover -s tests -v`
Expected: `OK (9 tests)`.

- [ ] **Step 5: Verify live injection + endpoint**

```powershell
$p = Start-Process cmd -ArgumentList '/c start.bat' -PassThru -WindowStyle Minimized
Start-Sleep -Seconds 6
$r = Invoke-WebRequest 'http://127.0.0.1:9090/' -UseBasicParsing -TimeoutSec 8
"theme injected: $($r.Content -match '<style>:root\{--bg:#0d1117')"
$rules = Invoke-RestMethod 'http://127.0.0.1:9090/api/rules' -TimeoutSec 8
"rules endpoint: accent=$($rules.theme.'--accent') rulebookLen=$($rules.rulebook.Length)"
```

Expected: both true; `accent=#6366f1`, `rulebookLen > 100`.

- [ ] **Step 6: Verify live theme change + stop server**

```powershell
(Get-Content 'rule.md' -Raw).Replace('accent: "#6366f1"', 'accent: "#ff00ff"') | Set-Content 'rule.md' -Encoding UTF8
$r2 = Invoke-WebRequest 'http://127.0.0.1:9090/' -UseBasicParsing -TimeoutSec 8
"accent changed live: $($r2.Content -match '--accent:#ff00ff')"
(Get-Content 'rule.md' -Raw).Replace('accent: "#ff00ff"', 'accent: "#6366f1"') | Set-Content 'rule.md' -Encoding UTF8
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'server.py' -and $_.CommandLine -match 'docs\\app' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
```

Expected: `accent changed live: True` (then rule.md restored, server stopped).

---

### Task 5: App README — Python environment + "change the look" sections

**Files:**
- Modify: `docs/app/README.md`

**Interfaces:**
- Consumes: nothing; this is docs only.

- [ ] **Step 1: Add the Python environment section**

After the "## How to start" section, insert:

```markdown
## How the app's Python works

The first time you double-click `start.bat`, the app creates its own private
Python environment in an `env` folder next to the app, then installs the
packages it needs from `requirements.txt`. That is a one-time thing (needs
internet).

- The second launch onward is instant — no re-installing.
- If `requirements.txt` changes (when new features are added), the app
  re-installs automatically the next time you start it.
- The `env` folder is private to this computer. Copy the app folder to
  another PC and it simply creates a fresh `env` there on first launch —
  your providers, settings, and rule.md stay untouched.
- Deleting `env` is safe: it is recreated on the next launch.
```

- [ ] **Step 2: Add the "change the look" section**

After the "## Where your data lives" section, insert:

```markdown
## How to change the look

Everything about the look lives in one file: `rule.md` (next to this README).

- The top part of `rule.md` is the **theme** — colors, corner rounding, font.
  Edit a color (e.g. change `accent` to a color you like), save the file, and
  refresh the browser. The app applies it immediately.
- The bottom part of `rule.md` is the **rulebook** — the design and feature
  rules the app follows. AI agents working on this app read it before making
  changes, and every change keeps it in sync.

If you mess up `rule.md` (bad color, broken file), the app just keeps its
built-in look and shows a warning in the black window — nothing breaks.
```

- [ ] **Step 3: Update the data table + verify**

In the "Where your data lives" table, add two rows:

```
| `env\` | the app's private Python environment (created on first run — safe to delete, recreated next launch) |
| `rule.md` | the app's look (theme colors) + the rulebook for AI agents |
```

Verify: re-read `docs/app/README.md`; confirm the new sections read naturally and the existing sections are intact.

---

### Task 6: Full verification battery (spec acceptance)

**Files:**
- None (verification only). Run from `C:\Users\loveb\.config\opencode\docs\app`.

- [ ] **Step 1: Fresh-environment acceptance (spec §6.1–6.2)**

Note: PS 5.1 `Set-Content -Encoding UTF8` writes a UTF-8 BOM which breaks rule.md's front-matter parser — use the BOM-free helper below for ANY rule.md edit. Kill stale servers first (they hold port 9090).

```powershell
function Set-FileUtf8NoBom([string]$Path, [string]$Content) { [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding($false))) }
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'server\.py' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
Remove-Item -Recurse -Force env -ErrorAction SilentlyContinue
$before1 = Get-FileHash 'providers.json' -Algorithm SHA256 | Select-Object -ExpandProperty Hash
$before2 = Get-FileHash 'state.json' -Algorithm SHA256 | Select-Object -ExpandProperty Hash
$p = Start-Process cmd -ArgumentList '/c start.bat' -PassThru -WindowStyle Minimized
$ok = $false
for ($i = 0; $i -lt 30; $i++) { Start-Sleep -Seconds 2; try { Invoke-RestMethod 'http://127.0.0.1:9090/api/status' -TimeoutSec 3 | Out-Null; $ok = $true; break } catch {} }
"fresh env: server up = $ok"
$after1 = Get-FileHash 'providers.json' -Algorithm SHA256 | Select-Object -ExpandProperty Hash
$after2 = Get-FileHash 'state.json' -Algorithm SHA256 | Select-Object -ExpandProperty Hash
"providers.json untouched: $($before1 -eq $after1)"
"state.json untouched: $($before2 -eq $after2)"
```

Expected: server up = True, both untouched = True.

- [ ] **Step 2: Full API regression with the venv Python (spec §6.5)**

```powershell
$h = @{ 'Content-Type' = 'application/json' }
$s = Invoke-RestMethod 'http://127.0.0.1:9090/api/status' -TimeoutSec 8; "status ready=$($s.ready)"
$d = Invoke-RestMethod -Method Post 'http://127.0.0.1:9090/api/discover' -Headers $h -Body '{}' -TimeoutSec 8; "discover agents=$($d.agents.Count)"
$sc = Invoke-RestMethod -Method Post 'http://127.0.0.1:9090/api/scan' -Headers $h -Body '{"agent":"opencode","dir":"C:\\Users\\loveb\\.config\\opencode"}' -TimeoutSec 8; "scan mcp=$($sc.mcps.Count) plugins=$($sc.plugins.Count)"
$p1 = Invoke-RestMethod -Method Post 'http://127.0.0.1:9090/api/providers' -Headers $h -Body '{"name":"Smoke","baseUrl":"http://localhost:20128/v1","apiKey":"sk-smoke-dummy"}' -TimeoutSec 8; "provider created=$($p1.id) hasKey=$($p1.hasKey)"
$t = Invoke-RestMethod -Method Post 'http://127.0.0.1:9090/api/test' -Headers $h -Body ("{0}" -f ('{"id":"' + $p1.id + '"}')) -TimeoutSec 25; "test ok=$($t.ok)"
$sw = Invoke-RestMethod -Method Post 'http://127.0.0.1:9090/api/switch' -Headers $h -Body ("{0}" -f ('{"id":"' + $p1.id + '"}')) -TimeoutSec 8; "switch ok=$($sw.ok)"
$g = Invoke-RestMethod 'http://127.0.0.1:9090/api/providers' -TimeoutSec 8; "no key leak: $(-not (($g | ConvertTo-Json -Depth 5) -match 'sk-smoke'))"
$bld = Invoke-RestMethod -Method Post 'http://127.0.0.1:9090/api/build' -Headers $h -Body '{"profile":"coding"}' -TimeoutSec 320; "build ok=$($bld.ok)"
Invoke-RestMethod -Method Delete "http://127.0.0.1:9090/api/providers/$($p1.id)" -TimeoutSec 8 | Out-Null; "cleanup done"
```

Expected: status ready=True, discover ≥1, scan mcp>0, provider created, test ok=True (OmniRoute live), switch ok=True, no key leak=True, build ok=True.

- [ ] **Step 3: Theme + rules acceptance (spec §6.3–6.4)**

```powershell
function Set-FileUtf8NoBom([string]$Path, [string]$Content) { [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding($false))) }
$r = Invoke-WebRequest 'http://127.0.0.1:9090/' -UseBasicParsing -TimeoutSec 8
"theme injected: $($r.Content -match '<style>:root\{--bg:#0d1117')"
$rules = Invoke-RestMethod 'http://127.0.0.1:9090/api/rules' -TimeoutSec 8
"rules endpoint: $($rules.theme.'--accent') / $($rules.rulebook.Length) chars"
Set-FileUtf8NoBom 'rule.md' ((Get-Content 'rule.md' -Raw -Encoding UTF8).Replace('border-hi: "#4a5261"', 'border-hi: "#bad"'))
$r2 = Invoke-WebRequest 'http://127.0.0.1:9090/' -UseBasicParsing -TimeoutSec 8
"invalid value falls back to default: $($r2.Content -match '--border-hi:#4a5261')"
Set-FileUtf8NoBom 'rule.md' ((Get-Content 'rule.md' -Raw -Encoding UTF8).Replace('border-hi: "#bad"', 'border-hi: "#4a5261"'))
```

Expected: theme injected=True, rules endpoint shows `#6366f1` + rulebook >100 chars, invalid value falls back=True. Then restore rule.md (done in command).

- [ ] **Step 4: Stop the server and confirm clean end state**

```powershell
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'server\.py' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
"rule.md accent still default: $((Get-Content 'rule.md' -Raw) -match 'accent: \"#6366f1\"')"
Get-ChildItem env -ErrorAction SilentlyContinue | Select-Object -First 3 | ForEach-Object { $_.Name }
```

Expected: rule.md default restored, env folder exists with python.exe.

- [ ] **Step 5 (supplemental, §6.2): second-launch — no reinstall, fast start**

```powershell
$hashBefore = (Get-Item 'env\.requirements.hash').LastWriteTime.ToString('o')
$sw = [System.Diagnostics.Stopwatch]::StartNew()
$p = Start-Process cmd -ArgumentList '/c start.bat' -PassThru -WindowStyle Minimized
$ok = $false
for ($i = 0; $i -lt 20; $i++) { Start-Sleep -Seconds 1; try { Invoke-RestMethod 'http://127.0.0.1:9090/api/status' -TimeoutSec 3 | Out-Null; $ok = $true; break } catch {} }
$sw.Stop()
"second launch: server up = $ok, time-to-ready = $($sw.Elapsed.TotalSeconds)s"
"hash marker mtime unchanged (no reinstall): $((Get-Item 'env\.requirements.hash').LastWriteTime.ToString('o') -eq $hashBefore)"
$r = Invoke-WebRequest 'http://127.0.0.1:9090/' -UseBasicParsing -TimeoutSec 8
"GUI loads with theme on normal launch: $($r.Content -match '<style>:root\{--bg:#0d1117')"
```

Expected: server up=True, time-to-ready well under 60s, hash unchanged=True, GUI loads=True.

- [ ] **Step 6 (supplemental, §6.3 positive control): valid accent change IS reflected**

```powershell
function Set-FileUtf8NoBom([string]$Path, [string]$Content) { [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding($false))) }
Set-FileUtf8NoBom 'rule.md' ((Get-Content 'rule.md' -Raw -Encoding UTF8).Replace('accent: "#6366f1"', 'accent: "#ff0000"'))
$r = Invoke-WebRequest 'http://127.0.0.1:9090/' -UseBasicParsing -TimeoutSec 8
"accent change reflected: $($r.Content -match '--accent:#ff0000')"
Set-FileUtf8NoBom 'rule.md' ((Get-Content 'rule.md' -Raw -Encoding UTF8).Replace('accent: "#ff0000"', 'accent: "#6366f1"'))
"restored: $((Get-Content 'rule.md' -Raw -Encoding UTF8) -match 'accent: \"#6366f1\"')"
```

Expected: accent change reflected=True, restored=True.

- [ ] **Step 7 (supplemental, reviewer finding 3): /api/test timeout 10s → 20s in testing.py**

In `docs/app/app/testing.py`, change the `urlopen(..., timeout=10)` in `_try_models` to `timeout=20`. Then live-verify both paths:

```powershell
$h = @{ 'Content-Type' = 'application/json' }
$p1 = Invoke-RestMethod -Method Post 'http://127.0.0.1:9090/api/providers' -Headers $h -Body '{"name":"Smoke","baseUrl":"http://localhost:20128/v1","apiKey":"sk-smoke-dummy"}' -TimeoutSec 8
$t1 = Invoke-RestMethod -Method Post 'http://127.0.0.1:9090/api/test' -Headers $h -Body ("{0}" -f ('{"id":"' + $p1.id + '"}')) -TimeoutSec 30
"live provider: ok=$($t1.ok) lat=$($t1.latencyMs)"
$p2 = Invoke-RestMethod -Method Post 'http://127.0.0.1:9090/api/providers' -Headers $h -Body '{"name":"Dead","baseUrl":"http://localhost:59999/v1","apiKey":""}' -TimeoutSec 8
$t2 = Invoke-RestMethod -Method Post 'http://127.0.0.1:9090/api/test' -Headers $h -Body ("{0}" -f ('{"id":"' + $p2.id + '"}')) -TimeoutSec 30
"dead provider fails fast: ok=$($t2.ok) lat=$($t2.latencyMs) (should be < 3000)"
Invoke-RestMethod -Method Delete "http://127.0.0.1:9090/api/providers/$($p1.id)" -TimeoutSec 8 | Out-Null
Invoke-RestMethod -Method Delete "http://127.0.0.1:9090/api/providers/$($p2.id)" -TimeoutSec 8 | Out-Null
"cleanup done"
```

Expected: live provider ok=True; dead provider ok=False, latency < 5s on this machine (connection refused detection takes ~2s per loopback address — IPv6 then IPv4 — so ~4s for `localhost`; the 20s timeout only bounds hung connections, never engages on refusals); both providers deleted after.

- [ ] **Step 8: Final stop + clean end state**

```powershell
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'server\.py' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
"rule.md pristine: $((Get-Content 'rule.md' -Raw -Encoding UTF8) -match 'accent: \"#6366f1\"' -and -not $((Get-Content 'rule.md' -Raw -Encoding UTF8).StartsWith([char]0xEF)))"
"providers empty: $((Get-Item 'providers.json').Length -eq 50)"
```

Expected: rule.md pristine=True, providers empty=True.

- [ ] **Step 9 (supplemental, final-review regression): rule.md encoding is byte-clean**

```powershell
$b = [IO.File]::ReadAllBytes('rule.md')
$em = 0; $corrupt = 0
for ($i = 0; $i -lt $b.Length - 1; $i++) {
  if ($b[$i] -eq 0xE2 -and $b[$i+1] -eq 0x80 -and $b[$i+2] -eq 0x94) { $em++ }
  if ($b[$i] -eq 0xC3 -and $b[$i+1] -eq 0x83) { $corrupt++ }
}
"proper em-dashes (E2 80 94): $em (expected 11)"
"corrupt sequences (C3 83): $corrupt (expected 0)"
```

Expected: `proper em-dashes: 11`, `corrupt sequences: 0`. (If the em-dash count differs, the rulebook text was changed — recount against the plan's Task 2 block.)

---

## Self-Review Notes

- Spec coverage: §3.1 → Task 1; §3.2 → Task 2; §3.3 rules.py → Task 3, serve.py + /api/rules → Task 4; §3.4 → Task 5; §6 acceptance → Task 6. Error-handling table → Tasks 1 (start.bat messages) + 3 (defaults) + 4 (console warning). §7 out-of-scope items are not implemented.
- Types: `_parse_rule_file` returns `(dict, str, str|None)` everywhere it is tested; `get_theme()/get_rulebook()/theme_problem()` signatures match Task 4's usage; `build_theme_style`/`inject_before_head` match Task 4's tests exactly.
- CSS keys: `KEY_MAP` derives from `DEFAULT_THEME` (single source), so the mapping can never drift from the keys used in Task 2's rule.md.
