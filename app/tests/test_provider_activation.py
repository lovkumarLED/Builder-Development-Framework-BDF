import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from fastapi import HTTPException

from app import agentstore, providers


class ProviderActivationTests(unittest.TestCase):
    def test_create_provider_can_remain_inactive(self):
        with tempfile.TemporaryDirectory() as folder, patch.object(agentstore, "require_agent_dir", return_value=Path(folder)):
            result = providers.create_provider(providers.ProviderBody(name="Review", baseUrl="https://example.test/v1", activate=False))
            self.assertFalse(result["active"])
            self.assertEqual(agentstore.get_active_providers(Path(folder)), [])

    def test_activate_then_deactivate_toggles_settings_list(self):
        with tempfile.TemporaryDirectory() as folder, patch.object(agentstore, "require_agent_dir", return_value=Path(folder)):
            agentstore.write_provider(Path(folder), "alpha", "Alpha", "https://example.test/v1", "k")
            agentstore.write_provider(Path(folder), "beta", "Beta", "https://example.test/v1", "k")
            self.assertEqual(providers.activate("alpha")["active"], True)
            self.assertEqual(agentstore.get_active_providers(Path(folder)), ["alpha"])
            self.assertEqual(providers.activate("beta")["active"], True)
            self.assertEqual(agentstore.get_active_providers(Path(folder)), ["beta", "alpha"])
            self.assertEqual(providers.deactivate("alpha")["active"], False)
            self.assertEqual(agentstore.get_active_providers(Path(folder)), ["beta"])
            self.assertEqual(providers.deactivate("beta")["active"], False)
            self.assertEqual(agentstore.get_active_providers(Path(folder)), [])

    def test_activate_missing_provider_raises(self):
        with tempfile.TemporaryDirectory() as folder, patch.object(agentstore, "require_agent_dir", return_value=Path(folder)):
            with self.assertRaises(HTTPException):
                providers.activate("nope")
            with self.assertRaises(HTTPException):
                providers.deactivate("nope")
