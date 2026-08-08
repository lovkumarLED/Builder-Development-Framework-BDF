@echo off
title AI Switcher
cd /d "%~dp0"

set "VENV_PY=env\Scripts\python.exe"

where python >nul 2>nul
if errorlevel 1 (
    echo.
    echo Python was not found on this computer.
    echo Install it from https://www.python.org/downloads/
    echo ^(tick "Add python.exe to PATH" during installation^), then try again.
    echo.
    pause
    exit /b 1
)

if not exist "%VENV_PY%" (
    echo.
    echo First run: creating the app's own Python environment ^(one-time^)...
    python -m venv env
    if errorlevel 1 (
        echo.
        echo Could not create the Python environment.
        echo Reinstall Python from https://www.python.org/downloads/ and try again.
        echo.
        pause
        exit /b 1
    )
)

set "HASH_FILE=env\.requirements.hash"
set "CUR_HASH="
for /f %%h in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 'requirements.txt').Hash"') do set "CUR_HASH=%%h"
set "OLD_HASH="
if exist "%HASH_FILE%" set /p OLD_HASH=<"%HASH_FILE%"
if not "%CUR_HASH%"=="%OLD_HASH%" (
    echo Installing app packages ^(first run or requirements changed^)...
    "%VENV_PY%" -m pip install --upgrade pip >nul 2>nul
    "%VENV_PY%" -m pip install -r requirements.txt
    if errorlevel 1 (
        echo.
        echo Package install failed. Check your internet connection and try again.
        echo.
        pause
        exit /b 1
    )
    echo %CUR_HASH%> "%HASH_FILE%"
)

echo.
echo Starting AI Switcher... your browser will open in a moment.
echo Close this window to stop the app.
echo.
"%VENV_PY%" server.py
pause
