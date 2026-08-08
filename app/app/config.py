"""Paths, constants, presets, and the agent registry for the AI Switcher app."""

import os
from pathlib import Path

APP_DIR = Path(__file__).resolve().parent.parent
CONFIG_ROOT = APP_DIR.parent.parent
SCRIPT_DIR = Path(os.environ.get("BDF_SCRIPTS_DIR", str(CONFIG_ROOT / "scripts")))
SCAFFOLD_SCRIPT = SCRIPT_DIR / "scaffold-agent.ps1"

STATE_FILE = APP_DIR / "state.json"

HOST = "127.0.0.1"
PORT = 9090

# Preset list (proxy + real providers). The Add-provider form in gui.html keeps
# the live copy with per-preset SDK packages — keep this list in sync with it.
PRESETS = {
    "OmniRoute": "http://localhost:20128/v1",
    "LiteLLM": "http://localhost:4000/v1",
    "CLI Proxy": "http://localhost:PORT/v1",
    "TokenRouter": "https://api.tokenrouter.com/v1",
    "Modal": "https://inference.us-west.modal.direct/v1",
    "OpenAI": "https://api.openai.com/v1",
    "Google (Gemini)": "https://generativelanguage.googleapis.com/v1beta/openai",
    "OpenRouter": "https://openrouter.ai/api/v1",
    "NVIDIA NIM": "https://integrate.api.nvidia.com/v1",
    "Custom": "",
}

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
