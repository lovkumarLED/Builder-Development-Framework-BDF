import { api, optional } from "../core/api.js";
import { escapeHtml } from "../core/dialog.js";
import { renderActivityWorkspace } from "./activity-workspace.js";

export const activityView = (events, error) => error ? "unavailable" : events.length ? "ready" : "empty";

export async function renderActivity(workspace) {
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
