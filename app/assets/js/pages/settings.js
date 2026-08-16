import { api, optional } from "../core/api.js";
import { escapeHtml, notify, openDialog } from "../core/dialog.js";
import { reducedMotion, setMotionPreference } from "../core/motion.js";
import { isClaude } from "../core/capabilities.js";
import { levelsForProvider, modelEditorMarkup, modelEditorRowMarkup, normalizeModelBatch, thinkingLevelMarkup } from "./settings-model-editor.js";
import { modelManagerRows, settingsWorkspaceMarkup } from "./settings-workspace.js";

const CLAUDE_RESTART_NOTICE = "Restarting Claude Code may be required for startup-only values.";

async function renderClaudeSettings(workspace) {
  workspace.innerHTML = `<section class="settings-workspace"><div class="card card--padded skeleton"></div></section>`;
  const [routes, status, inventory] = await Promise.all([
    optional(() => api.claudeRoutes(), { routes: [], appliedRouteId: null }),
    optional(() => api.claudeStatus(), null),
    optional(() => api.claudeScan(), { mcps: [], plugins: [], statePresent: false, stateParseError: false, projectCount: 0 }),
  ]);
  const applied = (routes.routes || []).find(route => route.id === routes.appliedRouteId) || null;
  const mcps = Array.isArray(inventory.mcps) ? inventory.mcps : [];
  const plugins = Array.isArray(inventory.plugins) ? inventory.plugins : [];
  const mcpRows = mcps.map(mcp => `<li class="claude-inventory-row"><strong>${escapeHtml(mcp.name)}</strong><span class="claude-type-chip">${escapeHtml(mcp.type)}</span><span class="muted">${escapeHtml(mcp.scope)}${mcp.project ? ` · ${escapeHtml(mcp.project)}` : ""}</span></li>`).join("");
  const pluginChips = plugins.map(name => `<span class="chip">${escapeHtml(name)}</span>`).join("");
  const stateNote = !inventory.statePresent
    ? "No .claude.json found."
    : inventory.stateParseError
      ? "Could not read .claude.json."
      : `Scanned from .claude.json${inventory.projectCount ? ` (${inventory.projectCount} project scope${inventory.projectCount === 1 ? "" : "s"})` : ""} - read-only, never edited by Switcher.`;
  workspace.innerHTML = `<section class="settings-workspace"><div class="card card--padded"><p class="eyebrow">Routing profiles</p><h2 class="page-title">Claude Code settings</h2><p class="page-intro">Claude-owned settings preserved. Marketplaces, plugin installation, MCP servers, skills, permissions, hooks, memory, and other settings stay Claude-owned and unsupported in this release.</p></div><div class="claude-settings-grid"><div class="card card--padded"><p class="eyebrow">Routing profile status</p><dl class="stack"><div><dt>Saved routes</dt><dd>${(routes.routes || []).length}</dd></div><div><dt>Applied route</dt><dd>${applied ? escapeHtml(applied.name) : "None"}</dd></div><div><dt>Applied model</dt><dd>${applied ? escapeHtml(applied.model) : "�?None"}</dd></div><div><dt>Backup available</dt><dd>${status?.lastBackupAvailable ? "Yes" : "No"}</dd></div><div><dt>Real-target lock</dt><dd>${status?.realTargetLocked ? "Locked until Gate 5 approval" : "Unlocked"}</dd></div></dl><p class="muted">${CLAUDE_RESTART_NOTICE}</p></div><div class="card card--padded"><p class="eyebrow">Claude inventory (read-only)</p><div class="claude-inventory-chips"><span class="chip chip--strong">${mcps.length} MCP servers</span><span class="chip chip--strong">${plugins.length} plugins</span></div>${mcpRows ? `<ul class="claude-inventory-list">${mcpRows}</ul>` : ""}${pluginChips ? `<div class="claude-inventory-plugins">${pluginChips}</div>` : ""}<p class="muted claude-inventory-note">${stateNote}</p></div></div></section>`;
}

