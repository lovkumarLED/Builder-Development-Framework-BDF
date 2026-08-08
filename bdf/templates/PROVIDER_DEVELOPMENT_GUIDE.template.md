# PROVIDER DEVELOPMENT GUIDE Template

> Template: creating user-owned provider definitions. Becomes `PROVIDER_DEVELOPMENT_GUIDE.md`.

---

# {{PROJECT_NAME}}

> How to create and manage provider definitions — the user-owned files the
> framework never writes.

---

# Purpose

Providers are **100% user-owned**. The framework creates the `providers/`
folder (like the profile folders), but it NEVER writes provider or model files
inside it. This guide explains how to create them yourself.

---

# The Provider Contract

- The framework scans the agent's main JSON and detects the provider section
  (guidance only).
- You create `{{PROVIDER_DIR}}/<id>.json` yourself.
- **The dual-key contract:** different agents read the API key from different
  fields — OpenCode reads `provider.<id>.apiKey`, Kilo reads
  `provider.<id>.options.apiKey`. Write the key in **both** places (see the
  example). If you write only one, the builder mirrors it automatically at
  merge time, so hand-written and app-written provider files produce
  identical output.
- Models can live:
  1. inline in the provider file (`models`),
  2. in `{{PROVIDER_DIR}}/<id>/models.json`,
  3. in `{{CONFIG_SOURCE_DIR}}/<profile>/<id>-models.json` (highest precedence).

---

# Creating a Provider File

## 1. Choose an ID

The provider id is the file name. Example: `<id>` → `{{PROVIDER_DIR}}/<id>.json`.

## 2. Create the file

```json
{
  "id": "<id>",
  "provider": {
    "<id>": {
      "npm": "<npm-package>",
      "name": "<Display Name>",
      "apiKey": "{env:<ID>_API_KEY}",
      "options": {
        "baseURL": "<https://api.provider.com/v1>",
        "apiKey": "{env:<ID>_API_KEY}"
      },
      "models": {}
    }
  }
}
```

## 3. Add models (optional)

Inline or profile-level (`{{CONFIG_SOURCE_DIR}}/<profile>/<id>-models.json`).

---

# API Keys — The No-Secrets Rule (ULTIMATE)

- Your provider files **may** contain literal API keys — they are your files
  and you protect them.
- The **system's own artifacts** (scripts, templates, docs, examples) NEVER
  contain literal keys — only `{env:VAR}` placeholders.
- The system **copies your content verbatim** (scan → copy → paste).

---

# Precedence

Model-source precedence (highest first):

```
{{CONFIG_SOURCE_DIR}}/<profile>/<id>-models.json
{{PROVIDER_DIR}}/<id>/models.json
inline provider models
{{CONFIG_SOURCE_DIR}}/<profile>/models.json
```

---

# Troubleshooting

| Symptom | Cause / Fix |
|---------|-------------|
| `No provider files found` | No `{{PROVIDER_DIR}}/*.json` exists — create one. |
| `Provider 'x': models not found` | Add a models source (inline, folder, or profile-level). |
| `No active providers selected` | Every active provider was dropped (no models) or settings lists none. |

---

**Document Version:** {{DOC_VERSION}}

**Status:** Active Provider Development Guide
