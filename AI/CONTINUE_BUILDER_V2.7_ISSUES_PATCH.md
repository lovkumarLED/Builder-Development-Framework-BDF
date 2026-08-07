# Continue Builder V2.7 — Issues & Patch

> Handoff MD. Read FIRST, then execute in order: System Check -> Fix Plan -> Re-verify -> Report.
> Created 2026-08-06. Follow `bdf/AI_WORKFLOW.md` and the handoff rules in `docs/AI/CONTINUE_PROJECT_BUILD.md`.

---

## 1. REAL SESSION PROBLEMS (user-confirmed; hallucination parts removed)

**P1 — Live API key embedded in the build.**
The user reported the builder output contains their live Modal API key. Root cause (verified): I restored `providers/modal.json` from a backup **verbatim**, copying the literal `apiKey` value into the source and therefore into the generated `opencode.json`.
User position: the builder must NEVER carry, restore, or invent API keys. Keys may only appear if a profile/provider source file already contains them. No feature exists that "finds" keys — the leak was my manual restore.

**P2 — Static artifact name (design change requested).**
The builder hardcodes one target artifact (`opencode.json` in 6 places: output write path, backup prefix `opencode_*`, provenance default `opencode.provenance.json`, -WhatIf messages, F7 diff naming, F5 docs). User wants the target artifact name to be **dynamic and resolved when a profile runs**, never fixed in the builder code — so the same builder can later generate for another target (e.g. Claude Code) by profile configuration.

**P3 — Context-window handoff discipline.**
The previous session overran one window and produced the handoff MD only at the end. Rule (CONTINUE_PROJECT_BUILD.md): write the handoff MD + a ready-to-paste continuation prompt BEFORE ~80% of the window is consumed, not after. This MD therefore comes early and is the checkpoint for every further session.

**P4 — Regression proof required after fixes.**
Because real builds changed outside-git artifacts (modular.json, opencode.json, provenance, backups), every fix must be followed by the full verification battery (Section 3), not just a single harness.

---

## 2. RETRACTED (user-confirmed hallucination — DO NOT fix)

- "Builder generates a models.json into the profile from omniroute-models.json" — NOT reproducible: verified via grep+filesystem, no builder writes `models.json` anywhere; no `models.json` exists in any profile. Was a test fixture left visible.
- "Builder brings back a deleted provider from backup" — NOT a feature: `Get-LatestBackupConfig` is used only for the F7 diff; the provider reappeared because I manually restored `providers/modal.json`. Removal of manual restores is folded into P1.

---

## 3. SYSTEM CHECK (run first, before touching fixes)

1. Harness battery — must all pass, exit 0:
   `scripts/test-opencode-v2.ps1` (17/17), `scripts/test-opencode-v2.5.ps1` (13/13), `scripts/test-opencode-v2.7.ps1` (30/30 — was 28, +Test 29 dynamic artifact +Test 30 no-literal-keys).
2. Baseline script hashes unchanged (V2.1/V2.5 frozen): build80C57810D991711A / test2CB4AC994F79CC5A / buildv2.1 78E905FD42B4C641 / testv2.1 7202BB22C287EAC0.
3. Real-world: `-Doctor` on coding + default (expect 0 issues, exit 0), `-WhatIf` on coding, real default build twice (byte-identical hash + "No changes detected vs previous backup.").
4. **Key scan** (the P1 gate): search providers/ + generated opencode.json + provenance for a literal `apiKey` value that does NOT look like `{env:...}`. Expectation after fix: zero.

---

## 4. FIX PLAN (step 2 — style chosen by user, see Section 5)

### 4.1 P1 fix (mandatory regardless of option)
- Sanitize `providers/modal.json`: replace the literal `apiKey` with the placeholder `{env:MODAL_API_KEY_OPENCODE}` (matches omniroute convention).
- Regenerate `opencode.json`; confirm the literal key no longer appears in it or the provenance.
- Add a note in `docs/BUILDER_SPEC.md` (verbatim) + a reminder in the harness the generated output must contain only env-placeholder keys.
- Do NOT copy any key-bearing content out of backups again. If a provider file is missing, pre-flight F2 will report it; do not "restore" it.

### 4.2 P2 — dynamic artifact (design gate)
Two candidate shapes (pick via Section 5, or ask user):
- **Option 1 — profile-sourced target.** Add optional `profiles/<profile>/target.json` (schema: `targets.schema.json`) with `{ "artifact": "opencode.json" }`. Builder resolves `$TargetArtifact` once (Stage 1); all hardcoded strings (output path, backup prefix, provenance name, WhatIf messages, messages, diffs) use it. Missing target.json defaults to `opencode.json` (backward-compatible). A Claude target profile would set `"artifact": "claude.json"` / whatever the target needs, changing only config, never code.
- **Option 2 — minimal artifact alias.** Same behavior but ONLY the output filename is dynamic; backup prefix + provenance stay `opencode_*`-style. Weakest version of the requirement.
- **Option 3 — full generalization.** target.json also defines the `$schema` family, backup prefix, provenance filename (e.g. `claude.provenance.json`). Most flexible, most tests to touch (test names, test-26 provenance, backup retention isolation).

