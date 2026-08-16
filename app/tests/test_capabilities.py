import unittest
from unittest.mock import patch

from app import capabilities


class CapabilityMatrixTests(unittest.TestCase):
    def test_opencode_and_kilo_match_design_matrix(self):
        expected = {
            "providerMode": "multi-provider",
            "savedRoutes": False,
            "providerCreation": True,
            "providerActivation": True,
            "pluginsManaged": True,
            "mcpManaged": True,
            "integrationsVisible": True,
            "reasoningFormats": True,
            "sdkSelection": True,
            "profilesMode": "bdf-profiles",
            "requestAnalytics": True,
            "routingActivity": False,
            "builderAvailable": True,
        }
        self.assertEqual(capabilities.CAPABILITIES["opencode"], expected)
        self.assertEqual(capabilities.CAPABILITIES["kilo"], expected)

    def test_claude_code_matches_design_matrix(self):
        expected = {
            "providerMode": "scalar-route",
            "savedRoutes": True,
            "providerCreation": False,
            "providerActivation": False,
            "pluginsManaged": False,
            "mcpManaged": False,
            "integrationsVisible": False,
            "reasoningFormats": False,
            "sdkSelection": False,
            "profilesMode": "routing-profiles",
            "requestAnalytics": False,
            "routingActivity": True,
            "builderAvailable": False,
        }
        self.assertEqual(capabilities.CAPABILITIES["claude-code"], expected)

    def test_capabilities_endpoint_returns_active_agent_shape(self):
        with patch.object(capabilities.agentstore, "active_agent_name", return_value="kilo"):
            result = capabilities.capabilities()
        self.assertEqual(result["agent"], "kilo")
        self.assertEqual(result["canonicalType"], "kilo")
        self.assertEqual(result["displayName"], "Kilo")
        self.assertEqual(result["capabilities"]["providerMode"], "multi-provider")

    def test_canonical_agent_type_mapping(self):
        cases = {
            "opencode": "opencode",
            "kilo": "kilo",
            "kilocode": "kilo",
            "claudecode": "claude-code",
            "claude-code": "claude-code",
        }
        for raw, expected in cases.items():
            self.assertEqual(capabilities.canonical_agent_type(raw), expected)

    def test_canonical_mapping_is_case_and_space_tolerant(self):
        self.assertEqual(capabilities.canonical_agent_type("  ClaudeCode "), "claude-code")
        self.assertEqual(capabilities.canonical_agent_type("KILO"), "kilo")

    def test_legacy_claudecode_entry_resolves_claude_capabilities(self):
        with patch.object(capabilities.agentstore, "active_agent_name", return_value="claudecode"):
            result = capabilities.capabilities()
        self.assertEqual(result["canonicalType"], "claude-code")
        self.assertEqual(result["displayName"], "Claude Code")
        self.assertEqual(result["capabilities"]["providerMode"], "scalar-route")
        self.assertEqual(result["capabilities"]["builderAvailable"], False)

    def test_unknown_agent_returns_null_capabilities(self):
        with patch.object(capabilities.agentstore, "active_agent_name", return_value="mystery-agent"):
            result = capabilities.capabilities()
        self.assertIsNone(result["canonicalType"])
        self.assertIsNone(result["capabilities"])

    def test_capability_response_contains_no_protected_values(self):
        with patch.object(capabilities.agentstore, "active_agent_name", return_value="claude-code"):
            result = capabilities.capabilities()
        text = repr(result)
        self.assertNotIn(("." + "claude" + ".json"), text)
        self.assertNotIn("\\Users\\", text)
        self.assertNotIn("sk-", text)
        self.assertNotIn("Bearer", text)


if __name__ == "__main__":
    unittest.main()
