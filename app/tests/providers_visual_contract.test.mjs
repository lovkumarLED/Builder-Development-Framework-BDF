import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { switchProviderAgent } from "../assets/js/pages/providers.js";

const providersSource = await readFile(new URL("../assets/js/pages/providers.js", import.meta.url), "utf8");
const workspaceSource = await readFile(new URL("../assets/js/pages/provider-workspace.js", import.meta.url), "utf8");
const source = `${providersSource}\n${workspaceSource}`;

test("providers page uses the approved split workspace", () => {
  assert.match(source, /providers-workspace/);
  assert.match(source, /provider-setup-panel/);
  assert.match(source, /provider-agent-selector/);
  assert.match(source, /Manage agents/);
});

test("provider setup panel exposes the approved three-step flow", () => {
  assert.match(source, /Choose/);
  assert.match(source, /Configure/);
  assert.match(source, /Test/);
  assert.match(source, /Save provider/);
});

test("provider setup exposes its provider-level reasoning format chooser", () => {
  assert.match(workspaceSource, /Model reasoning format/);
  assert.match(workspaceSource, /embeddedFormatChoices/);
});

test("provider cards use branded marks and a circular deck", () => {
  assert.match(source, /provider-brand-mark/);
  assert.match(source, /provider-deck-card--front/);
  assert.match(source, /circularProviderIndex/);
});

test("provider agent tabs switch between the two currently supported agents", () => {
  assert.match(workspaceSource, /data-provider-agent="opencode"/);
  assert.match(workspaceSource, /data-provider-agent="kilo"/);
  assert.doesNotMatch(workspaceSource, /ClaudeCode/);
  assert.doesNotMatch(workspaceSource, /data-add-agent/);
  assert.match(providersSource, /switchProviderAgent\(api,/);
  assert.match(providersSource, /renderProviders\(workspace\)/);
});

test("connected agent indicator is status text without a decorative dropdown arrow", () => {
  assert.match(workspaceSource, /provider-agent-selector/);
  assert.doesNotMatch(workspaceSource, /connected\s*<span>/);
});

test("provider cards separate deactivation from destructive removal", () => {
  assert.match(workspaceSource, /data-provider-action="deactivate">Deactivate provider/);
  assert.match(workspaceSource, /data-provider-action="remove">Remove provider/);
  assert.match(providersSource, /action === "remove"/);
  assert.match(providersSource, /api\.deleteProvider\(provider\.id\)/);
});

test("agent switching avoids redundant writes and calls the backend for a different agent", async () => {
  const calls = [];
  const apiClient = { switchAgent: async name => calls.push(name) };
  assert.equal(await switchProviderAgent(apiClient, "kilo", "kilo"), false);
  assert.equal(await switchProviderAgent(apiClient, "opencode", "kilo"), true);
  assert.deepEqual(calls, ["opencode"]);
});
