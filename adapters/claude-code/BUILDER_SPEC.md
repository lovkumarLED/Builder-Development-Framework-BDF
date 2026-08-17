# Claude Code Adapter Builder Specification

Lifecycle status: **Live validated**

Evidence date: 2026-08-17

## Command interfaces

### Fixture entry point (`build-claude-code.ps1`)

CLI contract (Gate 2, unchanged):

- `-FixtureRoot` (required): must be below the system temporary root.
- `-RoutingProfilePath` (required), `-SettingsPath` (required),
  `-SchemaPath` (optional, defaults under the fixture root).
- `-TestFailureStage` (optional): `None|AfterBackup|AfterTempWrite|AfterReplace`.
- Output contract: human-readable Gate 2 messages.

### Production entry point (`build-claude-code-production.ps1`)

Parameters and bound-parameter contract (section 7.1 of the Gate 4 handoff):

- `-Operation` (required): `Apply|Restore`.
- `-ProfileRoot`, `-SettingsPath`, `-SchemaPath` (required for both).
- Apply: `-RoutingProfilePath` required and bound; `-BackupPath`,
  `-ExpectedBackupSha256`, `-TargetBindingSha256` forbidden (presence, not
  value, is enforced).
- Restore: `-RoutingProfilePath` forbidden; `-BackupPath`,
  `-ExpectedBackupSha256`, `-TargetBindingSha256` required, bound, and
  non-empty.
- `-AllowRealTarget` (Gate 5 only): the production entry rejects a profile root
  equal to the process user profile unless this switch is present. Gate 4
  never passes it.
- `-TestFailureStage` (optional): all five Restore stages including
  `AfterRecoveryCopy` and `AfterRecoveryReplace`.

Output contract (strict JSON on stdout; redacted stderr; exit 0 success, 1
validation or transaction failure with the target in a verified state, 2 hard
recovery failure):

Apply:

```json
{ "ok": true, "backupName": "<settings.backup.<UTC>.<guid>.json>",
  "backupSha256": "<64 hex>", "preWriteTargetSha256": "<64 hex>",
  "postWriteTargetSha256": "<64 hex>", "coreVersion": "0.2.0",
  "schemaIdentity": "<64 hex>" }
```

Restore:

```json
{ "ok": true, "restoredTargetSha256": "<64 hex>", "coreVersion": "0.2.0",
  "schemaIdentity": "<64 hex>" }
```

The Python adapter validates the exact key set of both objects and rejects
extra or missing keys, wrong schema identity, mismatched hashes, and
unverifiable named backups.

## Validation stages and fail-fast rules

1. Real-profile lock before any target probe.
2. Settings path must equal the profile-root Claude settings target
   (case-insensitive).
3. Parameter contract from the bound-parameter set.
4. Trusted inputs (routing profile, schema, backup) validated as existing
   non-reparse leaves with forbidden state-leaf and comment-suffix guards
   before content reads.
5. Target binding (SHA-256 of the normalized canonical settings-target
   identity) recomputed and compared before Restore mutation.
6. Duplicate-key scan (decoded equivalents included) before deserialization.

## Managed patch surface

Only the top-level `env` object of the user-scope `.claude/settings.json` is
patched, and only the managed fields listed in `ADAPTER.md` (base URL, one
auth field, `ANTHROPIC_MODEL`, and the four curated compatibility options)
are edited. Patching is surgical: the builder reads bytes once, tokenizes
exact character spans, applies validated non-overlapping edits, and
reconstructs the output from the original text plus edits. It never
deserializes and regenerates the full document. Top-level `model` and every
byte outside the managed edit spans are preserved exactly (BOM, line
endings, indentation, property order, number/string spelling, nested
formatting, trailing newline).

Managed value semantics:

- compact window: decimal string `100000` through `1000000`;
- enabled Boolean options: string `1`;
- disabled Boolean options: property absent; `0` or `false` are never
  written for nonessential traffic;
- exactly one auth property present after apply;
- `gatewayDiscovery` combined with `disableNonessentialTraffic` is rejected
  before backup.

## Path and scope guards

- Target leaf must be `settings.json` under `.claude` under the profile root.
- The Claude state leaf and the comment-suffix are forbidden everywhere.
- Reparse components are rejected below the boundary.
- No client-supplied filesystem path reaches the entry points.

## Duplicate-key and malformed-input handling

Duplicate keys (including escaped equivalents) are rejected before mutation.
Malformed JSON is rejected with the validation stage reported and no backup or
temporary output created. Strict UTF-8 (with or without BOM) is required;
invalid UTF-8 is rejected before backup or mutation.

## Byte-preservation requirements

