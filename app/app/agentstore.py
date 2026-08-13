"""Agent-config store: reads/writes the agent's BDF provider files and active providers."""

import json
import os
import re
import shutil
import tempfile
import time
from datetime import datetime
from pathlib import Path

from fastapi import HTTPException

from .storage import get_state, set_state

NPM_OPENAI_COMPATIBLE = "@ai-sdk/openai-compatible"


def get_agents():
    state = get_state()
    if "agents" in state:
        agents = state.get("agents")
        return agents if isinstance(agents, list) else []
    agent, directory = state.get("agent"), state.get("dir")
    if agent and directory:
        return [{"name": agent, "dir": directory}]
    return []


def _normalize_state():
    state = get_state()
    agents = get_agents()
    active = state.get("activeAgent")
    if not active or not any(a.get("name") == active for a in agents):
        active = agents[0]["name"] if agents else None
    if "agents" not in state or state.get("activeAgent") != active:
        data = dict(state)
        data["agents"] = agents
        data["activeAgent"] = active
        set_state(**data)
    return agents, active


def active_agent_name():
    _, active = _normalize_state()
    return active


def current_agent():
    agents, active = _normalize_state()
    entry = next((a for a in agents if a.get("name") == active), None)
    if not entry:
        return None, None
    return entry["name"], Path(entry["dir"])


AGENT_NAME_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*$")


def _require_valid_agent_name(name):
    """Reject agent names that could escape their config directory lookups."""
    if not isinstance(name, str) or not AGENT_NAME_RE.match(name):
        raise HTTPException(400, "Invalid agent name - use letters, numbers, dots, dashes and underscores only.")


def add_agent(name, directory):
    _require_valid_agent_name(name)
    agents, active = _normalize_state()
    if any(a.get("name") == name for a in agents):
        raise HTTPException(400, f"An agent named '{name}' already exists.")
    agents.append({"name": name, "dir": str(directory)})
    data = dict(get_state())
    data["agents"] = agents
    data["activeAgent"] = active
    set_state(**data)
    return agents


def upsert_agent(name, directory):
    _require_valid_agent_name(name)
    agents, _ = _normalize_state()
    agents = [a for a in agents if a.get("name") != name]
    agents.append({"name": name, "dir": str(directory)})
    data = dict(get_state())
    data["agents"] = agents
    data["activeAgent"] = name
    set_state(**data)


def remove_agent(name):
    agents, active = _normalize_state()
    agents = [a for a in agents if a.get("name") != name]
    if active == name:
        active = agents[0]["name"] if agents else None
    data = dict(get_state())
    data["agents"] = agents
    data["activeAgent"] = active
    set_state(**data)
    return agents, active


def switch_agent(name):
    agents, _ = _normalize_state()
    if not any(a.get("name") == name for a in agents):
        raise HTTPException(404, "That agent doesn't exist.")
    data = dict(get_state())
    data["activeAgent"] = name
    set_state(**data)


def require_agent_dir():
    agent, directory = current_agent()
    if not agent or not directory:
        raise HTTPException(400, "No agent is set up yet. Run the setup wizard first.")
    return Path(directory)


def slugify(name):
    return re.sub(r"[^a-z0-9]+", "-", name.strip().lower()).strip("-")


PROVIDER_ID_RE = re.compile(r"^[a-z0-9][a-z0-9-]*$")


def _require_valid_provider_id(provider_id):
    """Reject ids that could escape the providers/ directory (path traversal)."""
    if not isinstance(provider_id, str) or not PROVIDER_ID_RE.match(provider_id):
        raise HTTPException(400, "Invalid provider id - use letters, numbers and dashes only.")


def _builder_version(path):
    match = re.search(r"-v(\d+(?:\.\d+)*)\.ps1$", path.name)
    if not match:
        return (0,)
    return tuple(int(part) for part in match.group(1).split("."))


def find_builder_script(agent_dir, agent):
    scripts_dir = agent_dir / "scripts"
    if scripts_dir.is_dir():
        versioned = list(scripts_dir.glob(f"build-{agent}-v*.ps1"))
        if versioned:
            return max(versioned, key=_builder_version)
        exact = scripts_dir / f"build-{agent}.ps1"
        if exact.is_file():
            return exact
        matches = sorted(scripts_dir.glob(f"build-{agent}*.ps1"))
        if matches:
            return matches[0]
    return None


def has_any_builder(agent_dir):
    scripts_dir = agent_dir / "scripts"
    return bool(scripts_dir.is_dir() and any(scripts_dir.glob("build-*.ps1")))


def _agent_dir_of(path):
    for parent in path.parents:
        if (parent / "profiles").is_dir() or (parent / "providers").is_dir():
            return parent
    return path.parent.parent


def _backup(path):
    if not path.is_file():
        return None
    backup_dir = _agent_dir_of(path) / "backup"
    backup_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    target = backup_dir / f"{path.stem}_{stamp}{path.suffix}"
    shutil.copy2(path, target)
    return target


def _read_json(path, default=None):
    try:
        data = json.loads(path.read_text(encoding="utf-8-sig"))
        return data if isinstance(data, dict) else default
    except (OSError, ValueError):
        return default


