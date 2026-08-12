"""AI Switcher — entry point. Serves the GUI and starts the local server."""

import threading
import webbrowser

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app import APP_VERSION, config
from app.activity import router as activity_router
from app.agents import router as agents_router
from app.banner import print_banner
from app.discovery import router as discovery_router
from app.engine import router as engine_router
from app.mcp import router as mcp_router
from app.plugins import router as plugins_router
from app.preferences import router as preferences_router
from app.profiles import router as profiles_router
from app.providers import router as providers_router
from app.proxy import router as proxy_router
from app.serve import router as serve_router
from app.testing import router as testing_router

app = FastAPI(title="AI Switcher", version=APP_VERSION)


class NoCacheStaticFiles(StaticFiles):
    """Dev app: always revalidate static assets so edited files show up on refresh."""

    def file_response(self, *args, **kwargs):
        response = super().file_response(*args, **kwargs)
        response.headers["Cache-Control"] = "no-cache"
        return response


app.mount("/lib", NoCacheStaticFiles(directory=config.APP_DIR / "lib"), name="lib")
app.mount("/assets", NoCacheStaticFiles(directory=config.APP_DIR / "assets"), name="assets")

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(127\.0\.0\.1|localhost)(:\d+)?",
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(serve_router)
app.include_router(agents_router)
app.include_router(discovery_router)
app.include_router(providers_router)
app.include_router(engine_router)
app.include_router(testing_router)
app.include_router(plugins_router)
app.include_router(mcp_router)
app.include_router(preferences_router)
app.include_router(profiles_router)
app.include_router(activity_router)
app.include_router(proxy_router)

if __name__ == "__main__":
    print_banner()
    url = f"http://{config.HOST}:{config.PORT}"
    threading.Timer(1.2, lambda: webbrowser.open(url)).start()
    uvicorn.run(app, host=config.HOST, port=config.PORT, log_level="info")
