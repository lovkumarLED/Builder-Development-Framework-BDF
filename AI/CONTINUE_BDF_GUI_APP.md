# CONTINUE — BDF GUI APP: "AI Switcher" for Normal Users (session 28e plan)

> Resume file for the next session. Read this first, then build the app.
> **PARALLEL BUILD: the frontend (gui.html) is built by Qwen 3.8 Max in another
> window from `AI/BDF_GUI_APP_FRONTEND_SPEC.md`. This session/agent builds the
> BACKEND (server.py + start.bat + README.md) to that contract.**

---

## The Vision (user's words)

The framework helps developers — but a **normal person** who just wants free AI
should not have to:

- install things manually,
- edit JSON,
- understand OmniRoute / LiteLLM / CLI-Proxy differences,
- or read a README.

They want ONE simple thing: **open the app, paste their provider details,
click, and switch between local servers (OmniRoute, LiteLLM, CLI Proxy) to get
free AI — constantly, easily, visually.**

This app is that: a **web-like GUI** that anyone can use.

---

## THE CORE PRINCIPLE: the app is BDF, made autonomous

**The app performs EXACTLY like the BDF performs — but by itself, for a normal
user. NO AI agent required.**

Two worlds, one system:

```
┌─────────────────────────────────────────────────────────────┐
│  WORLD 1 — DEVELOPERS (the MD BDF framework)                │
│  docs/bdf/*.md, docs/BUILDER_SPEC.md, planning/, templates  │
│  Developers edit the MDs, ask an AI agent to edit them,     │
│  and build their own builders through the framework.        │
└─────────────────────────────────────────────────────────────┘
                          │ (same engine, same behavior)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  WORLD 2 — NORMAL USERS (the GUI app, docs/app/)            │
│  The user opens the GUI, clicks, enters provider details,   │
│  and the APP does all the work BDF does — automatically:    │
│  it creates the .ps1 builder scripts for the user.          │
│  NO AI agent, NO MDs, NO terminal.                          │
└─────────────────────────────────────────────────────────────┘
```

**The user will NOT go to an AI agent and say: "Build this for me, follow the
framework, set everything up." The app IS the builder — it does that work
itself, the same way BDF would.**

### What "performs like BDF" means for the app

The BDF's job (for an agent, via MDs) is:

1. Discover / accept the agent's config location.
2. Scan the agent's own main JSON.
3. Split sections: mcp / plugin / settings / providers.
4. Seed profiles (coding / experimental / minimal).
5. Generate the builder scripts (build-.ps1, test-.ps1, scaffold-.ps1).
6. Keep providers/models user-owned; never write secrets.

**The app's job (for a human, via the GUI) is the SAME — fully automated:**

1. GUI asks: "Where are your coding agents?" or auto-discovers.
2. GUI scans the main JSON itself (no agent involved).
3. GUI shows the found sections as friendly cards.
4. GUI creates the profile structure with one click.
5. **GUI generates the .ps1 builder scripts itself** — the app writes
   `build-<agent>.ps1`, `test-<agent>.ps1`, `scaffold-<agent>.ps1` exactly like
   `scaffold-agent.ps1 -Bootstrap` would.
6. User adds providers through the GUI (keys stay in their file, never in the
   app code).
7. User clicks "Build" and the app runs the generated builder.

**Success test:** a person with zero dev knowledge opens the app, follows the
on-screen prompts, and ends up with working builder scripts + a working config
— without ever talking to an AI or opening a terminal for more than double-
clicking `start.bat`.

---

## The Two Questions (answered)

### 1. Where does the app live?

**Inside the docs folder, in a self-contained app folder**:

```
C:\Users\loveb\.config\opencode\docs\
├── app\          ← THE GUI APP (new)
├── bdf\          ← framework knowledge
├── AI\           ← AI task documents
├── planning\
├── _agent\
└── ...
```

Why: it keeps everything in one place under the docs brain of the project,
easy for the AI to maintain with the same documentation rules, and the app
ships as a self-contained folder a user can copy anywhere.

