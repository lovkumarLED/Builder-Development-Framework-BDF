"""Plugin endpoints (profile-level plugins for the agent's coding profile)."""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from . import agentstore

router = APIRouter(prefix="/api")


class PluginBody(BaseModel):
    plugin: str = ""


@router.get("/plugins")
def list_plugins():
    agent_dir = agentstore.require_agent_dir()
    return {"plugins": agentstore.read_plugins(agent_dir)}


@router.post("/plugins", status_code=201)
def add_plugin(body: PluginBody):
    plugin = body.plugin.strip()
    if not plugin:
        raise HTTPException(400, "Type a plugin first.")
    agent_dir = agentstore.require_agent_dir()
    plugins = agentstore.read_plugins(agent_dir)
    if plugin not in plugins:
        plugins.append(plugin)
    agentstore.write_plugins(agent_dir, plugins)
    return {"plugins": agentstore.read_plugins(agent_dir)}


@router.delete("/plugins")
def remove_plugin(body: PluginBody):
    plugin = body.plugin.strip()
    if not plugin:
        raise HTTPException(400, "Type a plugin first.")
    agent_dir = agentstore.require_agent_dir()
    plugins = [p for p in agentstore.read_plugins(agent_dir) if p != plugin]
    agentstore.write_plugins(agent_dir, plugins)
    return {"plugins": agentstore.read_plugins(agent_dir)}
