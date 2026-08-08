# AI Switcher

A small app that lives on your computer and lets you **switch between AI
servers (providers) with one click** — no technical knowledge needed.

Your AI tool (for example OpenCode, Cursor, or anything that speaks the
"OpenAI way") points at this app once, and the app forwards everything to
whichever provider you pick. Switching providers = one click in the app.

---

## What you need

- **Windows** (10 or 11)
- **Python** — install it from <https://www.python.org/downloads/>
  (during installation, tick **"Add python.exe to PATH"**)

That's it. No other setup, no terminal commands.

---

## How to start

1. Open the `app` folder.
2. Double-click **`start.bat`**.
3. Your browser opens the app automatically.

A small black window stays open — that's the app running. **Close it to stop
the app** (or just leave it open while you work).

> If a browser tab doesn't open, go to `http://127.0.0.1:9090` yourself.

---

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

---

## First-time setup (the wizard)

The first time you open the app, it walks you through 5 easy steps:

1. **Welcome** — click "Let's get started".
2. **Your coding agent** — click "Find my agent automatically". The app looks
   for the coding agents on your computer (OpenCode, Kilo, Aider, Goose, ...).
   Found one? Great. (Or type the folder path yourself, e.g.
   `C:\Users\YourName\.config\opencode`.)
3. **Scanning** — the app reads your agent's configuration **by itself**.
   Nothing is changed, it only looks.
4. **What it found** — the app shows cards: your MCP servers, your plugins,
   your profiles. Click **"Generate my builder"**.
5. **Done** — the app has created your profiles and your personal builder
   scripts. Now add a provider.

---

## Agents (which coding agent the app manages)

The **Agents card** sits at the top of the home screen:

- It shows every agent the app knows about — name, config folder, and who's
  **Active** (the one being managed right now).
- **Add agent**: type a name + the config folder (e.g.
  `C:\Users\YourName\.config\opencode`) → the app can manage it too. You can
  have kilo AND opencode (and more) registered at once.
- **Switch to this**: the whole app — providers, models, plugins, MCP, build —
  instantly starts managing the chosen agent. Nothing is mixed up between
  agents; each one keeps its own config.
- ✕ removes an agent from the list (never deletes its files).

After the first-time wizard, your agent is registered automatically.

---

## Adding a provider

A *provider* is an AI server that speaks the OpenAI way. Common ones:

| Preset          | Example address                  |
|-----------------|----------------------------------|
| OmniRoute       | `http://localhost:20128/v1`      |
| LiteLLM         | `http://localhost:4000/v1`       |
| CLI Proxy       | `http://localhost:PORT/v1`       |
| Custom          | any address you like             |

To add one:

1. Click **"Add provider"**.
2. Pick a preset (or Custom).
3. Give it a **name** (anything, e.g. "OmniRoute").
4. Check the address.
5. Pick the **SDK type** — how your server talks. "OpenAI-compatible (most
   servers)" fits OmniRoute, LiteLLM, CLI proxies, TokenRouter, and almost any
   local gateway. Choose OpenAI, OpenRouter, Claude (Anthropic), Gemini
   (Google), DeepSeek, Groq, and others for those APIs — or "Other…" to type
   any exact package name.
6. Paste the **API key** (if it needs one) — the little eye 👁 hides/shows it.
7. (Optional) Add its **models** — each with a thinking level.
8. Click **"Test connection"** — green ✓ means it works.
9. Click **Save** — the provider is added **and switched on** automatically, so the next build includes it. (Switch to another one anytime with one click.)

