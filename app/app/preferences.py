"""App-owned, local preferences that never alter an agent configuration."""

from fastapi import APIRouter, HTTPException

from .config import PREFERENCES_FILE
from .storage import _read, _write


DEFAULT_PREFERENCES = {
    "activityRetentionDays": 30,
    "requestContentRedaction": True,
    "reducedMotion": "system",
}
_MOTION_PREFERENCES = {"system", "reduce"}

router = APIRouter()


def get_preferences():
    data = _read(PREFERENCES_FILE, {})
    preferences = {**DEFAULT_PREFERENCES, **data}
    days = data.get("activityRetentionDays")
    if isinstance(days, bool):
        days = None
    try:
        days = int(days)
    except (TypeError, ValueError):
        days = DEFAULT_PREFERENCES["activityRetentionDays"]
    preferences["activityRetentionDays"] = days if 1 <= days <= 365 else DEFAULT_PREFERENCES["activityRetentionDays"]
    preferences["requestContentRedaction"] = True
    preferences["reducedMotion"] = data.get("reducedMotion") if data.get("reducedMotion") in _MOTION_PREFERENCES else "system"
    return preferences


def update_preferences(values):
    if values.get("requestContentRedaction") is False:
        raise HTTPException(400, "Request-content redaction is required.")
    days = values.get("activityRetentionDays", get_preferences()["activityRetentionDays"])
    if isinstance(days, bool):
        raise HTTPException(400, "Retention must be between 1 and 365 days.")
    try:
        days = int(days)
    except (TypeError, ValueError):
        raise HTTPException(400, "Retention must be between 1 and 365 days.")
    if not 1 <= days <= 365:
        raise HTTPException(400, "Retention must be between 1 and 365 days.")

    current = get_preferences()
    current["activityRetentionDays"] = days
    reduced_motion = values.get("reducedMotion", current["reducedMotion"])
    if reduced_motion not in _MOTION_PREFERENCES:
        raise HTTPException(400, "Motion preference must be 'system' or 'reduce'.")
    current["reducedMotion"] = reduced_motion
    _write(PREFERENCES_FILE, current)
    return current


@router.get("/api/preferences")
def read_preferences():
    return get_preferences()


@router.put("/api/preferences")
def write_preferences(values: dict):
    return update_preferences(values)
