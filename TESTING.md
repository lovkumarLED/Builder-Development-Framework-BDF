# TESTING

> Verification guide for the OpenCode Configuration Manager.

---

# Purpose

This document defines the testing process used to verify that the OpenCode Configuration Manager is functioning correctly.

Testing ensures that:

- Configuration files are valid.
- Builder behavior is correct.
- Generated configuration is valid.
- Existing functionality has not been broken by recent changes.

This document describes the current manual testing process.

Future automated testing will be documented after implementation.

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
Windows 11
```

Shell

```
PowerShell 7+
```

Application

```
OpenCode
```

Configuration Builder

```
build-opencode.ps1
```

Provider

```
OmniRoute
```

Profile

```
default
```

---

# Pre-Test Checklist

Before testing begins verify:

□ JSON files exist.

□ Provider configuration exists.

□ Builder script exists.

□ Backup directory exists.

□ OpenCode is installed.

□ OmniRoute is running.

□ Required environment variables are configured.

Testing should not begin until every item is complete.

---

# Test Categories

The current implementation is verified using the following categories.

| Category | Purpose |
|----------|---------|
| Folder Structure | Verify project layout |
| JSON Validation | Verify configuration syntax |
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
profiles/

providers/

scripts/

backup/
```

Confirm the following files exist.

```
profiles/default/settings.json

profiles/default/models.json

profiles/default/plugins.json

profiles/default/mcp.json

providers/omniroute.json

scripts/build-opencode.ps1
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
opencode.json
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

Verify that every configuration file contains valid JSON.

### Procedure

Open each configuration file and confirm that it parses successfully.

Files to verify:

```
settings.json

models.json

plugins.json

mcp.json

omniroute.json
```

### Expected Result

Every file contains valid JSON.

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

```powershell
.\build-opencode.ps1
```

or

```powershell
.\build-opencode.ps1 default
```

depending on the current implementation.

### Expected Result

The builder starts without PowerShell syntax errors.

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

Verify that the builder loads the active profile correctly.

### Procedure

Execute the builder.

Observe the console output.

Verify that the builder loads:

```
profiles/default/
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
providers/omniroute.json
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
- Break JSON syntax.

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
- MCP

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
opencode.json
```

### Expected Result

The file exists.

The JSON is valid.

The configuration contains all expected sections.

### Failure Result

Missing file.

Invalid JSON.

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
opencode.json
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

Verify that the generated configuration contains valid JSON.

### Procedure

Open

```
opencode.json
```

Parse the file using:

- OpenCode
- VS Code
- JSON Validator

### Expected Result

The file parses successfully.

### Failure Result

Invalid JSON syntax.

OpenCode cannot load the configuration.

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

mcp
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
profiles/default/models.json
```

with

```
opencode.json
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
backup/
```

### Expected Result

A new timestamped backup is created before the previous configuration is overwritten.

Example

```
backup/

opencode_2026-08-03_10-15-42.json
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
3. Verify OpenCode starts successfully.
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
2. Delete `opencode.json`.
3. Run the builder again.

Compare the generated configurations.

### Expected Result

Both generated files are identical.

### Failure Result

Different outputs indicate a regression or non-deterministic behavior.

---

# Manual Testing Procedure

Perform the following steps in order.

1. Verify project structure.
2. Verify JSON syntax.
3. Execute the builder.
4. Verify backup creation.
5. Verify generated configuration.
6. Launch OpenCode.
7. Confirm configured models are available.
8. Confirm no unexpected errors occur.

---

# Expected Results

A successful test session satisfies all of the following.

✓ Project structure is correct.

✓ Configuration files are valid.

✓ Builder executes successfully.

✓ Backup is created.

✓ Generated configuration is valid.

✓ OpenCode starts successfully.

✓ Configured models are available.

---

# Failure Indicators

Testing should be considered unsuccessful if any of the following occur.

- Builder fails to start.
- Invalid JSON is generated.
- Backup is missing.
- Required configuration sections are missing.
- OpenCode fails to load the generated configuration.
- Configured models are unavailable.

Any failure should be investigated before continuing development.

---

# Testing Checklist

Before considering a build complete:

□ Folder structure verified.

□ Configuration validated.

□ Builder executed successfully.

□ Backup created.

□ Generated configuration verified.

□ OpenCode launched.

□ Models available.

□ No unexpected errors observed.

---

# Future Automated Testing

The current project uses manual verification.

Future versions may introduce automated testing for:

- JSON schema validation.
- Builder unit tests.
- Integration testing.
- Configuration comparison.
- Regression testing.

Automated testing will be documented after implementation.

---

**Document Version:** 1.0

**Status:** Manual Testing Guide