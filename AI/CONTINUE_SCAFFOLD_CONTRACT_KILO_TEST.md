# CONTINUE — SCAFFOLD CONTRACT + KILO BUILDER TEST (session 28b handoff)

> Resume file. Read first, then continue exactly where the work stopped.

## Topic

V3 scaffold contract finalized per user ruling (session 28b):

- The framework creates the `providers/` folder (like the profile folders), but
  NEVER writes provider or model JSON files inside it. Provider and model files
  are 100% user-owned.
- ONE job: scan the agent's OWN main JSON (kilo.json for kilo — never another
  agent's config), split mcp / plugin sections, seed the profiles.
- Always create `profiles/coding` (main) + `profiles/experimental` +
  `profiles/minimal`, each with exactly three files: `settings.json`, `mcp.json`,
  `plugins.json`.
- `coding/mcp.json` + `coding/plugins.json` are seeded from the agent's own main
  JSON once (if missing) and are USER-OWNED afterwards — never overwritten.
- `experimental/` + `minimal/` get EMPTY `mcp.json`/`plugins.json` — never filled
  by the framework.
- `settings.json` is the only file the framework writes freely: `$schema` +
  `activeProviders` (detected from the main config). NEVER copy-paste the config.
- Works for ANY open-source coding agent (Aider, Goose, Codex-Cli, ...): discovery
  first; if none found, ask the user for the location of their coding agents.
  Closed-source agents never touched.

## Done (this session)

- `scripts/scaffold-agent.ps1` rewritten to the new contract:
  - Scans ONLY the agent's primary main JSON (registry order, first match).
  - Seeds coding mcp/plugins if missing; creates EMPTY shells for
    experimental/minimal; never overwrites existing mcp/plugins.
- `settings.json` minimal (`$schema` + `activeProviders`), never the full shape.
- Provider section = guidance only; the providers/ folder IS created (like the
  profile folders) but its JSON files are never written by the framework.
  - `-List`, discovery, ask-for-location, `-Bootstrap`, Non-JSON guard, error
    self-fix all preserved.
