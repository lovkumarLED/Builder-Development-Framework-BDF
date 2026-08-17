import { api } from "../core/api.js";
import { escapeHtml, notify, openDialog } from "../core/dialog.js";

export const PRESERVATION_NOTICE = "Claude-owned settings preserved.";
export const RESTART_NOTICE = "Restarting Claude Code may be required for startup-only values.";
export const ENV_REF_HELP = "Environment variable name, not the secret value.";
export const COMPAT_CONFIRM_TEXT = "I reviewed these compatibility settings and their tradeoffs.";

const UNSAFE_COPY = "Not managed by this adapter: marketplaces, plugin installation, MCP servers, skills, permissions, hooks, memory, the " + "." + "claude" + ".json" + " state file, and other settings.";

export function recommendClaudeCompatibility({ hasModelsEndpoint, supportsBetaFields, contextWindow, suppressNonessentialTraffic }) {
  const values = {
    gatewayDiscovery: false,
    disableExperimentalBetas: false,
    autoCompactWindow: 190000,
    disableNonessentialTraffic: Boolean(suppressNonessentialTraffic),
  };
  const notes = [];
  const context = String(contextWindow || "").trim();

  if (hasModelsEndpoint === "yes" && !values.disableNonessentialTraffic) {
    values.gatewayDiscovery = true;
  } else if (hasModelsEndpoint === "yes" && values.disableNonessentialTraffic) {
    notes.push({ code: "DISCOVERY_BLOCKED_BY_NONESSENTIAL_TRAFFIC", tone: "warning", text: "Nonessential traffic is suppressed, so gateway model discovery would be disabled anyway. Discovery stays off." });
  }

  if (supportsBetaFields === "no") {
    values.disableExperimentalBetas = true;
  } else if (supportsBetaFields === "unknown") {
    notes.push({ code: "BETA_COMPATIBILITY_NOT_VERIFIED", tone: "warning", text: "Beta-header compatibility is not verified, so experimental betas stay enabled." });
  }

  if (context !== "") {
    const parsed = Number(context);
    if (Number.isInteger(parsed) && parsed > 0) {
      if (parsed < 100000) {
        values.autoCompactWindow = 100000;
        notes.push({ code: "CONTEXT_BELOW_SUPPORTED_MINIMUM", tone: "warning", text: "The context window is below the supported minimum; /compact may be required." });
      } else if (parsed > 1000000) {
        values.autoCompactWindow = 1000000;
        notes.push({ code: "CONTEXT_CAPPED_AT_SUPPORTED_MAXIMUM", tone: "info", text: "The context window exceeds the supported maximum and is capped at 1000000." });
      } else {
        values.autoCompactWindow = parsed;
      }
    }
  } else {
    notes.push({ code: "CONTEXT_NOT_VERIFIED", tone: "info", text: "The context window is not verified; 190000 is a starting value only." });
  }

  return { values, notes };
}

export function isApplied(route, store) {
  return Boolean(route.configSha256) && store.appliedRouteId === route.id && store.appliedRouteConfigSha256 === route.configSha256;
}

export function hasPendingChanges(route, store) {
  return Boolean(route.configSha256) && store.appliedRouteId === route.id && store.appliedRouteConfigSha256 !== route.configSha256;
}

function routeCard(route, store) {
  const applied = isApplied(route, store);
  const pending = hasPendingChanges(route, store);
  const marker = applied ? '<span class="claude-route-status claude-route-status--applied">Applied</span>'
    : pending ? '<span class="claude-route-status claude-route-status--pending">Changes not applied</span>'
    : '<span class="claude-route-status">Saved</span>';
  const actions = applied
    ? '<button class="button button--quiet button--small" type="button" data-route-action="details">View details</button>'
    : `<button class="button button--primary button--small" type="button" data-route-action="apply">Apply route</button><button class="button button--quiet button--small" type="button" data-route-action="details">View details</button>`;
  const authLabel = route.authKind === "apiKey" ? "API key" : "Bearer token";
  return `<article class="claude-route-card ${applied ? "claude-route-card--applied" : "claude-route-card--saved"}" data-route-id="${escapeHtml(route.id)}"><div class="claude-route-card__head"><h3>${escapeHtml(route.name)}</h3>${marker}</div><dl class="claude-route-card__meta"><div><dt>Endpoint</dt><dd class="mono">${escapeHtml(route.baseUrl)}</dd></div><div><dt>Model</dt><dd>${escapeHtml(route.effectiveModel || route.model)}${route.model ? "" : ' <span class="claude-type-chip">from roles</span>'}</dd></div><div><dt>Auth</dt><dd>${authLabel} · <span class="mono">${escapeHtml(route.secretEnvRef)}</span></dd></div></dl><div class="claude-route-card__actions">${actions}</div></article>`;
}

