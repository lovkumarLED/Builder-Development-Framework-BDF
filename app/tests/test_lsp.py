"""Behavior tests for the LSP profile toggle (lsp.json).

Mirrors test_agentstore.py: agentstore read_lsp/write_lsp are exercised
directly against a temp agent_dir, and the router (list_lsp/set_lsp) is
exercised through the active-agent state (set_state) the same way
test_agentstore.py's current_agent tests set up state.
"""

import tempfile
import unittest
from pathlib import Path

from fastapi import HTTPException

from app import agentstore
from app.lsp import LspBody, list_lsp, set_lsp
from app.storage import set_state


class LspAgentStoreTests(unittest.TestCase):
    """read_lsp/write_lsp against a temp agent dir, no router machinery."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.agent_dir = Path(self.tmp.name)

    def test_read_defaults_when_missing(self):
        state = agentstore.read_lsp(self.agent_dir)
        self.assertEqual(state["lsp"], True)
        self.assertEqual(state["enabled"], False)

    def test_write_round_trip_bool_and_object(self):
        state = agentstore.write_lsp(self.agent_dir, True, False)
        self.assertEqual(state["lsp"], True)
        self.assertEqual(state["enabled"], False)
        state = agentstore.write_lsp(self.agent_dir, {"typescript": {"command": ["ts-server", "--stdio"]}}, True)
        self.assertEqual(state["lsp"]["typescript"]["command"][0], "ts-server")
        self.assertEqual(state["enabled"], True)

    def test_backup_created_on_write(self):
        agentstore.write_lsp(self.agent_dir, True, True)
        agentstore.write_lsp(self.agent_dir, False, False)
        backups = list((self.agent_dir / "backup").glob("lsp_*.json"))
        self.assertTrue(backups, "no backup created")
        self.assertEqual(agentstore.read_lsp(self.agent_dir)["enabled"], False)

    def test_invalid_value_rejected(self):
        with self.assertRaises(ValueError):
            agentstore.write_lsp(self.agent_dir, "nope", True)


class LspRouterTests(unittest.TestCase):
    """list_lsp/set_lsp through require_agent_dir (active-agent state)."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.agent_dir = Path(self.tmp.name) / "agent"
        (self.agent_dir / "profiles" / "coding").mkdir(parents=True)
        self._orig_state = None
        self._backup_state_file()
        from app import config
        if config.STATE_FILE.is_file():
            config.STATE_FILE.unlink()
        set_state(agent="lsp-test", dir=str(self.agent_dir))

    def _backup_state_file(self):
        from app import config
        state = config.STATE_FILE
        self._orig_state = state.read_text(encoding="utf-8") if state.is_file() else None

    def _reset_state(self):
        from app import config
        state = config.STATE_FILE
        if self._orig_state is None:
            state.unlink(missing_ok=True)
        else:
            state.write_text(self._orig_state, encoding="utf-8")

    def tearDown(self):
        self._reset_state()

    def test_read_defaults_when_missing(self):
        state = list_lsp()
        self.assertEqual(state["lsp"], True)
        self.assertEqual(state["enabled"], False)

    def test_write_round_trip(self):
        state = set_lsp(LspBody(lsp=True, enabled=False))
        self.assertEqual(state["enabled"], False)
        state = set_lsp(LspBody(lsp={"typescript": {"command": ["ts-server", "--stdio"]}}, enabled=True))
        self.assertEqual(state["lsp"]["typescript"]["command"][0], "ts-server")
        self.assertEqual(state["enabled"], True)

    def test_backup_first_preserves_previous(self):
        set_lsp(LspBody(lsp=True, enabled=True))
        set_lsp(LspBody(lsp=False, enabled=False))
        backups = list((self.agent_dir / "backup").glob("lsp_*.json"))
        self.assertTrue(backups, "no backup created")
        self.assertEqual(agentstore.read_lsp(self.agent_dir)["enabled"], False)

    def test_invalid_value_rejected(self):
        with self.assertRaises(HTTPException) as ctx:
            set_lsp(LspBody(lsp="nope", enabled=True))
        self.assertEqual(ctx.exception.status_code, 400)


if __name__ == "__main__":
    unittest.main()
