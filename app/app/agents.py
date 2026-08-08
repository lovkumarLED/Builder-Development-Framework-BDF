"""Agent endpoints: register agent config locations and switch which agent the app manages."""

from pathlib import Path

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from . import agentstore

router = APIRouter(prefix="/api")


class AgentBody(BaseModel):
    name: str = ""
    dir: str = ""


class AgentSwitchBody(BaseModel):
    name: str = ""


@router.get("/agents")
def list_agents():
    return {"agents": agentstore.get_agents(), "active": agentstore.active_agent_name()}


@router.post("/agents", status_code=201)
def add_agent(body: AgentBody):
    directory = Path(body.dir.strip())
    if not directory.is_dir():
        raise HTTPException(400, "That folder doesn't exist on this computer. Check the path and try again.")
    name = body.name.strip() or directory.name
    agentstore.add_agent(name, str(directory))
    agentstore.switch_agent(name)
    ready = agentstore.has_any_builder(directory)
    return {"agents": agentstore.get_agents(), "active": agentstore.active_agent_name(), "ready": ready}


@router.delete("/agents/{name}")
def delete_agent(name: str):
    agents, active = agentstore.remove_agent(name)
    return {"agents": agents, "active": active}


@router.post("/agents/switch")
def switch_agent(body: AgentSwitchBody):
    if not body.name.strip():
        raise HTTPException(400, "Type an agent name.")
    agentstore.switch_agent(body.name.strip())
    return {"ok": True, "active": agentstore.active_agent_name()}
