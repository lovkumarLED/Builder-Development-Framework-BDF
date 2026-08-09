# TESTING Template

> Template: verification guide. Becomes `TESTING.md`.

---

# TESTING

> Verification guide for {{PROJECT_NAME}}.

---

# Purpose

This document defines the testing process used to verify that {{PROJECT_NAME}} is functioning correctly.

Testing ensures that:

- Configuration files are valid.
- Builder behavior is correct.
- Generated configuration is valid.
- Existing functionality has not been broken by recent changes.

This document describes the current testing process.

Automated testing is provided by the test harness:

```
{{TEST_HARNESS}}
```

The harness runs the builder against isolated temporary fixtures and verifies both success and failure behavior.

It also runs the release manager against a temp copy of the docs and verifies the generated release documentation.

Current automated coverage (all harnesses green = done):

- {{TEST_HARNESS}} â€” 17 tests (9 builder + 8 Release Docs).
- V2.5 harness ({{V25_TEST_HARNESS}}) â€” 13 tests (active-provider selector).
- V2.7 harness ({{V27_TEST_HARNESS}}) â€” 33 tests (JSON Schema validation + hardening + reasoning formats).

Definition of complete: 17/17 + 13/13 + 33/33 PASSED, exit code 0.

Builder tests (V2.1 harness):

- Valid profile (real profile, no manual editing).
- Invalid JSON.
- Missing provider.
- Duplicate model IDs.
- Duplicate model names.
- Duplicate plugins.
- Malformed provider definition.
- Provider-specific models.
- Backup failure safety (output remains untouched).

Release Docs tests:

- Registry shape (valid versions, one Current, no duplicates).
- Release manager generates all outputs.
- Release manager is deterministic.
- CURRENT_RELEASE.md matches the registry Current entry.
- Registry and CHANGELOG consistency (legacy entries preserved).
- bdf/VERSION.md compatibility rows updated.
- Missing markers abort without writing.
- Real docs consistency (read-only).

Run it with:

```
powershell -File {{SCRIPTS_DIR}}/{{TEST_HARNESS}}
```

The harness exits non-zero when any test fails.

---

# Testing Philosophy

Testing follows four principles.

1. Validate before generating.
2. Never trust generated output without verification.
3. Every successful build should be reproducible.
4. Changes should never break previously working functionality.

Testing is considered part of development rather than an optional step.

---

# Test Environment

Current environment

Operating System

```
{{OS}}
```

Shell

```
{{SHELL}}
```

Application

```
{{APP_NAME}}
```

Configuration Builder

```
{{BUILDER_SCRIPT}}
```

Provider

```
{{CURRENT_PROVIDER}}
```

Profile

```
{{DEFAULT_PROFILE}}
```

Profile Selection

```
-Profile {{DEFAULT_PROFILE}}
```

---

# Pre-Test Checklist

Before testing begins verify:

â–¡ Configuration files exist.

â–¡ Provider configuration exists.

â–¡ Builder script exists.

â–¡ Backup directory exists.

â–¡ {{APP_NAME}} is installed.

â–¡ Required environment variables are configured.

Testing should not begin until every item is complete.

---

# Test Categories

The current implementation is verified using the following categories.

| Category | Purpose |
|----------|---------|
| Folder Structure | Verify project layout |
| Configuration Validation | Verify configuration syntax |
| Builder | Verify builder execution |
| Generated Configuration | Verify generated output |
| Backup | Verify backup creation |
| Regression | Verify existing functionality remains operational |

---

# Folder Structure Tests

## Test ID

```
FS-001
```

### Purpose

Verify that the required project structure exists.

### Procedure

Confirm the following directories exist.

```
{{CONFIG_SOURCE_DIR}}/

{{PROVIDER_DIR}}/

{{SCRIPTS_DIR}}/

{{BACKUP_DIR}}/
```

Confirm the following files exist.

```
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/settings.json

{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/models.json

{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/plugins.json

{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/service.json

{{PROVIDER_DIR}}/{{CURRENT_PROVIDER}}.json

{{SCRIPTS_DIR}}/{{BUILDER_SCRIPT}}
```

### Expected Result

Every required directory and file exists.

### Failure Result

Missing files prevent the builder from running correctly.

---

## Test ID

```
FS-002
```

### Purpose