export function claudeRoutesMarkup(routes, store, inventory = null, credentials = null) {
  const list = Array.isArray(routes) ? routes : [];
  const inv = inventory || { mcps: [], plugins: [] };
  const applied = list.find(route => route.id === store.appliedRouteId) || null;
  const mcpCount = Array.isArray(inv.mcps) ? inv.mcps.length : 0;
  const pluginCount = Array.isArray(inv.plugins) ? inv.plugins.length : 0;
  const chipbar = `<div class="claude-chipbar" aria-label="Claude Code summary"><span class="chip">${list.length} saved routes</span><span class="chip">Applied: ${applied ? escapeHtml(applied.name) : "none"}</span><span class="chip">${mcpCount} MCP servers</span><span class="chip">${pluginCount} plugins</span></div>`;
  const creds = Array.isArray(credentials) ? credentials : [];
  const credsCard = `<div class="card card--padded"><p class="eyebrow">Credentials</p><p class="field-note">App-managed keys are stored encrypted (Windows DPAPI); names and usage only are shown here.</p>${creds.length ? `<div class="claude-cred-list">${creds.map(c => `<div class="claude-cred-row"><div><span class="mono">${escapeHtml(c.name)}</span> <span class="claude-type-chip">${c.backend === "store" ? "locked store" : "env var"}</span><p class="muted">${c.usedBy.length ? "Used by " + c.usedBy.map(escapeHtml).join(", ") : "Not used by any route"}</p></div>${c.usedBy.length ? "" : `<button class="button button--danger button--small" type="button" data-cred-delete="${escapeHtml(c.name)}">Delete</button>`}</div>`).join("")}</div>` : `<p class="muted">No app-managed credentials yet.</p>`}</div>`;
  return `<div class="page-head"><div><p class="eyebrow">Routing</p><h1 class="page-title">Claude routes</h1><p class="page-intro">Multiple saved routes; one route can be applied at a time.</p></div><div class="page-actions"><button id="addClaudeRoute" class="button button--primary" type="button">Add route</button></div></div>${chipbar}<div class="claude-routes-workspace"><section class="claude-routes-main" aria-label="Saved Claude routes">${list.length ? `<div class="claude-routes-grid">${list.map(route => routeCard(route, store)).join("")}</div>` : `<div class="empty-state"><h3>No routes yet</h3><p>Save a routing profile, then apply it to Claude Code.</p><button id="emptyAddClaudeRoute" class="button button--primary" type="button">Add route</button></div>`}</section><aside class="claude-routes-sidebar"><div class="card card--padded"><p class="eyebrow">Claude Code</p><p>${PRESERVATION_NOTICE}</p><p>${RESTART_NOTICE}</p><p class="muted">${UNSAFE_COPY}</p><div class="claude-editor-status" data-claude-status></div></div>${credsCard}</aside></div>`;
}

