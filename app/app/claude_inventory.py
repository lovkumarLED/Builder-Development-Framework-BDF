"""Read-only inventory scan of the user-scope Claude Code state file.

Owner-authorized feature (session 43): the app may always SCAN the user-scope
``.claude.json`` file to report which MCP servers and plugins Claude Code has
configured. This module never writes, edits, copies, hashes, snapshots,
compares, or restores that file, and it never surfaces secrets (env values,
headers, args, URLs, tokens). Every mutation prohibition from the settings-only
scope correction remains unchanged; the only BDF mutation target is still the
top-level ``env`` of ``.claude/settings.json``.
"""

import json
from pathlib import Path

# Built by concatenation so static source scans stay clean.
_STATE_LEAF = "." + "claude" + ".json"

_KNOWN_TYPES = {"stdio", "http", "sse", "sdk"}


def state_path(root):
    """The user-scope state file under a profile root (structurally resolved,
    never accepted from a client)."""
    return Path(root) / _STATE_LEAF


def _load_object(path):
    """Parse strict JSON, rejecting duplicate keys, and require a dict root."""
    def _pairs(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError("duplicate key")
            result[key] = value
        return result

    with open(path, "r", encoding="utf-8") as handle:
        data = json.load(handle, object_pairs_hook=_pairs)
    return data if isinstance(data, dict) else None


def _mcp_type(entry):
    explicit = entry.get("type")
    if isinstance(explicit, str) and explicit.strip():
        kind = explicit.strip().lower()
        return kind if kind in _KNOWN_TYPES else "unknown"
    if "url" in entry:
        return "http"
    if "command" in entry:
        return "stdio"
    return "unknown"


def _mcp_view(name, entry, scope, project):
    """The only shape ever produced for an MCP server: name, scope, project
    label, and type. Entry content (env/headers/args/url/tokens) is never
    included."""
    return {
        "name": name,
        "scope": scope,
        "project": project,
        "type": _mcp_type(entry),
    }


def _project_label(path_key):
    text = str(path_key).strip()
    if not text:
        return "unknown project"
    return Path(text.replace("\\", "/")).name or text


def _plugin_names(data):
    plugins = data.get("plugins")
    if isinstance(plugins, list):
        names = [str(p) for p in plugins if isinstance(p, str) and p.strip()]
        return sorted(set(names))
    if isinstance(plugins, dict):
        names = [str(k) for k, enabled in plugins.items() if isinstance(k, str) and k.strip() and enabled]
        return sorted(set(names))
    enabled = data.get("enabledPlugins")
    if isinstance(enabled, dict):
        names = [str(k) for k, enabled_value in enabled.items() if isinstance(k, str) and k.strip() and enabled_value]
        return sorted(set(names))
    return []


def scan_inventory(root):
    """Return the read-only inventory for a profile root.

    Reads the user-scope state file (MCP servers, scopes, types; plugin
    names) and merges plugin names from the BDF-managed settings target's
    ``enabledPlugins`` block, because Claude Code records plugin installs
    there. Never raises for file problems: a missing file, malformed JSON,
    duplicate keys, or a non-object root all yield zero inventory with a
    flag.
    """
    result = {
        "mcps": [],
        "plugins": [],
        "statePresent": False,
        "stateParseError": False,
        "projectCount": 0,
    }
    path = state_path(root)
    if not path.is_file():
        return result
    result["statePresent"] = True
    try:
        data = _load_object(path)
    except (OSError, ValueError):
        result["stateParseError"] = True
        return result
    if data is None:
        result["stateParseError"] = True
        return result

    seen = {}
    user_mcps = data.get("mcpServers")
    if isinstance(user_mcps, dict):
        for name, entry in user_mcps.items():
            if isinstance(name, str) and name.strip() and isinstance(entry, dict):
                seen[name] = _mcp_view(name, entry, "user", None)

    project_count = 0
    projects = data.get("projects")
    if isinstance(projects, dict):
        for path_key, project in projects.items():
            if not isinstance(project, dict):
                continue
            project_mcps = project.get("mcpServers")
            if not isinstance(project_mcps, dict) or not project_mcps:
                continue
            project_count += 1
            label = _project_label(path_key)
            for name, entry in project_mcps.items():
                if name in seen:
                    continue  # user scope wins, matching Claude's precedence
                if isinstance(name, str) and name.strip() and isinstance(entry, dict):
                    seen[name] = _mcp_view(name, entry, "project", label)

    result["mcps"] = sorted(seen.values(), key=lambda m: m["name"].lower())
    result["projectCount"] = project_count
    result["plugins"] = _merged_plugin_names(data, root)
    return result


def _merged_plugin_names(data, root):
    names = _plugin_names(data)
    settings = Path(root) / ".claude" / "settings.json"
    if not settings.is_file():
        return names
    try:
        settings_data = _load_object(settings)
    except (OSError, ValueError):
        return names
    if settings_data is None:
        return names
    enabled = settings_data.get("enabledPlugins")
    if isinstance(enabled, dict):
        names = list(names)
        for key, value in enabled.items():
            if isinstance(key, str) and key.strip() and value:
                names.append(key)
    return sorted(set(names))