Verify that generated files are not stored inside the source directories.

### Procedure

Confirm that

```
{{GENERATED_ARTIFACT}}
```

exists only in the expected output location.

### Expected Result

Only one generated configuration exists.

### Failure Result

Multiple generated configurations may cause confusion or outdated configurations to be used.

---

# JSON Validation Tests

## Test ID

```
JS-001
```

### Purpose

Verify that every configuration file contains valid configuration.

### Procedure

Open each configuration file and confirm that it parses successfully.

Files to verify:

```
settings.json

models.json

plugins.json

service.json

{{CURRENT_PROVIDER}}.json
```

### Expected Result

Every file contains valid configuration.

### Failure Result

The builder must stop before generation begins.

---

## Test ID

```
JS-002
```

### Purpose

Verify that all required keys exist.

### Procedure

Check each configuration file against the definitions in

```
JSON_SCHEMAS.md
```

### Expected Result

Every required key is present.

### Failure Result

Validation fails and configuration generation is aborted.

---

# Builder Tests

## Test ID

```
BLD-001
```

### Purpose

Verify that the builder starts successfully.

### Procedure

Run the builder.

```
{{BUILDER_SCRIPT}}
```

### Expected Result

The builder starts without syntax errors.

The build process begins.

### Failure Result

The builder cannot execute.

No configuration is generated.

---

## Test ID

```
BLD-002
```

### Purpose

Verify that the builder loads the selected profile correctly.

### Procedure

Execute the builder with the profile parameter.

Observe the console output.

Verify that the builder loads:

```
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/
```

### Expected Result

The profile is loaded successfully.

No missing file errors are reported.

### Failure Result

The builder reports a missing profile or missing configuration file.

Generation stops immediately.

---

## Test ID

```
BLD-003
```

### Purpose

Verify that provider configuration is loaded correctly.

### Procedure

Execute the builder.

Confirm that the provider configuration is read from:

```
{{PROVIDER_DIR}}/{{CURRENT_PROVIDER}}.json
```

### Expected Result

Provider configuration loads successfully.

The provider object is available for merging.

### Failure Result

The builder reports:

- Missing provider
- Invalid provider
- Invalid provider schema

Generation stops.

---

## Test ID

```
BLD-004
```

### Purpose

Verify that configuration validation executes before generation.

### Procedure

Introduce an intentional configuration error.

Examples:

- Remove a required key.
- Break configuration syntax.

Run the builder.

### Expected Result

The builder detects the error.

Configuration generation does not begin.

### Failure Result

The builder generates an invalid configuration.

This is considered a critical defect.

---

## Test ID

```
BLD-005
```

### Purpose

Verify configuration merging.

### Procedure

Run the builder using valid configuration.

Verify that the following sections appear in the generated configuration.

- Provider
- Models
- Plugins
- Service

### Expected Result

All configuration sections are merged successfully.

### Failure Result

Missing sections indicate an incomplete merge process.

---

## Test ID

```
BLD-006
```

### Purpose

Verify configuration generation.

### Procedure

Run the builder.

Open:

```
{{GENERATED_ARTIFACT}}
```

### Expected Result

The file exists.

The configuration is valid.

The configuration contains all expected sections.

### Failure Result

Missing file.

Invalid configuration.

Incomplete configuration.

---

## Test ID

```
BLD-007
```

### Purpose

Verify deterministic output.

### Procedure

Run the builder twice without modifying any source files.

Compare both generated configurations.

### Expected Result

The generated configuration is identical.

### Failure Result

Different output indicates non-deterministic builder behavior.

---

## Test ID

```
BLD-008
```

### Purpose

Verify that a partial profile builds successfully.

### Procedure

Execute the builder with a profile that contains only the settings file.

### Expected Result

The build completes successfully.

Optional sections are reported as skipped.

The generated configuration contains the provider section.

### Failure Result

The builder fails because optional profile files are missing.

---

# Generated Configuration Tests

## Test ID

```
GEN-001
```

### Purpose

Verify that the generated configuration file exists.

### Procedure

Run the builder.

Verify that the following file exists.

```
{{GENERATED_ARTIFACT}}
```

### Expected Result

The file is created successfully.

### Failure Result

No configuration file is generated.

---

## Test ID

```
GEN-002
```

### Purpose

Verify that the generated configuration contains valid configuration.

