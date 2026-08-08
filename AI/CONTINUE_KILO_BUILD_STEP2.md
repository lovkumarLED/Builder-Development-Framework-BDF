# CONTINUE — KILO_BUILD (step 2 of 8)

> Resume file. Read first, then continue where work stopped.

## Topic
KiloCode Builder V1 (K1) — adapt OpenCode v2.7 builder into `~/.config/kilo` per `docs/AI/BUILD_KILOCODE_V1.md`.

## Done
- Researched Kilo: fork of OpenCode. Global `~/.config/kilo/kilo.jsonc` (schema `https://app.kilo.ai/config.json`); legacy fallback `kilo.json` / `opencode.json[c]`; project `.kilo/kilo.jsonc`. Real user configs exist at `~/.config/kilo/kilo.jsonc` + `kilo.json` (reference only, contains literal API keys — never modify).
- Created kilo subdirs: `scripts`, `profiles\default`, `providers` (empty), `schemas`, `backup`, `docs`.
- Copied templates: `scripts\build-kilo-v1.ps1` (copy of `build-opencode-v2.7.ps1`) and `scripts\test-kilo-v1.ps1` (copy of `test-opencode-v2.7.ps1`).
- Transformed build script (11 pairs, verified on disk): ConfigRoot→`.config\kilo`; `$BuilderVersion`→`1.0 (K1)`; `$TargetArtifact`→`kilo.jsonc`; extension guard accepts `.jsonc`; sprint header → `Generate kilo.jsonc from modular profile files. (Builder V1 K1 - KiloCode Adapter)`; banner → `KiloCode Config Builder V1 (K1) Adapter`; `builderVersion`→`K1`; finish/dry-run messages → `Builder K1`. **Merge-Settings passthrough injected** (settings.json = sole source of `$schema` + every other top-level Kilo key; `activeProviders` consumed, never emitted).
- Transformed test script (12 pairs): `kilo-builder-tests`, `build-kilo-v1.ps1`, `-Filter "kilo_*.json"`, `kilo.provenance.json`, `kilo.jsonc`, schema URL → `https://app.kilo.ai/config.json`, `$Prov.builderVersion -eq "K1"`, harness title, `BUILDER_SPEC_KILO_ADAPTER.md`.
- Fixed build comment line 19? NO — one `opencode` ref remains in build script (target.json comment block).

## Next
1. Sweep residual refs:
   - `build-kilo-v1.ps1` — line ~19 comment `default opencode.json` → `kilo.jsonc`. Also verify line 51-52 comment block updated (artifact comments still say opencode).
   - `test-kilo-v1.ps1` — 3 comment refs (line 160 `build-opencode-v2.5.ps1` → kilo; line 1394 `Non-opencode artifact` comment; line 1435 legacy `'opencode_*'` prefix assert — decide keep or reword).
   - `test-kilo-v1.ps1` **lines 726 + 1357**: `$SpecPath = "C:\Users\loveb\.config\opencode\docs\BUILDER_SPEC_KILO_ADAPTER.md"` → must become `C:\Users\loveb\.config\kilo\docs\BUILDER_SPEC_KILO_ADAPTER.md`.
   - Grep helper: search both scripts for `opencode` → expect 1 build / N test refs after cleanup.
2. **Create `~\.config\kilo\docs\BUILDER_SPEC_KILO_ADAPTER.md`** — Kilo-adapted spec. MUST contain tokens the harness checks:
   - Test 12 (V2.5): `Discover-Providers`, `Select-ActiveProviders`, `Persist-ActiveProviders`, `Get-ProfileProviderModels`, `-NonInteractive`, `<provider>-models.json`.
   - Test 28 (V2.7): `F1-F7` tokens (read test-opencode list: F1 schema, F2 preflight, F3 WhatIf, F4 backup retention, F5 provenance, F6 doctor, F7 diff summary) — check exact tokens the harness greps for.
   Recommend copy `~/.config/opencode/docs/BUILDER_SPEC.md` → kilo spec, then sed the name references (opencode→kilo, schema URL) without breaking tokens.
