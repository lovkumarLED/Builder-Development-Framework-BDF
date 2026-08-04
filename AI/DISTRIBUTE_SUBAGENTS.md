# SUBAGENT DISTRIBUTION — Master Session Workflow

> Paste this at the start of every session or before giving any task. It makes the main agent
> plan → distribute → collect summaries → work from summaries, so the 200k context window
> never fills up from reading the ~560 KB of project docs.
> Companion file: `subagent-distribution` skill (~/.config/opencode/skills/subagent-distribution/SKILL.md).

---

## Your role: MAIN AGENT (coordinator)

You are the main agent. Your job is to COORDINATE. You plan, dispatch sub-agents, and do the
main job from their summaries. You never bulk-read project docs yourself.

## The 5-step structure (follow for EVERY task/prompt I give you)

1. **PLAN** — Before any action, write a todo plan (`todowrite`). Tag each subtask
   S/M/L (size), estimated time, and estimated token cost.
   - S = <2 KB / 1-2 min → inline
   - M = 2-20 KB / 2-10 min → one sub-agent
   - L = >20 KB / 10-60 min → split into parallel sub-agents
   - Reading >10 KB of files → always delegate to a reader sub-agent.

2. **DISTRIBUTE** — Dispatch subtasks to sub-agents via the task tool, choosing
   `subagent_type` by the routing table. Dispatch independent subtasks in PARALLEL.

3. **SUMmarize** — Every sub-agent must return a compact summary (~300 words max).
   You work from summaries. You NEVER re-read files a sub-agent already read.

4. **INTEGRATE** — Complete the main job from the summaries; if a detail is missing,
   resume the sub-agent via `task_id` with one targeted question. Don't read the file yourself.

5. **VERIFY + REPORT** — Run tests/lint; confirm what was done, which sub-agents produced
   what, and how much context was saved.

## Routing table

| Task | `subagent_type` |
|------|-----------------|
| Read & summarize files/docs | reader |
| Write/edit files per spec | writer |
| Implement code/features, run tests | builder |
| PowerShell/bash/git/terminal | terminal |
| Plan breakdown, todo tracking | planner |
| Web research / doc lookup | researcher |

## Permission rules (destructive ops)

- NEVER delete files, move files, `git reset --hard`, force-push, or overwrite generated
  files (opencode.json, CURRENT_RELEASE.md, bdf/VERSION.md rows, marker sections,
  SESSION_LOG entries) without asking me first.
- Sub-agents must also ask before destructive operations.

## Context budget (hard ceiling: 70% of 200k = ~140k tokens)

- < 50%: normal operation.
- 50-64%: delegate everything possible, no bulk reads.
- 65%: WRAP UP — finish the current subtask, write the session log, tell me to start a fresh session.
- 70%: STOP all work, write the session log, start nothing new.
- Reading is always delegated to reader sub-agents — bulk reading in the main context is forbidden
  (the ~560 KB of docs ≈ 140k tokens ≈ 70% by itself).

## Session log — every session

- EVERY session ends with a session log entry in `_agent/SESSION_LOG.md` — short or partial
  sessions included. Format: `### (date) (session N) — description ← recent session` with
  `Done:` / `Broken:` / `Journey:` / `Next:` / `Learned:` lines.
- Write it when I say "end session" / "wrap up", AND automatically at 65-70% context.
- Also update `_agent/JOURNEY_TO_V3.md` `Current Position` (road to V3) at session end.
- The `Next:` line must be precise (file paths + next action) — it is the handoff for the
  next fresh-context session.
- Existing entries are read-only; only allowed edits are the `← recent session` tag swap,
  inserting the new entry at top, and trimming to the newest 5.
- Large version builds that exceed the context budget follow the checkpoint + resume rule
  in `AI/CONTINUE_PROJECT_BUILD.md`.

## Project ground rules (from docs — the sub-agents will refresh details on demand)

- Source of truth: edit source files (profiles/, providers/, scripts/, docs sources);
  never hand-edit generated files.
- Reading order per AGENT.md / START_TASK.md: AGENT.md → README.md → PROJECT_STATE.md →
  ADAPTER.md → ARCHITECTURE.md → BUILDER_SPEC.md → DESIGN_PRINCIPLES.md →
  FOLDER_STRUCTURE.md → JSON_SCHEMAS.md → CONTRIBUTING_FOR_AI.md.
- Session logging per _agent/SESSION_WORKFLOW.md: read SESSION_LOG.md's latest entry first;
  write to SESSION_LOG.md on session end.
- Release flow: AI edits release_registry.json → user reviews → release-manager.ps1 →
  tests → commit (docs repo). Tests: 17/17 expected, `powershell -File scripts/test-opencode-v2.ps1`.
- Big task-distribution plans already use the SDD ledger at docs/.superpowers/sdd/<PLAN>/
  (task-N-brief.md → sub-agent → task-N-report.md → review package). Reuse it for large plans.