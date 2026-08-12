"""Regression tests for the session-33 security review (FSC Part C).

No test-only dependencies: routes are exercised by calling the FastAPI route
functions directly (URL path params decode to the same strings Starlette
passes in), and the proxy is exercised via a hand-built ASGI Request.
"""

import asyncio
import http.server
import json
import tempfile
import threading
import unittest
from unittest.mock import patch
from pathlib import Path

from fastapi import HTTPException
from starlette.requests import Request

from app import agentstore, config, rules, serve, storage
from app.providers import ProviderBody, SwitchBody, delete_provider, switch_provider, update_provider
from app.storage import set_state
from app.testing import TestBody, test as test_connection


class SecurityTestBase(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.state_tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.state_tmp.cleanup)
        original_config_state = config.STATE_FILE
        original_storage_state = storage.STATE_FILE
        config.STATE_FILE = Path(self.state_tmp.name) / "state.json"
        storage.STATE_FILE = config.STATE_FILE
        self.addCleanup(setattr, config, "STATE_FILE", original_config_state)
        self.addCleanup(setattr, storage, "STATE_FILE", original_storage_state)
        self.agent_dir = Path(self.tmp.name)
        self._orig_state = None
        self._backup_state_file()
        if config.STATE_FILE.is_file():
            config.STATE_FILE.unlink()
        set_state(agent="test", dir=str(self.agent_dir))

    def _backup_state_file(self):
        state = config.STATE_FILE
        self._orig_state = state.read_text(encoding="utf-8") if state.is_file() else None

    def _reset_state(self):
        state = config.STATE_FILE
        if self._orig_state is None:
            state.unlink(missing_ok=True)
        else:
            state.write_text(self._orig_state, encoding="utf-8")

    def tearDown(self):
        self._reset_state()


class PathTraversalTests(SecurityTestBase):
    def test_agentstore_rejects_traversal_ids(self):
        with self.assertRaises(HTTPException) as ctx:
            agentstore.read_provider(self.agent_dir, "../escape")
        self.assertEqual(ctx.exception.status_code, 400)
        with self.assertRaises(HTTPException) as ctx:
            agentstore.write_provider(self.agent_dir, "..\\escape", "x", "http://a/v1", "k")
        self.assertEqual(ctx.exception.status_code, 400)
        with self.assertRaises(HTTPException) as ctx:
            agentstore.delete_provider(self.agent_dir, "..%2fescape")
        self.assertEqual(ctx.exception.status_code, 400)
        with self.assertRaises(HTTPException) as ctx:
            agentstore.write_models(self.agent_dir, "../../evil", [])
        self.assertEqual(ctx.exception.status_code, 400)
        with self.assertRaises(HTTPException) as ctx:
            agentstore.read_models(self.agent_dir, "../../evil")
        self.assertEqual(ctx.exception.status_code, 400)

    def test_delete_route_rejects_traversal_and_touches_nothing(self):
        canary = self.agent_dir / "secret.json"
        canary.write_text('{"should":"survive"}', encoding="utf-8")
        with self.assertRaises(HTTPException) as ctx:
            delete_provider("../secret")
        self.assertEqual(ctx.exception.status_code, 400)
        self.assertEqual(canary.read_text(encoding="utf-8"), '{"should":"survive"}')

    def test_put_route_rejects_traversal(self):
        with self.assertRaises(HTTPException) as ctx:
            update_provider("../secret", ProviderBody(name="x", baseUrl="http://a/v1", apiKey=""))
        self.assertEqual(ctx.exception.status_code, 400)

    def test_switch_and_test_reject_traversal_ids(self):
        with self.assertRaises(HTTPException) as ctx:
            switch_provider(SwitchBody(id="../x"))
        self.assertEqual(ctx.exception.status_code, 400)
        with self.assertRaises(HTTPException) as ctx:
            test_connection(TestBody(id="../x"))
        self.assertEqual(ctx.exception.status_code, 400)

    def test_missing_provider_still_404(self):
        with self.assertRaises(HTTPException) as ctx:
            delete_provider("nothere")
        self.assertEqual(ctx.exception.status_code, 404)
        with self.assertRaises(HTTPException) as ctx:
            update_provider("nothere", ProviderBody(name="x", baseUrl="http://a/v1"))
        self.assertEqual(ctx.exception.status_code, 404)

    def test_valid_slug_ids_still_work(self):
        agentstore.write_provider(self.agent_dir, "omniroute-2", "OmniRoute 2", "http://a/v1", "k")
        self.assertIsNotNone(agentstore.read_provider(self.agent_dir, "omniroute-2"))

    def test_agent_names_with_path_chars_rejected(self):
        with self.assertRaises(HTTPException) as ctx:
            agentstore.add_agent("../evil", str(self.agent_dir))
        self.assertEqual(ctx.exception.status_code, 400)
        with self.assertRaises(HTTPException) as ctx:
            agentstore.upsert_agent("a/b", str(self.agent_dir))
        self.assertEqual(ctx.exception.status_code, 400)

    def test_build_rejects_path_traversal_profile(self):
        from app.engine import BuildBody, build

        with self.assertRaises(HTTPException) as ctx:
            build(BuildBody(profile="../coding"))
        self.assertEqual(ctx.exception.status_code, 400)

    def test_build_passes_config_root_of_current_agent(self):
        from app.engine import BuildBody, build
        from app.storage import set_state as set_state_value

        set_state_value(agent="smoke", dir=str(self.agent_dir))
        agentstore.write_provider(self.agent_dir, "smoke", "Smoke", "http://a/v1", "k")
        settings_dir = self.agent_dir / "profiles" / "coding"
        settings_dir.mkdir(parents=True)
        (settings_dir / "settings.json").write_text(
            json.dumps({"activeProviders": ["smoke"]}), encoding="utf-8"
        )
        fake = self.agent_dir / "scripts"
        fake.mkdir()
        (fake / "build-smoke.ps1").write_text(
            "param([string]$Profile = 'coding', [switch]$NonInteractive, [string]$ConfigRoot)\n"
            "Write-Output ('CONFIGROOT=' + $ConfigRoot)\n",
            encoding="utf-8",
        )

        import app.engine as engine

        original = engine._run_ps1

        def spy(args, timeout):
            return 0, f"CONFIGROOT={args[args.index('-ConfigRoot') + 1]}"

        engine._run_ps1 = spy
        try:
            result = build(BuildBody(profile="coding"))
        finally:
            engine._run_ps1 = original
        self.assertTrue(result["ok"])
        self.assertIn(f"CONFIGROOT={self.agent_dir}", result["output"])