const defaultPreferences = { activityRetentionDays: 30, requestContentRedaction: true, reducedMotion: "system" };

function replaceModelOptions(select, models) {
  select.replaceChildren(...(models.length ? models : [{ model: "", name: "No models configured" }]).map(model => {
    const option = document.createElement("option");
    option.value = model.model;
    option.textContent = model.name || model.model;
    return option;
  }));
  select.dispatchEvent(new Event("ai-switcher:options-changed"));
}

function openAddModelDialog(trigger, provider, formats, onSaved) {
  let selectedFormat = provider.reasoningFormat || "opencode";
  const { dialog, close } = openDialog({
    title: "Add models", trigger, wide: true,
    content: modelEditorMarkup(provider, formats),
    actions: `<button class="button button--quiet" type="button" data-dialog-close>Cancel</button><button class="button button--primary" type="submit" form="settingsModelForm">Save models</button>`,
  });
  const rows = dialog.querySelector("#modelEditorRows");
  dialog.querySelector("[data-add-model-row]").addEventListener("click", () => {
    const index = Number(rows.dataset.nextIndex || rows.children.length);
    rows.insertAdjacentHTML("beforeend", modelEditorRowMarkup(index, formats, selectedFormat));
    rows.dataset.nextIndex = String(index + 1);
    rows.lastElementChild.querySelector("input")?.focus();
  });
  rows.addEventListener("click", async event => {
    const remove = event.target.closest("[data-remove-model]");
    if (remove) {
      const row = remove.closest("[data-model-row]");
      if (rows.children.length === 1) {
        row.querySelectorAll("input").forEach(input => { input.value = ""; input.checked = false; });
        row.querySelector("input")?.focus();
      } else row.remove();
      return;
    }
    const testButton = event.target.closest("[data-test-model]");
    if (!testButton) return;
    const row = testButton.closest("[data-model-row]");
    const result = row.querySelector("[data-test-result]");
    const modelId = row.querySelector(".settings-model-id").value.trim();
    const apiModelId = row.querySelector(".settings-model-api-id").value.trim();
    if (!modelId && !apiModelId) { result.textContent = "Enter a model ID first."; return; }
    testButton.disabled = true;
    result.textContent = "Testing…";
    try {
      const response = await api.testModel(provider.id, { model: modelId, apiModelId });
      result.textContent = response.message || (response.ok ? "Model replied OK." : "Model test failed.");
      result.classList.toggle("is-error", !response.ok);
    } catch (error) {
      result.textContent = error.message;
      result.classList.add("is-error");
    } finally {
      testButton.disabled = false;
    }
  });
  rows.addEventListener("change", event => {
    const format = event.target.closest("[data-reasoning-format]");
    if (!format) return;
    selectedFormat = format.value;
    rows.querySelectorAll("[data-model-row]").forEach(row => {
      row.querySelectorAll("[data-reasoning-format]").forEach(input => { input.checked = input.value === selectedFormat; });
      row.querySelector(".model-editor-thinking-choices").innerHTML = thinkingLevelMarkup(selectedFormat, formats);
    });
  });
  dialog.querySelector("#settingsModelForm").addEventListener("submit", async event => {
    event.preventDefault();
    const message = dialog.querySelector("#newModelMessage");
    try {
      const levels = levelsForProvider({ reasoningFormat: selectedFormat }, formats);
      const candidates = [...rows.querySelectorAll("[data-model-row]")].map(row => ({
        model: row.querySelector(".settings-model-id").value,
        name: row.querySelector(".settings-model-name").value,
        apiModelId: row.querySelector(".settings-model-api-id").value,
        thinking: [...row.querySelectorAll("[data-reasoning-level]:checked")].map(input => input.value),
        reasoningFormat: row.querySelector("[data-reasoning-format]:checked")?.value || selectedFormat,
      }));
      const result = normalizeModelBatch(provider.models || [], candidates, levels);
      await api.updateProvider(provider.id, { reasoningFormat: selectedFormat, models: result.added });
      provider.reasoningFormat = selectedFormat;
      provider.models = result.models;
      close(); notify(`${result.added.length} model${result.added.length === 1 ? "" : "s"} added to ${provider.name}.`, "success"); onSaved();
    } catch (error) { message.textContent = error.message; }
  });
}

