# Claude Code Adapter Contract

Lifecycle status: **Live validated**

Evidence date: 2026-08-17

## Target and adapter category

- Target: Claude Code (user-scope settings).
- Adapter category: unique bounded (patch) adapter. It does not satisfy the
  OpenCode/Kilo universal scaffold contract, the provider registry model, the
  plugin model, or the MCP model.

## Managed source and target files

- Patch target (user scope): the user-scope Claude settings file resolved
  structurally as `%USERPROFILE%\.claude\settings.json`.
- App-owned route store: `app/state/claude-routes.json` with the versioned
  shape `{ version: 1, appliedRouteId, appliedRouteConfigSha256, routes[] }`.
- App-owned backup manifest: `app/state/claude-backup-manifest.json`.
- App-owned activity log: `app/state/claude-activity.jsonl`.

## Excluded files and ownership boundaries

- The Claude state file (`.claude.json`) is opaque Claude-owned state. It is
  never read, parsed, copied, hashed, or written by the adapter.
- Marketplaces, plugin installation, MCP servers, skills, permissions, hooks,
  memory, sessions, credentials, prompts, and transcripts are Claude-owned and
  outside the adapter.
- Project `.claude/settings.json`, `.claude/settings.local.json`, and `.mcp.json`
  are future opt-in targets only; the first adapter never prefers them over the
  user-scope target.

## Supported scopes and precedence limitations

- Only the user scope is supported (`scope: "user"`).
- Higher-precedence managed, command-line, local, or project sources can
  override or merge with the user-scope target. This adapter records the
  detected Claude Code version and does not claim runtime precedence.

## Configuration model and managed fields

One scalar routing profile is applied at a time. BDF surgically patches only
the top-level `env` object of the user-scope `.claude/settings.json`. Managed
fields (all inside `env`):

- `ANTHROPIC_BASE_URL` (endpoint destination).
- Exactly one auth strategy: `ANTHROPIC_API_KEY` (X-Api-Key) or
  `ANTHROPIC_AUTH_TOKEN` (Authorization: Bearer), selected by the user and
  stored only as an environment-variable reference name.
- `ANTHROPIC_MODEL` (the route model, written to `env`; top-level `model` is
  never changed and remains the fallback only).
- `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY` (string `1` when enabled; key
  absent when disabled).
- `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` (string `1` when enabled; key
  absent when disabled).