class ThemeInjectionTests(SecurityTestBase):
    def test_switch_profile_rejects_traversal(self):
        from app.profiles import switch_profile

        with self.assertRaises(HTTPException) as ctx:
            switch_profile({"profile": "../../../Windows"})
        self.assertEqual(ctx.exception.status_code, 404)

    def test_switch_profile_rejects_arbitrary_dirs(self):
        from app.profiles import switch_profile

        agent_dir = Path(self.tmp.name)
        (agent_dir / "profiles" / "coding").mkdir(parents=True)
        with patch.object(agentstore, "require_agent_dir", return_value=agent_dir):
            with self.assertRaises(HTTPException) as ctx:
                switch_profile({"profile": ".."})
            self.assertEqual(ctx.exception.status_code, 404)

    def test_test_connection_rejects_non_http_scheme(self):
        from app.testing import TestBody, test as test_connection

        with self.assertRaises(HTTPException) as ctx:
            test_connection(TestBody(baseUrl="file:///etc/passwd", apiKey=""))
        self.assertEqual(ctx.exception.status_code, 400)

    def test_font_breakout_is_rejected(self):
        theme, _, problem = rules._parse_rule_file(
            "---\ntheme:\n  colors:\n    font: \"</style><script>alert(1)</script>\"\n---\n"
        )
        self.assertEqual(theme["--font"], rules.DEFAULT_THEME["--font"])
        self.assertIsNotNone(problem)

    def test_font_semicolon_breakout_is_rejected(self):
        theme, _, problem = rules._parse_rule_file(
            "---\ntheme:\n  colors:\n    font: \"sans-serif; } body{display:none}\"\n---\n"
        )
        self.assertEqual(theme["--font"], rules.DEFAULT_THEME["--font"])
        self.assertIsNotNone(problem)

    def test_build_theme_style_sanitizes_values(self):
        style = serve.build_theme_style({"--font": "x</style><script>y", "--bg": "#0d1117"})
        self.assertEqual(style.count("<"), 2)
        self.assertNotIn("<script", style)
        self.assertIn("--bg:#0d1117", style)

    def test_valid_font_stack_still_accepted(self):
        theme, _, problem = rules._parse_rule_file(
            "---\ntheme:\n  colors:\n    font: \"-apple-system, \\\"Segoe UI\\\", sans-serif\"\n---\n"
        )
        self.assertEqual(theme["--font"], '-apple-system, "Segoe UI", sans-serif')
        self.assertIsNone(problem)


