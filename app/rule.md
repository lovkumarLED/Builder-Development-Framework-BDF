---
theme:
  colors:
    startup-bg: "#0B0D12"
    workspace-bg: "#F8F4EE"
    surface: "#FFFDFC"
    surface-soft: "#F2ECE6"
    ink: "#1B191B"
    muted: "#746D70"
    border: "#DED7D2"
    border-hi: "#BDB3AD"
    coral: "#F16E5B"
    coral-hi: "#FF8A75"
    plum: "#6842AE"
    plum-deep: "#3E193B"
    green: "#3C9A63"
    red: "#D34F45"
    amber: "#C98928"
    radius: "16px"
    radius-sm: "12px"
    font: "Inter Tight, Segoe UI Variable, Segoe UI, sans-serif"
---

# AI Switcher — App Rules

> This file has two jobs:
> 1. The YAML front-matter above is the app's **theme** — the app reads it at
>    serve time and applies it to the interface. Edit a color, save, refresh
>    the browser — the app updates.
> 2. The sections below are the **rulebook** for humans and AI agents working
>    on this app — read them before changing anything.

## Hybrid Studio design rules

- Startup and onboarding use the dark cinematic surface. Operational pages
  use the warm-cloud workspace; this is the approved hybrid exception to the
  previous dark-only direction.
- The Counterphase symbol is the only brand mark. It contains no letters and
  replaces all flame/shield imagery.
- Coral identifies the primary action and active provider. Plum supports
  selection and data hierarchy. Green / red / amber remain status-only.
- Use locally bundled, OFL-licensed Inter Tight with Segoe UI fallbacks. Never
  load a font, script, or visual asset from a CDN.
- Provider cards represent software routes, not payment cards. Selecting a
  card never activates it; only the explicit "Switch provider" action does.
- Large click targets (at least 44px), visible 2px focus, semantic landmarks,
  focus-trapped dialogs, forced-colors support, and responsive layouts from
  wide desktop through narrow Windows windows are required.
- Motion is purposeful: page transitions, a directional provider deck, and
  the bounded Counterphase click burst. No perpetual particles or embers.
- `prefers-reduced-motion` disables pointer tracking, bubbles, flips, and
  chart entrance animation.

## Feature rules

- The app must let a normal person, alone: discover their coding agent, scan
  it, generate their builder scripts, add providers, test connections, switch
  the active provider, and build �?" WITHOUT an AI agent.
- The app must never: phone home, require an account, or send anything
  anywhere except the user's own requests to the provider they chose
  (local-first, 127.0.0.1).
- Reasoning formats: every provider carries a `reasoningFormat`
  (opencode | openai | claude | gemini | none) that decides the valid thinking
  levels and the variant JSON the app writes. Presets pre-pick it (CLI Proxy /
  OpenAI → openai, Google → gemini); users can change it. Levels invalid for
  the format are never written (e.g. `max` is NOT written for `openai` — GPT-5.x
  rejects it). The format lives in the provider file, never in the models file.
- Top-level navigation is Overview, Providers, Activity, Integrations, and
  Settings. Plugins and MCP server configurations live in Integrations.
- Activity stores allowlisted local proxy metadata only. Prompts, responses,
  keys, authorization headers, and raw bodies are never stored. Redaction is
  mandatory. Empty activity states must never invent traffic.
- Plugins are identifiers only; never claim installed, running, version, or
  health state. MCP entries are configurations only; display "Configured" and
  declared type, never connectivity or discovered tools. Expert JSON is an
  explicit disclosure inside the guided MCP flow.
- Only OpenCode and Kilo are shown as verified setup targets.

## Architecture rules

- Modular backend: `app/` package, one responsibility per module.
- BDF-exact data model: providers live in the agent's own `providers/<id>.json`
  files (the builder's source); the active provider lives in the agent's
  `profiles/coding/settings.json` (`activeProviders`). The app reads and
  writes those real files — it never keeps a private copy of provider data.
- No-Secrets rule: API keys live ONLY in the user's own provider files — never
  in code, logs, examples, or API responses.
- Backup-first: every provider/settings/models/plugins file is backed up
  (agent `backup/` folder) before the app rewrites it.
- The app manages model files (`<provider>-models.json`) and plugins
  (`plugins.json`) from the GUI — the user never edits JSON by hand; every
  write preserves unknown content and is backup-first.
- Local-first: the server binds 127.0.0.1 only.
- Self-contained engine: the app ships its own generator + builders + testers
  + schemas in `app/engine/` and NEVER depends on scripts outside the repo.
  A downloaded copy must be able to generate a working builder for any
  registered agent (opencode -> V2.7 builder, kilo -> K1 adapter) with zero
  setup. `BDF_SCRIPTS_DIR` is an escape hatch only, never a requirement.
- The builders generate `opencode.json` (OpenCode) / `kilo.json` (Kilo). Never
  create a `.jsonc` next to the built config — it shadows it and the built
  config silently disappears from the agent's model list.

## Rules for AI agents

- Read this file BEFORE changing the app.
- Every user-visible change must be reflected here and in the app README in
  the same change.
- After fixing a bug or issue, log it in `BUGFIXES.md` in the SAME change —
  what broke, why it broke, and how it was fixed, following the template at
  the top of that file. A fix is not done until its entry is written.
