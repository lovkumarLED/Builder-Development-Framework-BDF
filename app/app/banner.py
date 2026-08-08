"""Startup banner for the app console: BDF ASCII art in the logo's fire colors."""

import os
import sys

from . import APP_VERSION
from .config import HOST, PORT

LETTERS = {
    "A": [" █████", "██   ██", "███████", "██   ██", "██   ██"],
    "B": ["██████ ", "██   ██", "██████ ", "██   ██", "██████ "],
    "C": [" ██████", "██     ", "██     ", "██     ", " ██████"],
    "D": ["██████ ", "██   ██", "██   ██", "██   ██", "██████ "],
    "E": ["███████", "██     ", "█████  ", "██     ", "███████"],
    "F": ["███████", "██     ", "█████  ", "██     ", "██     "],
    "H": ["██   ██", "██   ██", "███████", "██   ██", "██   ██"],
    "I": ["███████", "  ███  ", "  ███  ", "  ███  ", "███████"],
    "L": ["██     ", "██     ", "██     ", "██     ", "███████"],
    "M": ["██   ██", "███████", "██ █ ██", "██   ██", "██   ██"],
    "R": ["██████ ", "██   ██", "██████ ", "██  ██ ", "██   ██"],
    "S": ["███████", "██     ", "██████ ", "     ██", "███████"],
    "T": ["███████", "  ███  ", "  ███  ", "  ███  ", "  ███  "],
    "W": ["██    ██", "██    ██", "██  █ ██", "██ ██ ██", " ████ ██"],
}

FLAME = [
    (255, 59, 48),
    (255, 101, 1),
    (253, 144, 0),
    (255, 151, 2),
    (255, 190, 80),
]
CYAN = (0, 200, 255)
AMBER = (255, 151, 2)
MUTED = (139, 150, 176)


def render_word(word):
    lines = [""] * 5
    for ch in word.upper():
        glyph = LETTERS.get(ch)
        if not glyph:
            continue
        for i in range(5):
            lines[i] += " " + glyph[i]
    return lines


def _enable_vt():
    if os.name != "nt":
        return
    try:
        import ctypes
        kernel32 = ctypes.windll.kernel32
        handle = kernel32.GetStdHandle(-11)
        mode = ctypes.c_uint32()
        if kernel32.GetConsoleMode(handle, ctypes.byref(mode)):
            kernel32.SetConsoleMode(handle, mode.value | 0x0004)
    except Exception:
        pass


def print_banner():
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass
    colorful = sys.stdout.isatty() and not os.environ.get("NO_COLOR")
    if colorful:
        _enable_vt()

    def paint(text, rgb):
        if not colorful:
            return text
        return f"\x1b[38;2;{rgb[0]};{rgb[1]};{rgb[2]}m{text}\x1b[0m"

    lines = []
    for i, line in enumerate(render_word("BDF")):
        lines.append(paint(line, FLAME[i]))
    lines.append("")
    for line in render_word("AI SWITCHER"):
        lines.append(paint(line, CYAN))
    lines.append("")
    lines.append(paint("v" + APP_VERSION, AMBER))
    lines.append(paint("BDF made autonomous - free AI, one click", MUTED))
    lines.append("")
    lines.append(paint(f"- Local:         http://localhost:{PORT}", CYAN))
    lines.append(paint(f"- Network:       http://{HOST}:{PORT}", MUTED))
    print("\n" + "\n".join(lines) + "\n")