**Research note (validated 2026-08-08) — is code inside docs/ good practice?**

- Mainstream monorepo convention (Turborepo, Nx, reopt, Ritza): apps belong in
  `apps/` / a top-level folder, `docs/` holds documentation only. No source
  recommends apps inside `docs/`.
- Repo-doctor audit rule: "when a subsystem grows a roadmap, an asset library,
  or an audience of its own — it's a product — **extract it** before it distorts
  the host repo's docs."
- Counter-argument (principles.dev): docs should be close to code — but that
  means docs next to code, not code inside docs.

**Decision for THIS project:** `docs/app/` is acceptable NOW because (a) this
repo is unusual — `docs/` IS the repository (git root, the project brain), (b)
the app is tiny and self-contained (server.py + gui.html), (c) users copy the
folder, so repo location doesn't affect them. **Future exit path: when the app
gets a real audience, extract it to a top-level folder or its own repo.**

### 2. Web-like GUI via an HTML file — is that better?

**YES — strongly.** This is the proven pattern (API-Switch, Relay Switch,
Clipal, Open WebUI all do exactly this):

- **User gets a folder** → double-clicks `start.bat` (or `index.html`) →
  a browser opens with the GUI → done.
- **No install, no terminal, no config files.** Everything lives in one
  folder next to the app.
- **Also good for developers**: an "Advanced" mode can expose the raw JSON /
  builder underneath, so both audiences use one app.

---

## What the App Does (product spec)

### Core loop (for the normal user)

```
Open the app (double-click start.bat → browser opens)
↓
Follow the on-screen setup wizard (no dev knowledge needed)
↓
App discovers / asks: "Where are your coding agents?"
↓
App SCANS the main JSON itself and shows friendly cards
↓
App CREATES the profile structure + GENERATES the .ps1 builder scripts
   (build-<agent>.ps1, test-<agent>.ps1, scaffold-<agent>.ps1) — by itself
↓
User adds a Provider (name + base URL + API key, OR pick a preset)
↓
Click "Test Connection" (✓ green = works)
↓
Click "Build" → the app RUNS the generated builder for the user
↓
Pick which provider is ACTIVE right now
↓
Chat / use AI immediately — switching providers is ONE CLICK
```

**The app does ALL of this without an AI agent.** It generates the builder
scripts the same way `scaffold-agent.ps1 -Bootstrap` would — the generation
logic is embedded in the app (or the app calls the real scaffold script
directly, which is even better: one engine, two frontends).

### Screens (v1 — keep it small)

