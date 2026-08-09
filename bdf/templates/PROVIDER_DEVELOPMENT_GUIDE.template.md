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

## 4. Reasoning formats (optional)

Different providers accept different reasoning settings. The provider file can
carry an optional `reasoningFormat` field; the builder passes it through, and
the app uses it to offer the right levels and write the right variant JSON.

| Format | Valid levels | Variant JSON per level |
|--------|--------------|------------------------|
| `opencode` (default) | `default`, `minimal`, `high`, `max` | `{ "reasoningEffort": "<level>" }` |
| `openai` | `none`, `low`, `medium`, `high`, `xhigh` | `{ "reasoningEffort": "<level>" }` |
| `claude` | `low`, `high`, `max` | `{ "thinking": { "type": "enabled", "budgetTokens": 8000 / 16000 / 32000 } }` |
| `gemini` | `minimal`, `low`, `medium`, `high` | `{ "thinkingConfig": { "thinkingBudget": 4096 / 8192 / 16384 / 32768 } }` |
| `none` | — | no variants written |

Claude-style variants (written for a `claude` format provider):

```json
{
  "models": {
    "claude-sonnet-4": {
      "name": "Claude Sonnet 4",
      "variants": {
        "low":  { "thinking": { "type": "enabled", "budgetTokens": 8000 } },
        "high": { "thinking": { "type": "enabled", "budgetTokens": 16000 } },
        "max":  { "thinking": { "type": "enabled", "budgetTokens": 32000 } }
      }
    }
  }
}
```

Gemini-style variants (written for a `gemini` format provider):

```json
{
  "models": {
    "gemini-3.6-flash": {
      "name": "Gemini 3.6 Flash",
      "variants": {
        "minimal": { "thinkingConfig": { "thinkingBudget": 4096 } },
        "medium":  { "thinkingConfig": { "thinkingBudget": 16384 } },
        "high":    { "thinkingConfig": { "thinkingBudget": 32768 } }
      }
    }
  }
}
```

An unknown or missing `reasoningFormat` is treated as `opencode`. Levels that
are not valid for the provider's format are dropped when the app writes the
models file (e.g. `max` is not valid for OpenAI GPT-5.x — the app refuses to
write it for `openai` format providers). Interactive builder runs ask the
developer for the format when it is missing or invalid levels are present,
persist it to the provider file (backup-first), and filter the generated
output the same way.

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