export async function renderClaudeRoutes(workspace) {
  workspace.innerHTML = '<div class="card card--padded skeleton"></div>';
  try {
    const [data, status, inventory, credentials] = await Promise.all([
      api.claudeRoutes(),
      api.claudeStatus().catch(() => null),
      api.claudeScan().catch(() => null),
      api.claudeCredentials().catch(() => null),
    ]);
    workspace.innerHTML = claudeRoutesMarkup(data.routes || [], data, inventory, credentials && credentials.credentials);
    if (status) {
      const block = workspace.querySelector("[data-claude-status]");
      block.innerHTML = `<p class="muted">Settings file: ${status.settingsPresent === true ? "present" : status.settingsPresent === null ? "unknown (locked)" : "missing"}</p><p class="muted">Last backup available: ${status.lastBackupAvailable ? "yes" : "no"}</p>${status.realTargetLocked ? '<p class="field-error">Real-target writes are locked until Gate 5 approval.</p>' : ""}<button class="button button--outline button--small" type="button" data-claude-restore>Restore latest backup</button>`;
      block.querySelector("[data-claude-restore]").addEventListener("click", () => restoreLatest(workspace, data));
    }
  } catch (error) {
    workspace.innerHTML = `<div class="empty-state"><h3>Claude routes unavailable</h3><p>${escapeHtml(error.message)}</p></div>`;
    return;
  }
  workspace.querySelector("#addClaudeRoute")?.addEventListener("click", event => openRouteEditor(workspace, null, event.currentTarget));
  workspace.querySelector("#emptyAddClaudeRoute")?.addEventListener("click", event => openRouteEditor(workspace, null, event.currentTarget));
  workspace.querySelectorAll("[data-route-action='apply']").forEach(button => button.addEventListener("click", () => {
    const id = button.closest("[data-route-id]").dataset.routeId;
    applyRoute(workspace, id);
  }));
  workspace.querySelectorAll("[data-route-action='details']").forEach(button => button.addEventListener("click", () => {
    const id = button.closest("[data-route-id]").dataset.routeId;
    openRouteDetails(workspace, id);
  }));
  workspace.querySelectorAll("[data-cred-delete]").forEach(button => button.addEventListener("click", async () => {
    const name = button.dataset.credDelete;
    if (!confirm(`Delete the app-managed credential ${name}?`)) return;
    try {
      await api.deleteClaudeCredential(name);
      notify("Credential deleted.", "success");
    } catch (error) {
      notify(error.message, "error");
    }
    await renderClaudeRoutes(workspace);
  }));
}

async function currentStore(workspace) {
  return api.claudeRoutes();
}

async function applyRoute(workspace, routeId) {
  try {
    const store = await currentStore(workspace);
    const revision = store.revision;
    const routesRevision = store.routesRevision;
    if (!revision || !routesRevision) throw new Error("The Claude target is locked.");
    const result = await api.applyClaudeRoute(routeId, { expectedRevision: revision, expectedRoutesRevision: routesRevision });
    notify("Route applied to Claude Code.", "success");
    await renderClaudeRoutes(workspace);
  } catch (error) {
    notify(error.message, "error");
    await renderClaudeRoutes(workspace);
  }
}

async function restoreLatest(workspace, store) {
  try {
    if (!store.revision || !store.routesRevision) throw new Error("The Claude target is locked.");
    const result = await api.restoreClaude({ expectedRevision: store.revision, expectedRoutesRevision: store.routesRevision });
    notify(result.message || "Backup restored.", "success");
  } catch (error) {
    notify(error.message, "error");
  }
  await renderClaudeRoutes(workspace);
}

