# CONTINUE — V3 UNIVERSAL AGENT FRAMEWORK (checkpoint after session 25)

Resume point for the next session. Scope: everything scheduled in the session-24b
checkpoint is DONE. No full system check ran this session (per design, same as 24c).

## Context
- `scripts/scaffold-agent.ps1` = V3 universal core (registry: opencode, kilo, claudecode,
  aider, goose, codex-cli; discovery + `-List` + multi-agent picker + "give me your config
  folder" prompt; scan-first split → profiles (coding always default); `-Bootstrap`).
- Wrappers: `scaffold-kilo-v1.ps1` / `scaffold-opencode.ps1`.
- Docs: BUILDER_SPEC + BUILDER_SPEC_KILO_ADAPTER → v1.2 (Universal Scaffold Mode);
  planning/BDF_ROAD_TO_V3.md (Universal-Agent Rule 1-8); ROADMAP (Phase 12 superseded,
  Phase 13 in progress); JOURNEY_TO_V3, SESSION_LOG (session 25).
- Harnesses green: kilo 30/30, opencode 2.7 30/30, 2.1 17/17, 2.5 13/13.

---

## Done this session (session 25 — do not redo)

### 1. Real OSS-agent bootstrap (main untested path — now verified)
- Sandbox with REAL opencode.json content (`%TEMP%\opencode\bootstrap-real`):
  `scaffold-agent.ps1 -Agent opencode -ConfigRoot <sandbox> -Bootstrap -NonInteractive`
  → generated `build-opencode.ps1` + `test-opencode.ps1` + `scaffold-opencode.ps1`.
- Generated builder run: `build-opencode.ps1 -ConfigRoot <sandbox> -Profile coding
  -NonInteractive` → exit 0, opencode.json written (9 mcp servers, 18 models),
  provenance sidecar stamped, backup created, "No changes detected" on rerun.
- Generated builder `-Doctor` → exit 0, 0 issues, reports target artifact + profile.
- Clean-room rebuild: delete generated 3 scripts → re-run -Bootstrap → rebuild →
  **byte-identical hash** (C4424BDB...B52F both runs). Determinism proven.
- Bug found + fixed: `-Bootstrap` re-scan picked up `opencode.provenance.json` as a
  main config on reruns (noise). Fix: main-file filter now excludes `.*provenance`.

### 2. coding/mcp.json overwrite policy — RESOLVED (user decision)
- User picked **refresh-with-backup**: scaffold ALWAYS refreshes mcp.json/plugins.json
  from the main target, but snapshots the previous file first to `backup/<tag>_<ts>.json`.
- Applied to ALL profiles (coding + experimental + minimal), both mcp.json and
  plugins.json (user: "same do what you prefer" for shells).
- Implemented in scaffold-agent.ps1: `Backup-ProfileFile` + `Write-ProfileJson`.
- Old `Assert-EmptyShell` removed (superseded — empty shells only when main has nothing).

### 3. Full kilo settings shape (real gap — now modeled + verified)
- Root cause: `Merge-Settings` in build-kilo-v1.ps1 already passes through every
  top-level key except `$schema`/`activeProviders`, but scaffold wrote settings.json
  with only those two keys → real build dropped model/agent/permission/skills.
- Fix (scaffold-agent.ps1): scan phase now collects EVERY other top-level section
  (model, small_model, agent, permission, username, hide_prompt_training_models,
  default_agent, experimental, skills, disabled_providers) into `$SettingsSections`;
  `Merge-SettingsSections` seeds them into profile settings.json:
  - file missing → create with schema + activeProviders + full shape;
  - file exists → merge ONLY missing keys, never clobber user-owned keys
    (verified: deleted `username`, rerun restored it; `activeProviders` kept).
- Verified in kilo sandbox (`%TEMP%\opencode\bootstrap-kilo`, real kilo.jsonc content,
  consent path via `echo y|`): build-kilo-v1.ps1 reproduces ALL 13 top-level sections
  ($schema, model, small_model, agent, permission, username, hide_prompt_training_models,
  default_agent, experimental, skills, mcp, disabled_providers, provider).
- 10/10 non-provider sections byte-identical vs real `~/.config/kilo/kilo.jsonc`.
- Consent path for .jsonc re-verified via `cmd /c "echo y| powershell -File ..."`.

### 4. aider/goose seeds — no-op
- Neither ~/.aider nor ~/.config/goose exists on this machine. Registry seeds remain;
  nothing to validate. `-List` still finds opencode, kilo, claudecode, codex-cli.

### 5. Harness battery (health gate, per session-24b rule)
- kilo 30/30, oc 2.7 30/30, oc 2.1 17/17, oc 2.5 13/13 — all PASS exit 0.
- Real `~/.config/kilo/kilo.jsonc` untouched (all testing done in sandboxes).

---

## Next (nothing mandated; optional follow-ups)
- (Optional) Update BUILDER_SPEC.md / BUILDER_SPEC_KILO_ADAPTER.md scaffold sections to
  document: refresh-with-backup policy + full-shape settings seeding + provenance
  exclusion (spec currently says "settings only if missing", now stale).
- (Optional) Run scaffold on the REAL ~/.config/kilo with consent (echo y) to seed the
  full shape into the real coding/settings.json — NOT done this session; real config
  left untouched by design. If user wants it, run:
  `cmd /c "echo y| powershell -File ~\.config\opencode\scripts\scaffold-agent.ps1 -Agent kilo -ConfigRoot ~\.config\kilo"`.
- (Optional) Real opencode config: same consent-free path (`-Agent opencode -ConfigRoot
  ~\.config\opencode`); scaffold now refreshes-with-backup, so it's safe.
- (Optional) Commit docs — never until asked.

## Verify (how to confirm this checkpoint)
- `%TEMP%\opencode\bootstrap-real\scripts\build-opencode.ps1` exists + runs (exit 0).
- `%TEMP%\opencode\bootstrap-kilo\profiles\coding\settings.json` contains all 13 keys.
- `Select-String 'Assert-EmptyShell' scaffold-agent.ps1` → 0 hits.
- Harness battery: kilo 30/30 + oc 30/17/13.

## Decisions
- mcp/plugins refresh policy = refresh-with-backup (user chose option 3 of 3).
- settings.json = merge-missing-keys only (never clobber user edits/activeProviders).
- `.provenance.json` files never scanned as main configs.
- Real kilo/opencode configs NOT touched this session; all verification sandboxed.

## Questions
- None open.

## Rules
We are NOT running a full system check next session either. The harness battery is the
health gate, not a full system check. Do NOT plan, run, or extend `AI/FULL_SYSTEM_CHECK.md`.

## Resume prompt
"Resume from `docs/AI/CONTINUE_V3_UNIVERSAL_FRAMEWORK.md`. Skip all mentions of a full
system check for THIS session. All four checkpoint tasks are DONE (real opencode
bootstrap verified: build+Doctor+byte-identical rebuild; mcp.json policy = refresh-with-
backup; full kilo settings shape modeled + 10/10 sections match; aider/goose no-op).
Optional next: (a) update BUILDER_SPEC scaffold docs (refresh-with-backup + full-shape
seeding), (b) run scaffold on REAL ~/.config/kilo or ~/.config/opencode with consent,
(c) commit docs on request.
Files: scaffold-agent.ps1 (universal core, edited this session), build-kilo-v1.ps1 /
build-opencode-v2.7.ps1 (unchanged, Merge-Settings passthrough is the mechanism),
BUILDER_SPEC.md + BUILDER_SPEC_KILO_ADAPTER.md (scaffold sections now stale)."
