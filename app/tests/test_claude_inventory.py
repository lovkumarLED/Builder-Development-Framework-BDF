import json
import tempfile
import unittest
from pathlib import Path

from app import claude_inventory


def write_state(root, payload):
    path = claude_inventory.state_path(root)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload), encoding="utf-8")
    return path


class ClaudeInventoryBase(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="bdf-inventory-"))
        self.root = self.tmp / "profile"
        self.root.mkdir(parents=True)

    def tearDown(self):
        import shutil
        shutil.rmtree(self.tmp, ignore_errors=True)


class UserScopeMcpTests(ClaudeInventoryBase):
    def test_user_scope_mcps_counted_with_types(self):
        write_state(self.root, {
            "mcpServers": {
                "filesystem": {"command": "npx", "args": ["-y", "server-fs"]},
                "github": {"type": "http", "url": "https://api.githubcopilot.com/mcp/"},
                "legacy": {"type": "sse", "url": "https://example.test/sse"},
                "sdk-ish": {"type": "sdk"},
            }
        })
        result = claude_inventory.scan_inventory(self.root)
        self.assertTrue(result["statePresent"])
        self.assertFalse(result["stateParseError"])
        self.assertEqual(len(result["mcps"]), 4)
        by_name = {m["name"]: m for m in result["mcps"]}
        self.assertEqual(by_name["filesystem"]["type"], "stdio")
        self.assertEqual(by_name["filesystem"]["scope"], "user")
        self.assertIsNone(by_name["filesystem"]["project"])
        self.assertEqual(by_name["github"]["type"], "http")
        self.assertEqual(by_name["legacy"]["type"], "sse")
        self.assertEqual(by_name["sdk-ish"]["type"], "sdk")

    def test_type_inference_url_and_command(self):
        write_state(self.root, {
            "mcpServers": {
                "remote": {"url": "https://example.test/mcp"},
                "local": {"command": "uvx", "args": ["server"]},
                "bare": {},
            }
        })
        result = claude_inventory.scan_inventory(self.root)
        by_name = {m["name"]: m for m in result["mcps"]}
        self.assertEqual(by_name["remote"]["type"], "http")
        self.assertEqual(by_name["local"]["type"], "stdio")
        self.assertEqual(by_name["bare"]["type"], "unknown")

    def test_unknown_explicit_types_map_to_unknown(self):
        write_state(self.root, {"mcpServers": {"odd": {"type": "telepathy"}}})
        result = claude_inventory.scan_inventory(self.root)
        self.assertEqual(result["mcps"][0]["type"], "unknown")


class ProjectScopeMcpTests(ClaudeInventoryBase):
    def test_project_mcps_grouped_and_labeled(self):
        write_state(self.root, {
            "projects": {
                "C:\\Users\\you\\my-app": {"mcpServers": {"db": {"command": "npx", "args": ["dbhub"]}}},
                "C:\\Users\\you\\other-app": {"mcpServers": {"search": {"type": "http", "url": "https://search.test/mcp"}}},
            }
        })
        result = claude_inventory.scan_inventory(self.root)
        self.assertEqual(result["projectCount"], 2)
        by_name = {m["name"]: m for m in result["mcps"]}
        self.assertEqual(by_name["db"]["scope"], "project")
        self.assertEqual(by_name["db"]["project"], "my-app")
        self.assertEqual(by_name["db"]["type"], "stdio")
        self.assertEqual(by_name["search"]["project"], "other-app")
        self.assertEqual(by_name["search"]["type"], "http")

    def test_user_scope_wins_over_project_same_name(self):
        write_state(self.root, {
            "mcpServers": {"db": {"command": "npx", "args": ["user-db"]}},
            "projects": {"C:\\Users\\you\\app": {"mcpServers": {"db": {"type": "http", "url": "https://project.test/mcp"}}}},
        })
        result = claude_inventory.scan_inventory(self.root)
        self.assertEqual(len(result["mcps"]), 1)
        self.assertEqual(result["mcps"][0]["scope"], "user")
        self.assertEqual(result["mcps"][0]["type"], "stdio")

    def test_projects_without_mcp_servers_do_not_count(self):
        write_state(self.root, {"projects": {"C:\\Users\\you\\plain": {"some": "state"}}})
        result = claude_inventory.scan_inventory(self.root)
        self.assertEqual(result["projectCount"], 0)
        self.assertEqual(result["mcps"], [])

    def test_posix_and_rooted_project_keys(self):
        write_state(self.root, {
            "projects": {
                "/home/you/proj": {"mcpServers": {"a": {"command": "npx"}}},
                "": {"mcpServers": {"b": {"command": "npx"}}},
            }
        })
        result = claude_inventory.scan_inventory(self.root)
        by_name = {m["name"]: m for m in result["mcps"]}
        self.assertEqual(by_name["a"]["project"], "proj")
        self.assertEqual(by_name["b"]["project"], "unknown project")


