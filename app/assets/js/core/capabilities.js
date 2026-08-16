import { store } from "./store.js";

const HIDDEN_FOR_CLAUDE = new Set(["integrations"]);

export function agentCapabilities() {
  return store.get().capabilities || null;
}

export function isClaude() {
  const caps = agentCapabilities();
  return Boolean(caps) && caps.providerMode === "scalar-route";
}

export function isOpenCodeFamily() {
  const caps = agentCapabilities();
  return Boolean(caps) && caps.providerMode === "multi-provider";
}

export function builderAvailable() {
  const caps = agentCapabilities();
  return Boolean(caps) && caps.builderAvailable === true;
}

export function navigationFor(capabilities) {
  const claude = Boolean(capabilities) && capabilities.providerMode === "scalar-route";
  return {
    providersLabel: claude ? "Routes" : "Providers",
    hiddenDestinations: claude ? HIDDEN_FOR_CLAUDE : new Set(),
  };
}

export function resolveDestination(destination, capabilities) {
  const nav = navigationFor(capabilities);
  if (nav.hiddenDestinations.has(destination)) return "overview";
  return destination;
}
