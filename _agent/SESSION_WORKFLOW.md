# SESSION_WORKFLOW

> Session start, end, and log rules for this documentation repository.

---

# Purpose

Work in this repository spans multiple sessions.

Every session starts with a fresh context window.

The session files preserve knowledge between sessions:

- `SESSION_LOG.md` stores the history of completed sessions.
- `SESSION_WORKFLOW.md` (this document) defines how sessions start, end, and write to the log.

An agent must follow this document at the start and end of every session.

---

# File Locations

```
_agent/

SESSION_LOG.md

SESSION_WORKFLOW.md
```

These files live inside the documentation repository.

---

# Session Start Rules

At the start of every session:

1. Read `_agent/SESSION_WORKFLOW.md`.
2. Read `_agent/SESSION_LOG.md`.
3. Read the most recent session entry.
4. Check its `Next:` line to determine where work should continue.
5. Read `PROJECT_STATE.md` to load the current repository state.
6. Follow the `AGENT.md` reading order before modifying any files.

Do not begin work without reading the most recent session entry.

---

# Session End Rules

When the user says "end session", "wrap up", or "done for today":

1. Write the session summary directly into `_agent/SESSION_LOG.md`.
2. Do not ask for confirmation.
3. Confirm the update with: Session log updated.
4. If a major refactor occurred this session, regenerate `PROJECT_STATE.md` (see AGENT.md, Project State section).
5. Do not update any other session file unless its rules changed.

---

# Entry Format

Every session entry follows this format.

```
### (date) (session N) — (short description) ← recent session
Done:
- (completed items, one per bullet)

Broken:
- (unresolved issues, one per bullet, or "None — clean session.")

Next: (what to start next, one line)

Learned: (one key takeaway)
```

Example

```
### Aug 3, 2026 (session 1) — Built the Builder Development Framework ← recent session
Done:
- Created the reusable framework documentation.
- Created documentation templates.

Broken:
- None — clean session.

Next: Review the framework with the user.

Learned: Externalizing session context into a log preserves work across context resets.
```

---

# Critical Rules

## Never Delete or Overwrite Sessions

Existing session entries are read-only.

Never edit or delete the `Done:`, `Broken:`, `Next:`, or `Learned:` content of an existing entry.

If an edit would modify existing session content, stop: it destroys history.

## Only Allowed Edits

The only permitted edits to existing entries are:

1. Remove the `← recent session` tag from the previous session's header line.
2. Insert the new session entry at the top of the Session History.
3. Trim the oldest entries when the count exceeds five.

---

# Session Log Rotation

The log keeps a maximum of five session entries.

Before inserting a new entry:

1. Count the existing entries.
2. If five or more exist, delete the oldest entries until only the most recent five remain.
3. Insert the new entry at the top of the Session History, directly below the `## Session History` heading.

---

# Recent Session Tagging

The newest session entry carries the tag at the end of its header line:

```
← recent session
```

When inserting a new entry:

1. Add the tag to the new entry's header.
2. Remove the tag from the previous entry's header.

Exactly one entry has the tag at any time.

---

# Consistency Rules

- Entries record facts only: what was done, what broke, what is next.
- `Broken: None — clean session.` is written only when no unresolved issues remain.
- Session numbers increase by one for every new entry.
- Dates use the format: MMM D, YYYY.
- The most recent session entry is always the first entry below the heading.

---

# Integration

`AGENT.md` contains the session continuity section.

It points to this document.

This document and `AGENT.md` must remain consistent with each other.

`AGENT.md` also contains the project state rules.

They point to this document for the session-end regeneration checkpoint.

---

**Document Version:** 1.1

**Status:** Active Session Rules