### Procedure

Open

```
{{GENERATED_ARTIFACT}}
```

Parse the file using:

- {{APP_NAME}}
- A code editor
- A configuration validator

### Expected Result

The file parses successfully.

### Failure Result

Invalid configuration syntax.

The application cannot load the configuration.

---

## Test ID

```
GEN-003
```

### Purpose

Verify that every required configuration section exists.

### Procedure

Inspect the generated configuration.

Verify the presence of:

```
provider

models

plugin

service
```

### Expected Result

Every required section exists.

### Failure Result

One or more sections are missing.

---

## Test ID

```
GEN-004
```

### Purpose

Verify model injection.

### Procedure

Compare:

```
{{CONFIG_SOURCE_DIR}}/{{DEFAULT_PROFILE}}/models.json
```

with

```
{{GENERATED_ARTIFACT}}
```

Verify that every configured model appears inside the provider configuration.

### Expected Result

All configured models are present.

### Failure Result

Missing or duplicated model definitions.

---

# Backup Tests

## Test ID

```
BKP-001
```

### Purpose

Verify automatic backup creation.

### Procedure

Generate a configuration twice.

Inspect:

```
{{BACKUP_DIR}}/
```

### Expected Result

A new timestamped backup is created before the previous configuration is overwritten.

Example

```
{{BACKUP_DIR}}/

{{GENERATED_ARTIFACT}}_2026-08-03_10-15-42.json
```

### Failure Result

No backup is created.

---

## Test ID

```
BKP-002
```

### Purpose

Verify backup integrity.

### Procedure

Open the most recent backup.

Verify that it contains a complete configuration.

### Expected Result

The backup is readable and complete.

### Failure Result

The backup is corrupted, incomplete, or unreadable.

---

# Regression Tests

## Test ID

```
REG-001
```

### Purpose

Verify that recent changes do not break existing functionality.

### Procedure

After any modification to the builder:

1. Run the builder.
2. Verify successful generation.
3. Verify the application starts successfully.
4. Verify the configured models are available.

### Expected Result

Previously working functionality continues to operate correctly.

### Failure Result

Existing functionality is broken by a recent change.

---

## Test ID

```
REG-002
```

### Purpose

Verify reproducibility.

### Procedure

Without changing any source configuration:

1. Run the builder.
2. Delete `{{GENERATED_ARTIFACT}}`.
3. Run the builder again.

Compare the generated configurations.

### Expected Result

Both generated files are identical.

### Failure Result

Different outputs indicate a regression or non-deterministic behavior.

---

# Active-Provider Selector Test Group (V2.5 Builder)

The V2.5 group verifies provider discovery, interactive selection persistence, per-provider model files, and the `-Provider`/`-NonInteractive` switches.

| Test | Name | Asserts |
|------|------|---------|
| 1 | Provider discovery | Every provider under `{{PROVIDER_DIR}}/` is discovered |
| 2 | Selection persistence | Selected active providers persist to profile settings; unchanged list rewrites nothing |
| 3 | Per-provider model precedence | Profile `<provider>-models.json` wins over provider-folder and inline models |
| 4 | Model source drop | Active provider without any models source is dropped with a warning, not a failure |
| 5 | CLI switches | `-Provider` and `-NonInteractive` behave per spec |

# JSON Schema Validation Test Group (V2.7 Builder)

The V2.7 group verifies the schema-validation entry gate and the F1-F7 feature set: pre-flight, dry-run, backup retention, provenance, diagnostics, merge diff, dynamic target artifact, and the no-literal-keys policy.

| Test | Name | Asserts |
|------|------|---------|
| 1 | Schema compliance | Config sources validate against `{{SCHEMA_DIR}}` schemas before builder validation |
| 2 | Pre-flight deps | Missing provider/profile/schema files reported together, then abort |
| 3 | WhatIf dry-run | Validates + merges only; writes nothing; prints planned changes; exit 0 |
| 4 | Backup retention | Backups pruned to newest N per artifact prefix (`-KeepBackups`) |
| 5 | Provenance sidecar | Sidecar written with builder version, profile, providers, timestamp, output hash |
| 6 | Doctor diagnostics | Read-only diagnostics; exit 0 clean / 1 issues; no writes |
| 7 | Merge diff summary | Diff vs previous backup reported; no prior backup = no diff |
| 8 | Dynamic target artifact | `target.json` artifact name drives output, backup prefix, provenance, WhatIf |
| 9 | No literal keys | Generated artifact contains only `{env:VAR}` apiKey placeholders |
| 10 | Reasoning-format variants merge | OpenAI (`reasoningEffort`), Claude (`thinking.budgetTokens`) and Gemini (`thinkingConfig.thinkingBudget`) variant shapes pass schema validation and merge into the generated config; provider `reasoningFormat` field accepted |
| 11 | Reasoning-format enforcement | Variant levels invalid for the provider's declared format are dropped from the generated output with a warning (e.g. `max` on an `openai` provider) |

