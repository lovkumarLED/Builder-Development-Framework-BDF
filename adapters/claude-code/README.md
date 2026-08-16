# Claude Code Adapter

Lifecycle status: **Integrated, not live validated**

Evidence date: 2026-08-14

## Purpose and audience

This document set describes the Claude Code adapter inside the Switcher app:
a narrow, scalar routing adapter that manages exactly one Claude Code route at
a time through a shared routing core. It is written for app developers, Claude
Code users, and AI agents extending the adapter.

Claude Code is fundamentally different from OpenCode and KiloCode. It is NOT a
provider registry, a plugin manager, an MCP manager, or a full Claude settings
generator. This adapter manages only the approved routing fields and preserves
every unsupported semantic value.

## Current lifecycle status

**Integrated, not live validated.** This means the adapter is integrated into
the app and its production-path logic is proven on temporary fixture copies. It
is NOT supported for normal use, and it does not imply Gate 5 evidence. Stronger
statuses ("Supported", "Production ready", "Live validated") require approved
live validation against a real Claude installation, which is Gate 5 and remains
unauthorized.

## Reading order

1. `ADAPTER.md` - authoritative target contract (managed sources, exclusions,
   configuration model, transaction contract).
2. `BUILDER_SPEC.md` - executable behavior contract for the shared routing core
   and both entry points.
3. `TESTING.md` - verification guide and authorized test groups per gate.
4. `COMPATIBILITY.md` - versioned evidence ledger.
5. `README.md` (this file) - entry point.

## Scope at this status

Managed by this adapter:

- Only the top-level `env` object of the user-scope Claude settings target
  (`settings.json`) is surgically patched, and only for exactly one scalar
  routing profile: endpoint base URL, exactly one auth strategy by
  environment-variable reference, `ANTHROPIC_MODEL`, and the four curated
  compatibility options. Top-level `model` and every unrelated byte are
  preserved exactly; the document is never regenerated.
- Saved routing profiles (multiple saved, exactly one applied) in the app-owned
  route store, with backup/restore status and redacted routing activity.

Explicitly NOT managed (Claude-owned, read-only or unsupported; zero access):

- Marketplaces, plugin installation, MCP servers, skills, permissions, hooks,
  memory, sessions, credentials, prompts, and transcripts.
- The Claude state file, `.claude/plugins`, project/local settings, `.mcp.json`,
  FCC executables, and anything under `.local\bin`.

## Implementation and schema locations

- Shared routing core: `app/engine/claude-code/claude-routing-core.psm1`
  (adapter implementation version 0.2.0).
- Fixture entry point: `app/engine/claude-code/build-claude-code.ps1`.
- Production entry point: `app/engine/claude-code/build-claude-code-production.ps1`.
- Routing schema: `app/engine/schemas/claude-code-routing.schema.json`.
- App-owned runtime state (Git-ignored): `app/state/claude-routes.json`,
  `app/state/claude-backup-manifest.json`, `app/state/claude-activity.jsonl`.
- Adapter backend: `app/app/claude_adapter.py`; capabilities:
  `app/app/capabilities.py`.

## Evidence gates reached and not reached

- Gate 1 (read-only research): reached - `planning/CLAUDE_CODE_GATE_1_RESEARCH_REPORT.md`.
- Gate 2 (fixture-only builder): reached - 65/65 harness (51 prior + 14
  env-only surgical tests), `planning/CLAUDE_CODE_GATE_2_FIXTURE_BUILDER_REPORT.md`.
- Gate 3 (provider/model behavior): reached - overall pass,
  `planning/CLAUDE_CODE_GATE_3_PROVIDER_MODEL_REPORT.md`.
- Gate 4A (app integration and production-path logic): reached -
  `planning/CLAUDE_CODE_GATE_4A_IMPLEMENTATION_REPORT.md` and its three repair
  rounds.
- Gate 4 (integration documentation): this document set and
  `planning/CLAUDE_CODE_GATE_4_APP_INTEGRATION_REPORT.md`.
- Gate 5 (approved live validation): NOT reached and NOT authorized. Gate 5B.4
  remains historical `HARD_FAILURE` evidence under the superseded broad
  ownership contract; the corrected env-only scope is documented in
  `planning/CLAUDE_CODE_SETTINGS_ONLY_SCOPE_CORRECTION_DESIGN.md` and its
  implementation report.

## Governing decisions

- Historical drop decision (2026-08-08): Claude Code was excluded from the
  universal OpenCode/Kilo architecture; that decision remains historical and is
  not rewritten.
- Narrow reversal (2026-08-14): a unique bounded routing adapter is approved;
  see `planning/DECISIONS.md`.
- Approved documentation architecture:
  `planning/UNIQUE_AGENT_ADAPTER_DOCUMENTATION_DESIGN.md`.
- Authoritative Claude research plan:
  `planning/CLAUDE_CODE_BDF_ADAPTATION_RESEARCH_PLAN.md`.

## Warning

Fixture, integration, and production-path evidence must never be interpreted as
a stronger status. This adapter is **Integrated, not live validated** until
approved Gate 5 live validation passes and is released. Gate 5 is not
authorized by this document.

## Document versions

| Document | Version |
|---|---|
| README.md | 1.0 |
| ADAPTER.md | 1.0 |
| BUILDER_SPEC.md | 1.0 |
| TESTING.md | 1.0 |
| COMPATIBILITY.md | 1.0 |

---

**Document Version:** 1.0

**Status:** Integrated, not live validated
