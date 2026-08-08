# BUILDER EXTENSION GUIDE Template

> Template: extending the builder. Becomes `BUILDER_EXTENSION_GUIDE.md`.

---

# {{PROJECT_NAME}}

> How to extend or modify the configuration builder in a BDF project.

---

# Purpose

The builder is the automation core: it loads, validates, backs up, merges, and
generates the final artifact. This guide explains its architecture and how to
extend it safely.

---

# The Builder Pipeline

```
1  Load
2  Validate          (JSON Schema F1 + builder validation)
3  Pre-flight        (dependency check F2)
4  Backup            (retention F4)
5  Merge             (settings → providers → models → plugins → MCP)
6  Verify            (pre-write output verification)
7  Generate          (artifact + provenance sidecar F5)
```

The builder is fully reproducible from `BUILDER_SPEC.md`.

---

# How to Add a Feature

1. **Document first.** Add the feature to `BUILDER_SPEC.md` (and the template
   if framework-generic).
2. **Write a failing test first.** Add a test to the harness.
3. **Implement** the smallest change in the builder.
4. **Run the full battery** (`{{TEST_HARNESS}}`, `{{V25_TEST_HARNESS}}`,
   `{{V27_TEST_HARNESS}}`).
5. **Update the harness header comment** — it lists every test.
6. **Update the docs** (TESTING.md, FOLDER_STRUCTURE.md, test-count mentions).
7. If framework-generic, bump `{{DOCS_DIR}}/bdf/VERSION.md`.

---

# Extension Boundaries

## What the builder MAY do

- Read configuration.
- Validate configuration.
- Create backups (with retention).
- Merge configuration in stages.
- Verify output before writing.
- Generate the artifact + provenance sidecar.

## What the builder MUST NEVER do

- Write literal API keys or secrets into system artifacts (No-Secrets Rule).
- Create provider/model JSON files (user-owned).
- Overwrite `mcp.json` / `plugins.json` that already exist (user-owned).
- Touch `.jsonc` without consent.
- Maintain configuration data — it only automates.

> **Agent config warning:** the builders generate `{{GENERATED_ARTIFACT}}`
> (the agent's main config). Do NOT create a `.jsonc` next to it — the agent
> reads the `.jsonc` *instead of* the `.json` when both exist, and your built
> config silently disappears from its model list. Generating both formats is
> planned for a future update — not right now.

---

# Adding a New Provider Type

1. Add a JSON Schema in `{{SCHEMA_DIR}}/`.
2. Register the schema mapping in the builder.
3. Add a validation test.
4. Document the shape in `JSON_SCHEMAS.md` + `PROVIDER_DEVELOPMENT_GUIDE.md`.

---

# Adding a Merge Stage

1. Add the stage function (e.g. `Merge-Custom`).
2. Call it in the pipeline in the right order.
3. Add it to the verification step.
4. Document stage + precedence in `BUILDER_SPEC.md`.
5. Add tests.

---

# Adding a CLI Flag

1. Add the `param()` entry.
2. Wire it into the relevant stage.
3. Document it in `BUILDER_SPEC.md` CLI table.
4. Add a test that exercises it.

---

# Verification Checklist

- [ ] All harnesses green.
- [ ] Harness header comment lists the new test.
- [ ] `BUILDER_SPEC.md` documents the feature.
- [ ] Templates mirror the reference (if framework-generic).
- [ ] No literal keys in system artifacts.
- [ ] Release manager deterministic.
- [ ] `{{DOCS_DIR}}/bdf/VERSION.md` bumped if templates changed.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Active Builder Extension Guide
