"""Unit tests for the DPAPI credential store (claude_credentials.py).

DPAPI (CryptProtectData/CryptUnprotectData) and the store file location are
patched, so no real encryption runs and the real app state is never touched.
The _dpapi_protect/_dpapi_unprotect stubs apply a trivial reversible marker so
resolve() round-trips are still exercised end-to-end.
"""

import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from app import claude_credentials


class CredentialStoreBase(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="bdf-credstore-"))
        self.store_file = self.tmp / "claude-credentials.bin"
        patchers = [
            patch.object(claude_credentials, "CREDENTIALS_FILE", self.store_file),
            patch.object(claude_credentials, "_dpapi_protect", lambda data: b"ENC:" + data),
            patch.object(claude_credentials, "_dpapi_unprotect",
                         lambda data: data[4:] if data.startswith(b"ENC:") else (_ for _ in ()).throw(OSError("bad"))),
        ]
        for p in patchers:
            p.start()
            self.addCleanup(p.stop)

    def tearDown(self):
        import shutil
        shutil.rmtree(self.tmp, ignore_errors=True)


class StoreRoundTripTests(CredentialStoreBase):
    def test_store_resolve_round_trip(self):
        claude_credentials.store("REF_A", "sk-value-a")
        self.assertEqual(claude_credentials.resolve("REF_A"), "sk-value-a")

    def test_store_replaces_existing_entry(self):
        claude_credentials.store("REF_A", "first")
        claude_credentials.store("REF_A", "second")
        self.assertEqual(claude_credentials.resolve("REF_A"), "second")

    def test_multiple_entries_isolated(self):
        claude_credentials.store("REF_A", "a")
        claude_credentials.store("REF_B", "b")
        self.assertEqual(claude_credentials.resolve("REF_A"), "a")
        self.assertEqual(claude_credentials.resolve("REF_B"), "b")
        self.assertEqual(claude_credentials.list_names(), ["REF_A", "REF_B"])

    def test_missing_resolves_none(self):
        self.assertIsNone(claude_credentials.resolve("NOPE"))
        self.assertFalse(claude_credentials.has("NOPE"))

    def test_delete_removes_entry(self):
        claude_credentials.store("REF_A", "a")
        claude_credentials.delete("REF_A")
        self.assertFalse(claude_credentials.has("REF_A"))
        self.assertIsNone(claude_credentials.resolve("REF_A"))
        claude_credentials.delete("REF_A")

    def test_empty_name_ignored(self):
        claude_credentials.store("", "x")
        self.assertFalse(claude_credentials.has(""))
        claude_credentials.delete("")
        self.assertIsNone(claude_credentials.resolve(""))


class StorePersistenceTests(CredentialStoreBase):
    def test_stored_bytes_are_not_plaintext(self):
        claude_credentials.store("REF_A", "sk-secret-plaintext")
        raw = self.store_file.read_bytes()
        self.assertNotIn(b"sk-secret-plaintext", raw)
        self.assertIn(b"REF_A", raw)

    def test_file_missing_reads_empty(self):
        self.assertEqual(claude_credentials.list_names(), [])
        self.assertIsNone(claude_credentials.resolve("X"))

    def test_malformed_json_reads_empty(self):
        self.store_file.write_text("{ not json", encoding="utf-8")
        self.assertEqual(claude_credentials.list_names(), [])
        self.assertIsNone(claude_credentials.resolve("X"))

    def test_wrong_version_reads_empty(self):
        self.store_file.write_text(json.dumps({"version": 99, "entries": {"A": "b"}}), encoding="utf-8")
        self.assertFalse(claude_credentials.has("A"))

    def test_corrupted_ciphertext_resolves_none(self):
        claude_credentials.store("REF_A", "a")
        claude_credentials.store("REF_B", "b")
        doc = json.loads(self.store_file.read_text(encoding="utf-8"))
        doc["entries"]["REF_A"] = "NOT_BASE64!!"
        self.store_file.write_text(json.dumps(doc), encoding="utf-8")
        self.assertIsNone(claude_credentials.resolve("REF_A"))
        self.assertEqual(claude_credentials.resolve("REF_B"), "b")

    def test_atomic_write_no_tmp_left(self):
        claude_credentials.store("REF_A", "a")
        leftovers = list(self.tmp.glob("*.tmp"))
        self.assertEqual(leftovers, [])


if __name__ == "__main__":
    unittest.main()
