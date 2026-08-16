"""Single source of truth for agent capabilities and canonical agent identity.

Capabilities key off the canonical agent type, never an arbitrary display name,
directory, or label. This module performs no Claude-state access.
"""

from fastapi import APIRouter

from . import agentstore

router = APIRouter(prefix="/api")

_OPENCODE_FAMILY = {
    "providerMode": "multi-provider",
    "savedRoutes": False,
    "providerCreation": True,
    "providerActivation": True,
    "pluginsManaged": True,
    "mcpManaged": True,
    "integrationsVisible": True,
    "reasoningFormats": True,
    "sdkSelection": True,
    "profilesMode": "bdf-profiles",
    "requestAnalytics": True,
    "routingActivity": False,
    "builderAvailable": True,
}

_CLAUDE_FAMILY = {
    "providerMode": "scalar-route",
    "savedRoutes": True,
    "providerCreation": False,
    "providerActivation": False,
    "pluginsManaged": False,
    "mcpManaged": False,
    "integrationsVisible": False,
    "reasoningFormats": False,
    "sdkSelection": False,
    "profilesMode": "routing-profiles",
    "requestAnalytics": False,
    "routingActivity": True,
    "builderAvailable": False,
}

CAPABILITIES = {
    "opencode": _OPENCODE_FAMILY,
    "kilo": _OPENCODE_FAMILY,
    "claude-code": _CLAUDE_FAMILY,
}

_DISPLAY_NAMES = {"opencode": "OpenCode", "kilo": "Kilo", "claude-code": "Claude Code"}

_CANONICAL = {
    "opencode": "opencode",
    "kilo": "kilo",
    "kilocode": "kilo",
    "claudecode": "claude-code",
    "claude-code": "claude-code",
}


def canonical_agent_type(name):
    """Map any persisted agent name to its canonical capability key.

    opencode -> opencode; kilo -> kilo; kilocode -> kilo;
    claudecode -> claude-code; claude-code -> claude-code.
    Unknown names return None (no capability set)."""
    key = str(name or "").strip().lower()
    return _CANONICAL.get(key)


@router.get("/capabilities")
def capabilities():
    name = agentstore.active_agent_name()
    canonical = canonical_agent_type(name)
    if canonical is None:
        return {"agent": name or None, "canonicalType": None, "displayName": name or None, "capabilities": None}
    return {
        "agent": name,
        "canonicalType": canonical,
        "displayName": _DISPLAY_NAMES.get(canonical, name),
        "capabilities": CAPABILITIES[canonical],
    }