# Release Docs Test Group (Tests 10-17)

The Release Docs group verifies the release pipeline (registry â†’ release manager â†’ generated documentation).

All tests except test 17 run against an isolated temp copy of the docs.

| Test | Name | Asserts |
|------|------|---------|
| 10 | Registry shape | Registry exists, one Current entry, valid version format, strictly descending order, no duplicate JSON keys |
| 11 | Release manager generates all outputs | Exit 0, CURRENT_RELEASE.md created, markers intact, every registry version present in CHANGELOG |
| 12 | Release manager deterministic | Two runs produce identical CHANGELOG and CURRENT_RELEASE.md |
| 13 | CURRENT_RELEASE matches registry | Quick reference contains the Current entry's builder version, project version, date, and testing summary |
| 14 | Registry and CHANGELOG consistent | Every registry entry present in CHANGELOG with its summary; legacy entries preserved; exactly one Current in the generated section |
| 15 | VERSION.md rows updated | Last Updated row matches the Current release date |
| 16 | Missing markers abort safely | Removing a marker makes the manager fail with exit non-zero and leaves CHANGELOG untouched |
| 17 | Real docs consistent (read-only) | Real `release_registry.json`, `CHANGELOG.md`, and `CURRENT_RELEASE.md` are consistent |

Test 17 is the only test in the harness that reads the real docs, and it is strictly read-only â€” it never writes or modifies the real documentation.

Run the harness with:

```
powershell -File {{SCRIPTS_DIR}}/{{TEST_HARNESS}}
powershell -File {{SCRIPTS_DIR}}/{{V25_TEST_HARNESS}}
powershell -File {{SCRIPTS_DIR}}/{{V27_TEST_HARNESS}}
```

Expected: 17/17 + 13/13 + 33/33 PASSED, exit 0.

## JSON Schema (V2.7) test group

The V2.7 group verifies the JSON Schema builder ({{V27_TEST_HARNESS}}) against isolated temporary fixtures, in the same style as the other test groups.

- Schema compliance: config sources validate against {{SCHEMA_DIR}} schemas before builder validation.
- Hardening: pre-flight dependency check, dry-run, backup retention, provenance, doctor diagnostics, merge diff summary.

---

# Manual Testing Procedure

Perform the following steps in order.

1. Verify project structure.
2. Verify configuration syntax.
3. Execute the builder.
4. Verify backup creation.
5. Verify generated configuration.
6. Launch the application.
7. Confirm configured models are available.
8. Confirm no unexpected errors occur.

---

# Expected Results

A successful test session satisfies all of the following.

âœ“ Project structure is correct.

âœ“ Configuration files are valid.

âœ“ Builder executes successfully.

âœ“ Backup is created.

âœ“ Generated configuration is valid.

âœ“ Application starts successfully.

âœ“ Configured models are available.

---

# Failure Indicators

Testing should be considered unsuccessful if any of the following occur.

- Builder fails to start.
- Invalid configuration is generated.
- Backup is missing.
- Required configuration sections are missing.
- Application fails to load the generated configuration.
- Configured models are unavailable.

Any failure should be investigated before continuing development.

---

# Testing Checklist

Before considering a build complete:

â–¡ Folder structure verified.

â–¡ Configuration validated.

â–¡ Builder executed successfully.

â–¡ Backup created.

â–¡ Generated configuration verified.

â–¡ Application launched.

â–¡ Models available.

â–¡ No unexpected errors observed.

---

# Future Testing Expansion

Future versions may extend automated testing with:

- JSON schema validation.
- Builder unit tests.
- Integration testing.
- Configuration comparison.
- Regression testing.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Testing Guide
