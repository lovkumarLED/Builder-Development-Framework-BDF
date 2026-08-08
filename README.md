<p align="center">
  <img src="app/assets/logo.png" width="160" alt="AI Switcher logo">
</p>

# 🔥 Builder Development Framework (BDF) + AI Switcher App

> **Learn the engineering process once. Reuse it forever.**
>
> The reusable engineering platform that builds configuration builders for **any
> open-source coding agent** — currently powering **OpenCode** and **KiloCode** —
> plus a **GUI app that does the exact same work, automatically, for normal
> people** (no AI agent, no terminal, no JSON editing).

[![Builder](https://img.shields.io/badge/Builder-V2.7%20(JSON%20Schema)-2ea44f)](#builder-v27-json-schema-validation)
[![Framework](https://img.shields.io/badge/BDF-2.2.9-blue)](#builder-development-framework)
[![Tests](https://img.shields.io/badge/tests-17%2F13%2F31%2F30%2F28%20green-brightgreen)](#testing)
[![Release](https://img.shields.io/badge/release-2.5.0-orange)](#releases)
[![Status](https://img.shields.io/badge/status-13%2F15%20phases%20complete%20%2B%20V3%20in%20progress-blue)](#roadmap)

---

## 🚀 What Is This?

**BDF is a builder of builders.** It is both:

1. A **configuration builder** — a small automation system that turns messy,
   hard-to-maintain config files into clean, validated, reproducible outputs.
2. An **engineering framework** — the process, templates, adapters, and
   intelligence layer that make building such builders predictable and reusable.

And now it has **two worlds powered by the same engine**:

| World | Who it's for | How it works |
|-------|-------------|--------------|
| **1 — The MD framework** | developers + AI agents | `docs/bdf/*.md` define the process; an AI agent builds/maintains builders from them |
| **2 — The AI Switcher app** (`docs/app/`) | **normal people** | the app itself does the BDF work — scan → split → seed profiles → generate builder scripts → build — with a friendly GUI, no AI agent, no terminal |

> **The app performs exactly like BDF — but autonomously.** It calls the *real*
> engine (`scripts/scaffold-agent.ps1`) and the *real* generated builders. One
> engine, two surfaces. Everything the framework does by hand for developers,
> the app does by itself for everyone.

It currently powers **three real projects** built on the same reusable framework:

| Project | What it builds | Builder |
|---------|----------------|---------|
| **OpenCode Configuration Manager** | `opencode.json` from modular sources | `build-opencode-v2.7.ps1` |
| **KiloCode Configuration Manager** | `kilo.json` from modular sources | `build-kilo-v1.ps1` |
| **AI Switcher App** | the same work, in a GUI — scan, seed, generate builders, build, switch providers | `docs/app/` (FastAPI + `gui.html`) |

---

## 🔥 AI Switcher App — BDF for everyone

A normal person who just wants free AI should not have to: install things
manually, edit JSON, understand OmniRoute vs LiteLLM vs CLI-Proxy, or read a
README. The app is that: **open it, paste your provider details, click — and
switch between local AI servers with one click.**

What it does (the BDF job, GUI'd):

```
Open the app → follow the wizard alone
↓
App discovers / finds your coding agent (OpenCode, Kilo, Aider, Goose, ...)
↓
App SCANS the main JSON itself and shows friendly cards (MCP, plugins, profiles)
↓
App CREATES the profiles + GENERATES your builder scripts (real scaffold engine)
↓
Add providers (name + address + key + models with thinking levels) — SDK types included
↓
Test connection ✓ → Build my config (runs your real builder, backup-first)
↓
Switch providers = one click — your AI tool keeps working
```

### How to start the app (the server)

1. **Windows** (10/11) with **Python** installed
   (<https://www.python.org/downloads/> — tick **"Add python.exe to PATH"**).
2. Double-click **`docs\app\start.bat`**.
   - **First run (one-time, needs internet):** the app creates its own private
     Python environment (`env\`) and installs its packages — then opens.
   - **Second run onward:** instant.
3. Your browser opens **`http://127.0.0.1:9090`** automatically — the console
   shows the app's flame banner with the local addresses.

Manual start (same thing, in a terminal):

```powershell
cd docs\app
python server.py        # first run; creates env\ and installs packages
# or, after the first run:
env\Scripts\python server.py
```

**Close the window = the app stops.** It is not a background service — it runs
only while the window you opened is open, unlike your provider servers
(OmniRoute, LiteLLM, CLI proxy), which sit in the background all day. A browser
page cannot touch your files or run PowerShell by itself — that local helper
window is the app's hands, and it exists only while you use it.

### First run — the setup wizard

1. **Welcome** → click "Let's get started".
2. **Your coding agent** → "Find my agent automatically" (or type the folder
   path, e.g. `C:\Users\YourName\.config\kilo`).
3. **Scanning** → the app reads your main JSON by itself — it only looks.
4. **What it found** → cards with your MCP servers, plugins, profiles. If the
   agent is **already set up** (has a builder), the button reads
   **"Looks good — open it →"** — one click, straight in, no re-scaffolding.
   Otherwise click **"Generate my builder"** — the app creates the scripts.
5. **Done** → add a provider.

### Agents — manage several coding agents

The **Agents card** sits at the top of the home screen:

- Every registered agent is listed — name, config folder, and who's **Active**
  (the one being managed right now).
- **Add agent**: name + config folder (e.g. `C:\Users\YourName\.config\opencode`)
  — any location, no code changes per user. An already-set-up folder is
  detected and **loaded immediately** (no setup forced); a genuinely new agent
  goes to the wizard.
- **Switch to this**: the whole app — providers, models, plugins, MCP, build —
  instantly starts managing the chosen agent. Each agent keeps its own config.
- ✕ removes an agent (never deletes its files); the app re-routes instantly,
  no refresh needed.

### Providers

- Presets: **OmniRoute** (`http://localhost:20128/v1`), **LiteLLM**
  (`http://localhost:4000/v1`), **CLI Proxy**, or **Custom**.
- **SDK type** dropdown — how your server talks. "OpenAI-compatible (most
  servers)" fits OmniRoute, LiteLLM, CLI proxies, TokenRouter and any local
  gateway; the list also includes OpenAI, OpenRouter, Claude (Anthropic),
  Gemini (Google), Mistral, Grok (xAI), DeepSeek, Groq, Perplexity, Together
  AI, Cerebras, Azure OpenAI, Amazon Bedrock, Cohere — or "Other…" to type an
  exact package name. (All 15 verified against the npm registry.)
- **API key** with show/hide 👁 — the app never shows it back, ever.
- **Test connection** ✓ green = works (per-card and inside the modal).
- **Save** → the provider is added **and switched on automatically**, so the
  next build includes it. The app writes your agent's `providers\<name>.json`
  (backup-first) — the exact file your builder reads. No JSON editing.

### The active hero

Every provider in your `activeProviders` list glows **🔥 Active** — side by
side in the hero card. "Switch to this" moves one to the front (the first is
the one your tool talks to through `127.0.0.1:9090`); **every active provider
is merged into the build**, each with its own models.

### Models (with thinking levels)

In the provider screen (and in the **Models card** on the home screen), add
each model: **model id** + optional display name + **thinking chips** —
`default`, `minimal`, `high`, `max` (e.g. Kimi-K3 with all four). The app
writes your `profiles\coding\<provider>-models.json` with the exact
`variants` / `reasoningEffort` shape the builder expects.

> A provider **without any models is skipped by the build** (the builder's model
> guard) — the app warns you about this. Models that exist in your files load
> back into the editors, chips pre-toggled.

### Plugins & MCP servers

- **Plugins card** — add/remove plugin ids (e.g.
  `superpowers@git+https://github.com/obra/superpowers.git`); the app writes
  `profiles\coding\plugins.json`, deduped, backup-first.
- **MCP servers card** — your agent's MCP tools with their type (local/remote):
  add (name + config JSON, validated — bad JSON gets a friendly inline error)
  / remove; writes `profiles\coding\mcp.json`, backup-first.

### Switch & Build

- Your agent's `activeProviders` is a **list** — the build merges **every
  provider in it**, each with its own models.
- **"Build my config"** runs your **real builder** (`build-<agent>.ps1`,
  `build-kilo-v1.ps1`, ...) with your profile — terminal-style output,
  colored, backup-first, provenance stamped.

### The one endpoint (proxy)

Anything that speaks the OpenAI way can point at
`http://127.0.0.1:9090/v1` **once** — the app forwards to whichever provider is
primary, so **switching providers is one click forever**, no tool reconfiguration.

### Safety & privacy

- **Local-first:** everything runs on `127.0.0.1` — nothing leaves your machine
  except your own requests to the provider you chose. No account, no telemetry.
- **No-Secrets:** API keys live only in your own provider files; never in code,
  logs, or API responses.
- **Backup-first:** every file the app rewrites (providers, models, plugins,
  MCP, settings) is backed up to your agent's `backup\` folder first.
- **Model/plugin/MCP files you already have are preserved** — the app merges,
  never clobbers, and never deletes without a backup.
- **`env\` is private to this computer** and safe to delete — recreated on next
  launch. Your providers/settings/rule.md are never touched by it.

### Troubleshooting (quick)

| Problem | Fix |
|---------|-----|
| Double-clicking `start.bat` does nothing | Python not installed / "Add to PATH" unticked |
| Browser says it can't connect | the black window should say "Application startup complete"; port busy? close other apps |
| A provider shows red on Test | that server isn't running right now |
| A provider is missing from the build | it has no models (add at least one), or it isn't in `activeProviders` (the app keeps all added providers there) |
| Popup content is cut off | the popup scrolls — use the flame scrollbar inside it |
| The app acts weird / stale | close ALL "AI Switcher" windows and double-click `start.bat` once — two windows = two servers fighting over the port |

Full plain-language guide: **`docs/app/README.md`**.

---

## 🧭 Roadmap

**13 of 15 phases complete** toward **BDF V3** — the first stable public version
that generates builders for OpenCode, KiloCode, and any same-architecture
open-source coding agent. **Phase 13 (BDF V3) is still in progress — the best is
yet to come.**

| Phase | Status |
|-------|--------|
| Phase 1 — Foundation | ✅ |
| Phase 2 — Builder Improvements | ✅ |
| Phase 3 — Multiple Profiles | ✅ |
| Phase 4 — Additional Providers | ✅ |
| Phase 5 — Validation Framework | ✅ |
| Phase 6 — Automated Testing | ✅ |
| Phase 7 — Builder Refactoring | ✅ |
| Phase 8 — Documentation Expansion | ✅ |
| Phase 9 — Release Manager V1 | ✅ |
| Phase 10 — BDF V2.5 Framework Generalization | ✅ |
| Phase 10.5 — Active-Provider Selector Builder | ✅ |
| Phase 10.6 — JSON Schema Validation | ✅ |
| Phase 11 — Claude Code Builder V1 | ✅ resolved (dropped) |
| Phase 12 — KiloCode Builder V1 | ✅ |
| Phase 13 — BDF V3 Universal Builder Generator | 🔄 in progress |
| Phase 14 — GUI App (AI Switcher) | ✅ |
| Phase 15 — More Coding Agents | 🔜 planned (untested) |

**Phase 15 note:** OpenCode + KiloCode are verified end-to-end today. The app
and the universal scaffold are expected to work with **more open-source coding
agents** too — it has not been tested with others yet, so we will find out when
we try them.

The journey is tracked live in `_agent/JOURNEY_TO_V3.md`.

---

## 📚 Documentation Map

The docs are split into two layers. **Framework** (generic, reusable) and
**project** (OpenCode-specific) — plus the **app**.

### Project documents

| Document | Description |
|----------|-------------|
| `AGENT.md` | AI agent entry guide — read order, rules |
| `ARCHITECTURE.md` | Overall system architecture |
| `BUILDER_SPEC.md` | Builder implementation specification (F1–F7, P1–P2) |
| `DEVELOPER_GUIDE.md` | How to work on the project (human onboarding) |
| `PROVIDER_DEVELOPMENT_GUIDE.md` | Creating user-owned provider definitions + models |
| `PROFILE_CREATION_GUIDE.md` | Creating and editing profiles |
| `BUILDER_EXTENSION_GUIDE.md` | Extending the builder |
| `FOLDER_STRUCTURE.md` | Directory and file responsibilities |
| `JSON_SCHEMAS.md` | Configuration file schemas |
| `TESTING.md` | Testing procedures |
| `TROUBLESHOOTING.md` | Common issues and fixes |
| `ROADMAP.md` | Planned future improvements |
| `CHANGELOG.md` | Project version history |
| `PROJECT_STATE.md` | Living state snapshot |
| `CURRENT_RELEASE.md` | Current release quick reference (generated) |
| `ADAPTER.md` | Project-specific facts (the adapter) |
| `release_registry.json` | Machine-readable release history (hand-edited) |
| `app/` | The **AI Switcher** GUI app — self-contained (backend, GUI, launcher, its own plain-language README, `rule.md` theme + rulebook) |

### Framework documents (`bdf/`)

| Document | Description |
|----------|-------------|
| `FRAMEWORK.md` | The complete engineering process |
| `BLUEPRINT_ENGINE.md` | The intelligence layer |
| `PROJECT_ADAPTER.md` | Making the framework project-specific |
| `BUILDER_EVOLUTION.md` | Creating future builder versions |
| `BUILDER_PHASES.md` | Alpha → Beta → General Release quality gates |
| `FRAMEWORK_LIFECYCLE.md` | Master lifecycle reference |
| `AI_WORKFLOW.md` | The AI agent workflow |
| `VERSION.md` | Framework versioning |
| `NEW_PROJECT_GUIDE.md` | Onboarding a new project |
| `RELEASE_MANAGER.md` | The generic release process |
| `TESTING.md` | The generic test-harness pattern |
| `LESSONS_LEARNED.md` | Reusable engineering lessons |
| `templates/` | 19 reusable documentation templates |

### Session & planning (`_agent/`, `planning/`, `AI/`)

| Document | Description |
|----------|-------------|
| `_agent/SESSION_WORKFLOW.md` | Session start/end/log rules |
| `_agent/SESSION_LOG.md` | Session history |
| `_agent/JOURNEY_TO_V3.md` | Live position on the road to V3 |
| `planning/BDF_ROAD_TO_V3.md` | The vision and definition of V3 |
| `planning/DECISIONS.md` | Permanent architectural decisions |
| `AI/` | Build plans, checkpoints, and continuation files |

---

## 🧱 Builder Development Framework (World 1 — developers)

**BDF is a builder of builders.** The framework's ONE job, the same for ANY
open-source coding agent:

1. Discover the agent's config location.
2. Scan the agent's OWN main JSON (read-only, first).
3. Split it into sections: mcp / plugin / settings. (Providers are detected for
   guidance only.)
4. Seed the three profiles — `coding` (always the main) + `experimental` +
   `minimal` — each with `settings.json`, `mcp.json`, `plugins.json`.
5. Generate the builder scripts (`build-<agent>.ps1`, `test-<agent>.ps1`,
   `scaffold-<agent>.ps1`) via `scaffold-agent.ps1 -Bootstrap`.
6. Keep providers/models user-owned: the framework creates the `providers/`
   folder but NEVER writes provider/model files inside it — those are 100%
   the user's (the **app** writes them on the user's behalf, backup-first).

### The universal scaffold

`scripts/scaffold-agent.ps1` is the V3 UNIVERSAL core: an open-source agent
registry (opencode, kilo, aider, goose, codex-cli, ...), discovery, `-List`,
`-Bootstrap` per-agent builder generation. It scans the agent's own main JSON,
splits mcp/plugin sections, seeds the profiles, and never touches `.jsonc`
without consent. Closed-source agents are never touched.

### Current builders

| Builder | Agent | Tests |
|---------|-------|-------|
| `build-opencode-v2.7.ps1` | OpenCode | 31/31 |
| `build-kilo-v1.ps1` | KiloCode | 30/30 |

Both share the same pipeline: JSON Schema validation (F1), pre-flight
dependency check (F2), `-WhatIf` dry run (F3), backup retention (F4),
provenance sidecar (F5), `-Doctor` diagnostics (F6), merge diff summary (F7),
active-provider selection with `settings.json` persistence, and a per-provider
model merge (profile-level `<provider>-models.json` > provider-folder >
inline > drop-with-warning).

---

## 🧪 Testing

- OpenCode V2.7 harness: **31/31**
- OpenCode V2.5 harness: **13/13**
- OpenCode V2 harness: **17/17**
- KiloCode V1 harness: **30/30**
- App unit tests: **28/28** (`docs/app/tests`, `unittest`, stdlib-only)
- App E2E: full click-through battery on a real agent config (providers CRUD,
  models, plugins, MCP, build, proxy, agents) with snapshot backup + hash-verified
  restore (session 29)

---

## 📦 Releases

Current release: **2.5.0** (Builder V2.7, JSON Schema Validation). Full history
in `CHANGELOG.md` and `docs/release_registry.json` (regenerated by
`scripts/release-manager.ps1`).

---

- **Backup before you touch. Never write secrets. Copy verbatim.**

---

**Version:** 2.5.0
**Builder Version:** V2.7 (JSON Schema Validation)
**Framework Version:** 2.2.9
**Document Version:** 2.3

Documentation Status: Current Implementation
