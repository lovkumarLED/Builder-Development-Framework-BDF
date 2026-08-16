import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { resolveDestination, navigationFor, isClaude, isOpenCodeFamily, builderAvailable } from "../assets/js/core/capabilities.js";
import { store } from "../assets/js/core/store.js";

const claude = { providerMode: "scalar-route", savedRoutes: true, providerCreation: false, providerActivation: false, pluginsManaged: false, mcpManaged: false, integrationsVisible: false, reasoningFormats: false, sdkSelection: false, profilesMode: "routing-profiles", requestAnalytics: false, routingActivity: true, builderAvailable: false };
const opencode = { providerMode: "multi-provider", savedRoutes: false, providerCreation: true, providerActivation: true, pluginsManaged: true, mcpManaged: true, integrationsVisible: true, reasoningFormats: true, sdkSelection: true, profilesMode: "bdf-profiles", requestAnalytics: true, routingActivity: false, builderAvailable: true };

const overviewSource = await readFile(new URL("../assets/js/pages/overview.js", import.meta.url), "utf8");
const activitySource = await readFile(new URL("../assets/js/pages/activity.js", import.meta.url), "utf8");
const settingsSource = await readFile(new URL("../assets/js/pages/settings.js", import.meta.url), "utf8");
const routerSource = await readFile(new URL("../assets/js/core/router.js", import.meta.url), "utf8");
const sidebarSource = await readFile(new URL("../assets/js/core/sidebar.js", import.meta.url), "utf8");
const mainSource = await readFile(new URL("../assets/js/main.js", import.meta.url), "utf8");
const onboardingSource = await readFile(new URL("../assets/js/pages/onboarding.js", import.meta.url), "utf8");

test("capability helpers resolve from the central contract", () => {
  store.set({ capabilities: claude });
  assert.equal(isClaude(), true);
  assert.equal(isOpenCodeFamily(), false);
  assert.equal(builderAvailable(), false);
  store.set({ capabilities: opencode });
  assert.equal(isClaude(), false);
  assert.equal(isOpenCodeFamily(), true);
  assert.equal(builderAvailable(), true);
  store.set({ capabilities: null });
  assert.equal(isClaude(), false);
});

test("navigation labels and hidden destinations come from capabilities", () => {
  const navClaude = navigationFor(claude);
  assert.equal(navClaude.providersLabel, "Routes");
  assert.deepEqual([...navClaude.hiddenDestinations], ["integrations"]);
  const navOpen = navigationFor(opencode);
  assert.equal(navOpen.providersLabel, "Providers");
  assert.equal(navOpen.hiddenDestinations.size, 0);
});

test("hidden destinations redirect to overview", () => {
  assert.equal(resolveDestination("integrations", claude), "overview");
  assert.equal(resolveDestination("integrations", opencode), "integrations");
  assert.equal(resolveDestination("providers", claude), "providers");
});

test("router consults capabilities and sidebar adapts labels and visibility", () => {
  assert.match(routerSource, /resolveDestination/);
  assert.match(sidebarSource, /applyCapabilityNavigation/);
  assert.match(sidebarSource, /Routes/);
  assert.match(sidebarSource, /integrations/);
  assert.match(sidebarSource, /globalBuildButton/);
});

test("first render waits for capabilities; build blocked for Claude", () => {
  assert.match(mainSource, /async function showWorkspace/);
  assert.match(mainSource, /await safeRefreshAgentContext/);
  assert.match(mainSource, /api\.capabilities\(\)/);
  assert.match(mainSource, /applyCapabilityNavigation/);
  assert.match(mainSource, /builderAvailable/);
});

test("pages consume capabilities centrally, never agent checks", () => {
  for (const [name, source] of [["overview", overviewSource], ["activity", activitySource], ["settings", settingsSource]]) {
    assert.match(source, /isClaude\(\)/, `${name} must branch on the central capability`);
    assert.doesNotMatch(source, /agent === "claude"|agent === 'claude'|=== "claudecode"/, `${name} must not invent agent checks`);
  }
});

test("overview swaps provider content for route status when Claude is active", () => {
  assert.match(overviewSource, /renderClaudeOverview/);
  assert.match(overviewSource, /Applied route/);
  assert.match(overviewSource, /claudeActivity/);
});

test("claude overview is a placed masonry with a read-only inventory card", () => {
  assert.match(overviewSource, /claudeScan/);
  assert.match(overviewSource, /claude-overview-masonry/);
  assert.match(overviewSource, /claude-overview-card--route/);
  assert.match(overviewSource, /claude-overview-card--inventory/);
  assert.match(overviewSource, /MCP servers/);
  assert.match(overviewSource, /plugins/);
  assert.match(overviewSource, /Scanned from \.claude\.json - read-only/);
});

test("claude settings shows the read-only inventory grid", () => {
  assert.match(settingsSource, /renderClaudeSettings/);
  assert.match(settingsSource, /unsupported in this release/);
  assert.match(settingsSource, /claudeScan/);
  assert.match(settingsSource, /claude-settings-grid/);
  assert.match(settingsSource, /claude-inventory-list/);
});

test("activity swaps request charts for redacted route activity", () => {
  assert.match(activitySource, /renderRouteActivity/);
  assert.match(activitySource, /Route activity/);
  assert.match(activitySource, /No request, token, or latency telemetry/);
});

test("route activity gets a summary chip bar", () => {
  assert.match(activitySource, /claude-chipbar/);
  assert.match(activitySource, /events/);
  assert.match(activitySource, /typeCounts/);
});

test("settings hides plugin, MCP, SDK, reasoning, and profile controls for Claude", () => {
  assert.match(settingsSource, /renderClaudeSettings/);
  assert.match(settingsSource, /unsupported in this release/);
});

test("onboarding offers the Claude Code tile unconditionally with a lock-free scan", () => {
  assert.match(onboardingSource, /claude-code/);
  assert.match(onboardingSource, /claudeScan/);
  assert.doesNotMatch(onboardingSource, /claudeDiscover/);
  assert.match(onboardingSource, /discoveredAgents = \[\.\.\.discoveredAgents, \{ id: "claude-code"/);
  assert.match(onboardingSource, /claudeConnect/);
});

test("onboarding shows the same scanned summary line for Claude Code", () => {
  assert.match(onboardingSource, /Scanned \$\{escapeHtml\(chosenAgent\.name\)\}: \$\{\(scanResult\.providers \|\| \[\]\)\.length\} providers/);
  assert.match(onboardingSource, /\.length\} MCP servers · \$\{\(scanResult\.plugins/);
});
