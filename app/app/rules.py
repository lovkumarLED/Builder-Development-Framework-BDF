"""rule.md parser, validator, and theme provider."""

import re
from pathlib import Path

from .config import APP_DIR

RULE_FILE = APP_DIR / "rule.md"

DEFAULT_THEME = {
    "--startup-bg": "#0B0D12",
    "--workspace-bg": "#F8F4EE",
    "--surface": "#FFFDFC",
    "--surface-soft": "#F2ECE6",
    "--ink": "#1B191B",
    "--muted": "#746D70",
    "--border": "#DED7D2",
    "--border-hi": "#BDB3AD",
    "--coral": "#F16E5B",
    "--coral-hi": "#FF8A75",
    "--plum": "#6842AE",
    "--plum-deep": "#3E193B",
    "--green": "#3C9A63",
    "--red": "#D34F45",
    "--amber": "#C98928",
    "--radius": "16px",
    "--radius-sm": "12px",
    "--font": '"Inter Tight", "Segoe UI Variable", "Segoe UI", sans-serif',
    # Compatibility aliases for older UI consumers and custom rule files.
    "--bg": "#0B0D12",
    "--card": "#FFFDFC",
    "--text": "#1B191B",
    "--accent": "#F16E5B",
    "--accent-hi": "#FF8A75",
}

KEY_MAP = {name[2:]: name for name in DEFAULT_THEME}

_COLOR_RE = re.compile(r"^#[0-9a-fA-F]{6}$")
_SIZE_RE = re.compile(r"^\d+(px|rem|%|em)?$")
_FONT_RE = re.compile(r"^[A-Za-z0-9 ,._\"'-]+$")
_BREAKOUT_CHARS = set("<>{;}\n\r")

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
                if value and _FONT_RE.match(value) and not _BREAKOUT_CHARS.intersection(value):
                    theme[css_key] = value
                else:
                    problems.append(f"invalid font '{value}' for {key}")
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
