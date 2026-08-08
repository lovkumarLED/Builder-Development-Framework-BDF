# CONTINUE — V3 Universal Agent Framework (Step 3, Framework Improvements)

> FILE-NAME NOTE (session 28): this file is named CONTINUE_KILO_BUILD_STEP3.md but its
> content is the session-24b **V3 Universal** checkpoint; the Kilo step-3 content was
> superseded by this universal checkpoint mid-chain. Successor checkpoints:
> `CONTINUE_V3_UNIVERSAL_FRAMEWORK.md` and `_v2.md`. Kept as historical record.

Session stop → resume point. Session 24b (Aug 7, 2026). K1 harness 30/30, OpenCode 17/13/30 all green.

## Done
- `opencode\scripts\scaffold-agent.ps1` rebuilt as the V3 UNIVERSAL core:
  - Open-source agent registry (extensible `$AgentRegistry`): opencode, kilo, claudecode, aider, goose, codex-cli.
  - Discovery: auto-select single agent; multi-agent picker; when none found → asks user
    "Give me the location of your coding agents" (config folder) and uses it.
  - `-List` prints discovered open-source agents only. Closed-source never touched.
  - Scan-first V3 contract: read main config(s) → split provider/mcp/plugin →
    paste into profiles (coding always default) → settings (schema-based, idempotent) →
    never writes provider/models files → never touches .jsonc without consent.
  - `-Bootstrap`: generates build-<agent>.ps1 + test-<agent>.ps1 + scaffold-<agent>.ps1
    for any discovered/custom agent (verified on sandbox `custom` agent: build-custom/
    test-custom/scaffold-custom all generated).
  - Error self-fix: top-level trap writes promoted diagnosis + -Doctor hint on any error.
- Wrappers preserved: scaffold-kilo-v1.ps1 + scaffold-opencode.ps1 delegate to universal.
- Docs updated:
  - `planning/BDF_ROAD_TO_V3.md`: Supported Projects → V3 UNIVERSAL (any OSS agent),
    Universal-Agent Rule (1-8), Definition of V3 universal.
  - `ROADMAP.md`: Phase 12 Claude is superseded (registry entry), Phase 13 V3 Builder
    Generator → "Discover installed open-source coding agents", Definition of complete
    universal + error-fix rule.
  - `BUILDER_SPEC.md` (opencode) + `BUILDER_SPEC_KILO_ADAPTER.md` → v1.2 Universal mode.
  - `JOURNEY_TO_V3` Step 3 gets "universal3 core" milestone (session 24b).
- Verified: `-List` on this machine → opencode, kilo, claudecode, codex-cli.
- Full battery: kilo 30/30, oc 2.7 30/30, oc 2.1 17/17, oc 2.5 13/13 — all PASS.

## Open
1. Real bootstrap run against a freshly-discovered third-party agent (e.g. aider or
   goose) — the Sandbox test used a synthetic custom agent only.
2. V3 error-loop: make the trap ALSO suggest running generated `build-<agent>.ps1 -Doctor`
   end-to-end in one flow (currently hint only; builders already have -Doctor).
3. Registry is open (add-a-line); expand with more OSS agents as needed.
4. coding/mcp.json overwrite policy decision (carried from prior session): keep-if-exists
   vs current always-refresh.

## Next (when resumed)
1. Bootstrap a real third-party agent (point at an agent config folder), run its builder
   build, verify profiles → config generation.
2. Wire scaffold `-Bootstrap` to also run `-Doctor` / self-check after generating.
3. If user wants: add aider/goose to the harness battery as discovery-only tests.
4. No commits until asked.

## Verify
- `scaffold-agent.ps1 -List` prints only open-source agents found.
- For any agent: profiles/{coding,experimental,minimal} created; coding has mcp.json,
  plugins.json, settings.json; providers/ folder exists but NEVER written with provider/
  models files; .jsonc untouched unless -y prompt.
- `test-kilo-v1.ps1` 30/30; `test-opencode-v2.7.ps1` 30/30; v2.1 17/17; v2.5 13/13.

## Rules
- V3 is universal: any open-source coding agent with a local .json config is supported.
- Closed-source agents never read/written.
- Never touch .jsonc without user consent.
- Scan first, write second. Coding is always the default profile.
- Framework never writes provider/models files; user owns them.
- Every error → diagnosis + fix + rerun (self-fix loop).
- No commits until user asks.