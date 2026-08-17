# PROFILE CREATION GUIDE Template

> Template: creating and editing profiles. Becomes `PROFILE_CREATION_GUIDE.md`.

---

# {{PROJECT_NAME}}

> How to create, edit, and understand profiles in a BDF builder project.

---

# Purpose

Profiles are the heart of the configuration system. Each profile is a folder
under `{{CONFIG_SOURCE_DIR}}/` that contributes settings, MCP servers, and
plugins to the generated artifact.

---

# The Default Profiles

The framework ALWAYS creates three profiles:

```
{{CONFIG_SOURCE_DIR}}/

coding/          ← the MAIN profile (always)
experimental/
minimal/
```

Each profile carries exactly four files:

```
{{CONFIG_SOURCE_DIR}}/<profile>/

settings.json
mcp.json
plugins.json
lsp.json
```

## coding — the main profile

- `settings.json` — `$schema` + `activeProviders` (framework-writable).
- `mcp.json` — seeded once from the agent's own main JSON; **user-owned after**.
- `plugins.json` — seeded once from the agent's own main JSON; **user-owned after**.
- `lsp.json` — seeded from the main config's `lsp` value; **user-owned after**.
  Disabled by default (`enabled: false`) until you turn it on.

## experimental / minimal

- `settings.json` — written by the framework.
- `mcp.json` / `plugins.json` — created EMPTY, never filled by the framework.
- `lsp.json` — created with the default `{ "lsp": true, "enabled": false }`.

---

# The File Contract

## settings.json

```json
{
  "$schema": "<schema-url>",
  "activeProviders": ["<provider-id>"]
}
```

## mcp.json

```json
{
  "mcp": {
    "server-name": {
      "type": "local",
      "command": ["npx", "-y", "some-mcp-server"]
    }
  }
}
```

## plugins.json

```json
{
  "plugin": ["some-plugin"]
}
```

## lsp.json

```json
{
  "lsp": true,
  "enabled": false
}
```

- `lsp` — either a plain on/off boolean or an object keyed by server name (each
  server may carry optional `command`, `extensions`, `disabled`, `env`,
  `initialization`). Copied verbatim into the generated config as the `lsp` key
  when enabled.
- `enabled` — the LSP master switch. **Disabled by default**; the user turns it
  on (the app's Integrations page toggle or the builder's interactive prompt).
- User-owned after creation. The framework never overwrites it.
- Builder behavior: `enabled: true` → generated config carries `"lsp": <value>`;
  `enabled: false` → generated config carries `"lsp": false`; no `lsp.json` → no
  `lsp` key. The interactive prompt asks "LSP servers: [1] enabled [2] disabled
  (Enter keeps current)" when not `-NonInteractive`; the app and
  `-NonInteractive` runs use the stored `enabled` value.

---

# Creating a New Profile

1. Create the folder: `{{CONFIG_SOURCE_DIR}}/<name>/`.
2. Create `settings.json` (or let the framework create it).
3. Create `mcp.json`, `plugins.json`, and `lsp.json` (empty is fine; you fill
   them).
4. Build with: `-Profile <name>`.

---

# Rules

- `coding` is ALWAYS the main profile — never delete or rename it.
- `mcp.json` / `plugins.json` / `lsp.json` are user-owned after creation.
- The user may add more profiles or edit any file at any time.
- `target.json` (optional, P2) can change the generated artifact name per
  profile: `{ "artifact": "<name>.json" }`.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Active Profile Creation Guide
