---
theme:
  colors:
    bg: "#0A0D16"
    card: "#111527"
    border: "#232A3D"
    border-hi: "#35405C"
    text: "#E8EEF9"
    muted: "#8B96B0"
    accent: "#00C8FF"
    accent-hi: "#4CDEFF"
    green: "#3FB950"
    red: "#FF3B30"
    amber: "#FF9702"
  radius: "14px"
  radius-sm: "10px"
---

# AI Switcher — App Rules

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
- The builders generate `opencode.json` (OpenCode) / `kilo.json` (Kilo). Never
  create a `.jsonc` next to the built config — it shadows it and the built
  config silently disappears from the agent's model list.

## Rules for AI agents

- Read this file BEFORE changing the app.
- Every user-visible change must be reflected here and in the app README in
  the same change.
