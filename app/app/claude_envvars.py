"""User-scope Windows environment variable management for Claude routes.

Owner-directed credential flow (session 45): when the user enters an API key
in the route form, the app creates/updates the named user-scope environment
variable itself (persistent, per-user registry) AND sets it in the running
process's environment so the builder child process inherits it immediately —
no server restart is ever required. When an app-managed route is removed and
nothing else references the variable, the app deletes it.

Values are never read back by callers except for existence checks; the value
itself is only ever written. Tests patch this module's functions, so no real
registry or process environment is touched in fixtures.
"""

import ctypes
import os
import winreg

_ENV_KEY = "Environment"


def _set_process_env(name, value):
    """Set the variable in the current process so child processes (the
    production builder) inherit it without a restart."""
    if value is None:
        ctypes.windll.kernel32.SetEnvironmentVariableW(name, None)
        os.environ.pop(name, None)
    else:
        ctypes.windll.kernel32.SetEnvironmentVariableW(name, value)
        os.environ[name] = value


def user_env_exists(name):
    """True when the variable already exists in the user-scope registry
    environment (i.e. it predates this app or another route managed it)."""
    try:
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, _ENV_KEY) as key:
            winreg.QueryValueEx(key, name)
        return True
    except OSError:
        return False


def user_env_get(name):
    """Read the value of a user-scope registry environment variable, or None
    when it is absent. Used to reload app-managed credentials into a server
    process that restarted after the variable was created."""
    try:
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, _ENV_KEY) as key:
            value, _ = winreg.QueryValueEx(key, name)
        if isinstance(value, bytes):
            value = value.decode("utf-8", errors="replace")
        return value if isinstance(value, str) else None
    except OSError:
        return None


def ensure_process_env(name):
    """Ensure the named credential resolves in the current process environment
    so the production builder child can find it. When a restarted server no
    longer inherits an app-managed variable, resolve it from the user-scope
    registry into os.environ (the registry is the app's persistent store)."""
    if not name or name in os.environ:
        return os.environ.get(name)
    value = user_env_get(name)
    if value is not None:
        os.environ[name] = value
    return os.environ.get(name)


def set_user_env(name, value):
    """Persist the variable in the user-scope registry environment and apply
    it to the current process immediately."""
    with winreg.CreateKeyEx(winreg.HKEY_CURRENT_USER, _ENV_KEY, 0, winreg.KEY_SET_VALUE) as key:
        winreg.SetValueEx(key, name, 0, winreg.REG_SZ, value)
    _set_process_env(name, value)


def delete_user_env(name):
    """Remove the variable from the user-scope registry environment and the
    current process. Missing variables are ignored."""
    try:
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, _ENV_KEY, 0, winreg.KEY_SET_VALUE) as key:
            winreg.DeleteValue(key, name)
    except OSError:
        pass
    _set_process_env(name, None)
