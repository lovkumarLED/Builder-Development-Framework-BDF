"""state.json persistence (providers now live in the agent's own config, BDF-style)."""

import json
import threading

from .config import STATE_FILE

_lock = threading.Lock()


def _read(path, default):
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        return data if isinstance(data, dict) else default
    except (OSError, ValueError):
        return default


def _write(path, data):
    with _lock:
        tmp = path.with_suffix(path.suffix + ".tmp")
        tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
        tmp.replace(path)


def get_state():
    return _read(STATE_FILE, {})


def set_state(**values):
    data = get_state()
    data.update(values)
    _write(STATE_FILE, data)
