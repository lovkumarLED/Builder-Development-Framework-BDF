"""Paths, constants, and the agent registry for the AI Switcher app."""

import os
from pathlib import Path

APP_DIR = Path(__file__).resolve().parent.parent
CONFIG_ROOT = APP_DIR.parent.parent
SCRIPT_DIR = Path(os.environ.get("BDF_SCRIPTS_DIR", str(CONFIG_ROOT / "scripts")))
SCAFFOLD_SCRIPT = SCRIPT_DIR / "scaffold-agent.ps1"

STATE_FILE = APP_DIR / "state.json"

HOST = "127.0.0.1"
PORT = 9090

AGENT_REGISTRY = [
    {"name": "opencode", "home": ".config\\opencode", "main": ["opencode.json"], "plugkeys": ["plugin"]},
    {"name": "kilo", "home": ".config\\kilo", "main": ["kilo.json", "kilo.jsonc"], "plugkeys": ["plugin", "skills.urls"]},
    {"name": "claudecode", "home": ".claude", "main": [".claude.json", "settings.json"], "plugkeys": ["plugins"]},
    {"name": "aider", "home": ".aider", "main": [".aider.conf.json"], "plugkeys": ["plugins"]},
    {"name": "goose", "home": ".config\\goose", "main": ["config.json"], "plugkeys": ["plugins"]},
    {"name": "codex-cli", "home": ".codex", "main": ["config.toml"], "plugkeys": ["plugins"]},
]

EXCLUDED_MAIN_NAMES = (
    "package", "package-lock", "tsconfig", "changelog", "release",
    "settings", "mcp", "plugins", "target", "models", "provenance",
)
