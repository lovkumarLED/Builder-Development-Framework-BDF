import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { isApplied, hasPendingChanges, claudeRoutesMarkup, PRESERVATION_NOTICE, RESTART_NOTICE, ENV_REF_HELP, COMPAT_CONFIRM_TEXT, recommendClaudeCompatibility } from "../assets/js/pages/claude-routes.js";
import { renderProviderWorkspace } from "../assets/js/pages/provider-workspace.js";
import { store } from "../assets/js/core/store.js";

const routesSource = await readFile(new URL("../assets/js/pages/claude-routes.js", import.meta.url), "utf8");
const workspaceSource = await readFile(new URL("../assets/js/pages/provider-workspace.js", import.meta.url), "utf8");

const route = {
  id: "route-1", name: "Main", baseUrl: "https://api.example.test/v1", authKind: "apiKey",
  secretEnvRef: "BDF_GATE4A_API_KEY_REF", model: "sonnet", gatewayDiscovery: true,
  disableExperimentalBetas: true, autoCompactWindow: 190000, disableNonessentialTraffic: false,
  configSha256: "a".repeat(64),
};

const storeData = { routes: [route], appliedRouteId: "route-1", appliedRouteConfigSha256: "a".repeat(64) };

test("applied state compares the backend configSha256 field, never a client array", () => {
  assert.equal(isApplied(route, storeData), true);
  assert.equal(hasPendingChanges(route, storeData), false);
  const edited = { ...route, model: "other-model", configSha256: "b".repeat(64) };
  assert.equal(isApplied(edited, storeData), false);
  assert.equal(hasPendingChanges(edited, storeData), true);
  assert.doesNotMatch(routesSource, /JSON\.stringify\(\[/);
});

test("claude routes workspace renders title, explanation, add action, and cards", () => {
  const markup = claudeRoutesMarkup([route], storeData);
  assert.match(markup, /Claude routes/);
  assert.match(markup, /one route can be applied at a time/);
  assert.match(markup, /Add route/);
  assert.match(markup, /claude-route-card/);
});

test("routes page uses the two-column workspace and a summary chip bar", () => {
  const markup = claudeRoutesMarkup([route], storeData, { mcps: [{ name: "fs", type: "stdio" }], plugins: ["skills@market"] });
  assert.match(markup, /claude-routes-workspace/);
  assert.match(markup, /claude-routes-main/);
  assert.match(markup, /claude-routes-sidebar/);
  assert.match(markup, /claude-chipbar/);
  assert.match(markup, /1 saved routes/);
  assert.match(markup, /Applied: Main/);
  assert.match(markup, /1 MCP servers/);
  assert.match(markup, /1 plugins/);
});

test("route card shows endpoint, model, and auth reference clearly", () => {
  const markup = claudeRoutesMarkup([route], storeData);
  assert.match(markup, /Endpoint/);
  assert.match(markup, /https:\/\/api\.example\.test\/v1/);
  assert.match(markup, /Model/);
  assert.match(markup, /sonnet/);
  assert.match(markup, /API key/);
  assert.match(markup, /BDF_GATE4A_API_KEY_REF/);
  assert.match(markup, /claude-route-card__meta/);
});

test("card actions are limited to Apply route and View details", () => {
  const appliedMarkup = claudeRoutesMarkup([route], storeData);
  assert.doesNotMatch(appliedMarkup, /Deactivate provider/);
  assert.doesNotMatch(appliedMarkup, /Test connection/);
  assert.doesNotMatch(appliedMarkup, /Remove provider/);
  const savedStore = { ...storeData, appliedRouteId: null, appliedRouteConfigSha256: null };
  const savedMarkup = claudeRoutesMarkup([route], savedStore);
  assert.match(savedMarkup, /Apply route/);
  assert.match(savedMarkup, /View details/);
});

test("editor never renders SDK, package, reasoning, or activation controls", () => {
  assert.doesNotMatch(routesSource, /SDK type/);
  assert.doesNotMatch(routesSource, /provider package/);
  assert.doesNotMatch(routesSource, /reasoning-format selector/);
  assert.doesNotMatch(routesSource, /data-provider-action="activate"/);
  assert.match(routesSource, /claudeRouteAuthKind/);
  assert.match(routesSource, /claudeRouteSecretEnvRef/);
});

test("editor takes the API key value and never echoes it back", () => {
  assert.match(routesSource, /claudeRouteSecret/);
  assert.match(routesSource, /Paste your key here/);
  assert.match(routesSource, /no manual setup, no restart/);
  assert.match(routesSource, /secretValue:/);
  assert.doesNotMatch(routesSource, /claudeRouteSecret"[^>]*value=/);
});

test("route details marks app-managed environment variables", () => {
  assert.match(routesSource, /managed by Switcher/);
  assert.match(routesSource, /envVarManaged/);
});

test("preservation, restart, and env-reference notices are exact", () => {
  assert.equal(PRESERVATION_NOTICE, "Claude-owned settings preserved.");
  assert.equal(RESTART_NOTICE, "Restarting Claude Code may be required for startup-only values.");
  assert.equal(ENV_REF_HELP, "Environment variable name, not the secret value.");
});

test("unsupported surface is read-only copy, never controls", () => {
  const markup = claudeRoutesMarkup([route], storeData);
  assert.match(markup, /Not managed by this adapter/);
  assert.doesNotMatch(markup, /data-mcp/);
  assert.doesNotMatch(markup, /data-plugin/);
});

test("delete applied route is guarded in the details flow", () => {
  assert.match(routesSource, /Apply another route before deleting the applied route/);
  const appliedDetails = claudeRoutesMarkup([route], storeData);
  assert.doesNotMatch(appliedDetails, /data-delete-route/);
});

test("API values are escaped before innerHTML insertion", () => {
  assert.match(routesSource, /escapeHtml\(/);
  const malicious = { ...route, name: "<img src=x onerror=alert(1)>" };
  const markup = claudeRoutesMarkup([malicious], { routes: [malicious], appliedRouteId: null, appliedRouteConfigSha256: null });
  assert.doesNotMatch(markup, /<img src=x/);
});

test("revision tokens are submitted with mutations", () => {
  assert.match(routesSource, /expectedRevision/);
  assert.match(routesSource, /expectedRoutesRevision/);
});

test("provider workspace delegates to routes when Claude is active", () => {
  store.set({ capabilities: { providerMode: "scalar-route" } });
  assert.match(workspaceSource, /renderClaudeRoutes/);
  assert.match(workspaceSource, /isClaude\(\)/);
});

test("agent switcher offers Claude Code as a separate page, never a provider tile", () => {
  assert.match(workspaceSource, /data-provider-agent="claude-code"/);
  assert.match(workspaceSource, /aria-selected="\$\{activeAgentId === "claude-code"\}"/);
  assert.match(workspaceSource, /Claude Code/);
  assert.doesNotMatch(workspaceSource, /data-provider-action="claude/);
});

test("routes page fetches the read-only inventory for the chip bar", () => {
  assert.match(routesSource, /api\.claudeScan\(\)/);
  assert.match(routesSource, /claudeRoutesMarkup\(data\.routes \|\| \[\], data, inventory\)/);
});

test("inventory chips degrade gracefully when the scan is absent", () => {
  const markup = claudeRoutesMarkup([route], storeData);
  assert.match(markup, /0 MCP servers/);
  assert.match(markup, /0 plugins/);
});

test("restore button wired to restore client with stored revisions", () => {
  assert.match(routesSource, /restoreClaude\(/);
  assert.match(routesSource, /data-claude-restore/);
});

test("recommendation: discovery on only for yes models and traffic not suppressed", () => {
  const r = recommendClaudeCompatibility({ hasModelsEndpoint: "yes", supportsBetaFields: "yes", contextWindow: "200000", suppressNonessentialTraffic: false });
  assert.equal(r.values.gatewayDiscovery, true);
  assert.equal(r.values.autoCompactWindow, 200000);
  assert.deepEqual(r.notes, []);
});

test("recommendation: discovery blocked by suppressed traffic", () => {
  const r = recommendClaudeCompatibility({ hasModelsEndpoint: "yes", supportsBetaFields: "yes", contextWindow: "", suppressNonessentialTraffic: true });
  assert.equal(r.values.gatewayDiscovery, false);
  assert.equal(r.values.disableNonessentialTraffic, true);
  assert.ok(r.notes.some(n => n.code === "DISCOVERY_BLOCKED_BY_NONESSENTIAL_TRAFFIC" && n.tone === "warning"));
});

test("recommendation: betas disabled only when beta fields unsupported", () => {
  const no = recommendClaudeCompatibility({ hasModelsEndpoint: "no", supportsBetaFields: "no", contextWindow: "", suppressNonessentialTraffic: false });
  assert.equal(no.values.disableExperimentalBetas, true);
  const yes = recommendClaudeCompatibility({ hasModelsEndpoint: "no", supportsBetaFields: "yes", contextWindow: "", suppressNonessentialTraffic: false });
  assert.equal(yes.values.disableExperimentalBetas, false);
});

test("recommendation: unknown beta support warns without enabling", () => {
  const r = recommendClaudeCompatibility({ hasModelsEndpoint: "no", supportsBetaFields: "unknown", contextWindow: "", suppressNonessentialTraffic: false });
  assert.equal(r.values.disableExperimentalBetas, false);
  assert.ok(r.notes.some(n => n.code === "BETA_COMPATIBILITY_NOT_VERIFIED" && n.tone === "warning"));
});

test("recommendation: context below minimum clamps and warns", () => {
  const r = recommendClaudeCompatibility({ hasModelsEndpoint: "no", supportsBetaFields: "yes", contextWindow: "50000", suppressNonessentialTraffic: false });
  assert.equal(r.values.autoCompactWindow, 100000);
  assert.ok(r.notes.some(n => n.code === "CONTEXT_BELOW_SUPPORTED_MINIMUM" && n.tone === "warning"));
});

test("recommendation: context above maximum caps with info", () => {
  const r = recommendClaudeCompatibility({ hasModelsEndpoint: "no", supportsBetaFields: "yes", contextWindow: "2000000", suppressNonessentialTraffic: false });
  assert.equal(r.values.autoCompactWindow, 1000000);
  assert.ok(r.notes.some(n => n.code === "CONTEXT_CAPPED_AT_SUPPORTED_MAXIMUM" && n.tone === "info"));
});

test("recommendation: unknown context keeps 190000 starting value", () => {
  const r = recommendClaudeCompatibility({ hasModelsEndpoint: "no", supportsBetaFields: "yes", contextWindow: "", suppressNonessentialTraffic: false });
  assert.equal(r.values.autoCompactWindow, 190000);
  assert.ok(r.notes.some(n => n.code === "CONTEXT_NOT_VERIFIED" && n.tone === "info"));
});

test("recommendation: suppressed traffic mirrors input", () => {
  const on = recommendClaudeCompatibility({ hasModelsEndpoint: "no", supportsBetaFields: "yes", contextWindow: "", suppressNonessentialTraffic: true });
  const off = recommendClaudeCompatibility({ hasModelsEndpoint: "no", supportsBetaFields: "yes", contextWindow: "", suppressNonessentialTraffic: false });
  assert.equal(on.values.disableNonessentialTraffic, true);
  assert.equal(off.values.disableNonessentialTraffic, false);
});

test("assistant: four curated controls only, no raw env editor", () => {
  assert.match(routesSource, /claudeRouteGateway/);
  assert.match(routesSource, /claudeRouteBetas/);
  assert.match(routesSource, /claudeRouteCompact/);
  assert.match(routesSource, /claudeRouteTraffic/);
  assert.doesNotMatch(routesSource, /claudeRouteEnvEditor/);
  assert.doesNotMatch(routesSource, /<textarea[^>]*env/);
});

test("assistant: confirmation required before save, never pre-checked", () => {
  assert.equal(COMPAT_CONFIRM_TEXT, "I reviewed these compatibility settings and their tradeoffs.");
  assert.match(routesSource, /claudeRouteCompatConfirm/);
  assert.match(routesSource, /Review and confirm the compatibility settings before saving/);
  assert.doesNotMatch(routesSource, /id="claudeRouteCompatConfirm"[^>]*checked/);
});

test("assistant: apply button gated behind Show recommendations", () => {
  assert.match(routesSource, /data-compat-recommend/);
  assert.match(routesSource, /data-compat-apply disabled/);
  assert.match(routesSource, /Show recommendations/);
  assert.match(routesSource, /Apply recommendations/);
});

test("assistant: no gateway contact copy is present", () => {
  assert.match(routesSource, /no gateway is contacted to generate them/);
});

test("assistant: conflict UI unchecks and disables the conflicting option", () => {
  assert.match(routesSource, /syncConflict/);
  assert.match(routesSource, /traffic\.checked && gateway\.checked/);
  assert.match(routesSource, /gateway\.checked = false/);
  assert.match(routesSource, /gateway\.disabled = true/);
});

test("assistant: mobile-scoped classes exist in CSS", async () => {
  const cssSource = await readFile(new URL("../assets/css/provider-workspace.css", import.meta.url), "utf8");
  assert.match(cssSource, /\.claude-compat-assistant/);
  assert.match(cssSource, /@media \(max-width: 560px\)/);
  assert.match(cssSource, /\.claude-compat-actions/);
});