function editorForm(route) {
  const r = route || {};
  const checked = (value, key) => value ? 'checked' : '';
  return `<form id="claudeRouteForm" class="stack"><div class="field"><label for="claudeRouteName">Route name</label><input id="claudeRouteName" required maxlength="64" value="${escapeHtml(r.name || "")}" autocomplete="off"></div><div class="field"><label for="claudeRouteUrl">Endpoint base URL</label><input id="claudeRouteUrl" required type="url" value="${escapeHtml(r.baseUrl || "")}" autocomplete="off"></div><div class="field"><label for="claudeRouteAuthKind">Auth strategy</label><select id="claudeRouteAuthKind"><option value="apiKey" ${r.authKind === "authToken" ? "" : "selected"}>API key reference</option><option value="authToken" ${r.authKind === "authToken" ? "selected" : ""}>Bearer-token reference</option></select></div><div class="field"><label for="claudeRouteSecretEnvRef">Environment variable name</label><input id="claudeRouteSecretEnvRef" required value="${escapeHtml(r.secretEnvRef || "")}" autocomplete="off"><p class="field-note">${ENV_REF_HELP}</p></div><div class="field"><label for="claudeRouteSecret">API key value</label><div class="provider-secret"><input id="claudeRouteSecret" type="password" autocomplete="new-password" placeholder="Paste your key here"><button type="button" aria-label="Show API key">◉</button></div><p class="field-note">Switcher saves it as the environment variable above - no manual setup, no restart. Leave empty to keep an existing variable.</p></div><div class="field"><label for="claudeRouteModel">Model ID</label><input id="claudeRouteModel" value="${escapeHtml(r.model || "")}" autocomplete="off"><p class="field-note">Optional when you assign a role model below — the main model is derived from your Sonnet role (or first role) when blank.</p></div><div class="field"><label class="checkbox-row"><input id="claudeRouteGateway" type="checkbox" ${checked(r.gatewayDiscovery, "gatewayDiscovery")}> Gateway model discovery</label></div><div class="field"><label class="checkbox-row"><input id="claudeRouteBetas" type="checkbox" ${checked(r.disableExperimentalBetas, "disableExperimentalBetas")}> Disable experimental beta headers</label></div><div class="field"><label class="checkbox-row"><input id="claudeRouteCompactOn" type="checkbox" ${r.autoCompactWindow ? "checked" : ""}> Auto-compact window</label><input id="claudeRouteCompact" type="number" min="100000" max="1000000" value="${escapeHtml(String(r.autoCompactWindow || 190000))}" ${r.autoCompactWindow ? "" : "disabled"}></div><div class="field"><label class="checkbox-row"><input id="claudeRouteTraffic" type="checkbox" ${checked(r.disableNonessentialTraffic, "disableNonessentialTraffic")}> Disable nonessential traffic</label></div><fieldset class="claude-role-section"><legend>Claude model roles</legend><p class="field-note">Assign this route's models to Claude's role aliases. Each role holds one model ID. A blank role is not written, and any stale value is removed on apply.</p>${(["opus","sonnet","haiku","fable"]).map(role => `<div class="claude-role-row"><label class="claude-role-name">${role[0].toUpperCase() + role.slice(1)}</label><input class="claude-role-model" data-role-model="${role}" placeholder="model-id" value="${escapeHtml(((r.modelRoles || {})[role] || ""))}" autocomplete="off"></div>`).join("")}<div class="field"><label class="checkbox-row"><input id="claudeRouteRestrict" type="checkbox" ${r.restrictModelPicker === false ? "" : "checked"}> Restrict the /model picker to this route's models</label><p class="field-note">Writes availableModels + enforceAvailableModels so /model shows only this route's models (enforcement needs Claude Code 2.1.175+).</p></div></fieldset><fieldset class="claude-compat-assistant"><legend>Gateway compatibility assistant</legend><p class="field-note">Recommendations are advisory; no gateway is contacted to generate them.</p><div class="field"><label for="claudeCompatModels">Does the gateway expose /v1/models?</label><select id="claudeCompatModels"><option value="unknown" selected>Unknown</option><option value="yes">Yes</option><option value="no">No</option></select></div><div class="field"><label for="claudeCompatBetas">Does it accept Anthropic beta fields?</label><select id="claudeCompatBetas"><option value="unknown" selected>Unknown</option><option value="yes">Yes</option><option value="no">No</option></select></div><div class="field"><label for="claudeCompatContext">Model context window (optional)</label><input id="claudeCompatContext" type="number" min="1" placeholder="e.g. 200000" autocomplete="off"></div><div class="field"><label class="checkbox-row"><input id="claudeCompatTraffic" type="checkbox"> Suppress nonessential traffic</label></div><div class="claude-compat-actions"><button class="button button--outline button--small" type="button" data-compat-recommend>Show recommendations</button><button class="button button--secondary button--small" type="button" data-compat-apply disabled>Apply recommendations</button></div><div class="claude-compat-summary" data-compat-summary hidden></div><div class="field"><label class="checkbox-row"><input id="claudeRouteCompatConfirm" type="checkbox"> ${COMPAT_CONFIRM_TEXT}</label></div></fieldset><p id="claudeRouteMessage" class="field-error" role="alert"></p></form>`;
}

function valuesFrom(dialog) {
  const compactOn = dialog.querySelector("#claudeRouteCompactOn")?.checked ?? true;
  const roles = {};
  dialog.querySelectorAll("[data-role-model]").forEach(input => {
    const value = input.value.trim();
    if (value) roles[input.dataset.roleModel] = value;
  });
  return {
    name: dialog.querySelector("#claudeRouteName").value.trim(),
    baseUrl: dialog.querySelector("#claudeRouteUrl").value.trim(),
    authKind: dialog.querySelector("#claudeRouteAuthKind").value,
    secretEnvRef: dialog.querySelector("#claudeRouteSecretEnvRef").value.trim(),
    secretValue: dialog.querySelector("#claudeRouteSecret").value.trim(),
    model: dialog.querySelector("#claudeRouteModel").value.trim(),
    gatewayDiscovery: dialog.querySelector("#claudeRouteGateway").checked,
    disableExperimentalBetas: dialog.querySelector("#claudeRouteBetas").checked,
    autoCompactWindow: compactOn ? Number(dialog.querySelector("#claudeRouteCompact").value) : null,
    disableNonessentialTraffic: dialog.querySelector("#claudeRouteTraffic").checked,
    modelRoles: roles,
    restrictModelPicker: dialog.querySelector("#claudeRouteRestrict").checked,
  };
}

