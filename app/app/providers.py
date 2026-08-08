"""Provider CRUD and switching endpoints (BDF provider files in the agent's config)."""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from . import agentstore

router = APIRouter(prefix="/api")


class ModelItem(BaseModel):
    model: str = ""
    name: str = ""
    thinking: list[str] = []


class ProviderBody(BaseModel):
    name: str = ""
    baseUrl: str = ""
    apiKey: str = ""
    npm: str = ""
    models: list[ModelItem] | None = None


class SwitchBody(BaseModel):
    id: str


def _public(provider, active_ids, models=None):
    return {
        "id": provider["id"],
        "name": provider["name"],
        "baseUrl": provider["baseUrl"],
        "hasKey": bool(provider.get("apiKey")),
        "active": provider["id"] in active_ids,
        "npm": provider.get("npm") or "",
        "models": models or [],
    }


@router.get("/providers")
def list_providers():
    agent_dir = agentstore.require_agent_dir()
    active_ids = agentstore.get_active_providers(agent_dir)
    providers = []
    for provider in agentstore.list_providers(agent_dir):
        models = agentstore.read_models(agent_dir, provider["id"])
        providers.append(_public(provider, active_ids, models))
    return {"providers": providers, "activeProvider": active_ids[0] if active_ids else None}


@router.post("/providers", status_code=201)
def create_provider(body: ProviderBody):
    name = body.name.strip()
    base_url = body.baseUrl.strip()
    if not name:
        raise HTTPException(400, "Give your provider a name first.")
    if not base_url:
        raise HTTPException(400, "The base URL can't be empty.")
    provider_id = agentstore.slugify(name)
    if not provider_id:
        raise HTTPException(400, "That name can't be used as a provider id — use letters and numbers.")
    agent_dir = agentstore.require_agent_dir()
    if agentstore.read_provider(agent_dir, provider_id):
        raise HTTPException(400, f"A provider named '{name}' already exists on your agent. Use a different name.")
    provider = agentstore.write_provider(agent_dir, provider_id, name, base_url, body.apiKey.strip(), body.npm.strip())
    agentstore.activate_provider(agent_dir, provider_id)
    models = []
    if body.models is not None:
        models = agentstore.write_models(agent_dir, provider_id, [m.model_dump() for m in body.models])
    return _public(provider, agentstore.get_active_providers(agent_dir), models)


@router.put("/providers/{provider_id}")
def update_provider(provider_id: str, body: ProviderBody):
    agent_dir = agentstore.require_agent_dir()
    existing = agentstore.read_provider(agent_dir, provider_id)
    if not existing:
        raise HTTPException(404, "That provider doesn't exist anymore. Refresh the page.")
    name = body.name.strip() or existing["name"]
    base_url = body.baseUrl.strip() or existing["baseUrl"]
    api_key = body.apiKey.strip() or existing["apiKey"]
    npm = body.npm.strip() or existing["npm"]
    provider = agentstore.write_provider(agent_dir, provider_id, name, base_url, api_key, npm)
    models = agentstore.read_models(agent_dir, provider_id)
    if body.models is not None:
        models = agentstore.write_models(agent_dir, provider_id, [m.model_dump() for m in body.models])
    return _public(provider, agentstore.get_active_providers(agent_dir), models)


@router.delete("/providers/{provider_id}")
def delete_provider(provider_id: str):
    agent_dir = agentstore.require_agent_dir()
    if not agentstore.read_provider(agent_dir, provider_id):
        raise HTTPException(404, "That provider doesn't exist anymore. Refresh the page.")
    agentstore.delete_models(agent_dir, provider_id)
    agentstore.delete_provider(agent_dir, provider_id)
    active_ids = agentstore.get_active_providers(agent_dir)
    if provider_id in active_ids:
        agentstore.set_active_providers(agent_dir, [i for i in active_ids if i != provider_id])
    return {"ok": True}


@router.post("/switch")
def switch_provider(body: SwitchBody):
    agent_dir = agentstore.require_agent_dir()
    if not agentstore.read_provider(agent_dir, body.id):
        raise HTTPException(404, "That provider doesn't exist anymore. Refresh the page.")
    agentstore.activate_provider(agent_dir, body.id)
    return {"ok": True, "activeProvider": body.id}
