"""LSP endpoints (profile-level LSP toggle + value for the agent's coding profile)."""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from . import agentstore

router = APIRouter(prefix="/api")


class LspBody(BaseModel):
    # object (not `bool | dict`) so an invalid shape reaches set_lsp's own
    # validation and returns 400 instead of a pydantic 422.
    lsp: object = True
    enabled: bool = True


@router.get("/lsp")
def list_lsp():
    agent_dir = agentstore.require_agent_dir()
    return agentstore.read_lsp(agent_dir)


@router.put("/lsp")
def set_lsp(body: LspBody):
    if not isinstance(body.lsp, (bool, dict)):
        raise HTTPException(400, "lsp must be a boolean or an object.")
    agent_dir = agentstore.require_agent_dir()
    try:
        return agentstore.write_lsp(agent_dir, body.lsp, body.enabled)
    except ValueError as exc:
        raise HTTPException(400, str(exc))
