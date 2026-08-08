"""MCP server endpoints (profile-level MCP servers for the agent's coding profile)."""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from . import agentstore

router = APIRouter(prefix="/api")


class McpBody(BaseModel):
    name: str = ""
    config: dict | None = None


@router.get("/mcp")
def list_mcp():
    agent_dir = agentstore.require_agent_dir()
    return {"mcps": agentstore.read_mcp(agent_dir)}


@router.post("/mcp", status_code=201)
def add_mcp(body: McpBody):
    name = body.name.strip()
    if not name:
        raise HTTPException(400, "Give the MCP server a name first.")
    if not isinstance(body.config, dict) or not body.config:
        raise HTTPException(400, "The config must be JSON with a type (local/remote) and a command or url.")
    agent_dir = agentstore.require_agent_dir()
    agentstore.write_mcp(agent_dir, name, body.config)
    return {"mcps": agentstore.read_mcp(agent_dir)}


@router.delete("/mcp")
def remove_mcp(body: McpBody):
    name = body.name.strip()
    if not name:
        raise HTTPException(400, "Type a name first.")
    agent_dir = agentstore.require_agent_dir()
    if not agentstore.remove_mcp(agent_dir, name):
        raise HTTPException(404, "That MCP server doesn't exist.")
    return {"mcps": agentstore.read_mcp(agent_dir)}