The surgical pipeline verifies: every edit is in bounds, names are unique,
and spans do not overlap; output equals the original text with only the
validated edits applied (ordinal comparison); every unchanged segment between
edits matches exactly; the output reparses and passes the unsupported-snapshot
comparison plus managed-value verification. Formatting normalization no longer
occurs: the full settings object is never re-serialized.

## Transaction order, backup, atomic replacement, post-write verification, and recovery

Apply: validation, pre-write hash capture, backup copy, temporary write,
atomic replace, post-write verification, machine-readable metadata emission.
Any failure restores the backup and verifies the target.

Restore: eligibility checks, recovery copy, staged backup replace, post-restore
verification, byte equality to the validated backup. A post-restore failure
restores the recovery copy; a recovery failure is a hard failure (exit 2) and
the same backup is never retried. Restore verification never requires the
restored settings to match the current route.

## Output redaction and secret handling

No absolute paths, usernames, resolved secret values, target contents, manifest
paths, or backup paths are emitted. Secrets are resolved only from the process
environment at execution time and never printed.


### Provider/model inspector (`inspect-provider-model.ps1`)

A Gate 3 evidence helper: consumes a fake Anthropic-compatible loopback
`/v1/models` response to prove discovery, display-name fallback, opaque model
ID pass-through, `ANTHROPIC_MODEL` precedence display, and alias-pinning
semantics. It never contacts a real gateway and never runs without an isolated
interpreter. Its behavior is proven by `test-provider-model.ps1` (25 tests,
Gate 3 overall pass).

## Exact Apply and Restore parameter contract (handoff section 7.1)

The production entry enforces presence from the script-level bound-parameter
set; explicitly bound empty forbidden parameters are rejected before target
mutation.

Apply requires bound: `-Operation Apply`, `-ProfileRoot`, `-SettingsPath`,
`-RoutingProfilePath`, `-SchemaPath`. Forbidden for Apply (presence):
`-BackupPath`, `-ExpectedBackupSha256`, `-TargetBindingSha256`.

Restore requires bound and non-empty: `-Operation Restore`, `-ProfileRoot`,
`-SettingsPath`, `-SchemaPath`, `-BackupPath`, `-ExpectedBackupSha256`,
`-TargetBindingSha256`. Forbidden for Restore (presence):
`-RoutingProfilePath`.

`-AllowRealTarget` is the Gate 5-only switch; Gate 4 never passes it.

`-TestFailureStage` allowed values: `None`, `AfterBackup`, `AfterTempWrite`,
`AfterReplace`, `AfterRecoveryCopy`, `AfterRecoveryReplace` (the last two
reachable only through a synthetic main-flow failure, so recovery is
exercised deterministically).

## Target binding, schema identity, backup eligibility, no-retry, and hard-failure evidence

- Target binding: SHA-256 over the normalized canonical settings-target
  identity (full path, lower-cased, backslashes to forward slashes, trailing
  separator trimmed). The Python adapter stores it in the manifest, passes it
  to Restore, and both PowerShell layers recompute and compare it before
  target mutation.
- Schema identity: Restore requires `-SchemaPath`; the entry validates the
  schema leaf and emits its SHA-256; the adapter rejects a wrong returned
  schema identity without committing metadata.
- Backup eligibility: filename contract, containment, no reparse components,
  actual hash equality, JSON parseability, and duplicate-key rejection - all
  before target mutation.
- No-retry: a failed restore never retries the same backup; the recovery copy
  restores the pre-restore target, and a recovery failure is a hard failure
  (exit 2).
- Hard-failure residual evidence: an injected deletion failure in commit
  finalization returns a generic hard failure, never success, and preserves
  exactly the verified evidence file that could not be deleted.

## Gate 5 reached

This specification describes production-path behavior proven on temporary
fixture copies (Gates 2-4A) and now validated live (2026-08-17, corrected Gate
5B pass + Gate 5C approved) against the real user-scope `.claude/settings.json`
with one saved loopback route, `/status` evidence, and one no-session routing
request returning the fixed marker. Lifecycle status is **Live validated**.

## Status-specific restrictions

- Gate 2 files prove fixture-only behavior.
- Gate 4A files prove production-path logic on temporary fixture copies only.
- Gate 5B live validation proves the env-only routing scope on the real target;
  it does not broaden the managed surface beyond the top-level `env` routing
  fields, and the real-target lock stays closed until the owner opens it.

## Implementation traceability

Behavior maps to the shared core functions `Invoke-ClaudeRoutingApply` and
`Invoke-ClaudeRoutingRestore` in `claude-routing-core.psm1`; this document
describes the contract, the module is the executable source of truth.

---

**Document Version:** 1.1

**Status:** Live validated
