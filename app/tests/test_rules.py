import unittest

from app import rules


class RuleParsingTests(unittest.TestCase):
    def test_valid_front_matter(self):
        text = (
            "---\n"
            "theme:\n"
            "  colors:\n"
            "    bg: \"#112233\"\n"
            "    accent: \"#ff00ff\"\n"
            "  radius: \"16px\"\n"
            "---\n"
            "\n"
            "# Rulebook\n"
            "body text\n"
        )
        theme, body, problem = rules._parse_rule_file(text)
        self.assertEqual(theme["--bg"], "#112233")
        self.assertEqual(theme["--accent"], "#ff00ff")
        self.assertEqual(theme["--radius"], "16px")
        self.assertEqual(theme["--green"], rules.DEFAULT_THEME["--green"])
        self.assertEqual(body, "# Rulebook\nbody text")
        self.assertIsNone(problem)

    def test_invalid_color_keeps_default(self):
        theme, _, problem = rules._parse_rule_file(
            "---\ntheme:\n  colors:\n    bg: \"notacolor\"\n---\n"
        )
        self.assertEqual(theme["--bg"], rules.DEFAULT_THEME["--bg"])
        self.assertIsNotNone(problem)

    def test_unknown_key_ignored(self):
        theme, _, _ = rules._parse_rule_file(
            "---\ntheme:\n  colors:\n    hotpink: \"#ff0000\"\n---\n"
        )
        self.assertEqual(theme, rules.DEFAULT_THEME)

    def test_no_front_matter(self):
        _, _, problem = rules._parse_rule_file("# no front matter\n")
        self.assertIsNotNone(problem)

    def test_unclosed_front_matter(self):
        _, _, problem = rules._parse_rule_file("---\ntheme:\n")
        self.assertIsNotNone(problem)

    def test_font_quotes_unescaped(self):
        theme, _, _ = rules._parse_rule_file(
            "---\ntheme:\n  colors:\n    font: \"-apple-system, \\\"Segoe UI\\\", sans-serif\"\n---\n"
        )
        self.assertEqual(theme["--font"], '-apple-system, "Segoe UI", sans-serif')


class CacheAndFallbackTests(unittest.TestCase):
    def test_missing_file_uses_defaults_and_problem(self):
        original = rules.RULE_FILE
        try:
            rules.RULE_FILE = rules.RULE_FILE.with_name("rule.does-not-exist.md")
            rules._cache = {"mtime": None, "theme": None, "rulebook": None, "problem": None}
            self.assertEqual(rules.get_theme(), rules.DEFAULT_THEME)
            self.assertEqual(rules.get_rulebook(), "")
            self.assertIsNotNone(rules.theme_problem())
        finally:
            rules.RULE_FILE = original
            rules._cache = {"mtime": None, "theme": None, "rulebook": None, "problem": None}

    def test_bom_prefixed_file_parses(self):
        original = rules.RULE_FILE
        tmp = rules.RULE_FILE.parent / "_bom_tmp.md"
        try:
            tmp.write_text("\ufeff---\ntheme:\n  colors:\n    accent: \"#123456\"\n---\nbody\n", encoding="utf-8")
            rules.RULE_FILE = tmp
            rules._cache = {"mtime": None, "theme": None, "rulebook": None, "problem": None}
            self.assertEqual(rules.get_theme()["--accent"], "#123456")
            self.assertIsNone(rules.theme_problem())
        finally:
            tmp.unlink(missing_ok=True)
            rules.RULE_FILE = original
            rules._cache = {"mtime": None, "theme": None, "rulebook": None, "problem": None}