class PluginTests(ClaudeInventoryBase):
    def test_plugins_array_names(self):
        write_state(self.root, {"plugins": ["cli@3.1.0@slackbrad/claude-code-slack", "skills@1.0.0@acme/skills"]})
        result = claude_inventory.scan_inventory(self.root)
        self.assertEqual(result["plugins"], ["cli@3.1.0@slackbrad/claude-code-slack", "skills@1.0.0@acme/skills"])

    def test_plugins_array_dedupes_and_sorts(self):
        write_state(self.root, {"plugins": ["b", "a", "b"]})
        result = claude_inventory.scan_inventory(self.root)
        self.assertEqual(result["plugins"], ["a", "b"])

    def test_enabled_plugins_fallback(self):
        write_state(self.root, {"enabledPlugins": {"skills@market": True, "off@market": False}})
        result = claude_inventory.scan_inventory(self.root)
        self.assertEqual(result["plugins"], ["skills@market"])

    def test_no_plugin_keys_yields_empty(self):
        write_state(self.root, {"mcpServers": {}})
        result = claude_inventory.scan_inventory(self.root)
        self.assertEqual(result["plugins"], [])

    def test_managed_settings_enabled_plugins_merged(self):
        write_state(self.root, {"plugins": ["a@market"]})
        settings = self.root / ".claude" / "settings.json"
        settings.parent.mkdir(parents=True, exist_ok=True)
        settings.write_text(json.dumps({
            "model": "kept",
            "enabledPlugins": {"b@market": True, "off@market": False, "a@market": True},
        }), encoding="utf-8")
        result = claude_inventory.scan_inventory(self.root)
        self.assertEqual(result["plugins"], ["a@market", "b@market"])

    def test_malformed_managed_settings_do_not_break_plugins(self):
        write_state(self.root, {"plugins": ["a@market"]})
        settings = self.root / ".claude" / "settings.json"
        settings.parent.mkdir(parents=True, exist_ok=True)
        settings.write_text("{broken", encoding="utf-8")
        result = claude_inventory.scan_inventory(self.root)
        self.assertEqual(result["plugins"], ["a@market"])


class RedactionTests(ClaudeInventoryBase):
    def test_secret_fields_never_returned(self):
        write_state(self.root, {
            "mcpServers": {
                "server-one": {
                    "command": "npx",
                    "args": ["-y", "server"],
                    "env": {"API_KEY": "sk-super-secret-value"},
                    "headers": {"Authorization": "Bearer token-value"},
                    "url": "https://secret.test/mcp",
                }
            }
        })
        result = claude_inventory.scan_inventory(self.root)
        self.assertEqual(len(result["mcps"]), 1)
        self.assertEqual(sorted(result["mcps"][0].keys()), ["name", "project", "scope", "type"])
        text = json.dumps(result)
        self.assertNotIn("sk-super", text)
        self.assertNotIn("token-value", text)
        self.assertNotIn("https://secret.test", text)
        self.assertNotIn("Authorization", text)
        self.assertNotIn("API_KEY", text)


class StateFileErrorTests(ClaudeInventoryBase):
    def test_missing_file_yields_zero_inventory(self):
        result = claude_inventory.scan_inventory(self.root)
        self.assertFalse(result["statePresent"])
        self.assertFalse(result["stateParseError"])
        self.assertEqual(result["mcps"], [])
        self.assertEqual(result["plugins"], [])
        self.assertEqual(result["projectCount"], 0)

    def test_malformed_json_flags_parse_error(self):
        path = write_state(self.root, {})
        path.write_text("{not json", encoding="utf-8")
        result = claude_inventory.scan_inventory(self.root)
        self.assertTrue(result["statePresent"])
        self.assertTrue(result["stateParseError"])
        self.assertEqual(result["mcps"], [])

    def test_duplicate_keys_flags_parse_error(self):
        path = claude_inventory.state_path(self.root)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('{"mcpServers": {"a": {"command": "npx"}}, "mcpServers": {"b": {"command": "npx"}}}', encoding="utf-8")
        result = claude_inventory.scan_inventory(self.root)
        self.assertTrue(result["stateParseError"])
        self.assertEqual(result["mcps"], [])

    def test_non_object_root_flags_parse_error(self):
        path = write_state(self.root, {})
        path.write_text("[1, 2, 3]", encoding="utf-8")
        result = claude_inventory.scan_inventory(self.root)
        self.assertTrue(result["stateParseError"])

    def test_scan_never_writes_the_state_file(self):
        payload = {"mcpServers": {"a": {"command": "npx"}}}
        path = write_state(self.root, payload)
        before = path.read_bytes()
        claude_inventory.scan_inventory(self.root)
        self.assertEqual(path.read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