export async function renderSettings(workspace) {
  if (isClaude()) {
    await renderClaudeSettings(workspace);
    return;
  }
  workspace.innerHTML = `<section class="settings-workspace"><div class="card card--padded skeleton"></div><div class="card card--padded skeleton"></div></section>`;
  const [providerData, formatData, preferenceData, pluginData, mcpData, profileData] = await Promise.all([
    optional(() => api.providers(), { providers: [] }),
    optional(() => api.formats(), { formats: [] }),
    optional(() => api.preferences(), defaultPreferences),
    optional(() => api.plugins(), { plugins: [] }), optional(() => api.mcp(), { mcps: {} }),
    optional(() => api.profiles(), { profiles: [], active: null }),
  ]);
  const providers = providerData.providers || [];
  const formats = formatData.formats || [];
  const preferences = { ...defaultPreferences, ...(preferenceData.preferences || preferenceData) };
  const plugins = pluginData.plugins || [];
  const mcps = mcpData.mcps || mcpData.mcp || {};
  const profiles = profileData.profiles || [];
  let activeProfile = profileData.active || profiles[0] || "coding";
  setMotionPreference(preferences.reducedMotion);
  workspace.innerHTML = settingsWorkspaceMarkup({ providers, plugins, mcps, preferences, profiles, activeProfile });

  workspace.querySelectorAll("[data-settings-target]").forEach(button => button.addEventListener("click", () => {
    workspace.querySelectorAll(".settings-nav-item").forEach(item => item.classList.toggle("is-active", item === button));
    workspace.querySelector(`#${button.dataset.settingsTarget}`)?.scrollIntoView({ behavior: reducedMotion() ? "auto" : "smooth", block: "start" });
  }));

  workspace.querySelector("#profileChange")?.addEventListener("click", () => {
    const list = workspace.querySelector("#profileList");
    list.hidden = !list.hidden;
    workspace.querySelector("#profileChange").setAttribute("aria-expanded", String(!list.hidden));
  });
  workspace.querySelectorAll("[data-profile]").forEach(button => button.addEventListener("click", async () => {
    const next = button.dataset.profile;
    const message = workspace.querySelector("#profileMessage");
    if (next === activeProfile) { workspace.querySelector("#profileList").hidden = true; return; }
    try {
      await api.switchProfile(next);
      activeProfile = next;
      message.textContent = `Switched to profile '${next}'.`;
      notify(`Switched to profile '${next}'.`, "success");
      renderSettings(workspace);
    } catch (error) { message.textContent = error.message; notify(error.message, "error"); }
  }));

  const providerSelect = workspace.querySelector("#settingsProvider");
  const modelSelect = workspace.querySelector("#settingsModel");
  const selectedProvider = () => providers.find(provider => provider.id === providerSelect?.value) || null;
  const syncSelectedProvider = () => {
    const provider = selectedProvider();
    if (!provider) return;
    replaceModelOptions(modelSelect, provider.models || []);
    const context = workspace.querySelector("#settingsModelContext");
    const count = provider.models?.length || 0;
    context.innerHTML = `<strong>${count} ${count === 1 ? "model" : "models"}</strong><span>Models are saved to <code>${escapeHtml(provider.id)}-models.json</code>.</span>`;
    syncSelectedModel();
  };

  const reasoningPanel = workspace.querySelector("#settingsReasoningPanel");
  const reasoningFormatSelect = workspace.querySelector("#settingsReasoningFormat");
  const reasoningLevels = workspace.querySelector("#settingsReasoningLevels");
  const reasoningSaved = workspace.querySelector("#settingsReasoningSaved");

  const syncSelectedModel = () => {
    const provider = selectedProvider();
    const modelId = modelSelect?.value;
    if (!provider || !modelId || !reasoningPanel) { if (reasoningPanel) reasoningPanel.hidden = true; return; }
    const model = (provider.models || []).find(item => item.model === modelId);
    if (!model) { reasoningPanel.hidden = true; return; }
    reasoningPanel.hidden = false;
    workspace.querySelector("#settingsReasoningModel").textContent = model.name || modelId;
    workspace.querySelector("#settingsReasoningCurrent").textContent = model.thinking?.length
      ? `Current: ${model.thinking.join(", ")}`
      : "Current: none";
    reasoningFormatSelect.replaceChildren(...formats.map(format => {
      const option = document.createElement("option");
      option.value = format.id;
      option.textContent = format.label;
      return option;
    }));
    const currentFormat = provider.reasoningFormat || "opencode";
    reasoningFormatSelect.value = formats.some(f => f.id === currentFormat) ? currentFormat : "opencode";
    renderReasoningLevels();
    reasoningSaved.textContent = "";
  };

  const renderReasoningLevels = () => {
    const selectedFormat = reasoningFormatSelect?.value || "opencode";
    reasoningLevels.innerHTML = levelsForProvider({ reasoningFormat: selectedFormat }, formats)
      .map(level => `<button type="button" data-reasoning-level="${escapeHtml(level)}" aria-pressed="false">${escapeHtml(level)}</button>`).join("");
  };
  reasoningFormatSelect?.addEventListener("change", renderReasoningLevels);
  reasoningLevels?.addEventListener("click", event => {
    const button = event.target.closest("[data-reasoning-level]");
    if (!button) return;
    button.setAttribute("aria-pressed", String(button.getAttribute("aria-pressed") !== "true"));
  });
  workspace.querySelector("#settingsReasoningSave")?.addEventListener("click", async () => {
    const provider = selectedProvider();
    const modelId = modelSelect?.value;
    if (!provider || !modelId) return;
    const format = reasoningFormatSelect?.value || "opencode";
    const levels = [...reasoningLevels.querySelectorAll("[data-reasoning-level][aria-pressed='true']")].map(b => b.dataset.reasoningLevel);
    reasoningSaved.textContent = "Saving…";
    try {
      await api.updateProvider(provider.id, { models: [{ model: modelId, name: (provider.models.find(m => m.model === modelId) || {}).name || modelId, thinking: levels, reasoningFormat: format }] });
      provider.models = provider.models.map(m => m.model === modelId ? { ...m, thinking: levels } : m);
      reasoningSaved.textContent = "Saved. Run Build my config to apply.";
      notify("Reasoning saved for the selected model.", "success");
    } catch (error) {
      if (/doesn't exist|Not Found|404/.test(error.message)) { renderSettings(workspace); return; }
      reasoningSaved.textContent = error.message; notify(error.message, "error");
    }
  });

  workspace.querySelector("#settingsReasoningRemove")?.addEventListener("click", async () => {
    const provider = selectedProvider();
    const modelId = modelSelect?.value;
    if (!provider || !modelId) return;
    reasoningSaved.textContent = "Removing…";
    try {
      await api.deleteModel(provider.id, modelId);
      provider.models = (provider.models || []).filter(m => m.model !== modelId);
      reasoningSaved.textContent = `Removed ${modelId}.`;
      notify(`Removed ${modelId} from ${provider.name}.`, "success");
      replaceModelOptions(modelSelect, provider.models);
      syncSelectedModel();
    } catch (error) {
      if (/doesn't exist|Not Found|404/.test(error.message)) { renderSettings(workspace); return; }
      reasoningSaved.textContent = error.message; notify(error.message, "error");
    }
  });

  providerSelect?.addEventListener("change", syncSelectedProvider);
  modelSelect?.addEventListener("change", syncSelectedModel);
  syncSelectedProvider();

  const managerProvider = workspace.querySelector("#modelManagerProvider");
  const managerList = workspace.querySelector("#modelManagerList");
  const managerDelete = workspace.querySelector("#modelManagerDelete");
  const managerSelection = workspace.querySelector("#modelManagerSelection");
  const managerMessage = workspace.querySelector("#modelManagerMessage");
  const managerSelectedProvider = () => providers.find(provider => provider.id === managerProvider?.value) || null;
  const updateManagerSelection = () => {
    const count = managerList?.querySelectorAll("[data-manager-model]:checked").length || 0;
    if (managerSelection) managerSelection.textContent = `${count} selected`;
    if (managerDelete) managerDelete.disabled = count === 0;
  };
  const renderManagerModels = () => {
    if (!managerList) return;
    managerList.innerHTML = modelManagerRows(managerSelectedProvider());
    if (managerMessage) managerMessage.textContent = "";
    updateManagerSelection();
  };
  managerProvider?.addEventListener("change", renderManagerModels);
  managerList?.addEventListener("change", updateManagerSelection);
  managerDelete?.addEventListener("click", async () => {
    const provider = managerSelectedProvider();
    const selectedIds = [...managerList.querySelectorAll("[data-manager-model]:checked")].map(input => input.value);
    if (!provider || !selectedIds.length) return;
    managerDelete.disabled = true;
    managerDelete.textContent = "Deleting…";
    managerMessage.textContent = "";
    try {
      for (const modelId of selectedIds) await api.deleteModel(provider.id, modelId);
      provider.models = (provider.models || []).filter(model => !selectedIds.includes(model.model));
      if (provider.id === providerSelect?.value) syncSelectedProvider();
      renderManagerModels();
      managerMessage.textContent = `${selectedIds.length} model${selectedIds.length === 1 ? "" : "s"} deleted.`;
      notify(managerMessage.textContent, "success");
    } catch (error) {
      managerMessage.textContent = error.message;
      notify(error.message, "error");
    } finally {
      managerDelete.textContent = "Delete selected";
      updateManagerSelection();
    }
  });

  workspace.querySelector("#addModel")?.addEventListener("click", event => {
    const provider = selectedProvider();
    if (provider) openAddModelDialog(event.currentTarget, provider, formats, () => renderSettings(workspace));
  });

  workspace.querySelector("#settingsBuild")?.addEventListener("click", async event => {
    const button = event.currentTarget, output = workspace.querySelector("#settingsBuildOutput");
    button.disabled = true; output.textContent = "[running] Building configuration…";
    try {
      const result = await api.build(activeProfile || "coding");
      output.textContent = result.output || (result.ok ? "[ok] Build complete" : "[error] Build did not complete");
      notify(result.ok ? "Build complete." : "Build reported a problem.", result.ok ? "success" : "error");
    } catch (error) { output.textContent = `[error] ${error.message}`; notify(error.message, "error"); }
    finally { button.disabled = false; }
  });

  const savePreferences = async () => {
    const message = workspace.querySelector("#preferenceMessage");
    try {
      await api.updatePreferences({ activityRetentionDays: Number(workspace.querySelector("#retentionDays").value), requestContentRedaction: true, reducedMotion: workspace.querySelector("#motionPreference").value });
      message.textContent = "Preferences saved locally.";
    } catch (error) { message.textContent = error.message; }
  };
  workspace.querySelector("#preferenceForm")?.addEventListener("submit", event => { event.preventDefault(); savePreferences(); });
  workspace.querySelector("#retentionDays")?.addEventListener("change", savePreferences);
  workspace.querySelector("#motionPreference")?.addEventListener("change", event => { setMotionPreference(event.target.value); savePreferences(); });
}