Consequences accepted: harness changes (tests gain a target.json fixture verifying a non-opencode artifact + backup prefix + provenance name); docs `BUILDER_SPEC.md` gets a "Target artifact resolution" section; registry `2.5.0` docs keep.

### 4.3 Session-size guard (P3) — always BEFORE doing the above in a new session
- Write `/AI/CONTINUE_BUILDER_V2.7_ISSUES_PATCH.md` (this file) at each checkpoint.
- Re-open exactly as in prompt, pasting: `Following AI/CONTINUE_BUILDER_V2.7_ISSUES_PATCH.md step 3 (system) / 4.x fix / 5 suggestions`, and never continue past a harness failure.

---

## 5. FIX DECISION (user-selected — 2026-08-06)

**P2 = Option 1 — Profile target (dynamic artifact, config-driven).**
- Add optional `profiles/<profile>/target.json` -> `{ "artifact": "opencode.json" }` (+ `targets.schema.json`).
- Builder resolves `$TargetArtifact = artifact` once during Stage 1 (Load Profile); missing or invalid target.json -> default `opencode.json` (backward compatible).
- Promotes ALL hardcoded `opencode.json` strings into `$TargetArtifact`-driven ones: output write path, backup prefix (base name of artifact), provenance default name. `-WhatIf` messages + F7 + retention prune their chosen prefix.
- Future Claude profile = new `target.json`; code untouched (= fully config-driven dynamism).
- Schema addition: `schemas/targets.schema.json` (required `artifact`; `additionalProperties: false`), JSON_SCHEMAS.md + FOLDER_STRUCTURE + BUILDER_SPEC ("Target artifact resolution" section), a `target.json` fixture in tests proving non-opencode artifact + prefix + provenance name.
- P1 sanitize (mandatory in the same pass): replace literal `apiKey` in `providers/modal.json` with `{env:MODAL_API_KEY_OPENCODE}`, regenerate output, key-scan clean.

### 5.1 EXECUTED (session 2026-08-06)

- `scripts/build-opencode-v2.7.ps1`: target.json resolution block (~L50-79, `$TargetArtifact`/`$TargetBase`), output path, `$ProvenancePath` default (`<TargetBase>.provenance.json`), backup names (`${TargetBase}_<time>.json`), prune prefix, Get-LatestBackupConfig filter, WhatIf + write messages, F2 pre-flight + Get-CurrentSources + schema mapping for `target.json`. Parser clean (0 errors).
- `scripts/test-opencode-v2.7.ps1`: + Test 29 `Test-DynamicTargetArtifact` + Test 30 `Test-NoLiteralKeysInOutput`; `Write-Schemas` gained `targets.schema.json`. 28 -> 30 registered. Parser clean (0 errors).
- `schemas/targets.schema.json` created; `schemas/README.md` targets row added.
- `providers/modal.json` recreated WITHOUT literal key (`{env:MODAL_API_KEY_OPENCODE}` only; file had been deleted, default profile lists modal active).
- `profiles/experimental/target.json` + `profiles/minimal/target.json` seeded `{"artifact":"opencode.json"}`.
- Docs rewritten inline (writer subagent hung, returned nothing): BUILDER_SPEC.md (Target artifact resolution + API key policy, F4/F5/CLI/verbatim updates), JSON_SCHEMAS.md (target.json section, 7-schema table), FOLDER_STRUCTURE.md (target.json, modal.json, targets.schema.json, 30 tests). Templates audited = placeholder-only, no change.
- `docs/release_registry.json` 2.5.0 updated (P1/P2, 30 tests, revoked line removed) + `release-manager.ps1 -ConfigRoot docs` green.
- Temp-fixture smoke test (non-opencode target): claude.json + claude.provenance.json written, dynamic backup prefix, exit 0, no literal apiKey in output. Cleaned up.

### 5.2 EXECUTED (session 2026-08-06, battery) — PENDING resolved

Full Section 3 battery run. Result: GREEN with 3 fixes (all config/test-side, no frozen-script changes):

