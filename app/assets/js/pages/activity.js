import { api, optional } from "../core/api.js";
import { escapeHtml } from "../core/dialog.js";
import { isClaude } from "../core/capabilities.js";
import { renderActivityWorkspace } from "./activity-workspace.js";

export const activityView = (events, error) => error ? "unavailable" : events.length ? "ready" : "empty";

export async function renderActivity(workspace) {
  if (isClaude()) {
    await renderRouteActivity(workspace);
    return;
  }
  const load = async days => {
    workspace.innerHTML = '<div class="card card--padded skeleton activity-loading"></div>';
    try {
      const [activityData, summary] = await Promise.all([
        api.activity(days, 250),
        optional(() => api.activitySummary(days), null),
      ]);
      const events = Array.isArray(activityData) ? activityData : (activityData.events || []);
      renderActivityWorkspace(workspace, { events, summary, days, onDaysChange: load });
    } catch (error) {
      workspace.innerHTML = `<div class="empty-state"><span class="status">Activity unavailable</span><h3>Local activity could not load</h3><p>${escapeHtml(error.message)}</p><button class="button button--primary" type="button" data-retry>Try again</button></div>`;
      workspace.querySelector("[data-retry]")?.addEventListener("click", () => load(days));
    }
  };

  await load(7);
}

async function renderRouteActivity(workspace) {
  workspace.innerHTML = '<div class="card card--padded skeleton activity-loading"></div>';
  try {
    const data = await api.claudeActivity(200);
    const events = Array.isArray(data.events) ? data.events : [];
    const rows = events.map(event => `<li class="claude-activity-row"><time class="muted mono">${escapeHtml(String(event.ts || "").slice(0, 19).replace("T", " "))}</time><span><strong>${escapeHtml(String(event.type || "").replaceAll("_", " "))}</strong>${event.routeId ? ` <span class="muted mono">${escapeHtml(event.routeId)}</span>` : ""}</span></li>`).join("");
    const typeCounts = events.reduce((counts, event) => { counts[event.type] = (counts[event.type] || 0) + 1; return counts; }, {});
    const typeChips = Object.entries(typeCounts).map(([type, count]) => `<span class="chip">${escapeHtml(String(type).replaceAll("_", " "))} · ${count}</span>`).join("");
    const chipbar = `<div class="claude-chipbar" aria-label="Route activity summary"><span class="chip chip--strong">${events.length} events</span>${typeChips}</div>`;
    workspace.innerHTML = `<div class="page-head"><div><p class="eyebrow">Analytics</p><h1 class="page-title">Route activity</h1><p class="page-intro">Switcher-controlled routing events only. No request, token, or latency telemetry is claimed for Claude Code.</p></div></div>${chipbar}${rows ? `<section class="card card--padded"><ul class="claude-activity-timeline">${rows}</ul></section>` : '<div class="empty-state"><h3>No routing activity yet</h3><p>Apply a route or restore a backup to see events here.</p></div>'}`;
  } catch (error) {
    workspace.innerHTML = `<div class="empty-state"><h3>Route activity unavailable</h3><p>${escapeHtml(error.message)}</p></div>`;
  }
}
