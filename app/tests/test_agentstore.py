import json
import tempfile
import unittest
from pathlib import Path

from app import agentstore


class AgentStoreTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.agent_dir = Path(self.tmp.name)

    def test_slugify(self):
        self.assertEqual(agentstore.slugify("OmniRoute"), "omniroute")
        self.assertEqual(agentstore.slugify("LiteLLM X"), "litellm-x")
        self.assertEqual(agentstore.slugify("  Hello, World!  "), "hello-world")
        self.assertEqual(agentstore.slugify("!!!"), "")

    def test_create_and_read_provider(self):
        provider = agentstore.write_provider(self.agent_dir, "smoke", "Smoke", "http://localhost:20128/v1", "sk-test")
        self.assertEqual(provider["id"], "smoke")
        self.assertEqual(provider["name"], "Smoke")
        self.assertEqual(provider["baseUrl"], "http://localhost:20128/v1")
        self.assertEqual(provider["apiKey"], "sk-test")
        read = agentstore.read_provider(self.agent_dir, "smoke")
        self.assertEqual(read["baseUrl"], "http://localhost:20128/v1")
        self.assertTrue((self.agent_dir / "providers" / "smoke.json").is_file())

    def test_update_creates_backup(self):
        agentstore.write_provider(self.agent_dir, "smoke", "Smoke", "http://a/v1", "k1")
        agentstore.write_provider(self.agent_dir, "smoke", "Smoke", "http://b/v1", "k2")
        backups = list((self.agent_dir / "backup").glob("smoke_*.json"))
        self.assertEqual(len(backups), 1)
        provider = agentstore.read_provider(self.agent_dir, "smoke")
        self.assertEqual(provider["baseUrl"], "http://b/v1")
        self.assertEqual(provider["apiKey"], "k2")

    def test_delete_removes_file_with_backup(self):
        agentstore.write_provider(self.agent_dir, "smoke", "Smoke", "http://a/v1", "k")
        agentstore.delete_provider(self.agent_dir, "smoke")
        self.assertIsNone(agentstore.read_provider(self.agent_dir, "smoke"))
        self.assertEqual(len(list((self.agent_dir / "backup").glob("smoke_*.json"))), 1)

    def test_settings_merge_preserves_user_keys(self):
        settings_dir = self.agent_dir / "profiles" / "coding"
        settings_dir.mkdir(parents=True)
        (settings_dir / "settings.json").write_text(
            json.dumps({"$schema": "s", "activeProviders": ["omniroute"], "instructions": ["AGENTS.md"]}),
            encoding="utf-8",
        )
        agentstore.set_active_providers(self.agent_dir, ["smoke"])
        data = json.loads((settings_dir / "settings.json").read_text(encoding="utf-8"))
        self.assertEqual(data["activeProviders"], ["smoke"])
        self.assertEqual(data["instructions"], ["AGENTS.md"])
        self.assertEqual(data["$schema"], "s")

    def test_active_provider_returns_first_active_with_file(self):
        agentstore.write_provider(self.agent_dir, "smoke", "Smoke", "http://a/v1", "k")
        self.assertIsNone(agentstore.active_provider(self.agent_dir))
        settings_dir = self.agent_dir / "profiles" / "coding"
        settings_dir.mkdir(parents=True)
        (settings_dir / "settings.json").write_text(json.dumps({"activeProviders": ["smoke"]}), encoding="utf-8")
        self.assertEqual(agentstore.active_provider(self.agent_dir)["id"], "smoke")

    def test_write_preserves_unknown_file_content(self):
        providers_dir = self.agent_dir / "providers"
        providers_dir.mkdir(parents=True)
        (providers_dir / "omniroute.json").write_text(
            json.dumps({"id": "omniroute", "provider": {"omniroute": {"name": "OmniRoute", "apiKey": "{env:X}", "options": {"baseURL": "http://a/v1"}}}}),
            encoding="utf-8",
        )
        agentstore.write_provider(self.agent_dir, "omniroute", "OmniRoute", "http://b/v1", "{env:X}")
        data = json.loads((providers_dir / "omniroute.json").read_text(encoding="utf-8"))
        inner = data["provider"]["omniroute"]
        self.assertEqual(inner["options"]["baseURL"], "http://b/v1")
        self.assertEqual(inner["apiKey"], "{env:X}")

    def test_models_roundtrip(self):
        agentstore.write_models(self.agent_dir, "smoke", [
            {"model": "opencode-zen/deepseek-v4-flash-free", "name": "DeepSeek V4 Flash", "thinking": ["high", "max"]},
            {"model": "zen/mimo", "name": "MiMo", "thinking": ["minimal"]},
        ])
        models = agentstore.read_models(self.agent_dir, "smoke")
        self.assertEqual(len(models), 2)
        self.assertEqual(models[0]["model"], "opencode-zen/deepseek-v4-flash-free")
        self.assertEqual(models[0]["thinking"], ["high", "max"])
        data = json.loads((self.agent_dir / "profiles" / "coding" / "smoke-models.json").read_text(encoding="utf-8"))
        self.assertEqual(data["models"]["zen/mimo"]["variants"]["minimal"], {"reasoningEffort": "minimal"})

    def test_models_update_replaces_and_backs_up(self):
        agentstore.write_models(self.agent_dir, "smoke", [{"model": "a", "name": "A", "thinking": ["high"]}])
        agentstore.write_models(self.agent_dir, "smoke", [{"model": "b", "name": "B", "thinking": ["max"]}])
        models = agentstore.read_models(self.agent_dir, "smoke")
        self.assertEqual([m["model"] for m in models], ["b"])
        self.assertEqual(len(list((self.agent_dir / "backup").glob("smoke-models_*.json"))), 1)

    def test_models_delete_backs_up_and_removes(self):
        agentstore.write_models(self.agent_dir, "smoke", [{"model": "a", "name": "A", "thinking": ["high"]}])
        agentstore.delete_models(self.agent_dir, "smoke")
        self.assertEqual(agentstore.read_models(self.agent_dir, "smoke"), [])
        self.assertFalse((self.agent_dir / "profiles" / "coding" / "smoke-models.json").exists())
        self.assertEqual(len(list((self.agent_dir / "backup").glob("smoke-models_*.json"))), 1)

    def test_activate_moves_to_front_keeping_others(self):
        settings_dir = self.agent_dir / "profiles" / "coding"
        settings_dir.mkdir(parents=True)
        (settings_dir / "settings.json").write_text(
            json.dumps({"activeProviders": ["omniroute", "tokenrouter", "smoke"]}),
            encoding="utf-8",
        )
        agentstore.activate_provider(self.agent_dir, "smoke")
        self.assertEqual(agentstore.get_active_providers(self.agent_dir), ["smoke", "omniroute", "tokenrouter"])
        agentstore.activate_provider(self.agent_dir, "omniroute")
        self.assertEqual(agentstore.get_active_providers(self.agent_dir), ["omniroute", "smoke", "tokenrouter"])

    def test_plugins_roundtrip_and_backup(self):
        self.assertEqual(agentstore.read_plugins(self.agent_dir), [])
        agentstore.write_plugins(self.agent_dir, ["superpowers@git+https://github.com/obra/superpowers.git", "another"])
        self.assertEqual(agentstore.read_plugins(self.agent_dir), ["superpowers@git+https://github.com/obra/superpowers.git", "another"])
        data = json.loads((self.agent_dir / "profiles" / "coding" / "plugins.json").read_text(encoding="utf-8"))
        self.assertEqual(data["plugin"], ["superpowers@git+https://github.com/obra/superpowers.git", "another"])
        agentstore.write_plugins(self.agent_dir, ["another"])
        self.assertEqual(agentstore.read_plugins(self.agent_dir), ["another"])
        self.assertEqual(len(list((self.agent_dir / "backup").glob("plugins_*.json"))), 1)
