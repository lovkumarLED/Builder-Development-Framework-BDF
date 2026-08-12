"""Provider connection tester (calls the /v1/models endpoint)."""

import re
import time
import urllib.error
import urllib.request

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from . import agentstore

router = APIRouter(prefix="/api")

_URL_RE = re.compile(r"^https?://", re.IGNORECASE)


class _NoRedirectHandler(urllib.request.HTTPRedirectHandler):
    """Never follow upstream redirects: a redirect must not re-point the
    bearer token at an arbitrary host (SSRF-via-redirect)."""

    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


_OPENER = urllib.request.build_opener(_NoRedirectHandler)


class TestBody(BaseModel):
    id: str = ""
    baseUrl: str = ""
    apiKey: str = ""


def _models_url(base_url):
    base = base_url.strip().rstrip("/")
    return base + "/models" if base.endswith("/v1") else base + "/v1/models"


def _try_models(url, api_key):
    request = urllib.request.Request(url, headers={"Accept": "application/json"})
    if api_key:
        request.add_header("Authorization", "Bearer " + api_key)
    start = time.perf_counter()
    try:
        with _OPENER.open(request, timeout=20) as response:
            response.read(64)
            latency = round((time.perf_counter() - start) * 1000)
            return True, latency, None
    except urllib.error.HTTPError as error:
        latency = round((time.perf_counter() - start) * 1000)
        return False, latency, f"The server answered with an error (code {error.code}). The URL or key may be wrong."
    except (urllib.error.URLError, OSError) as error:
        latency = round((time.perf_counter() - start) * 1000)
        return False, latency, "Couldn't reach it. Is that server running?"


@router.post("/test")
def test(body: TestBody):
    base_url, api_key = body.baseUrl, body.apiKey
    if body.id:
        agent_dir = agentstore.require_agent_dir()
        provider = agentstore.read_provider(agent_dir, body.id)
        if not provider:
            raise HTTPException(404, "That provider doesn't exist anymore. Refresh the page.")
        base_url, api_key = provider.get("baseUrl", ""), provider.get("apiKey", "")
    if not base_url.strip():
        raise HTTPException(400, "The base URL can't be empty.")
    if not _URL_RE.match(base_url.strip()):
        raise HTTPException(400, "The base URL must start with http:// or https://.")
    ok, latency, problem = _try_models(_models_url(base_url), api_key.strip())
    message = f"Connected in {latency} ms" if ok else problem
    return {"ok": ok, "message": message, "latencyMs": latency}
