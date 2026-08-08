# PROVIDER DEVELOPMENT GUIDE

> How to create and manage provider definitions — the user-owned files the
> framework never writes.

---

# Purpose

Providers are **100% user-owned**. The framework creates the `providers/`
folder (like the profile folders), but it NEVER writes provider or model files
inside it. This guide explains how to create them yourself.

---

# Audience

Anyone configuring a builder project for a new provider (OpenCode, KiloCode, or
any open-source coding agent).

---

# The Provider Contract

- The framework scans the agent's main JSON and detects the provider section
  (guidance only).
- You create `providers/<id>.json` yourself.
- Models can live:
  1. inline in the provider file (`models`),
  2. in `providers/<id>/models.json`,
  3. in `profiles/<profile>/<id>-models.json` (highest precedence).

---

# Creating a Provider File

## 1. Choose an ID

The provider id is the file name. Example: `omniroute` → `providers/omniroute.json`.

## 2. Create the file

Minimal shape:

```json
{
  "id": "omniroute",
  "provider": {
    "omniroute": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "OmniRoute",
      "apiKey": "{env:OMNIROUTE_API_KEY_OPENCODE}",
      "options": {
        "baseURL": "http://localhost:20128/v1"
      },
      "models": {}
    }
  }
}
```

## 3. Add models (optional)

Inline:

```json
"models": {
  "opencode-zen/deepseek-v4-flash-free": {
    "name": "DeepSeek V4 Flash (FREE VIA ZEN)"
  }
}
```

Or profile-level (highest precedence) — `profiles/<profile>/<id>-models.json`:

```json
{
  "models": {
    "opencode-zen/deepseek-v4-flash-free": {
      "name": "DeepSeek V4 Flash (FREE VIA ZEN)",
      "variants": {
        "high": { "reasoningEffort": "high" },
        "max": { "reasoningEffort": "max" }
      }
    }
  }
}
```

---

# API Keys — The No-Secrets Rule (ULTIMATE)

- Your provider files **may** contain literal API keys — they are your files
  and you protect them.
- The **system's own artifacts** (scripts, templates, docs, examples) NEVER
  contain literal keys — only `{env:VAR}` placeholders.
- The system **copies your content verbatim** (scan → copy → paste). It never
  invents, carries, or restores keys.

Recommended pattern (works everywhere, never leaks into system artifacts):

```json
"apiKey": "{env:OMNIROUTE_API_KEY_OPENCODE}"
```

The `{env:VAR}` placeholder is resolved from the environment at runtime.

---

# Precedence

Model-source precedence (highest first):

```
profiles/<profile>/<id>-models.json
providers/<id>/models.json
inline provider models
profiles/<profile>/models.json
```

---

# How the Builder Uses Providers

The builder (e.g. `build-opencode-v2.7.ps1`):

1. Discovers all `providers/*.json`.
2. Resolves active providers from `profiles/<profile>/settings.json` →
   `activeProviders`.
3. Loads each active provider + its models.
4. Merges them into the generated artifact.

If a provider has **no models source**, the builder drops it with a warning
(not considered active). If no active provider remains, the build aborts.

---

# Troubleshooting

| Symptom | Cause / Fix |
|---------|-------------|
| `No provider files found in <root>\providers` | No `providers/*.json` exists — create one. |
| `Provider 'x': models not found` | Add a models source (inline, folder, or profile-level). |
| `No active providers selected` | Every active provider was dropped (no models) or settings lists none. |
| Schema validation fails | Run `-Doctor` and check the schema message (`provider.schema.json`). |

---

**Document Version:** 1.0

**Status:** Active Provider Development Guide