- **Battery:** test-opencode-v2.ps1 17/17, test-opencode-v2.5.ps1 13/13, test-opencode-v2.7.ps1 30/30 — all exit 0. Frozen hashes unchanged (buildV2.1 78E905FD42B4C641 / testV2.1 7202BB22C287EAC0 / buildV2.5 80C57810D991711A / testV2.5 2CB4AC994F79CC5A).
- **Fix A (v2.1 harness green):** restored real `profiles/coding/models.json` (mirror of `omniroute-models.json`, same as prior sessions did). Frozen harness Test 1 reads it; it had been deleted, breaking 17/17.
- **Fix B (v2.7 Test 22):** `build-opencode-v2.7.ps1` WhatIf messages now print bare artifact name (`Would write opencode.json`) instead of full path — test asserts the artifact-relative string.
- **Fix C (v2.7 Test 29):** test needed a second real build before asserting `claude_*` backup prefix (first build has nothing to back up).
- **Real-world:** -Doctor coding + default = 0 issues, exit 0. -WhatIf coding exit 0, writes nothing. default build twice = byte-identical SHA256 5646FBF...E0AF + "No changes detected vs previous backup." experimental + minimal builds exit 0 (resolved via target.json, output opencode.json).
- **Real-config gap found + fixed:** `experimental`/`minimal` had NO `<provider>-models.json`, so the V2.5+ active-provider guard dropped omniroute and aborted ("No active providers"). Seeded a 2-model `omniroute-models.json` in each (same pattern as default/coding). FOLDER_STRUCTURE.md updated to match.
- **Key-scan gate:** 26/26 JSON files (profiles/ + providers/ + schemas/ + opencode.json + provenance) — zero literal apiKey, only `{env:...}` placeholders.
- **LEGACY LITERAL-KEY BACKUPS on disk (P1 residual, user decision):** `backup/opencode_2026-08-06_07-58-15.json`, `backup/opencode_2026-08-06_08-47-54.json`, `backup/opencode_2026-08-06_08-49-51.json` contain the live Modal key. Recommend the user rotates that key; deletion handled by user (destructive, not auto).

---

## 6. INCOMPLETE / NOT DONE THIS SESSION

- Real builds: DONE this session — all four profiles (default, coding, experimental, minimal) built/checked green (see 5.2).
- Release docs regeneration AFTER final fixes: DONE via `scripts/release-manager.ps1 -ConfigRoot docs` (registry 2.5.0 with P1/P2). v2.7 build/test scripts were patched post-release (WhatIf message + test 29) — release docs not regenerated after those edits; run release-manager again if versioned docs must match script state.
- Templates (15x `docs/bdf/templates/*.template.md`): audited = version-neutral placeholders only; no `target.json`/`targets.schema.json` pushed in (keeps generic).
- Nothing is committed (user-gated). Outside-git artifacts updated: `scripts/build-opencode-v2.7.ps1`, `scripts/test-opencode-v2.7.ps1`, `schemas/targets.schema.json`, `providers/modal.json`, `profiles/experimental/target.json`, `profiles/minimal/target.json`, `profiles/coding/models.json`, `profiles/experimental/omniroute-models.json`, `profiles/minimal/omniroute-models.json`, docs. `backup/` unchanged (legacy literal-key files remain, user deletes).
- Clean-room rehearsal (Task 10): DONE previous session, passed (fresh fixture build exit 0 + determinism + Doctor).

---

## 7. NEXT ACTIONS (exact order for the next agent)

1. Run Section 3 system check. Report 3 lines: harness counts (17/13/30), real-world exit codes, key-scan result.
2. P1 + P2 implemented (see 5.1). Do NOT re-execute; verify + battery instead.
3. Re-run Section 3 everywhere after each structural change.
4. `experimental`/`minimal` target.json seeded (5.1) — verify resolution on the real builders.
5. Update `docs/AI/CONTINUE_BUILDER_V2.7_ISSUES_PATCH.md` progress markers after battery.
6. STOP and report, do not commit unless explicitly told.

---

## 8. CONTINUATION PROMPT (copy whole block, single message)

```
You are continuing the OpenCode Configuration Manager Builder V2.7 work.
1. Read C:\Users\loveb\.config\opencode\docs\AI\CONTINUE_BUILDER_V2.7_ISSUES_PATCH.md in full.
2. Run Section 3 SYSTEM CHECK now: harness battery (17/13/30), real-world -Doctor/-WhatIf on coding + default, real default build twice (byte-identical + silent diff), key-scan gate (expect zero literal apiKey in providers/ + opencode.json + provenance). Report 3 lines.
3. P1 + P2 fixes are IMPLEMENTED (Section 5.1). Do not re-code; verify the battery proves them.
4. If any harness fails, fix it and re-run the battery until all green and deterministic.
5. Update the patch MD's progress markers, do NOT commit files, and finish with a one-line summary per Section 4.x.
```

---

**Handoff prompt for THIS issue list (managed in chat):** battery + real-build verification next session — fixes land, run Section 3 now (see Section 8 prompt).