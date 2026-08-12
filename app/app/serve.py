"""Serves the GUI (gui.html) with a built-in placeholder fallback."""

from fastapi import APIRouter
from fastapi.responses import HTMLResponse

from . import rules
from .config import APP_DIR

router = APIRouter()

_last_warning = None

PLACEHOLDER = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Switcher</title>
<style>
  body{margin:0;font-family:"Segoe UI",system-ui,sans-serif;background:#0d1117;color:#e6edf3;display:flex;align-items:center;justify-content:center;min-height:100vh}
  .card{background:#161b22;border:1px solid #30363d;border-radius:16px;padding:40px 48px;max-width:520px;text-align:center}
  h1{margin:0 0 8px;font-size:28px}
  p{color:#8b949e;line-height:1.6}
  .dot{display:inline-block;width:10px;height:10px;border-radius:50%;background:#3fb950;margin-right:8px;animation:pulse 2s infinite}
  @keyframes pulse{0%,100%{opacity:1}50%{opacity:.4}}
  code{background:#21262d;padding:2px 6px;border-radius:6px;font-size:13px}
  .status{margin-top:16px;font-size:14px;color:#3fb950}
</style>
</head>
<body>
<div class="card">
  <h1>Switcher</h1>
  <p>The backend is running on <code>127.0.0.1:9090</code>.<br>
  The full interface (<code>gui.html</code>) is not here yet —<br>
  drop it into the <code>docs\\app</code> folder and refresh this page.</p>
  <div class="status"><span class="dot"></span>Backend running</div>
</div>
</body>
</html>
"""


def _sanitize_css_value(value):
    """Belt-and-braces: no CSS/HTML breakout characters in theme values."""
    return "".join(ch for ch in str(value) if ch not in "<>{;}\n\r\t")


def build_theme_style(theme):
    declarations = ";".join(
        f"{key}:{_sanitize_css_value(value)}" for key, value in theme.items()
    )
    return f"<style>:root{{{declarations}}}</style>"


def inject_before_head(html, injection):
    marker = "</head>"
    position = html.lower().find(marker)
    if position == -1:
        return html
    return html[:position] + injection + html[position:]


@router.get("/")
def index():
    global _last_warning
    gui = APP_DIR / "gui.html"
    if gui.is_file():
        html = gui.read_text(encoding="utf-8")
        problem = rules.theme_problem()
        if problem and problem != _last_warning:
            _last_warning = problem
            print(f"[rules] {problem}")
        response = HTMLResponse(inject_before_head(html, build_theme_style(rules.get_theme())))
        response.headers["Cache-Control"] = "no-cache"
        return response
    return HTMLResponse(PLACEHOLDER)


@router.get("/api/rules")
def rules_endpoint():
    return {"theme": rules.get_theme(), "rulebook": rules.get_rulebook()}