- `CLAUDE_CODE_AUTO_COMPACT_WINDOW` (decimal string 100000-1000000).
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` (string `1` when enabled; key
  absent when disabled; never `0` or `false`).

Discovery plus disabled nonessential traffic is rejected by the schema, the
PowerShell core, the Python adapter, and the app UI before any mutation.

Top-level `model` and every byte outside the managed `env` edit spans are
preserved exactly. The builder never deserializes and regenerates the full
document; it applies validated character-span edits and verifies
reconstruction ordinally.

Multiple routes may be saved; exactly zero or one route is applied.
`appliedRouteId` and `appliedRouteConfigSha256` are set atomically; a route
renders as applied only when both match.

## Secret-reference policy

- The editor and API manage environment-variable reference names, never secret
  values.
- Reference names match `^[A-Za-z_][A-Za-z0-9_]*$`.
- The production entry resolves the reference from its process environment at
  execution time only.
- Secrets never appear in stores, manifests, activity, responses, exceptions,
  subprocess output, or reports.

## Preservation, backup, atomic write, verification, and rollback contract

- Unsupported settings keys and every byte outside managed `env` edit spans
  are preserved exactly (BOM, line endings, indentation, property order,
  number/string spelling, nested formatting, trailing newline). Surgical
  edit spans are validated for bounds, uniqueness, and non-overlap before
  application; output is reconstructed from the original text plus edits and
  compared ordinally.
- Backup filename contract:
  `settings.backup.<UTC yyyyMMddHHmmssfff>.<32-hex-guid>.json` in the target
  directory.
- Writes are atomic (same-directory temporary file plus replace), verified by
  re-parse, managed-value checks, and semantic comparison.
- Apply and restore transactions commit the target, the route store, the
  manifest, and the activity log consistently, with a defined rollback sequence
  that restores and verifies every owned artifact or reports a generic hard
  failure while preserving evidence.
- A pre-call recovery copy is taken before production Apply; invalid output
  restores from the output-named validated backup or the recovery copy.

## Implementation, schema, fixture, and entry-point paths

- Core: `app/engine/claude-code/claude-routing-core.psm1`.
- Fixture entry: `app/engine/claude-code/build-claude-code.ps1`.
- Production entry: `app/engine/claude-code/build-claude-code-production.ps1`.
- Schema: `app/engine/schemas/claude-code-routing.schema.json`.
- Backend: `app/app/claude_adapter.py`; capabilities:
  `app/app/capabilities.py`.


## Revision tokens and concurrency

Two full lowercase 64-character SHA-256 revision tokens exist:

- `revision`: SHA-256 of the current user-scope settings target.
- `routesRevision`: SHA-256 of the app-owned route store.

Both match `^[0-9a-f]{64}$`, are opaque, and contain no path or settings
content. Apply and restore require both tokens; edit and delete require
`routesRevision`; the server recomputes both under the adapter lock
immediately before mutation and returns HTTP 409 on mismatch with no backup,
store, manifest, or target mutation. Successful apply and restore return the
new tokens. The frontend stores the loaded tokens and submits them with each
mutation.

## Route-store, fingerprint, manifest, and activity lifecycle

- Route store (`app/state/claude-routes.json`): versioned shape
  `{ version: 1, appliedRouteId, appliedRouteConfigSha256, routes[] }`.
  `appliedRouteId` and `appliedRouteConfigSha256` are set atomically on apply;
  a route renders as applied only when its id and its canonical config
  fingerprint (`configSha256`, derived per route response) both match. Editing
  the applied route produces a fingerprint mismatch rendered as
  "Changes not applied" until the user explicitly applies. A null applied id
  requires a null fingerprint.
- Backup manifest (`app/state/claude-backup-manifest.json`): capped at 10
  entries. Each entry records backup name and SHA-256, pre- and post-write
  target hashes, target binding, applied and previous applied route id and
  fingerprint, previous store backup metadata, timestamps, core version, and
  schema identity.
- Prune and pop: a successful restore pops the consumed newest entry so the
  next restore walks backward one transaction. Adding an eleventh entry
  prunes only the oldest manifest-owned backups after validating filename,
  containment, binding, and hash; all validation happens before any move, and
  moves use transaction-unique create-new staging names. A failure unstages
  and rolls back, so no manifest ever references deleted backups. Deletion
  finalization runs only after the commit completes; an injected deletion
  failure returns a generic hard failure, never success, and preserves exactly
  the verified evidence file that could not be deleted (the residual
  hard-failure evidence condition accepted in Gate 4A).
- Activity log (`app/state/claude-activity.jsonl`): exactly the newest 200
  valid single-line events, each `{ "ts", "type", "routeId" }`; user-entered
  route names never appear. Route create/edit/delete/apply/restore and failure
  events are recorded; store-plus-activity commits are rollback-backed.

## Canonical source mapping

The Switcher app surface treats `app/engine/claude-code/` (shared routing
core, fixture and production entry points, fixtures, harness) as the canonical
implementation location and `app/state/claude-routes.json` as the canonical
route source. The research plan's root-level canonical proposal
(`providers/claude-code.json`, `profiles/<profile>/claude-settings.json`,
root `schemas/`, `scripts/`) remains the proposal for a future BDF-native
surface and is not created by Gate 4 (see `planning/DECISIONS.md`, 2026-08-14).

## Real-target locks

Two independent locks protect the real user profile:

- HTTP-layer lock: `ALLOW_REAL_CLAUDE_TARGET = False` in the adapter backend.
  While locked, every mutating endpoint returns HTTP 503 and status and
  discovery report the locked state without probing the real layout.
- PowerShell-layer lock: the production entry rejects a profile root equal to
  the process user profile unless `-AllowRealTarget` is passed.

Gate 5 is the only authority that may unlock either lock; Gate 4 never passes
`-AllowRealTarget` and never flips the HTTP constant.

## Version detection and compatibility obligations

- The adapter records the detected Claude Code version (2.1.153 as observed in
  Gate 1) per compatibility row and never assumes future versions.
- Adapter implementation version: 0.2.0 (authoritative constant in
  `claude-routing-core.psm1`).

## Restart expectations

"Restarting Claude Code may be required for startup-only values." Startup-only
values are not reloaded live; the adapter displays this notice and does not
claim live reload.

## Release and support boundary

- Current status: **Live validated** (2026-08-17, corrected Gate 5B pass + Gate
  5C approved) for the env-only routing scope exercised by the gate.
- The real-target lock stays closed until the owner opens it; apply/restore
  return 503 by default.
- No release entry exists for this adapter.

---

**Document Version:** 1.1

**Status:** Live validated
