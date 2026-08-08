# BUILDER EXTENSION GUIDE

> How to extend or modify the configuration builder in a BDF project.

---

# Purpose

The builder is the automation core: it loads, validates, backs up, merges, and
generates the final artifact. This guide explains its architecture and how to
extend it safely.

---

# The Builder Pipeline

Every builder follows the same 7-stage architecture:

```
1  Load
2  Validate          (JSON Schema F1 + builder validation)
3  Pre-flight        (dependency check F2)
4  Backup            (retention F4)
5  Merge             (settings → providers → models → plugins → MCP)
6  Verify            (pre-write output verification)
7  Generate          (artifact + provenance sidecar F5)
```

Supported CLIs (V2.7):

| Flag | Purpose |
|------|---------|
| `-Profile` | Profile to build |
| `-ConfigRoot` | Config root (defaults to the agent's config dir) |
| `-WhatIf` | Dry run — validate + merge, write nothing (F3) |
| `-Doctor` | Read-only diagnostics (F6) |
| `-KeepBackups` | Backup retention count, default 10 (F4) |
| `-ProvenancePath` | Provenance sidecar path (F5) |
| `-SchemaDir` | Schema directory (F1) |
| `-NonInteractive` | No prompts |

---

# Where the Code Lives

| Project | Builder | Tests |
|---------|---------|-------|
| OpenCode | `scripts/build-opencode-v2.7.ps1` | `scripts/test-opencode-v2.7.ps1` |
| KiloCode | `~/.config/kilo/scripts/build-kilo-v1.ps1` | `~/.config/kilo/scripts/test-kilo-v1.ps1` |

The builder is fully reproducible from documentation: `BUILDER_SPEC.md`
describes every stage, function contract, CLI switch, precedence rule, and file
shape exactly.

---

# How to Add a Feature

1. **Document first.** Add the feature to `BUILDER_SPEC.md` (and the template
   `bdf/templates/BUILDER_SPEC.template.md` if it is framework-generic).
2. **Write a failing test first.** Add a test to the harness
   (`test-opencode-v2.7.ps1`) that asserts the new behavior.
3. **Implement** the smallest change in the builder.
4. **Run the full battery:**

```
powershell -File scripts/test-opencode-v2.ps1        # 17 tests
powershell -File scripts/test-opencode-v2.5.ps1      # 13 tests
powershell -File scripts/test-opencode-v2.7.ps1      # 31 tests
```

5. **Update the harness header comment** — it lists every test (single source
   of truth for the test count).
6. **Update the docs**: `TESTING.md`, `FOLDER_STRUCTURE.md`, and the
   test-count mentions everywhere (README, PROJECT_STATE, registry) if the
   count changed.
7. If the change is framework-generic, bump `bdf/VERSION.md`.

---

# Extension Boundaries

## What the builder MAY do

- Read configuration.
- Validate configuration (schemas + builder validation).
- Create backups (with retention).
- Merge configuration in stages.
- Verify output before writing.
- Generate the artifact + provenance sidecar.

## What the builder MUST NEVER do

- Write literal API keys or secrets into system artifacts (No-Secrets Rule).
- Create provider/model JSON files (user-owned).
- Overwrite mcp.json / plugins.json that already exist (user-owned).
- Touch `.jsonc` without consent.
- Maintain configuration data — it only automates.

> **Agent config warning:** the builders generate `opencode.json` (OpenCode) /
> `kilo.json` (Kilo). Do NOT create `opencode.jsonc` next to `opencode.json` —
> OpenCode reads the `.jsonc` *instead of* the `.json` when both exist, and your
> built config silently disappears from `/models`. Generating both formats is
> planned for a future update — not right now.

---

# Adding a New Provider Type

Providers are user-owned; the builder just needs to load them. If your provider
introduces a new file shape:

1. Add a JSON Schema in `schemas/`.
2. Register the schema mapping in the builder's `Get-SchemaFile`-style function.
3. Add a validation test to the harness.
4. Document the shape in `JSON_SCHEMAS.md` + `PROVIDER_DEVELOPMENT_GUIDE.md`.

---

# Adding a Merge Stage

The merge pipeline is modular: settings → providers → models → plugins → MCP →
final.

To add a new stage:

1. Add the stage function (e.g. `Merge-Custom`).
2. Call it in the pipeline in the right order.
3. Add a stage to the verification step.
4. Document the stage + precedence in `BUILDER_SPEC.md`.
5. Add tests.

---

# Adding a CLI Flag

1. Add the `param()` entry.
2. Wire it into the relevant stage.
3. Document it in `BUILDER_SPEC.md` CLI table.
4. Add a test that exercises it (e.g. `-WhatIf` has its own test).
5. If it changes defaults, update `ADAPTER.md` / `README.md` where they are
   documented.

---

# Verification Checklist

Before considering an extension done:

- [ ] All 4 harnesses green (17/13/31/30).
- [ ] Harness header comment lists the new test.
- [ ] `BUILDER_SPEC.md` documents the feature.
- [ ] Templates mirror the reference (if framework-generic).
- [ ] No literal keys in system artifacts.
- [ ] Release manager deterministic (run twice, second is a no-op).
- [ ] `bdf/VERSION.md` bumped if templates changed.

---

**Document Version:** 1.0

**Status:** Active Builder Extension Guide
