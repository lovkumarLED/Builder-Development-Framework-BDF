import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const page = fs.readFileSync(new URL("../assets/js/pages/integrations.js", import.meta.url), "utf8");
const view = fs.readFileSync(new URL("../assets/js/pages/integration-workspace.js", import.meta.url), "utf8");
const css = fs.readFileSync(new URL("../assets/css/integration-workspace.css", import.meta.url), "utf8");
const shell = fs.readFileSync(new URL("../gui.html", import.meta.url), "utf8");

test("integrations uses the approved reference composition", () => {
  assert.match(page, /integration-workspace\.js/);
  for (const text of [
    "Managing:", "Changes are backed up", "Plugins", "Add plugin",
    "MCP servers", "Add MCP server", "AI provider connection",
    "Use Switcher with another tool", "Build required", "Build my config",
  ]) assert.match(view, new RegExp(text));
  assert.match(view, /integration-workspace/);
  assert.match(css, /grid-template-columns:\s*minmax\(0,\s*1\.58fr\)\s+minmax\(300px,\s*\.9fr\)/);
  assert.match(css, /@media\s*\(max-width:\s*980px\)/);
  assert.match(shell, /integration-workspace\.css/);
});

test("integrations keeps real actions wired", () => {
  for (const action of ["addPlugin", "addMcp", "testPrimary", "copyEndpoint", "buildConfig"])
    assert.match(view, new RegExp(`id=["']${action}["']`));
  assert.match(page, /api\.testProvider/);
  assert.match(page, /api\.build/);
  assert.match(page, /navigator\.clipboard\.writeText/);
});

test("active provider connections scroll without visible scrollbar chrome", () => {
  assert.match(css, /\.integration-provider-list\s*\{[^}]*overflow-y:\s*auto[^}]*scrollbar-width:\s*none/is);
  assert.match(css, /\.integration-provider-list::-webkit-scrollbar\s*\{[^}]*display:\s*none/is);
});
