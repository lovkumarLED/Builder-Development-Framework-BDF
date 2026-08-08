"""rule.md parser, validator, and theme provider."""

import re
from pathlib import Path

from .config import APP_DIR

RULE_FILE = APP_DIR / "rule.md"

DEFAULT_THEME = {
    "--bg": "#0d1117",
    "--card": "#161b22",
    "--border": "#30363d",
    "--border-hi": "#4a5261",
    "--text": "#e6edf3",
    "--muted": "#8b949e",
    "--accent": "#6366f1",
    "--accent-hi": "#818cf8",
    "--green": "#3fb950",
    "--red": "#f85149",
    "--amber": "#d29922",
    "--radius": "14px",
    "--radius-sm": "10px",
    "--font": '-apple-system, "Segoe UI", system-ui, sans-serif',
}

KEY_MAP = {name[2:]: name for name in DEFAULT_THEME}

_COLOR_RE = re.compile(r"^#[0-9a-fA-F]{6}$")
_SIZE_RE = re.compile(r"^\d+(px|rem|%|em)?$")

_cache = {"mtime": None, "theme": None, "rulebook": None, "problem": None}


def _parse_rule_file(text):
    """Return (theme, rulebook, problem) from raw rule.md text."""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return dict(DEFAULT_THEME), text.strip(), "rule.md must start with --- (front-matter missing)."
    end = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end = i
            break
    if end is None:
        return dict(DEFAULT_THEME), text.strip(), "rule.md front-matter is never closed."
    body = "\n".join(lines[end + 1:]).strip()
    theme = dict(DEFAULT_THEME)
    section = None
    problems = []
    for line in lines[1:end]:
        stripped = line.strip()
        if not stripped or stripped.startswith("- "):
            continue
        if stripped == "theme:":
            section = "theme"
        elif stripped == "colors:":
            section = "colors"
        elif section == "colors" and ":" in stripped:
            key, _, raw_value = stripped.partition(":")
            css_key = KEY_MAP.get(key.strip())
            if css_key is None:
                problems.append(f"unknown color key '{key.strip()}' ignored")
                continue
            value = raw_value.strip().strip('"').replace('\\"', '"')
            if css_key in ("--radius", "--radius-sm"):
                if _SIZE_RE.match(value):
                    theme[css_key] = value
                else:
                    problems.append(f"invalid size '{value}' for {key}")
            elif css_key == "--font":
                if value:
                    theme[css_key] = value
            elif _COLOR_RE.match(value):
                theme[css_key] = value
            else:
                problems.append(f"invalid color '{value}' for {key}")
    problem = problems[0] if problems else None
    return theme, body, problem


def _load():
    try:
        mtime = RULE_FILE.stat().st_mtime
    except OSError:
        mtime = None
    if _cache["mtime"] == mtime and _cache["theme"] is not None:
        return _cache
    if mtime is None:
        _cache.update(
            mtime=None,
            theme=dict(DEFAULT_THEME),
            rulebook="",
            problem="rule.md not found - using default theme.",
        )
        return _cache
    try:
        text = RULE_FILE.read_text(encoding="utf-8-sig")
    except OSError as exc:
        _cache.update(mtime=mtime, theme=dict(DEFAULT_THEME), rulebook="", problem=f"rule.md unreadable: {exc}")
        return _cache
    theme, body, problem = _parse_rule_file(text)
    _cache.update(mtime=mtime, theme=theme, rulebook=body, problem=problem)
    return _cache


def get_theme():
    return dict(_load()["theme"])


def get_rulebook():
    return _load()["rulebook"]


def theme_problem():
    return _load()["problem"]