def _write_json(path, data):
    fd, tmp_name = tempfile.mkstemp(dir=path.parent, prefix=path.name + ".", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(json.dumps(data, indent=2, ensure_ascii=False))
        _replace_retry(tmp_name, path)
    except BaseException:
        try:
            os.unlink(tmp_name)
        except OSError:
            pass
        raise


def _replace_retry(tmp_name, path, attempts=6):
    """Rename tmp onto the target with backoff.

    On Windows the destination can be transiently locked while another
    concurrent writer renames onto it (or the AV scans it), surfacing as
    PermissionError 13 'Access is denied'. Retry briefly before giving up.
    """
    for attempt in range(attempts):
        try:
            os.replace(tmp_name, path)
            return
        except OSError:
            if attempt == attempts - 1:
                raise
            time.sleep(0.02 * (attempt + 1))


def _provider_dict(provider_file):
    data = _read_json(provider_file, {})
    provider_id = provider_file.stem
    inner = (data.get("provider") or {}).get(provider_id, {})
    name = inner.get("name") or provider_id
    options = inner.get("options") or {}
    return {
        "id": provider_id,
        "name": name,
        "baseUrl": options.get("baseURL", ""),
        "apiKey": inner.get("apiKey", "") or "",
        "npm": inner.get("npm") or NPM_OPENAI_COMPATIBLE,
        "reasoningFormat": resolve_format(inner.get("reasoningFormat")),
    }


def list_providers(agent_dir):
    providers_dir = agent_dir / "providers"
    if not providers_dir.is_dir():
        return []
    return [_provider_dict(f) for f in sorted(providers_dir.glob("*.json"))]


def read_provider(agent_dir, provider_id):
    _require_valid_provider_id(provider_id)
    provider_file = agent_dir / "providers" / f"{provider_id}.json"
    if not provider_file.is_file():
        return None
    return _provider_dict(provider_file)


def write_provider(agent_dir, provider_id, name, base_url, api_key, npm=None, reasoning_format=None):
    _require_valid_provider_id(provider_id)
    providers_dir = agent_dir / "providers"
    providers_dir.mkdir(parents=True, exist_ok=True)
    provider_file = providers_dir / f"{provider_id}.json"
    data = _read_json(provider_file, {})
    _backup(provider_file)
    inner = (data.get("provider") or {}).get(provider_id, {})
    inner["name"] = name
    inner["apiKey"] = api_key
    inner["reasoningFormat"] = resolve_format(reasoning_format or inner.get("reasoningFormat"))
    options = dict(inner.get("options") or {})
    options["baseURL"] = base_url
    options["apiKey"] = api_key
    inner["options"] = options
    inner["npm"] = npm or inner.get("npm") or NPM_OPENAI_COMPATIBLE
    inner.setdefault("models", {})
    data["provider"] = data.get("provider") or {}
    data["provider"][provider_id] = inner
    data["id"] = provider_id
    _write_json(provider_file, data)
    return _provider_dict(provider_file)


MODEL_PROFILE = "coding"

REASONING_FORMATS = {
    "opencode": {
        "label": "OpenCode",
        "levels": ["default", "minimal", "high", "max"],
        "variant": lambda level: {"reasoningEffort": level},
    },
    "openai": {
        "label": "OpenAI / ChatGPT",
        "levels": ["none", "low", "medium", "high", "xhigh"],
        "variant": lambda level: {"reasoningEffort": level},
    },
    "claude": {
        "label": "Claude",
        "levels": ["low", "high", "max"],
        "variant": lambda level: {
            "thinking": {"type": "enabled", "budgetTokens": {"low": 8000, "high": 16000, "max": 32000}[level]}
        },
    },
    "gemini": {
        "label": "Gemini",
        "levels": ["minimal", "low", "medium", "high"],
        "variant": lambda level: {
            "thinkingConfig": {"thinkingBudget": {"minimal": 4096, "low": 8192, "medium": 16384, "high": 32768}[level]}
        },
    },
    "none": {
        "label": "No reasoning",
        "levels": [],
        "variant": None,
    },
}


def resolve_format(format_id=None):
    """Return a known format id; anything unknown falls back to opencode."""
    if isinstance(format_id, str) and format_id in REASONING_FORMATS:
        return format_id
    return "opencode"


def models_file(agent_dir, provider_id, profile=MODEL_PROFILE):
    _require_valid_provider_id(provider_id)
    return agent_dir / "profiles" / profile / f"{provider_id}-models.json"


def read_models(agent_dir, provider_id, profile=MODEL_PROFILE, format_id=None):
    data = _read_json(models_file(agent_dir, provider_id, profile), {})
    models = data.get("models") or {}
    result = []
    for model_id, entry in models.items():
        if not isinstance(entry, dict):
            continue
        variants = entry.get("variants") or {}
        thinking = sorted(v for v in variants.keys() if isinstance(v, str))
        result.append({"model": model_id, "name": entry.get("name") or model_id, "thinking": thinking})
    result.sort(key=lambda m: m["model"])
    return result


def write_models(agent_dir, provider_id, items, profile=MODEL_PROFILE, format_id=None):
    fmt = resolve_format(format_id)
    path = models_file(agent_dir, provider_id, profile)
    path.parent.mkdir(parents=True, exist_ok=True)
    existing = _read_json(path, {})
    _backup(path)
    models = dict(existing.get("models") or {})
    for item in items or []:
        model_id = item.get("model")
        if not model_id:
            continue
        entry = dict(models.get(model_id) or {})
        entry["name"] = item.get("name") or model_id
        explicit_format = bool(item.get("reasoningFormat"))
        item_format = resolve_format(item.get("reasoningFormat") or fmt)
        spec = REASONING_FORMATS[item_format]
        allowed = set(spec["levels"])
        previous_variants = dict(entry.get("variants") or {})
        variants = {}
        requested = item.get("thinking") or []
        if not requested and not explicit_format:
            requested = list(spec["levels"])
        for level in requested:
            if not explicit_format and level in previous_variants:
                variants[level] = previous_variants[level]
            elif level in allowed and spec["variant"] is not None:
                variants[level] = spec["variant"](level)
        entry["variants"] = variants
        models[model_id] = entry
    existing["models"] = models
    _write_json(path, existing)
    return read_models(agent_dir, provider_id, profile, format_id=fmt)


def delete_models(agent_dir, provider_id, profile=MODEL_PROFILE):
    path = models_file(agent_dir, provider_id, profile)
    if path.is_file():
        _backup(path)
        path.unlink()


def delete_model(agent_dir, provider_id, model_id, profile=MODEL_PROFILE):
    """Remove a single model entry from the provider's models file."""
    path = models_file(agent_dir, provider_id, profile)
    data = _read_json(path, {})
    models = data.get("models") or {}
    if model_id not in models:
        return False
    _backup(path)
    del models[model_id]
    data["models"] = models
    _write_json(path, data)
    return True


def plugins_file(agent_dir, profile=MODEL_PROFILE):
    return agent_dir / "profiles" / profile / "plugins.json"


def read_plugins(agent_dir, profile=MODEL_PROFILE):
    data = _read_json(plugins_file(agent_dir, profile), {})
    plugins = data.get("plugin")
    if isinstance(plugins, list):
        return [str(p) for p in plugins if p]
    return []


def write_plugins(agent_dir, plugins, profile=MODEL_PROFILE):
    path = plugins_file(agent_dir, profile)
    path.parent.mkdir(parents=True, exist_ok=True)
    data = _read_json(path, {})
    _backup(path)
    data["plugin"] = [p for p in plugins if p]
    _write_json(path, data)
    return read_plugins(agent_dir, profile)


def mcp_file(agent_dir, profile=MODEL_PROFILE):
    return agent_dir / "profiles" / profile / "mcp.json"


def read_mcp(agent_dir, profile=MODEL_PROFILE):
    data = _read_json(mcp_file(agent_dir, profile), {})
    mcps = data.get("mcp")
    return mcps if isinstance(mcps, dict) else {}


def write_mcp(agent_dir, name, config, profile=MODEL_PROFILE):
    path = mcp_file(agent_dir, profile)
    path.parent.mkdir(parents=True, exist_ok=True)
    data = _read_json(path, {})
    _backup(path)
    mcps = data.get("mcp")
    if not isinstance(mcps, dict):
        mcps = {}
    mcps[name] = config
    data["mcp"] = mcps
    _write_json(path, data)
    return mcps


def remove_mcp(agent_dir, name, profile=MODEL_PROFILE):
    path = mcp_file(agent_dir, profile)
    data = _read_json(path, {})
    mcps = data.get("mcp")
    if not isinstance(mcps, dict) or name not in mcps:
        return False
    _backup(path)
    del mcps[name]
    data["mcp"] = mcps
    _write_json(path, data)
    return True


def delete_provider(agent_dir, provider_id):
    _require_valid_provider_id(provider_id)
    provider_file = agent_dir / "providers" / f"{provider_id}.json"
    if provider_file.is_file():
        _backup(provider_file)
        provider_file.unlink()


def get_active_providers(agent_dir):
    settings = _read_json(agent_dir / "profiles" / "coding" / "settings.json", {})
    active = settings.get("activeProviders", [])
    if isinstance(active, str):
        active = [active]
    return [item for item in active if isinstance(item, str) and item]


def set_active_providers(agent_dir, provider_ids):
    settings_path = agent_dir / "profiles" / "coding" / "settings.json"
    settings_path.parent.mkdir(parents=True, exist_ok=True)
    settings = _read_json(settings_path, {})
    _backup(settings_path)
    settings["activeProviders"] = list(provider_ids)
    _write_json(settings_path, settings)


def activate_provider(agent_dir, provider_id):
    """Move a provider to the front of the active list (all stay merged in builds)."""
    active = get_active_providers(agent_dir)
    set_active_providers(agent_dir, [provider_id] + [p for p in active if p != provider_id])


def active_provider(agent_dir):
    for provider_id in get_active_providers(agent_dir):
        provider = read_provider(agent_dir, provider_id)
        if provider:
            return provider
    return None