> When you save a provider, the app **writes it into your agent's own
> `providers/` folder** (e.g. `providers\omniroute.json`) — the same place your
> agent's builder reads from. Your keys are only ever stored in your own
> provider files. They never leave your computer, and the app never shows them
> back to you (you can only add a new one, never read the old one).
>
> Existing provider files (created by you earlier, or by the app) show up
> automatically — the app never overwrites anything without making a backup
> first (`backup\` folder in your agent's config).
>
> **Models:** add each model name with its thinking level (default / minimal /
> high / max) right in the provider screen — the app writes your
> `profiles\coding\<provider>-models.json` for you, exactly like the builder
> expects. No hand-editing JSON.
>
> **Plugins:** the app has a Plugins card on the home screen — type a plugin
> id and click Add; the app writes your `profiles\coding\plugins.json`.
> Remove is one click (backup kept first).
>
> **MCP servers:** an MCP card next to Plugins — your agent's MCP servers with
> their type, each removable in one click. Add a new one with a name + its
> config (JSON — e.g. `{"type": "local", "command": ["npx", "-y", "@example/mcp"]}`),
> validated before it's written to `profiles\coding\mcp.json` (backup-first).
>
> **Models card:** the home screen also has a Models card — pick a provider
> and its models load as rows (model id, display name, thinking chips).
> Remove a dead model, add a new one (e.g. when a provider swaps models),
> click **Save models** — the app writes
> `profiles\coding\<provider>-models.json` for you, backup-first. No JSON
> editing ever.

---

## Switching providers

On the home screen you see all your providers as cards, and the big glowing
hero shows **every active provider** — all of them 🔥 Active, side by side.

- The **first** one in the list is the primary — the one your tool talks to
  through `127.0.0.1:9090` (the note under the hero says so).
- Click **"Switch to this"** on any other card — it moves to the front and
  becomes the primary; **every active provider is still merged into the build**.
- **Test** re-checks a provider's connection (green = working, red = not
  reachable, gray = never tested).

---

## Building your configuration

Your AI agent works best with a *built* configuration (profiles + providers
merged into its main config file).

- **"Generate my builder"** (in the wizard) creates your personal builder
  scripts — exactly like the professional tool would, but done by the app.
- **"Build my config"** (home screen) runs the build for you. You see a
  terminal-style panel with colored lines while it works.
  - Green lines = done ✓
  - Amber lines = warnings
  - Red lines = problems (the app shows a "Try again" button)

The build **backs up your old config first**, so nothing is ever lost.

---

## Chatting

Anything that can talk to `http://127.0.0.1:9090/v1` in the OpenAI way can
talk through this app. Point your tool at:

```
http://127.0.0.1:9090/v1
```

and it will reach whichever provider is active — switching is still one click
in the app.

---

## Where your data lives

Everything stays inside the `app` folder (or next to your agent):

| File | What it is |
|------|------------|
| `state.json` | which agent is set up, where it lives |
| `<agent>\providers\` | your providers — the app writes them here (backup-first), exactly where your agent's builder reads them |
| `<agent>\profiles\coding\<provider>-models.json` | your models (with thinking levels) — the app writes them when you add models |
| `<agent>\profiles\coding\plugins.json` | your plugins — the app writes them from the Plugins card |
| `<agent>\profiles\coding\mcp.json` | your MCP servers — the app writes them from the MCP card |
| `<agent>\profiles\coding\settings.json` | which provider is active (`activeProviders`) — the app updates it when you switch |
| `<agent>\backup\` | automatic backups of everything the app changes |
| `profiles\` | your agent's profiles (`coding`, `experimental`, `minimal`) |
| `<agent>\scripts\build-<agent>.ps1` etc. | your generated builder scripts |
| `env\` | the app's private Python environment (created on first run — safe to delete, recreated next launch) |
| `rule.md` | the app's look (theme colors) + the rulebook for AI agents |

To move the app, copy the whole folder. Your providers live with your agent —
copy your agent's config folder too (or re-add your providers in the app).

---

## How to change the look

Everything about the look lives in one file: `rule.md` (next to this README).

- The top part of `rule.md` is the **theme** — colors and corner rounding.
  Edit a color (e.g. change `accent` to a color you like), save the file, and
  refresh the browser. The app applies it immediately.
- The bottom part of `rule.md` is the **rulebook** — the design and feature
  rules the app follows. AI agents working on this app read it before making
  changes, and every change keeps it in sync.

If you mess up `rule.md` (bad color, broken file), the app just keeps its
built-in look and shows a warning in the black window — nothing breaks.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Double-clicking `start.bat` does nothing | Python is not installed, or "Add python.exe to PATH" wasn't ticked. Install/reinstall Python. |
| "The server is running but the browser says it can't connect" | Check the small black window — it should say "Application startup complete". If it shows an error (e.g. port already in use), close other apps and retry. |
| A provider shows red on Test | That server isn't running right now. Start it, or check the address. |
| "No active provider" when chatting | Add a provider, then click "Switch to this" on it. |

---

## Privacy

- The app runs **only on your computer** (`127.0.0.1`) — nothing is sent
  anywhere except your own requests to the provider you chose.
- No account, no phone-home, no analytics.
- Keys never appear in the app's own files, logs, or on screen (only in your
  `providers.json`).