3. **Fixtures** under `~/kilocode/config/kilo` (or test temp dirs): (a) `schemas` — copy `*.schema.json` from `~/.config/opencode/schemas/`; (b) `profiles/default` — settings.json (with `$schema` + `activeProviders`), `models.json`/`<provider>-models.json`, `mcp.json`, `plugins.json`, optional `target.json`; (c) `providers/modal.json` or repo style `providers/<id>.json` with `{env:VAR}` placeholders only — NO literal keys.
4. **Run** `powershell -ExecutionPolicy Bypass -File ~\.config\kilo\scripts\test-kilo-v1.ps1` → expect 30/30.
5. If green: sanity openCode harnesses unaffected (`~/.config/opencode/scripts/test-opencode-*.ps1` 17/13/30 still pass).
6. Real K1 run on `profiles/default`: verify backup retention, provenance sidecar, output `kilo.jsonc`.
7. Docs: update `docs/ROADMAP.md`, `docs/release_registry.json` entry, `_agent/JOURNEY_TO_V3.md`, CHANGELOG, report.

## Verify
- `Select-String -Path .\build-kilo-v1.ps1,..\test-kilo-v1.ps1 -Pattern 'opencode'` — build should show 0-1 comment-only; test 0-2 comment-only + 0 specpath pointing to opencode.
- `Test-Path C:\Users\loveb\.config\kilo\docs\BUILDER_SPEC_KILO_ADAPTER.md` = True with required tokens.
- `Test-Path C:\Users\loveb\.config\kilo\schemas\*.schema.json` non-empty.

## Decisions
- Kilo points spec at `C:\Users\loveb\.config\kilo\docs\BUILDER_SPEC_KILO_ADAPTER.md` (kilo docs dir, not opencode dir).
- KV1 `$BuilderVersion = "1.0 (K1)"`, passes K1 provenance marker `builderVersion: "K1"`.

## Questions
- None blocking. (Founder rule: no destructive ops without asking; no git commit.)

## Resume
Paste into next opencode session (primary agent, ~/.config/kilo build):

```
Read C:\Users\loveb\.config\opencode\docs\AI\CONTINUE_KILO_BUILD_STEP3.md

Follow AGENT.md + _agent/SESSION_WORKFLOW.md + README.md conventions.
Do NOT restart Kilo build from scratch. The transform setup is DONE (scripts present, 11+12 pairs applied).
LOW CONTEXT MODE: <60% work fast; 60-75% delegate reads to reader subagents; 75% stop, write checkpoint.
Fix the following (verify each with grep — expect 1 build ref + 2 comment refs remaining, then assert 0 in paths pointing to .config\opencode):
  1. build-kilo-v1.ps1 line 19 comment: default opencode.json → kilo.jsonc
  2. test-kilo-v1.ps1 line 726 + 1357: opencode/docs → kilo/docs BUILDER_SPEC_KILO_ADAPTER.md
  3. Create kilo spec at docs/BUILDER_SPEC_KILO_ADAPTER.md covering tokens (V5 + F1-F7 groups exactly as harness checks) — start from opencode docs/BUILDER_SPEC.md copy, rename only.
  4. Fixtures: schemas/*.schema.json + providers/modal.json + profiles/default/{settings,models or modal-models,mcp,plugins,target}.json with {env:VAR} only — no literal keys.
  5. Run test-kilo-v1.ps1 → 30/30. Then opencode harnesses still green. Sanity K1 build real.
  6. Update ROADMAP.md, release_registry.json, JOURNEY_TO_V3.md, CHANGELOG, report. No commits.
  7. If context gets low, write CONTINUE_KILO_1_<STEP>.md with Done/Next/Verify/Rules and give me the resume prompt.
```

Every stop: update `docs\AI\CONTINUE_*.md` + `_agent\SESSION_LOG.md` + `_agent\JOURNEY_TO_V3.md`, then paste resume prompt.