async function saveRoute(workspace, dialog, routeId, store) {
  const message = dialog.querySelector("#claudeRouteMessage");
  const body = valuesFrom(dialog);
  try {
    if (routeId) {
      const result = await api.updateClaudeRoute(routeId, { ...body, expectedRoutesRevision: store.routesRevision });
      notify("Route saved. Changes are not applied until you choose Apply.", "success");
    } else {
      await api.createClaudeRoute(body);
      notify("Route saved. Choose Apply route when ready.", "success");
    }
    dialog.querySelector("[data-dialog-close]").click();
    await renderClaudeRoutes(workspace);
  } catch (error) {
    message.textContent = error.message;
  }
}

export function openRouteEditor(workspace, route, trigger) {
  const { dialog, close } = openDialog({
    title: route ? `Edit ${route.name}` : "Add route",
    trigger,
    content: editorForm(route),
    actions: `<button class="button button--quiet" type="button" data-dialog-close>Cancel</button><button class="button button--primary" type="submit" form="claudeRouteForm">Save route</button>`,
    wide: true,
    onOpen(dialog) {
      dialog.classList.add("claude-route-dialog");
      const first = dialog.querySelector("#claudeRouteName");
      if (first) first.focus();
      const secretToggle = dialog.querySelector(".provider-secret button");
      secretToggle?.addEventListener("click", event => {
        const input = dialog.querySelector("#claudeRouteSecret");
        const show = input.type === "password";
        input.type = show ? "text" : "password";
        event.currentTarget.setAttribute("aria-label", show ? "Hide API key" : "Show API key");
      });
      const compactOn = dialog.querySelector("#claudeRouteCompactOn");
      const compactInput = dialog.querySelector("#claudeRouteCompact");
      const syncCompact = () => { compactInput.disabled = !compactOn.checked; };
      compactOn?.addEventListener("change", syncCompact);
      syncCompact();
      wireCompatibilityAssistant(dialog);
    },
  });
  dialog.querySelector("#claudeRouteForm").addEventListener("submit", async event => {
    event.preventDefault();
    const message = dialog.querySelector("#claudeRouteMessage");
    const store = await currentStore(workspace);
    if (route && !store.routesRevision) { message.textContent = "The saved routes could not be read."; return; }
    const confirmBox = dialog.querySelector("#claudeRouteCompatConfirm");
    if (!confirmBox || !confirmBox.checked) {
      message.textContent = "Review and confirm the compatibility settings before saving.";
      return;
    }
    await saveRoute(workspace, dialog, route?.id, store);
  });
}

function wireCompatibilityAssistant(dialog) {
  const gateway = dialog.querySelector("#claudeRouteGateway");
  const betas = dialog.querySelector("#claudeRouteBetas");
  const compact = dialog.querySelector("#claudeRouteCompact");
  const traffic = dialog.querySelector("#claudeRouteTraffic");
  const models = dialog.querySelector("#claudeCompatModels");
  const betaFields = dialog.querySelector("#claudeCompatBetas");
  const context = dialog.querySelector("#claudeCompatContext");
  const suppress = dialog.querySelector("#claudeCompatTraffic");
  const summary = dialog.querySelector("[data-compat-summary]");
  const recommendBtn = dialog.querySelector("[data-compat-recommend]");
  const applyBtn = dialog.querySelector("[data-compat-apply]");

  const syncConflict = () => {
    if (traffic.checked && gateway.checked) {
      gateway.checked = false;
      gateway.disabled = true;
    } else if (traffic.checked) {
      gateway.disabled = true;
    } else {
      gateway.disabled = false;
    }
    if (gateway.checked && traffic.checked) {
      traffic.checked = false;
      traffic.disabled = true;
    } else if (gateway.checked) {
      traffic.disabled = true;
    } else {
      traffic.disabled = false;
    }
  };
  traffic.addEventListener("change", syncConflict);
  gateway.addEventListener("change", syncConflict);
  syncConflict();

  recommendBtn.addEventListener("click", () => {
    const recommendation = recommendClaudeCompatibility({
      hasModelsEndpoint: models.value,
      supportsBetaFields: betaFields.value,
      contextWindow: context.value,
      suppressNonessentialTraffic: suppress.checked,
    });
    const lines = recommendation.notes.map(note => `<p class="claude-compat-note claude-compat-note--${note.tone}">${escapeHtml(note.text)}</p>`).join("");
    summary.innerHTML = `<p class="claude-compat-benefit">Discovery: ${recommendation.values.gatewayDiscovery ? "on" : "off"} - Betas disabled: ${recommendation.values.disableExperimentalBetas ? "on" : "off"} - Compact: ${escapeHtml(String(recommendation.values.autoCompactWindow))} - Nonessential traffic: ${recommendation.values.disableNonessentialTraffic ? "suppressed" : "on"}</p>${lines}`;
    summary.hidden = false;
    applyBtn.disabled = false;
    applyBtn.dataset.values = JSON.stringify(recommendation.values);
  });

  applyBtn.addEventListener("click", () => {
    if (!applyBtn.dataset.values) return;
    const values = JSON.parse(applyBtn.dataset.values);
    gateway.checked = values.gatewayDiscovery;
    betas.checked = values.disableExperimentalBetas;
    compact.value = String(values.autoCompactWindow);
    traffic.checked = values.disableNonessentialTraffic;
    const compactOn = document.querySelector("#claudeRouteCompactOn");
    if (compactOn) { compactOn.checked = true; compact.disabled = false; }
    syncConflict();
  });
}

