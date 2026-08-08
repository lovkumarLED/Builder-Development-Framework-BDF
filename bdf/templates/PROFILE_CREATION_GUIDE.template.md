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

Each profile carries exactly three files:

```
{{CONFIG_SOURCE_DIR}}/<profile>/

settings.json
mcp.json
plugins.json
```

## coding — the main profile

- `settings.json` — `$schema` + `activeProviders` (framework-writable).
- `mcp.json` — seeded once from the agent's own main JSON; **user-owned after**.
- `plugins.json` — seeded once from the agent's own main JSON; **user-owned after**.

## experimental / minimal

- `settings.json` — written by the framework.
- `mcp.json` / `plugins.json` — created EMPTY, never filled by the framework.

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

---

# Creating a New Profile

1. Create the folder: `{{CONFIG_SOURCE_DIR}}/<name>/`.
2. Create `settings.json` (or let the framework create it).
3. Create `mcp.json` and `plugins.json` (empty is fine; you fill them).
4. Build with: `-Profile <name>`.

---

# Rules

- `coding` is ALWAYS the main profile — never delete or rename it.
- `mcp.json` / `plugins.json` are user-owned after creation.
- The user may add more profiles or edit any file at any time.
- `target.json` (optional, P2) can change the generated artifact name per
  profile: `{ "artifact": "<name>.json" }`.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Active Profile Creation Guide