class _RedirectHandler(http.server.BaseHTTPRequestHandler):
    hits = []
    auth_headers = []

    def do_GET(self):
        type(self).hits.append(self.path)
        type(self).auth_headers.append(self.headers.get("Authorization"))
        if self.path == "/v1/models":
            self.send_response(302)
            self.send_header("Location", "/steal")
            self.end_headers()
        elif self.path == "/steal":
            body = b"SECRET_DATA"
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, *args):
        pass


class ProxyRedirectTests(SecurityTestBase):
    @classmethod
    def setUpClass(cls):
        _RedirectHandler.hits = []
        _RedirectHandler.auth_headers = []
        cls.httpd = http.server.ThreadingHTTPServer(("127.0.0.1", 0), _RedirectHandler)
        cls.port = cls.httpd.server_address[1]
        cls.thread = threading.Thread(target=cls.httpd.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.httpd.shutdown()
        cls.httpd.server_close()

    def setUp(self):
        super().setUp()
        _RedirectHandler.hits = []
        _RedirectHandler.auth_headers = []
        from app import activity

        self.activity_tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.activity_tmp.cleanup)
        self.original_activity_file = activity.ACTIVITY_FILE
        activity.ACTIVITY_FILE = Path(self.activity_tmp.name) / "activity.jsonl"
        self.addCleanup(setattr, activity, "ACTIVITY_FILE", self.original_activity_file)
        agentstore.write_provider(
            self.agent_dir, "redir", "Redir", f"http://127.0.0.1:{self.port}/v1", "sk-sec-test"
        )
        settings_dir = self.agent_dir / "profiles" / "coding"
        settings_dir.mkdir(parents=True)
        (settings_dir / "settings.json").write_text(
            json.dumps({"activeProviders": ["redir"]}), encoding="utf-8"
        )

    def _proxy_request(self):
        async def receive():
            return {"type": "http.request", "body": b"", "more_body": False}

        scope = {
            "type": "http",
            "method": "GET",
            "path": "/v1/models",
            "raw_path": b"/v1/models",
            "query_string": b"",
            "headers": [(b"host", b"127.0.0.1:9090")],
            "client": ("127.0.0.1", 12345),
            "server": ("127.0.0.1", 9090),
            "scheme": "http",
            "receive": receive,
        }
        from app.proxy import proxy

        return asyncio.run(proxy("models", Request(scope, receive)))

    def test_proxy_does_not_follow_redirects(self):
        response = self._proxy_request()
        self.assertEqual(response.status_code, 302)
        self.assertNotIn(b"SECRET_DATA", response.body)
        self.assertEqual(_RedirectHandler.hits, ["/v1/models"])
        self.assertEqual(_RedirectHandler.auth_headers, ["Bearer sk-sec-test"])

    def test_proxy_rejects_injection_paths(self):
        from app.proxy import _PATH_SAFE_RE

        for bad_path in ["models@evil.com", "a b", "models?x=1", "models%0aheader"]:
            self.assertIsNone(_PATH_SAFE_RE.match(bad_path), f"path {bad_path} not blocked")
        self.assertIsNotNone(_PATH_SAFE_RE.match("models"))
        self.assertIsNotNone(_PATH_SAFE_RE.match("chat/completions"))


class _ActivityHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        body = self.rfile.read(int(self.headers.get("Content-Length", 0)))
        if self.path == "/v1/fail":
            self.send_response(429)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"error":"upstream-response-secret"}')
            return
        if b'"stream":true' in body:
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.end_headers()
            self.wfile.write(b'data: {"delta":"stream-response-secret"}\n\n')
            return
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(
            b'{"choices":[{"message":{"content":"response-private"}}],'
            b'"usage":{"prompt_tokens":4,"completion_tokens":6,"total_tokens":10}}'
        )

    def log_message(self, *args):
        pass