export function openRouteDetails(workspace, routeId) {
  api.claudeRoutes().then(data => {
    const route = (data.routes || []).find(r => r.id === routeId);
    if (!route) { notify("That route doesn't exist anymore. Refresh the page.", "error"); return; }
    openDialog({
      title: route.name,
      trigger: document.activeElement,
      content: `<dl class="stack"><div><dt class="eyebrow">Endpoint</dt><dd class="mono">${escapeHtml(route.baseUrl)}</dd></div><div><dt class="eyebrow">Auth</dt><dd>${escapeHtml(route.authKind)} reference: ${escapeHtml(route.secretEnvRef)}${route.envVarManaged ? ' <span class="claude-type-chip">managed by Switcher</span>' : ""}</dd></div><div><dt class="eyebrow">Model</dt><dd>${escapeHtml(route.effectiveModel || route.model)}${route.model ? "" : ' <span class="claude-type-chip">from roles</span>'}</dd></div>${(["opus","sonnet","haiku","fable"]).filter(role => (route.modelRoles || {})[role]).map(role => `<div><dt class="eyebrow">${role[0].toUpperCase() + role.slice(1)} role</dt><dd class="mono">${escapeHtml((route.modelRoles || {})[role])}</dd></div>`).join("")}<div><dt class="eyebrow">Policies</dt><dd>Gateway discovery ${route.gatewayDiscovery ? "on" : "off"} - Betas ${route.disableExperimentalBetas ? "disabled" : "enabled"} - Auto-compact ${route.autoCompactWindow ? escapeHtml(String(route.autoCompactWindow)) : "off"} - Nonessential traffic ${route.disableNonessentialTraffic ? "disabled" : "enabled"} - Picker ${route.restrictModelPicker === false ? "unrestricted" : "restricted to route models"}</dd></div><div><dt class="eyebrow">Status</dt><dd>${isApplied(route, data) ? "Applied" : hasPendingChanges(route, data) ? "Changes not applied" : "Saved"}</dd></div></dl>`,
      actions: `<button class="button button--quiet" type="button" data-dialog-close>Close</button><button class="button button--secondary" type="button" data-edit-route>Edit</button>${data.appliedRouteId === route.id ? "" : '<button class="button button--danger" type="button" data-delete-route>Delete</button>'}`,
      onOpen(dialog) {
        dialog.querySelector("[data-edit-route]")?.addEventListener("click", () => { dialog.querySelector("[data-dialog-close]").click(); openRouteEditor(workspace, route, document.activeElement); });
        dialog.querySelector("[data-delete-route]")?.addEventListener("click", async () => {
          try {
            const current = await currentStore(workspace);
            if (current.appliedRouteId === route.id) throw new Error("Apply another route before deleting the applied route.");
            await api.deleteClaudeRoute(route.id, { expectedRoutesRevision: current.routesRevision });
            notify("Route deleted.", "success");
            dialog.querySelector("[data-dialog-close]").click();
            await renderClaudeRoutes(workspace);
          } catch (error) {
            notify(error.message, "error");
          }
        });
      },
    });
  }).catch(error => notify(error.message, "error"));
}
