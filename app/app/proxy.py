"""OpenAI-compatible proxy: forwards /v1/* requests to the active provider."""

import urllib.error
import urllib.request

from fastapi import APIRouter, HTTPException, Request
from fastapi.responses import JSONResponse, Response, StreamingResponse

from . import agentstore

router = APIRouter()


@router.api_route("/v1/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def proxy(path: str, request: Request):
    try:
        agent_dir = agentstore.require_agent_dir()
    except HTTPException as exc:
        return JSONResponse({"error": {"message": str(exc.detail)}}, status_code=exc.status_code)
    provider = agentstore.active_provider(agent_dir)
    if not provider:
        return JSONResponse(
            {"error": {"message": "No active provider. Add one and click 'Switch to this' first."}},
            status_code=503,
        )
    base_url = (provider.get("baseUrl") or "").rstrip("/")
    if not base_url:
        return JSONResponse(
            {"error": {"message": "The active provider has no base URL."}},
            status_code=500,
        )
    target = base_url + "/" + path
    if request.url.query:
        target += "?" + request.url.query
    body = await request.body()
    headers = {
        "Authorization": "Bearer " + provider.get("apiKey", ""),
        "Content-Type": request.headers.get("content-type", "application/json"),
    }
    upstream = urllib.request.Request(
        target,
        data=body or None,
        method=request.method,
        headers=headers,
    )
    try:
        response = urllib.request.urlopen(upstream, timeout=120)
    except urllib.error.HTTPError as error:
        try:
            detail = error.read().decode("utf-8", "replace")
        except OSError:
            detail = ""
        return Response(content=detail, status_code=error.code, media_type="application/json")
    except (urllib.error.URLError, OSError) as error:
        reason = getattr(error, "reason", str(error))
        return JSONResponse(
            {"error": {"message": f"Couldn't reach the active provider: {reason}"}},
            status_code=502,
        )

    content_type = response.headers.get("content-type", "application/json")

    def chunks():
        while True:
            part = response.read(8192)
            if not part:
                break
            yield part

    return StreamingResponse(chunks(), media_type=content_type)
