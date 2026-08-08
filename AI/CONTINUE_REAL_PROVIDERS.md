# CONTINUE — Real Providers: fix TokenRouter 401 + make the app work with legitimate providers (session 30 plan)

> Resume file for the next session. Read this first, then execute.
> Root cause of the 401 is IDENTIFIED (research done in session 29) — this
> session implements + verifies the fix, then extends the app's provider story
> to real (non-local) providers.

---

## The problem

The user adds a legitimate provider (TokenRouter) through the app:

- The app's OWN proxy test works: `POST /v1/chat/completions` through the app →
  **HTTP 200** (kimi-k3 answered) — the key and the API are fine.
- But when **Kilo** makes the same request to
  `https://api.tokenrouter.com/v1/chat/completions`, it gets:
  `401 "Token not provided"` — **no token was sent at all**.
- OpenCode works fine with the identical setup.

## Research findings (session 29, web-verified)

### 1. TokenRouter auth (docs.tokenrouter.me / tokenrouter.com)

- OpenAI-compatible gateway. Auth = `Authorization: Bearer <key>` — exactly
  what the app's proxy sends (that's why the proxy test passes).
- The user's endpoint `https://api.tokenrouter.com/v1` is valid for their key.
- `401 "Token not provided"` = the request arrived WITHOUT an Authorization
  header → the CALLER (Kilo's runtime) didn't attach the key.

### 2. Where coding agents store provider keys — KiloCode (kilo.ai docs + GitHub)

Kilo has **TWO storage classes**:

| Class | File | What lives there |
|-------|------|------------------|
| Config (non-secret) | `~/.config/kilo/kilo.jsonc` | provider definitions, models, base URLs |
| **Auth (secrets)** | `~/.local/share/kilo/auth.json` (data dir, mode 0600) | credentials added via `kilo auth login` / `/connect` |

Key facts:

- **Custom providers put the API key in `provider.<id>.options.apiKey`** — NOT
  top-level `provider.<id>.apiKey`:

  ```json
  {
    "provider": {
      "openai-compatible": {
        "options": {
          "apiKey": "{env:MY_PROVIDER_API_KEY}",
          "baseURL": "https://api.my-provider.com/v1"
        }
      }
    }
  }
  ```

- `options.apiKey` supports literal values, `{env:VAR}`, and `{file:...}`.
- Keys entered via the UI/`/connect`/`kilo auth login` go into **auth.json**,
  which is why you can see a provider in Kilo without a plaintext key in the
  config.
- **OpenCode** (which works) reads the top-level `provider.<id>.apiKey`.

## Root cause (high confidence)

> The app writes the key as **top-level `provider.<id>.apiKey`** (mirroring the
> user's original omniroute.json shape). **OpenCode reads it there → works.
> Kilo's runtime reads `provider.<id>.options.apiKey` → finds nothing → sends
> no Authorization header → TokenRouter 401.**

The K1 builder emits `providers/<id>.json` content verbatim into kilo.json, so
the fix belongs in **how the app writes provider files**.

---

## The fix (design)

### 1. Dual key placement in `app/agentstore.py` `write_provider`

Write the key to **both** locations in the provider entry:

```json
{
  "provider": {
    "tokenrouter": {
      "name": "TokenRouter",
      "apiKey": "sk-...",              ← OpenCode reads this
      "options": {
        "baseURL": "https://api.tokenrouter.com/v1",
        "apiKey": "sk-..."             ← Kilo reads this (NEW)
      }
    }
  }
}
```

- `_provider_dict` keeps reading top-level `apiKey` (unchanged).
- Existing provider files without `options.apiKey`: the app adds it on the
  next write (edit/save) — or a one-time migration on read? Decide: **write
  both on every write_provider call**; existing files get it when edited. For
  the user's real fix, re-save tokenrouter via the API (or PUT) once.

### 2. Rebuild + verify the real scenario

1. Re-save the tokenrouter provider (adds `options.apiKey`).
2. Run `POST /api/build` (kilo) → verify built `kilo.json`'s tokenrouter
   entry now has `options.apiKey`.
3. Ask the user to test chat in Kilo (the real proof). If it STILL 401s,
   next suspect: Kilo requires the key in `auth.json` (data dir) instead —
   investigate `kilo auth list` / the auth.json format and decide whether the
   app should also write there (or invoke `/connect`-style flow).

### 3. Make the app's provider story "real providers" (user's ask)

The app was built to switch local proxies; the user wants legitimate providers
(TokenRouter, OpenRouter, ...) to work through it. Deliverables:

- The dual key placement above (the core fix).
- **SDK dropdown** already exists (15 packages) — real providers select their
  own (OpenRouter → `@openrouter/ai-sdk-provider`, etc.).
- **Test connection** already validates with the real key (GET /v1/models).
- Add a small **"Provider tips"** hint in the modal for real providers? (e.g.
  "Some agents read the key from options — the app writes both.") — optional.
- Verify OpenRouter-style providers end-to-end if the user has another real
  key available.

---

## Implementation steps (next session)

1. `app/agentstore.py`: `write_provider` writes `inner["apiKey"]` AND
   `inner.setdefault("options", {})["apiKey"]` (both = the same key value).
2. Unit test: write → file contains BOTH `apiKey` and `options.apiKey`;
   read still returns the key; update keeps both in sync.
3. Re-save the real tokenrouter provider file via the API (so `options.apiKey`
   lands) — snapshot kilo first (backup-first discipline).
4. Rebuild kilo via `/api/build`; inspect built kilo.json for `options.apiKey`.
5. User test in Kilo chat (the acceptance test).
6. If 401 persists → research `~/.local/share/kilo/auth.json` (data dir) and
   `/connect` flows; design auth.json integration.
7. Docs: app README (provider section: "the app writes your key where your
   agent reads it"), root README if needed.

## Verification checklist

- [ ] Unit tests green (31 + new dual-key tests)
- [ ] Built kilo.json tokenrouter entry contains `options.apiKey`
- [ ] User's Kilo chat with TokenRouter answers (no 401)
- [ ] OpenCode still works (regression)
- [ ] App proxy still works (regression)
- [ ] kilo snapshot restored / hash-verified after any destructive tests

## Out of scope

- Cursor integration (proprietary encrypted store — research only).
- Writing to Kilo's `auth.json` UNLESS the options.apiKey fix proves
  insufficient.
- The launch ceremony (still pending user approval).

---

## Resume prompt

```
Read C:\Users\loveb\.config\opencode\docs\AI\CONTINUE_REAL_PROVIDERS.md

Follow AGENT.md + _agent/SESSION_WORKFLOW.md.
ROLE: implement the real-provider fix.

1. The root cause is identified in the MD: the app writes provider keys as
   top-level provider.<id>.apiKey (OpenCode reads it there — works), but
   Kilo's runtime reads provider.<id>.options.apiKey — so Kilo sends no
   token and TokenRouter returns 401 "Token not provided".
2. Implement the fix per the MD: dual key placement in
   app/agentstore.py write_provider (apiKey + options.apiKey), unit tests,
   re-save the real tokenrouter provider, rebuild kilo, verify the built
   kilo.json carries options.apiKey.
3. The acceptance test: the user chats in Kilo with TokenRouter and gets
   an answer (no 401). If it still 401s, research
   ~/.local/share/kilo/auth.json + `kilo auth login` / `/connect` flows and
   design the auth.json integration.
4. Keep the discipline: snapshot kilo before writes, hash-verify after,
   No-Secrets, backup-first, update the app README + SESSION_LOG + JOURNEY.
```
