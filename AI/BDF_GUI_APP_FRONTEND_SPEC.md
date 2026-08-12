# BDF GUI APP — FRONTEND SPEC (model-agnostic — works with Qwen 3.8 Max, Kimi, Claude, or any coding model)

> Build the ENTIRE frontend from this file. You do NOT need any other file.
> The backend already exists (or will exist) and exposes the API contract below.
> Your deliverable: ONE file — `gui.html` — complete, polished, working.

---

## What you are building

A **simple, clean, dark-themed web GUI** ("Switcher") that lets a normal,
non-developer person:

1. Run a first-time **Setup Wizard** (find their coding agent → scan → generate builder).
2. Add AI providers (OmniRoute, LiteLLM, CLI Proxy presets or custom) with name, base URL, and API key.
3. **Test** each provider connection.
4. **Switch** which provider is ACTIVE with one click.
5. **Build** their configuration.
6. (Later) chat with the active provider.

The whole UI is **one HTML file** — no build tools, no frameworks, no CDN
dependencies. Vanilla HTML + CSS + JavaScript only. It must work offline by
double-clicking (a local server serves it at `http://127.0.0.1:9090`).

---

## Visual style — SIMPLE, CLEAN, COOL ANIMATIONS

### Design language

- **Dark theme**: background near-black (e.g. `#0d1117`), cards slightly lighter (e.g. `#161b22`), subtle borders (`#30363d`).
- **One accent color**: indigo/violet (e.g. `#6366f1`) — used for primary buttons, active states, focus rings.
- **Success green** `#3fb950`, **error red** `#f85149`, **amber** `#d29922` for status.
- **Big friendly cards** for providers — no tables, no jargon, no raw JSON visible.
- **Large click targets** (buttons min ~44px tall), rounded corners (12–16px), soft shadows, generous spacing.
- **System font stack**: `-apple-system, "Segoe UI", Inter, Roboto, system-ui, sans-serif`.
- **Plain words everywhere**: "Connect", "Switch to this", "Build my config", "Looks good!" — NEVER show endpoint names, JSON keys, or technical terms to the user.
- Fully responsive (works on small windows and tablets).

### Cool animations (CSS-only, tasteful, 150–400ms)

1. **Page load**: fade-in + subtle slide-up for sections (`@keyframes fadeUp`, staggered `animation-delay`).
2. **Active provider card**: glowing ring + pulse animation; dashboard background subtly transitions.
3. **Status dots**: soft breathing/pulse while testing, steady glow when green.
4. **Buttons**: hover lift (`translateY(-2px)`) + deeper shadow + accent glow.
5. **Cards**: hover border brightens, slight scale (1.01–1.02).
6. **Wizard steps**: animated slide between steps (left/right), progress bar fills smoothly.
7. **Toasts**: slide in from the right, auto-fade — "Connected ✓", "Builder generated ✓", "Switched to OmniRoute".
8. **Loading states**: spinner (or shimmer) on buttons while requests run.
9. **Empty state**: friendly message ("No providers yet — add your first one") with a subtle bounce on the CTA.
10. **Background**: very subtle animated gradient or soft floating blobs (low opacity), respecting `prefers-reduced-motion`.
11. Respect `prefers-reduced-motion` — disable heavy animations for those users.

---

## Screens (all in the one file, shown/hidden by JS)

### 1. Setup Wizard (first-run)

Shown when `/api/status` says the agent is not set up yet.

- **Step 1 — Welcome**: app name, tagline, big "Let's get started" button.
- **Step 2 — Agent location**: "Find my agent automatically" (calls `POST /api/discover`) OR a text input for a config folder path (calls `POST /api/discover` with `{"path": "..."}`).
- **Step 3 — Scanning**: spinner + animated status lines ("Looking at your config...", "Found your MCP servers ✓", "Found your plugins ✓") — calls `POST /api/scan`.
- **Step 4 — Found stuff**: friendly cards showing what was found (agents, MCP count, plugins count). Big button: **"Generate my builder"** → calls `POST /api/scaffold` → success animation + toast "Builder generated ✓".
- **Step 5 — Done**: "All set! Now add a provider." → goes to Dashboard.

### 2. Dashboard (Home)

- **Hero card**: the ACTIVE provider — big name, glowing ring, green status dot, "Active" badge, big **"Switch away"** hint (or if none active: "No active provider").
- **Provider cards grid**: every saved provider as a card — name, base URL (short), status dot (green/red/amber/gray), buttons: **"Switch to this"**, **"Test"**, edit (✎), delete (🗑 with confirm).
- Top bar: app name, "Add provider" button, "Build my config" button.
- **"Build my config"** → calls `POST /api/build` → opens a Build panel (see below).

### 3. Add / Edit Provider (modal)