| Screen | Purpose |
|--------|---------|
| **Setup Wizard** | Step-by-step: agent location → scan → profiles → builder generation |
| **Home / Dashboard** | Which provider is active now, big "switch" buttons, status dots (green/red) |
| **Providers** | Add/edit/remove providers (presets: OmniRoute, LiteLLM, CLI Proxy) |
| **Build** | "Generate builder scripts" + "Run build" buttons (the BDF engine, GUI'd) |
| **Chat** | A tiny built-in chat box to try the active provider (nice-to-have v1.1) |
| **Advanced (hidden mode)** | Show the generated JSON + the generated .ps1 scripts |

### Reuse the real engine (recommended)

The app should **call the existing BDF engine** instead of re-implementing it:

- `scaffold-agent.ps1 -Agent <agent> -NonInteractive` → generates profiles +
  builder scripts.
- `build-<agent>.ps1 -Profile coding` → runs the build.
- The app is a **GUI frontend for the real BDF engine** — one behavior, two
  surfaces. This guarantees "the app performs exactly like BDF performs".

### The magic: one local endpoint

Like the successful tools, the app runs a **tiny local proxy**:

```
Your AI tool (OpenCode, Cursor, any OpenAI-compatible)
        ↓  points at
http://127.0.0.1:9090/v1
        ↓  app routes to
OmniRoute | LiteLLM | CLI Proxy | (whichever is ACTIVE)
```

So the user configures the AI tool ONCE, and the app switches providers
behind the scenes. Switching = editing the active provider = no JSON.

### Presets (v1)

| Preset | Base URL (example) | Note |
|--------|-------------------|------|
| OmniRoute | `http://localhost:20128/v1` | Local OpenAI-compatible |
| LiteLLM | `http://localhost:4000/v1` | Local gateway |
| CLI Proxy | `http://localhost:xxxxx/v1` | Local proxy |
| Custom | any | User types it |

---

## Recommended Tech Stack

Keep it DEAD SIMPLE for v1 — one language, one server, one HTML file:

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **Python + FastAPI (or Flask) + single HTML/JS page** | Easy to write, one file server, runs anywhere, we already live in PowerShell/Windows | Needs Python installed | ⭐ Recommended for v1 |
| Node.js + Express + single HTML | Similar | Needs Node | Fine too |
| Tauri (Rust) + React | Portable single EXE, beautiful | Heavy to build | v2 idea |
| Pure static HTML + user-run commands | Zero deps | Can't run the proxy itself | Not enough |

**Recommended v1**: `docs/app/` with

```
docs/app/
├── server.py          ← FastAPI: serves GUI + calls the real BDF engine + local proxy
├── gui.html           ← the whole UI (one file, vanilla JS + CSS, dark theme)
├── providers.json     ← user's providers (created by the GUI, never hand-edited)
├── start.bat          ← double-click: python server.py + open browser
└── README.md          ← "how to use" in plain words (no dev jargon)
```

The app **reuses the BDF engine** (scaffold-agent.ps1 + the builders) and the
BDF philosophy: providers are user-owned data files (`providers.json` next to
the app), the app writes them, the user never touches JSON.

---

## UI/UX SPEC (user requirement: SIMPLE + CLEAN + COOL ANIMATIONS)

The user said: "I want the app to be very simple and clean, with cool
animations and all. First create the app with all the GUI features; colors and
different animation styles come later per my direction."

So: build the FULL feature set NOW with a tasteful default look. Do NOT wait
for color/animation direction — ship a polished default, and the user will
tweak colors/animations afterward.

### Design language (default v1)

- **Dark theme** (near-black background `#0d1117`-style, subtle borders).
- **One accent color** for actions (e.g. indigo/violet `#6366f1` or teal).
- **Big friendly cards** for providers — no tables, no jargon.
- **Status dots**: green = connected, red = error, amber = testing, gray = idle.
- **Large click targets** — the user might use a touchpad, not a terminal.
- **Rounded corners** (12-16px), soft shadows, generous spacing.
- **System font stack** (Segoe UI, Inter, system-ui) — no webfont downloads
  (local-first, offline-friendly).
- **Plain words everywhere**: "Connect", "Switch to this", "Build my config",
  "Looks good!" — never "POST /api/switch" or "activeProviders".

### Cool animations (default v1 — tasteful, not gimmicky)

Implement these with CSS only (no animation library — keep it one file, zero
deps):

1. **Page load**: fade-in + subtle slide-up for each screen section
   (`@keyframes fadeUp`, staggered via `animation-delay`).
2. **Provider switch**: when a provider becomes ACTIVE, animate a glowing ring /
   pulse on its card + smooth background transition on the dashboard.
3. **Status dot**: soft breathing/pulse while testing, steady glow when green.
4. **Button hover**: gentle lift (translateY(-2px)) + shadow deepen + accent
   glow.
5. **Card hover**: border brightens, slight scale (1.01-1.02).
6. **Wizard steps**: animated step transitions (slide left/right between
   steps), progress bar that fills smoothly.
7. **Toast notifications**: slide in from the right, fade out — "Connected ✓",
   "Builder generated ✓", "Switched to OmniRoute".
8. **Loading states**: spinner or shimmer on buttons while /api/test or
   /api/build runs.
9. **Empty state**: a friendly illustrated-empty message ("No providers yet —
   add your first one") with a subtle bounce on the CTA.
10. **Background**: optional subtle animated gradient or soft floating blobs
    (very low opacity, `prefers-reduced-motion` respected).

### Accessibility / polish

- Respect `prefers-reduced-motion` (disable heavy animations for those users).
- All animations are fast (150-400ms), never blocking.
- Keyboard accessible (Tab order, Enter works on buttons).

### Screens recap (all in one HTML, shown/hidden by JS)

| Screen | Key elements |
|--------|--------------|
| Setup Wizard (first run) | Step 1: agent location (auto-detect or folder picker) → Step 2: "Scan" with spinner → Step 3: found sections as cards → Step 4: "Generate my builder" big button with success animation |
| Dashboard | Active provider hero card (big, glowing), other providers as switchable cards, status dots, "Build my config" button |
| Providers | Add form (name, base URL, key with show/hide toggle, preset dropdown), list of saved providers, edit/delete, "Test" button per card |
| Build | "Build my config" → terminal-style output panel (colored, scrollable) |
| Chat (v1.1) | simple chat box |
| Advanced | raw JSON + generated .ps1 viewers (hidden by default, toggle in footer) |

---

## Rules the App MUST follow (from the framework)

1. **No-Secrets Rule (ULTIMATE)**: the app's own code/templates/examples never
   contain literal API keys. User keys live only in the user's local
   `providers.json` (never committed, never in system artifacts).
2. **Backup-first**: before rewriting `providers.json`, back it up
   (`providers.backup.json`).
3. **The app writes provider data; the user never edits JSON.**
4. **Local-first**: everything runs on `127.0.0.1`; nothing leaves the machine
   except the user's own requests to their chosen provider.
5. **README Synchronization Rule**: any user-visible feature → update the app
   README in the same change.
6. **Autonomy rule (THE core)**: the app does the BDF's work itself — the user
   never needs an AI agent to set anything up. If a step in the app requires
   the AI, the app is WRONG. Fix it.

---

## Build Order (next session)

**WHO BUILDS WHAT:**
- **Frontend (`docs/app/gui.html`)** → **Qwen 3.8 Max** in another window, from
  `AI/BDF_GUI_APP_FRONTEND_SPEC.md` (self-contained spec: design, animations,
  screens, full API contract).
- **Backend (`docs/app/server.py`, `start.bat`, `README.md`)** → this agent
  (OpenCode), to the same API contract. The two meet in the middle at the API.

1. `docs/app/server.py` — FastAPI app implementing THE API CONTRACT in
   `AI/BDF_GUI_APP_FRONTEND_SPEC.md`:
   - `GET /` → serve `gui.html`
   - `GET /api/status`, `POST /api/discover`, `POST /api/scan`
   - `GET/POST /api/providers`, `PUT/DELETE /api/providers/<id>`
   - `POST /api/test`, `POST /api/switch`
   - `POST /api/scaffold` → **run the real BDF engine**:
     calls `scaffold-agent.ps1 -Agent <agent> -NonInteractive` (profiles +
     builder script generation) and returns the result for the GUI
   - `POST /api/build` → **run the generated builder**:
     calls `build-<agent>.ps1 -Profile coding -NonInteractive`
   - `POST /v1/*` → tiny OpenAI-compatible proxy that forwards to the active provider
   - API keys NEVER returned by GET (masked); backups before every write
2. `docs/app/gui.html` — **BUILT BY QWEN 3.8 MAX** (parallel window, from
   `AI/BDF_GUI_APP_FRONTEND_SPEC.md`). This agent does NOT build the frontend —
   it implements the backend to the contract and tests against the real
   `gui.html` once Qwen 3.8 Max delivers it.
3. `docs/app/start.bat` — `python server.py` + auto-open browser at
   `http://127.0.0.1:9090`.
4. `docs/app/README.md` — plain-language instructions with screenshots.
5. Smoke test (THE SUCCESS TEST): a non-developer follows the wizard alone →
   app scans, generates build-<agent>.ps1, runs the build, switches provider,
   chats. No AI agent involved anywhere.
6. Update repo docs: `FOLDER_STRUCTURE.md`, `PROJECT_STATE.md`, `README.md`
   (README Sync Rule!), `ROADMAP.md` (new Phase 14 — GUI App), session log.

---

## Launch Ceremony (AFTER the app works)

Per the user: after building the app, we do the **launch ceremony** and launch
it for the public. Not now — after the app is built and tested.

---

## Research References (validated 2026-08-08)

These prove the pattern and give design ideas:

- **API-Switch** (github.com/DuanZPeng/API-Switch) — Tauri desktop, one local
  endpoint `127.0.0.1:9090`, channel switching, failover. Our closest cousin.
- **Relay Switch** (relayswitch.dev) — local desktop gateway, web UI on
  `127.0.0.1:3456`, switch upstream services without editing tool configs.
- **Clipal** (github.com/lansespirit/Clipal) — beautiful local web UI,
  provider add/edit/enable/disable, hot reload, localhost-locked admin.
- **ai-switch** (github.com/keepmind9/ai-switch) — Go single binary + admin
  UI at `localhost:12345/ui`, protocol conversion.
- **LLamification** (github.com/magillos/LLamification) — python GUI to add
  provider (name, base URL, key), refresh models, start proxy.
- **Open WebUI + LiteLLM** — the full-stack heavyweight version (Docker,
  too heavy for a normal user — but proves the web-UI pattern).

Key lesson: **every successful tool = one local endpoint + a web UI + simple
provider CRUD.** None of them ask the user to edit JSON.

---

## Resume Prompt

```
Read C:\Users\loveb\.config\opencode\docs\AI\CONTINUE_BDF_GUI_APP.md
Read C:\Users\loveb\.config\opencode\docs\AI\BDF_GUI_APP_FRONTEND_SPEC.md  (API CONTRACT — implement it exactly)

Follow AGENT.md + _agent/SESSION_WORKFLOW.md.
ROLE: YOU build the BACKEND. The frontend (gui.html) is built by Qwen 3.8 Max in
another window from the FRONTEND_SPEC. You implement the backend to that
contract and do NOT create gui.html (use a placeholder page to smoke-test,
then drop in Qwen 3.8 Max's file when delivered).

THE CORE PRINCIPLE: the app performs EXACTLY like BDF but autonomously — the
user never needs an AI agent. The app itself scans, seeds profiles, GENERATES
the .ps1 builder scripts (by calling the real scaffold-agent.ps1 -Bootstrap
engine), and runs the build. A normal person follows the GUI wizard alone.

1. docs/app/server.py (FastAPI) implementing the FULL API CONTRACT from the FRONTEND_SPEC:
   - GET / (serve gui.html), GET /api/status, POST /api/discover, POST /api/scan
   - GET/POST /api/providers, PUT/DELETE /api/providers/<id>  (apiKey masked on GET, never returned)
   - POST /api/test (try /v1/models), POST /api/switch
   - POST /api/scaffold → scaffold-agent.ps1 -Agent <agent> -NonInteractive (generates profiles + builder scripts)
   - POST /api/build → build-<agent>.ps1 -Profile coding -NonInteractive
   - POST /v1/* → local OpenAI-compatible proxy on 127.0.0.1:9090 to the ACTIVE provider
   - backup providers.json before every write; presets OmniRoute/LiteLLM/CLI Proxy/Custom
2. docs/app/start.bat (python server.py + open browser at http://127.0.0.1:9090)
3. docs/app/README.md (plain-language, no dev jargon)
4. Smoke test the API with curl/Invoke-RestMethod (status, providers CRUD, test, switch,
   scaffold on the real opencode agent, build). If Qwen 3.8 Max's gui.html exists, test through it.
5. SUCCESS TEST: a non-developer follows the wizard alone → app generates
   build-<agent>.ps1, runs the build, switches provider — no AI agent involved.
6. Update FOLDER_STRUCTURE.md, PROJECT_STATE.md, README.md (README Sync Rule),
   ROADMAP.md (Phase 14), SESSION_LOG.md
Rules: No-Secrets Rule (keys only in user's providers.json, never in app code/examples),
backup providers.json before writes, local-first 127.0.0.1 only.
Do NOT start the launch ceremony — that happens after the app is built and user-approved.
```
