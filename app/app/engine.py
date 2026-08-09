"""Runs the bundled BDF engine (scaffold-agent.ps1) and the generated builders."""

import shutil
import subprocess
from pathlib import Path

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from . import agentstore
from .config import ENGINE_SCHEMAS, SCAFFOLD_SCRIPT
from .storage import get_state, set_state

router = APIRouter(prefix="/api")

PS1 = "powershell.exe"
PS1_ARGS = ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File"]


def _seed_schemas(directory):
    """Give a freshly scaffolded agent the bundled JSON schemas so its
    generated builder can run schema validation out of the box."""
    if not ENGINE_SCHEMAS.is_dir():
        return
    target = Path(directory) / "schemas"
    if target.is_dir():
        return
    try:
        shutil.copytree(ENGINE_SCHEMAS, target)
    except OSError:
        pass


class ScaffoldBody(BaseModel):
    agent: str
    dir: str


class BuildBody(BaseModel):
    profile: str = "coding"


def _run_ps1(args, timeout):
    command = [PS1, *PS1_ARGS, *args]
    try:
        proc = subprocess.run(
            command,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout,
            cwd=SCAFFOLD_SCRIPT.parent,
        )
    except subprocess.TimeoutExpired:
        raise HTTPException(500, "The command took too long and was stopped. Try again.")
    output = ((proc.stdout or "") + (proc.stderr or "")).strip()
    return proc.returncode, output


@router.post("/scaffold")
def scaffold(body: ScaffoldBody):
    directory = Path(body.dir)
    if not directory.is_dir():
        raise HTTPException(400, "That folder doesn't exist on this computer.")
    if not SCAFFOLD_SCRIPT.is_file():
        raise HTTPException(
            500,
            "The engine script (scaffold-agent.ps1) was not found. Put this app next to it or set the BDF_SCRIPTS_DIR environment variable.",
        )
    code, output = _run_ps1(
        [
            str(SCAFFOLD_SCRIPT),
            "-Agent",
            body.agent,
            "-ConfigRoot",
            str(directory),
            "-NonInteractive",
            "-Bootstrap",
        ],
        180,
    )
    agentstore.upsert_agent(body.agent, str(directory))
    if code == 0:
        _seed_schemas(directory)
    scripts_dir = directory / "scripts"
    generated = [
        name
        for name in (f"build-{body.agent}.ps1", f"test-{body.agent}.ps1", f"scaffold-{body.agent}.ps1")
        if (scripts_dir / name).is_file()
    ]
    profiles_dir = directory / "profiles"
    profiles = [p.name for p in profiles_dir.glob("*") if p.is_dir()] if profiles_dir.is_dir() else []
    return {
        "ok": code == 0,
        "generated": generated,
        "profiles": profiles,
        "message": output or ("Done." if code == 0 else "Something went wrong. See the output above."),
    }


@router.post("/build")
def build(body: BuildBody):
    if any(part in body.profile for part in ("/", "\\", "..")):
        raise HTTPException(400, "Invalid profile name.")
    agent, directory = agentstore.current_agent()
    if not agent or not directory:
        raise HTTPException(400, "No agent is set up yet. Run the setup wizard first.")
    script = agentstore.find_builder_script(Path(directory), agent)
    if not script:
        raise HTTPException(
            400,
            f"No builder script for '{agent}' was found. Run 'Generate my builder' first.",
        )
    code, output = _run_ps1(
        [str(script), "-Profile", body.profile, "-NonInteractive", "-ConfigRoot", str(directory)],
        300,
    )
    return {"ok": code == 0, "output": output}
