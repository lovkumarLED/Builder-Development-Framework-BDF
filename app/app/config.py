"""Paths, constants, and the agent registry for the Switcher app."""

import os
from pathlib import Path

APP_DIR = Path(__file__).resolve().parent.parent

# The app is self-contained: the full engine (scaffold generator, opencode
# builder + harness, kilo adapter + harness, JSON schemas) ships inside the
# repo under app/engine/. Anyone who downloads the app can generate working
# builders for opencode / kilo without any preinstalled scripts. BDF_SCRIPTS_DIR
# is kept as an escape hatch for power users who maintain their own copy.
ENGINE_DIR = APP_DIR / "engine"
SCRIPT_DIR = Path(os.environ.get("BDF_SCRIPTS_DIR", str(ENGINE_DIR)))
SCAFFOLD_SCRIPT = SCRIPT_DIR / "scaffold-agent.ps1"
ENGINE_SCHEMAS = ENGINE_DIR / "schemas"

STATE_FILE = APP_DIR / "state.json"
PREFERENCES_FILE = APP_DIR / "preferences.json"
ACTIVITY_FILE = APP_DIR / "activity.jsonl"

# Claude adapter runtime state (Git-ignored via app/.gitignore rule `state/`).
CLAUDE_ROUTES_FILE = APP_DIR / "state" / "claude-routes.json"
CLAUDE_MANIFEST_FILE = APP_DIR / "state" / "claude-backup-manifest.json"
CLAUDE_ACTIVITY_FILE = APP_DIR / "state" / "claude-activity.jsonl"
# Structural segments of the user-scope Claude settings target; never a literal
# real path and never resolved against real Claude state by Gate 4 code paths.
CLAUDE_SETTINGS_REL = (".claude", "settings.json")

HOST = "127.0.0.1"
PORT = 9090

AGENT_REGISTRY = [
    {"name": "opencode", "home": ".config\\opencode", "main": ["opencode.json"], "plugkeys": ["plugin"]},
    {"name": "kilo", "home": ".config\\kilo", "main": ["kilo.json"], "plugkeys": ["plugin", "skills.urls"]},
    {"name": "aider", "home": ".aider", "main": [".aider.conf.json"], "plugkeys": ["plugins"]},
    {"name": "goose", "home": ".config\\goose", "main": ["config.json"], "plugkeys": ["plugins"]},
    {"name": "codex-cli", "home": ".codex", "main": ["config.toml"], "plugkeys": ["plugins"]},
]

EXCLUDED_MAIN_NAMES = (
    "package", "package-lock", "tsconfig", "changelog", "release",
    "settings", "mcp", "plugins", "target", "models", "provenance",
)
