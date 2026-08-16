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
