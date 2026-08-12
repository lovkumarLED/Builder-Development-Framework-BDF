import unittest

from app import serve
from app.serve import build_theme_style, inject_before_head


class ThemeInjectionTests(unittest.TestCase):
    def test_build_theme_style_contains_variables(self):
        style = build_theme_style({"--bg": "#0d1117", "--accent": "#6366f1"})
        self.assertIn("--bg:#0d1117", style)
        self.assertIn("--accent:#6366f1", style)
        self.assertTrue(style.startswith("<style>:root{"))

    def test_inject_before_head_places_style_inside_head(self):
        html = "<html><head><title>t</title></head><body>x</body></html>"
        result = inject_before_head(html, "<style></style>")
        self.assertEqual(result, "<html><head><title>t</title><style></style></head><body>x</body></html>")

    def test_no_head_returns_unchanged(self):
        html = "<html><body>x</body></html>"
        self.assertEqual(inject_before_head(html, "<style></style>"), html)

    def test_index_serves_accessible_modular_hybrid_shell(self):
        """Catches removal of primary navigation or return to an inline monolith."""
        response = serve.index()
        html = response.body.decode("utf-8")
        self.assertIn('id="startupMark"', html)
        self.assertIn('aria-label="Primary"', html)
        for destination in ("overview", "providers", "activity", "integrations", "settings"):
            self.assertIn(f'data-route="{destination}"', html)
        self.assertIn('<script type="module" src="/assets/js/main.js', html)
        self.assertNotIn("logo.png", html)
