# TROUBLESHOOTING Template

> Template: known issues, diagnostics, and recovery. Becomes `TROUBLESHOOTING.md`.

---

# TROUBLESHOOTING

> Known issues, diagnostics, and recovery procedures for {{PROJECT_NAME}}.

---

# Purpose

This document records problems encountered during the development of {{PROJECT_NAME}}.

Unlike the testing guide, which verifies expected behavior, this document focuses on diagnosing and resolving unexpected failures.

Only issues that have actually been encountered and investigated should be documented here.

Future issues should be appended to this document after they have been fully understood.

---

# Troubleshooting Workflow

Whenever an issue occurs, follow this workflow.

```
Observe Problem

↓

Read Error Message

↓

Identify Failed Stage

↓

Determine Root Cause

↓

Apply Fix

↓

Re-run Builder

↓

Verify Resolution
```

Do not apply random fixes without first identifying the root cause.

---

# Problem Categories

| Category | Description |
|----------|-------------|
| Execution | Script execution errors |
| Configuration | Configuration syntax errors |
| Builder | Generation failures |
| Provider | Provider configuration errors |
| Environment | Operating system or environment issues |
| Application | Runtime configuration errors |

---

# Execution Issues

## Issue ID

```
EXE-001
```

### Problem

Unexpected token errors during builder execution.

Example

```
Unexpected token ':' in expression or statement.
```

### Cause

Script syntax errors.

Typical causes include:

- Missing braces.
- Missing quotation marks.
- Invalid syntax constructs.
- Incorrect declarations.

### Resolution

Review the reported line.

Correct the syntax before running the builder again.

### Prevention

Validate each modification before continuing development.

Avoid editing multiple unrelated sections simultaneously.

---

# Configuration Issues

## Issue ID

```
CFG-001
```

### Problem

Invalid configuration.

### Symptoms

Builder fails during validation.

The application refuses to load the generated configuration.

### Cause

Malformed configuration.

Examples include:

- Missing comma.
- Extra comma.
- Missing closing brace.
- Invalid string formatting.

### Resolution

Validate every configuration file before generation.

Use a validator or editor with syntax highlighting.

### Prevention

Keep configuration files small and focused.

---

# Provider Issues

## Issue ID

```
PROV-001
```

### Problem

Provider configuration cannot be loaded.

### Symptoms

Builder reports missing or invalid provider.

### Cause

Incorrect provider filename.

Incorrect provider identifier.

Missing provider definition.

### Resolution

Verify:

```
{{PROVIDER_DIR}}/

{{CURRENT_PROVIDER}}.json
```

Confirm that the provider identifier matches the filename and the provider referenced by the profile settings.

---

## Issue ID

```
PROV-002
```

### Problem

Models are not available after generation.

### Cause

Model injection failed.

### Resolution

Verify that the models file contains valid model definitions.

Verify that the builder correctly injects the models into the provider object.

---

# Environment Issues

## Issue ID

```
ENV-001
```

### Problem

Environment variable changes are not detected.

### Symptoms

The builder or application continues using old credentials.

### Cause

The operating system does not update the current terminal session after environment variables are modified.

### Resolution

Close the terminal.

Open a new session.

Run the builder again.

### Prevention

Restart the terminal after modifying environment variables.

---

# Builder Issues

## Issue ID

```
BLD-001
```

### Problem

Builder stops before generation.

### Cause

Validation failure.

### Resolution

Read the reported validation error.

Correct the configuration.

Run the builder again.

Do not bypass validation.

---

## Issue ID

```
BLD-002
```

### Problem

Generated configuration is incomplete.

### Cause

One or more configuration sections were not merged.

### Resolution

Verify that the builder successfully loads:

- settings
- provider
- models
- plugins
- service configuration

Confirm that every section participates in the merge stage.

---

# Backup Issues

## Issue ID

```
BKP-001
```

### Problem

No backup is created.

### Cause

Backup stage did not execute.

### Resolution

Verify that the builder performs backup creation before overwriting

```
{{GENERATED_ARTIFACT}}
```

The build should not continue if backup creation fails.

---

# Application Issues

## Issue ID

```
APP-001
```

### Problem

The application starts but configured models are missing.

### Cause

The generated configuration does not contain the expected model definitions.

### Resolution

Verify:

- models file
- provider configuration
- generated configuration

Ensure model injection completed successfully.

---

# General Recovery Procedure

If the cause of an issue is unknown:

1. Verify the folder structure.
2. Validate every configuration file.
3. Verify provider configuration.
4. Execute the builder.
5. Read the first reported error.
6. Resolve the root cause.
7. Execute the builder again.
8. Verify the generated configuration.
9. Launch the application.

Do not attempt multiple unrelated fixes simultaneously.

---

# Lessons Learned

During development the following practices consistently reduced debugging time.

- Validate before generating.
- Make one change at a time.
- Read the first reported error.
- Keep configuration modular.
- Preserve backups.
- Never modify generated files manually.

These practices should be followed during future development.

---

# Future Issues

New troubleshooting entries should include:

- Issue ID
- Problem
- Symptoms
- Root Cause
- Resolution
- Prevention

This keeps the troubleshooting guide consistent as the project evolves.

---

**Document Version:** {{DOC_VERSION}}

**Status:** Current Troubleshooting Guide