class ProxyActivityTests(SecurityTestBase):
    @classmethod
    def setUpClass(cls):
        cls.httpd = http.server.ThreadingHTTPServer(("127.0.0.1", 0), _ActivityHandler)
        cls.port = cls.httpd.server_address[1]
        cls.thread = threading.Thread(target=cls.httpd.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.httpd.shutdown()
        cls.httpd.server_close()

    def setUp(self):
        super().setUp()
        from app import activity

        self.activity = activity
        self.activity_tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.activity_tmp.cleanup)
        self.original_activity_file = activity.ACTIVITY_FILE
        activity.ACTIVITY_FILE = Path(self.activity_tmp.name) / "activity.jsonl"
        self.addCleanup(setattr, activity, "ACTIVITY_FILE", self.original_activity_file)
        agentstore.write_provider(
            self.agent_dir, "activity", "Activity", f"http://127.0.0.1:{self.port}/v1", "sk-sec-test"
        )
        settings_dir = self.agent_dir / "profiles" / "coding"
        settings_dir.mkdir(parents=True)
        (settings_dir / "settings.json").write_text(
            json.dumps({"activeProviders": ["activity"]}), encoding="utf-8"
        )

    def _proxy_request(self, path="chat/completions", body=b"{}"):
        async def receive():
            return {"type": "http.request", "body": body, "more_body": False}

        scope = {
            "type": "http",
            "method": "POST",
            "path": f"/v1/{path}",
            "raw_path": f"/v1/{path}".encode(),
            "query_string": b"",
            "headers": [(b"host", b"127.0.0.1:9090"), (b"content-type", b"application/json")],
            "client": ("127.0.0.1", 12345),
            "server": ("127.0.0.1", 9090),
            "scheme": "http",
            "receive": receive,
        }
        from app.proxy import proxy

        return asyncio.run(proxy(path, Request(scope, receive)))

    def test_proxy_records_usage_metadata_without_request_or_response_content(self):
        """Catches proxy telemetry that persists prompt, key, headers, or upstream response text."""
        response = self._proxy_request(
            body=b'{"model":"safe-model","messages":[{"content":"private prompt"}]}'
        )
        self.assertEqual(response.status_code, 200)
        events = self.activity.list_events(30, 1)
        self.assertTrue(events, "a successful proxy attempt must record metadata")
        event = events[0]
        self.assertEqual(event["model"], "safe-model")
        self.assertEqual(event["status"], 200)
        self.assertEqual(event["inputTokens"], 4)
        self.assertEqual(event["outputTokens"], 6)
        self.assertEqual(event["totalTokens"], 10)
        serialized = json.dumps(event)
        for forbidden in ("private prompt", "sk-sec-test", "response-private", "Authorization"):
            self.assertNotIn(forbidden, serialized)

    def test_streaming_proxy_event_has_no_fabricated_token_counts(self):
        """Catches a streaming path that buffers content or invents unavailable usage metadata."""
        response = self._proxy_request(body=b'{"model":"safe-model","stream":true}')

        async def collect():
            return b"".join([part async for part in response.body_iterator])

        self.assertIn(b"stream-response-secret", asyncio.run(collect()))
        event = self.activity.list_events(30, 1)[0]
        self.assertEqual((event["inputTokens"], event["outputTokens"], event["totalTokens"]), (None, None, None))
        self.assertNotIn("stream-response-secret", json.dumps(event))

    def test_error_attempt_is_sanitized_and_recorder_failure_keeps_proxy_usable(self):
        """Catches error-detail persistence or telemetry failure altering a proxy response."""
        error_response = self._proxy_request(path="fail", body=b'{"model":"safe-model"}')
        self.assertEqual(error_response.status_code, 429)
        error_event = self.activity.list_events(30, 1)[0]
        self.assertEqual(error_event["errorCategory"], "upstream_http_error")
        self.assertNotIn("upstream-response-secret", json.dumps(error_event))

        original_record_event = self.activity.record_event
        self.activity.record_event = lambda event: (_ for _ in ()).throw(RuntimeError("recorder unavailable"))
        self.addCleanup(setattr, self.activity, "record_event", original_record_event)
        response = self._proxy_request(body=b'{"model":"safe-model"}')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b"response-private", response.body)


if __name__ == "__main__":
    unittest.main()
