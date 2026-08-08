"""Agent-config store: reads/writes the agent's BDF provider files and active providers."""

import json
import re
import shutil
from datetime import datetime
from pathlib import Path

from fastapi import HTTPException

from .storage import get_state

NPM_OPENAI_COMPATIBLE = "@ai-sdk/openai-compatible"


def require_agent_dir():
    state = get_state()
    agent = state.get("agent")
    directory = state.get("dir")
    if not agent or not directory:
        raise HTTPException(400, "No agent is set up yet. Run the setup wizard first.")
    return Path(directory)


def slugify(name):
    return re.sub(r"[^a-z0-9]+", "-", name.strip().lower()).strip("-")


def find_builder_script(agent_dir, agent):
    scripts_dir = agent_dir / "scripts"
    exact = scripts_dir / f"build-{agent}.ps1"
    if exact.is_file():
        return exact
    if scripts_dir.is_dir():
        matches = sorted(scripts_dir.glob(f"build-{agent}*.ps1"))
        if matches:
            return matches[0]
    return None


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
        data = json.loads(path.read_text(encoding="utf-8"))
        return data if isinstance(data, dict) else default
    except (OSError, ValueError):
        return default


def _write_json(path, data):
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    tmp.replace(path)


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
    }


def list_providers(agent_dir):
    providers_dir = agent_dir / "providers"
    if not providers_dir.is_dir():
        return []
    return [_provider_dict(f) for f in sorted(providers_dir.glob("*.json"))]


def read_provider(agent_dir, provider_id):
    provider_file = agent_dir / "providers" / f"{provider_id}.json"
    if not provider_file.is_file():
        return None
    return _provider_dict(provider_file)


def write_provider(agent_dir, provider_id, name, base_url, api_key, npm=None):
    providers_dir = agent_dir / "providers"
    providers_dir.mkdir(parents=True, exist_ok=True)
    provider_file = providers_dir / f"{provider_id}.json"
    data = _read_json(provider_file, {})
    _backup(provider_file)
    inner = (data.get("provider") or {}).get(provider_id, {})
    inner["name"] = name
    inner["apiKey"] = api_key
    inner["options"] = {"baseURL": base_url}
    inner["npm"] = npm or inner.get("npm") or NPM_OPENAI_COMPATIBLE
    inner.setdefault("models", {})
    data["provider"] = data.get("provider") or {}
    data["provider"][provider_id] = inner
    data["id"] = provider_id
    _write_json(provider_file, data)
    return _provider_dict(provider_file)


MODEL_PROFILE = "coding"


def models_file(agent_dir, provider_id, profile=MODEL_PROFILE):
    return agent_dir / "profiles" / profile / f"{provider_id}-models.json"


def read_models(agent_dir, provider_id, profile=MODEL_PROFILE):
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


def write_models(agent_dir, provider_id, items, profile=MODEL_PROFILE):
    path = models_file(agent_dir, provider_id, profile)
    path.parent.mkdir(parents=True, exist_ok=True)
    existing = _read_json(path, {})
    _backup(path)
    models = {}
    for item in items or []:
        model_id = item.get("model")
        if not model_id:
            continue
        entry = dict(existing.get("models") or {}).get(model_id) or {}
        entry["name"] = item.get("name") or model_id
        variants = {}
        for level in item.get("thinking") or []:
            if level:
                variants[level] = {"reasoningEffort": level}
        entry["variants"] = variants
        models[model_id] = entry
    existing["models"] = models
    _write_json(path, existing)
    return read_models(agent_dir, provider_id, profile)


def delete_models(agent_dir, provider_id, profile=MODEL_PROFILE):
    path = models_file(agent_dir, provider_id, profile)
    if path.is_file():
        _backup(path)
        path.unlink()


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


def delete_provider(agent_dir, provider_id):
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
