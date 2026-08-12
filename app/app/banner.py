"""Startup banner for the app console: BDF SWITCHER ASCII art in the logo's
fire colors, with a blast burst + sound on launch.

- "BDF" sweeps a coral->plum gradient (matching bdf-counterphase-logo.svg)
- "SWITCHER" uses the coral accent
- A blast burst (expanding ripples + particles, like the welcome-page logo
  click) fires around the art when the console is interactive, together with
  a short "boom" sound (winsound beeps). Disabled when piped, NO_COLOR set,
  reduced terminal width, or NO_SOUND / NO_ANIMATION set.
- A soft animated shimmer pulses across the tagline (disabled when piped,
  NO_COLOR set, or reduced terminal width), matching the app's motion design.
"""

import math
import os
import random
import shutil
import sys
import threading
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
    switcher = render_word("SWITCHER")
    for i, line in enumerate(switcher):
        shade = _lerp(CORAL_HI, CORAL, i / max(1, len(switcher) - 1))
        lines.append(_paint(line, shade, colorful))
    return lines


def _play_blast_sound():
    """Short 'boom' burst via winsound beeps (best-effort, never throws)."""
    if os.environ.get("NO_SOUND"):
        return
    try:
        import winsound
        for freq, ms in ((1500, 40), (1000, 45), (700, 50), (420, 130)):
            winsound.Beep(freq, ms)
    except Exception:
        pass


def _blast_animation(center_row, center_col):
    """Expand ripples + particles around the banner center (welcome-page burst).

    Uses absolute ANSI positioning; every written cell is tracked and cleared
    afterwards so the banner stays pristine. Best-effort, never throws.
    """
    try:
        size = shutil.get_terminal_size()
    except Exception:
        return
    if size.columns < 100 or size.lines < 16:
        return
    written = set()
    try:
        sys.stdout.write("\x1b[?25l")
        for step in range(10):
            radius = 2 + step * 1.7
            cells = []
            for i in range(14):
                angle = (i / 14) * 2 * math.pi
                r = radius + random.uniform(-0.7, 0.7)
                col = center_col + int(math.cos(angle) * r)
                row = center_row + int(math.sin(angle) * r * 0.5)
                if 0 < row < size.lines and 0 < col < size.columns:
                    cells.append((row, col, PLUM if i % 2 else CORAL))
            for _ in range(7):
                angle = random.uniform(0, 2 * math.pi)
                dist = random.uniform(radius, radius + 3.5)
                col = center_col + int(math.cos(angle) * dist)
                row = center_row + int(math.sin(angle) * dist * 0.5)
                if 0 < row < size.lines and 0 < col < size.columns:
                    cells.append((row, col, CORAL_HI))
            frame = "".join(
                f"\x1b[{row};{col}H" + _paint("█", rgb, True)
                for row, col, rgb in cells
            )
            sys.stdout.write(frame)
            written.update((row, col) for row, col, _ in cells)
            sys.stdout.flush()
            time.sleep(0.05)
    except Exception:
        pass
    finally:
        try:
            for row, col in written:
                if 0 < row < size.lines and 0 < col < size.columns:
                    sys.stdout.write(f"\x1b[{row};{col}H ")
            sys.stdout.write("\x1b[?25h")
            sys.stdout.flush()
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

    print("\n" + "\n".join(lines))
    # Welcome-page-style blast: expanding ripples + particles + boom sound.
    art_width = max(len(line) for line in lines)
    center_col = max(2, art_width // 2)
    center_row = max(2, len(lines) // 2 + 1)
    threading.Thread(target=_play_blast_sound, daemon=True).start()
    _blast_animation(center_row, center_col)
    print()

    # Animated: sweep a coral->plum glow across the tagline.
    width = len(tagline)
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
