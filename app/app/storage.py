"""state.json persistence (providers now live in the agent's own config, BDF-style)."""

import json
import threading

from .config import STATE_FILE

_lock = threading.Lock()


def _read(path, default):
    try:
        data = json.loads(path.read_text(encoding="utf-8-sig"))
        return data if isinstance(data, dict) else default
    except (OSError, ValueError):
        return default


def _write(path, data):
    with _lock:
        tmp = path.with_suffix(path.suffix + ".tmp")
        tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
        tmp.replace(path)


def get_state():
    with _lock:
        return _read(STATE_FILE, {})


def set_state(**values):
    with _lock:
        data = _read(STATE_FILE, {})
        data.update(values)
        tmp = STATE_FILE.with_suffix(STATE_FILE.suffix + ".tmp")
        tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
        tmp.replace(STATE_FILE)