Fields:
- **Preset dropdown**: OmniRoute / LiteLLM / CLI Proxy / Custom.
- **Name** (text).
- **Base URL** (text, pre-filled from preset).
- **API key** (password field with show/hide 👁 toggle).
- **Test connection** button (calls `POST /api/test`) → live status result in the modal.
- **Save** (calls `POST /api/providers` — PUT for edit).
- Validation: name + base URL required; friendly inline error messages.

### 4. Build panel

- **"Build my config"** button → calls `POST /api/build`.
- **Terminal-style output panel**: dark console look, colored lines (green success, amber warnings, red errors), auto-scrolling, monospace font.
- Success: big green check + toast "Build succeeded ✓".
- Error: red banner + "Try again" button.

### 5. Advanced (hidden, footer toggle)

- A small footer link "Advanced" toggles a panel showing the raw `providers.json` and the generated `.ps1` script names. Read-only. For developers only.

---

## API CONTRACT (the backend you will call)

Base URL: `http://127.0.0.1:9090`. All responses are JSON. The frontend MUST
handle errors gracefully (network fail, 4xx/5xx) with friendly messages.

| Method | Path | Body | Returns |
|--------|------|------|---------|
| GET | `/api/status` | — | `{"ready": bool, "agent": str|null, "hasBuilder": bool}` |
| POST | `/api/discover` | `{}` or `{"path": "C:\\..."}` | `{"agents": [{"name": "...", "dir": "...", "main": "..."}], "chosen": {...}}` |
| POST | `/api/scan` | `{"agent": "opencode", "dir": "C:\\..."}` | `{"agent": "...", "mcps": [...], "plugins": [...], "profiles": [...]}` |
| POST | `/api/scaffold` | `{"agent": "...", "dir": "..."}` | `{"ok": true, "generated": ["build-<agent>.ps1", ...], "message": "..."}` |
| GET | `/api/providers` | — | `{"providers": [{"id": "...", "name": "...", "baseUrl": "...", "active": bool}], "activeProvider": "..."}` |
| POST | `/api/providers` | `{"name": "...", "baseUrl": "...", "apiKey": "..."}` | created provider object |
| PUT | `/api/providers/<id>` | same as POST | updated provider object |
| DELETE | `/api/providers/<id>` | — | `{"ok": true}` |
| POST | `/api/test` | `{"id": "..."}` or `{"baseUrl": "...", "apiKey": "..."}` | `{"ok": bool, "message": "...", "latencyMs": int}` |
| POST | `/api/switch` | `{"id": "..."}` | `{"ok": true, "activeProvider": "..."}` |
| POST | `/api/build` | `{"profile": "coding"}` | `{"ok": bool, "output": "..."}` |
| POST | `/api/chat` | `{"message": "...", "model": "..."}` | SSE stream or `{"reply": "..."}` (v1.1 — optional) |

**Notes for you:**
- `apiKey` is never returned by GET endpoints (masked as `"••••••••"` or omitted). The frontend never displays it back.
- Presets: OmniRoute → `http://localhost:20128/v1`, LiteLLM → `http://localhost:4000/v1`, CLI Proxy → `http://localhost:xxxxx/v1` (let user fill port), Custom → empty.
- The backend owns `providers.json` storage + backups. You only talk JSON.
- If `/api/build` output is large, the backend may return it in one `output` string — render it in the terminal panel.

---

## File layout (your deliverable)

```
docs/app/gui.html   ← THE ONLY FILE YOU CREATE
```

Style and behavior should be **self-contained inside gui.html** (inline `<style>`
and `<script>`). No external files, no CDN.

---

## Quality checklist (before you say done)

- [ ] Dark theme, single accent color, consistent spacing — looks clean and modern.
- [ ] All 10 animations present, tasteful, `prefers-reduced-motion` respected.
- [ ] Setup Wizard flows through discover → scan → scaffold with spinners + toasts.
- [ ] Dashboard: active hero card glowing, provider cards with status dots, switch/test/edit/delete all work.
- [ ] Add/Edit modal with presets, show/hide key, inline validation, test-connection live result.
- [ ] Build panel with colored terminal output and success/error states.
- [ ] Advanced toggle shows raw JSON + script names.
- [ ] All API calls use the contract above; errors show friendly messages, never raw JSON.
- [ ] No literal API keys anywhere in the code (the key only ever travels in a request body to the backend).
- [ ] Responsive, keyboard-accessible, large click targets.
- [ ] It works served from `http://127.0.0.1:9090` (relative fetch paths — no hardcoded host except the base URL).

---

## Handoff

When finished, tell the user:

1. `docs/app/gui.html` is complete and where to put it.
2. Any assumptions you made about the API (fields you expected that are not in the contract).
3. Screenshots or a description of the visual design.

Do NOT create any other files. Do NOT touch Python, PowerShell, or the backend.
The backend is built by another agent in parallel.