- Cleaned framework-created model files (user-owned domain):
  - `kilo/profiles/coding/omniroute-models.json` — removed.
  - `opencode/profiles/experimental/omniroute-models.json` +
    `opencode/profiles/minimal/omniroute-models.json` — removed.
  - `kilo/providers/omniroute.json` — was removed during cleanup, then RESTORED
    (user ruling: the framework creates the providers/ folder, but the JSON files
    inside are the user's — the user had created omniroute.json themselves).
- Reset kilo profile `settings.json` files to the minimal shape
  (`$schema` + `activeProviders`), like the OpenCode reference.
- Kilo test (backup-first): main `kilo.json` + `kilo.jsonc` + profiles backed up
  to `%TEMP%\opencode\kilo-backup-20260808-071644` BEFORE the test.
  - `test-kilo-v1.ps1` → 30/30 PASSED, exit 0.
  - Main `kilo.json` byte-identical after the test (backup policy verified —
    the system always backs up before touching, so no worry).
  - Real `build-kilo-v1.ps1 -Profile coding` with the user's restored
    `kilo/providers/omniroute.json` fails at the models guard ("models not found")
    — provider file is read correctly; the models source is the user-owned part.
- Docs updated: `BUILDER_SPEC.md`, `bdf/templates/BUILDER_SPEC.template.md`,
  `kilo/docs/BUILDER_SPEC_KILO_ADAPTER.md` (Contract rewritten),
  `PROJECT_STATE.md` (scaffold description + framework 2.2.4),
  `FOLDER_STRUCTURE.md` (V3 scaffold profile shape section),
  `ROADMAP.md` (Phase 13 definition of complete + status),
  `planning/BDF_ROAD_TO_V3.md` (Supported Projects + Definition of V3 rules),
  `planning/NEXT_PHASE_IMPLEMENTATION_PLAN.md` (Phases 5 + 7),
  `_agent/JOURNEY_TO_V3.md` (session 28b step record),
  `bdf/VERSION.md` (2.2.3 → 2.2.4, version-bump rule for template change).
- Release manager: deterministic (run 1 wrote bdf/VERSION.md rows, run 2 no-op exit 0).

## NOT done this session (explicitly deferred)

- The full framework system check was NOT run this session (it takes a lot of
  context/tokens; a full battery across every project and the clean-room
  regeneration was not executed).
- The kilo builder real-config build test could not complete end-to-end because
  the provider file (`kilo/providers/omniroute.json`) has no models source yet
  (empty `models: {}` and no `<provider>-models.json`) — the models source is
  user-owned. The harness (fixture-based) is green 30/30; the real build needs
  the user's own models.
- Same for opencode `experimental`/`minimal`: their framework-created
  `omniroute-models.json` was removed per the contract, so those two profiles
  abort with "No active providers selected" until the user adds their own model
  files — expected, by design. The `coding` profile (user-owned models) builds
  fine.

## Next (next session — ONLY this)

1. Run the kilo builder test the way we build inside kilo:
   - Backup-first is automatic (the system always backs up the main JSON before
     touching anything — verified this session).
   - The real build is ALREADY GREEN (session 28c): provider file + models
     source restored, `build-kilo-v1.ps1 -Profile coding` completes, `kilo.json`
     regenerated, provenance stamped, rerun idempotent.
   - Re-run `test-kilo-v1.ps1` → expect 30/30.
   - Verify main `kilo.json`/`kilo.jsonc` are unchanged by the tests (byte check).
2. Nothing else. No other checks, no other batteries.

## Verify (how to confirm this checkpoint)

- `powershell -File C:\Users\loveb\.config\kilo\scripts\test-kilo-v1.ps1` → 30/30 exit 0.
- `powershell -File C:\Users\loveb\.config\kilo\scripts\build-kilo-v1.ps1 -Profile coding -NonInteractive` → finishes successfully, exit 0.
- `Test-Path C:\Users\loveb\.config\kilo\providers` → True (folder created by the framework; JSON files inside are user-owned).
- `kilo/profiles/coding` contains `settings.json`, `mcp.json`, `plugins.json`, `omniroute-models.json` (user-owned models source).
- `scaffold-agent.ps1 -List` → discovers opencode, kilo, claudecode, codex-cli.
- No-Secrets Rule: system artifacts (scripts/templates/docs) contain zero literal API keys; user files may contain their keys.

## Decisions

- Two-world rule (ULTIMATE): user-owned files (main config, profiles, providers)
  may contain literal API keys — user protects them. System artifacts (scripts,
  templates, docs, examples) NEVER contain literal keys — `{env:VAR}` only.
  The system copies user content verbatim (scan → copy → paste).
- Providers + models are 100% user-owned; the framework creates the providers/
  folder (like the profile folders) but never writes the JSON files inside it.
- mcp.json/plugins.json are user-owned after creation; the framework never
  overwrites them.
- experimental/minimal mcp.json + plugins.json are created empty, never filled.
- settings.json is the only framework-written file (`$schema` + `activeProviders`).
- Each agent's profiles are seeded from that agent's OWN main JSON only.

## Questions

- None blocking.

## Resume prompt

```
Read C:\Users\loveb\.config\opencode\docs\AI\CONTINUE_SCAFFOLD_CONTRACT_KILO_TEST.md

Follow AGENT.md + _agent/SESSION_WORKFLOW.md.
Do NOT restart or redo completed work — trust the checkpoint file.
Run the Verify step first.
Next: ONLY the kilo builder test (backup-first is automatic):
  1. If the user created their own provider files, run build-kilo-v1.ps1 -Profile coding -NonInteractive and confirm kilo.json is generated.
  2. Re-run test-kilo-v1.ps1 (expect 30/30) and byte-check the main kilo.json/kilo.jsonc.
  3. Nothing else.
```
