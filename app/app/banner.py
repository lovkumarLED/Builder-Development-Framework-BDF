"""Startup banner for the app console: BDF ASCII art in the logo's fire colors.

The banner mirrors the brand identity of the Switcher UI:
- "BDF" sweeps a coral->plum gradient (matching bdf-counterphase-logo.svg)
- "AI SWITCHER" uses the coral accent
- A soft animated shimmer pulses across the tagline (disabled when piped,
  NO_COLOR set, or reduced terminal width), matching the app's motion design.
"""

import os
import sys
import time

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
    "N": ["██   ██", "█████ █", "██ ████", "██   ██", "██   ██"],
    "R": ["██████ ", "██   ██", "██████ ", "██  ██ ", "██   ██"],
    "S": ["███████", "██     ", "██████ ", "     ██", "███████"],
    "T": ["███████", "  ███  ", "  ███  ", "  ███  ", "  ███  "],
    "W": ["██    ██", "██    ██", "██  █ ██", "██ ██ ██", " ████ ██"],
    "K": ["██   ██", "██  ██ ", "█████  ", "██ ██  ", "██  ███"],
    "O": [" █████ ", "██   ██", "██   ██", "██   ██", " █████ "],
}

# Brand gradient: coral (logo start) -> plum (logo end)
CORAL = (255, 90, 74)
CORAL_HI = (255, 138, 117)
PLUM = (98, 50, 79)
MUTED = (116, 109, 112)
GREEN = (60, 154, 99)

# Shimmer palette for the animated tagline (coral -> plum -> coral loop)
SHIMMER = [
    (255, 138, 117),
    (255, 138, 117),
    (233, 105, 92),
    (200, 85, 96),
    (168, 66, 95),
    (132, 72, 113),
    (98, 50, 79),
    (132, 72, 113),
    (168, 66, 95),
    (200, 85, 96),
    (233, 105, 92),
]

ANIM_INTERVAL = 0.05  # seconds per shimmer column step


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


def _lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def _gradient_steps(start, end, steps):
    return [_lerp(start, end, i / max(1, steps - 1)) for i in range(steps)]


def _paint(text, rgb, colorful):
    if not colorful:
        return text
    return f"\x1b[38;2;{rgb[0]};{rgb[1]};{rgb[2]}m{text}\x1b[0m"


def _static_lines(colorful):
    lines = []
    bdf = render_word("BDF")
    coral_plum = _gradient_steps(CORAL, PLUM, 5)
    for i, line in enumerate(bdf):
        lines.append(_paint(line, coral_plum[i], colorful))
    lines.append("")
    switcher = render_word("AI SWITCHER")
    for i, line in enumerate(switcher):
        shade = _lerp(CORAL_HI, CORAL, i / max(1, len(switcher) - 1))
        lines.append(_paint(line, shade, colorful))
    return lines


def print_banner():
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, OSError):
        pass
    colorful = sys.stdout.isatty() and not os.environ.get("NO_COLOR")
    if colorful:
        _enable_vt()
    animated = colorful and not os.environ.get("NO_ANIMATION")

    lines = _static_lines(colorful)
    tagline = "BDF made autonomous - free AI, one click"

    if not animated:
        print("\n" + "\n".join(lines) + "\n")
        print(_paint(tagline, MUTED, False))
        print(_paint(f"v{APP_VERSION}", GREEN, False))
        print(_paint(f"- Local:         http://localhost:{PORT}", CORAL_HI, False))
        print(_paint(f"- Network:       http://{HOST}:{PORT}", MUTED, False))
        print("")
        return

    # Animated: print the art, then sweep a coral->plum glow across the tagline.
    tail = "\n".join(lines)
    width = len(tagline)
    print("\n" + tail + "\n")
    sys.stdout.write("\x1b[?25l")
    try:
        for offset in range(width + len(SHIMMER)):
            chars = []
            for i, ch in enumerate(tagline):
                distance = (i - offset) % width
                if distance < len(SHIMMER):
                    chars.append(_paint(ch, SHIMMER[distance], True))
                else:
                    chars.append(_paint(ch, MUTED, True))
            sys.stdout.write("\r" + "".join(chars))
            sys.stdout.flush()
            time.sleep(ANIM_INTERVAL)
    finally:
        sys.stdout.write("\x1b[?25h")
    sys.stdout.write("\r" + _paint(tagline, MUTED, True) + "\n")
    sys.stdout.write(_paint(f"v{APP_VERSION}", GREEN, True) + "\n")
    sys.stdout.write(_paint(f"- Local:         http://localhost:{PORT}", CORAL_HI, True) + "\n")
    sys.stdout.write(_paint(f"- Network:       http://{HOST}:{PORT}", MUTED, True) + "\n\n")
    sys.stdout.flush()
