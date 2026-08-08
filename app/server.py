"""AI Switcher — entry point. Serves the GUI and starts the local server."""

import threading
import webbrowser

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app import APP_VERSION, config
from app.discovery import router as discovery_router
from app.engine import router as engine_router
from app.plugins import router as plugins_router
from app.providers import router as providers_router
from app.proxy import router as proxy_router
from app.serve import router as serve_router
from app.testing import router as testing_router

app = FastAPI(title="AI Switcher", version=APP_VERSION)

app.mount("/lib", StaticFiles(directory=config.APP_DIR / "lib"), name="lib")
app.mount("/assets", StaticFiles(directory=config.APP_DIR / "assets"), name="assets")

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(127\.0\.0\.1|localhost)(:\d+)?",
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(serve_router)
app.include_router(discovery_router)
app.include_router(providers_router)
app.include_router(engine_router)
app.include_router(testing_router)
app.include_router(plugins_router)
app.include_router(proxy_router)

if __name__ == "__main__":
    url = f"http://{config.HOST}:{config.PORT}"
    threading.Timer(1.2, lambda: webbrowser.open(url)).start()
    uvicorn.run(app, host=config.HOST, port=config.PORT, log_level="info")
