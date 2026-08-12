import { api, optional } from "../core/api.js";
import { store } from "../core/store.js";
import { escapeHtml, notify } from "../core/dialog.js";

const icon = {
  calendar: `<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3.5" y="5" width="17" height="15.5" rx="2.5"/><path d="M3.5 9.8h17M8 3v4M16 3v4"/></svg>`,
  chevronDown: `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m6.5 9.5 5.5 5.5 5.5-5.5"/></svg>`,
  chevronRight: `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9.5 6.5 5.5 5.5-5.5 5.5"/></svg>`,
  terminal: `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m5 7 5 5-5 5M12 17h7"/></svg>`,
  trendUp: `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3.5 16.5 9 11l3.5 3.5 7.5-7.5"/><path d="M15 7h5.5v5.5"/></svg>`,
  shield: `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3.2 19 6v5.2c0 4.2-2.8 7.9-7 9.6-4.2-1.7-7-5.4-7-9.6V6z"/><path d="m9.2 12 2 2 3.8-4.2"/></svg>`,
  clock: `<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2.2"/></svg>`,
  users: `<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="9" cy="8.6" r="3.4"/><path d="M3.2 19.4c.7-3.2 3-4.9 5.8-4.9s5.1 1.7 5.8 4.9"/><circle cx="17" cy="9.4" r="2.6"/><path d="M15.4 14.7c2.6.2 4.6 1.7 5.2 4.3"/></svg>`,
  arrowUp: `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 17 17 7M9 7h8v8"/></svg>`,
  arrowDown: `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 7l10 10M17 9v8H9"/></svg>`
};

const AGENT_DISPLAY = { opencode: "OpenCode", kilo: "Kilo" };
const LOGO_PALETTE = [
  ["#ff6d5d", "#f6574b"], ["#7b4bc1", "#6840bd"], ["#555acb", "#4449b5"],
  ["#45ad62", "#3c9a63"], ["#f0a53d", "#df922a"], ["#2e9e8f", "#26887b"],
  ["#e26a60", "#cf5a50"], ["#4a8fd3", "#3c7cba"],
];
const BRAND_LOGO = {
  omniroute: "/assets/brands/omniroute.svg",
  litellm: "/assets/brands/litellm.png",
  "cli-proxy": "/assets/brands/cli-proxy.svg",
  tokenrouter: "/assets/brands/tokenrouter.png",
  openrouter: "/assets/brands/openrouter.svg",
};

export function circularRelayIndex(index, delta, count) {
  if (count < 1) return 0;
  return ((index + delta) % count + count) % count;
}

export function relayDragStep(deltaY, threshold = 42) {
  if (Math.abs(deltaY) < threshold) return 0;
  return deltaY > 0 ? 1 : -1;
}

export function relayLayerProviders(providers, index) {
  const count = providers.length;
  if (!count) return { front: null, middle: null, back: null };
  return {
    front: providers[circularRelayIndex(index, 0, count)],
    middle: count > 1 ? providers[circularRelayIndex(index, 1, count)] : null,
    back: null,
  };
}

function generatedLogo(name, size = "md") {
  const clean = String(name || "?").trim();
  const hash = [...clean].reduce((sum, char) => (sum * 31 + char.charCodeAt(0)) >>> 0, 7);
  const [c1, c2] = LOGO_PALETTE[hash % LOGO_PALETTE.length];
  const initials = clean.split(/[\s_\-()]+/).filter(Boolean).slice(0, 2).map(word => word[0].toUpperCase()).join("") || "?";
  return `<span class="gen-logo gen-logo--${size}" style="background:linear-gradient(135deg, ${c1}, ${c2})" aria-hidden="true">${escapeHtml(initials)}</span>`;
}

function providerLogoMark(name, size = "md") {
  const clean = String(name || "").toLowerCase();
  const entry = Object.entries(BRAND_LOGO).find(([key]) => clean.includes(key));
  if (entry) {
    return `<span class="gen-logo gen-logo--${size} gen-logo--img" aria-hidden="true"><img src="${entry[1]}" alt=""></span>`;
  }
  return generatedLogo(name, size);
}

function header(agentName, days) {
  return `<div class="page-head overview-head"><h1 class="page-title">Workspace overview</h1><div class="page-controls">
    <label class="chip chip--select" for="overviewRange">${icon.calendar}<select id="overviewRange" aria-label="Overview date range"><option value="1" ${days === 1 ? "selected" : ""}>Last 24 hours</option><option value="7" ${days === 7 ? "selected" : ""}>Last 7 days</option><option value="30" ${days === 30 ? "selected" : ""}>Last 30 days</option></select>${icon.chevronDown}</label>
    <span class="chip"><span class="status-dot status-dot--ok" aria-hidden="true"></span>${escapeHtml(agentName)}</span>
    <span class="chip chip--mono">${icon.terminal}<span>127.0.0.1:9090</span></span>
  </div></div>`;
}

function relayProviderDetail(provider) {
  const modelCount = Array.isArray(provider.models) ? provider.models.length : 0;
  const active = Boolean(provider.active);
  return `<div class="relay-front__head">${providerLogoMark(provider.name)}<strong>${escapeHtml(provider.name)}</strong>${active ? '<span class="active-pill">Active</span>' : ""}</div>
      <dl class="relay-front__meta">
        <div><dt>Models</dt><dd>${modelCount} ${modelCount === 1 ? "model" : "models"}</dd></div>
        <div><dt>Endpoint</dt><dd class="mono">${escapeHtml(provider.baseUrl || "â€”")}</dd></div>
        <div><dt>SDK</dt><dd>${escapeHtml(provider.npm || "OpenAI-compatible")}</dd></div>
        <div><dt>Auth</dt><dd>${provider.hasKey ? "API key stored" : "No key"}</dd></div>
      </dl>
      <div class="relay-front__actions">${active ? '<button class="button button--danger" type="button" data-relay-action="deactivate">Remove provider</button>' : '<button class="button button--primary" type="button" data-relay-action="activate">Add provider</button>'}<button class="button button--outline" type="button" data-route="providers">View details</button></div>`;
}

function relayProviderMini(provider) {
  return `<div class="relay-mini">${providerLogoMark(provider.name, "sm")}<strong>${escapeHtml(provider.name)}</strong></div><div class="relay-incoming-detail" aria-hidden="true" inert>${relayProviderDetail(provider)}</div>`;
}

function relayStackMarkup(providers, index, activeId) {
  const { front, middle, back } = relayLayerProviders(providers, index);
  return `<div class="relay-stack">
    <div class="relay-stack__card relay-stack__card--back" aria-hidden="true">${back ? relayProviderMini(back) : ""}</div>
    ${middle ? `<div class="relay-stack__card relay-stack__card--middle">${relayProviderMini(middle)}</div>` : ""}
    <div class="relay-stack__card relay-stack__card--front">${relayProviderDetail(front)}</div>
  </div>`;
}

function relayCard(providers, activeId) {
  const ordered = [...providers].sort((a, b) => (a.id === activeId ? -1 : b.id === activeId ? 1 : 0));
  const card = document.createElement("article");
  card.className = "card relay-card";
  card.setAttribute("tabindex", "0");
  card.setAttribute("aria-label", "Provider relay â€” scroll to browse");
  if (!ordered.length) {
    card.innerHTML = `<h2 class="card-title">Your provider relay</h2>
      <div class="empty-state"><h3>No providers configured yet</h3><p>Add a provider (OmniRoute, LiteLLM, CLI Proxy, TokenRouter, OpenRouter, or any custom endpoint) and traffic through the local proxy will route through it.</p><button class="button button--primary" type="button" data-route="providers">Add a provider</button></div>`;
    return card;
  }
  const stack = document.createElement("div");
  stack.innerHTML = relayStackMarkup(ordered, 0, activeId);
  card.innerHTML = `<h2 class="card-title">Your provider relay</h2>`;
  card.append(stack.firstElementChild);
  const stackEl = card.querySelector(".relay-stack");
  let index = 0;
  let busy = false;
  let wheelDelta = 0;
  let wheelReset = 0;
  let drag = null;
  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  const clearDragPreview = () => {
    card.classList.remove("is-dragging");
    stackEl.querySelectorAll(".relay-stack__card").forEach(element => { element.style.transform = ""; });
  };

  const previewDrag = deltaY => {
    const amount = Math.min(1, Math.abs(deltaY) / 110);
    const direction = deltaY >= 0 ? 1 : -1;
    const front = stackEl.querySelector(".relay-stack__card--front");
    const incoming = stackEl.querySelector(direction > 0 || ordered.length === 2 ? ".relay-stack__card--middle" : ".relay-stack__card--back");
    if (front) {
      const scale = direction > 0 ? 1 + amount * 0.055 : 1 - amount * 0.035;
      front.style.transform = `translate3d(${direction * amount * 9}px, ${deltaY * 0.22}px, 0) scale(${scale})`;
    }
    if (incoming) {
      const x = direction > 0 ? amount * 14 : amount * 7;
      const y = direction > 0 ? amount * 22 : amount * 17;
      incoming.style.transform = `translate3d(${x}px, ${y}px, 0) scale(${1 + amount * 0.035})`;
    }
  };

  const step = delta => {
    if (busy || ordered.length < 2) return;
    const dir = delta > 0 ? 1 : -1;
    if (reduceMotion) {
      index = circularRelayIndex(index, dir, ordered.length);
      stackEl.innerHTML = relayStackMarkup(ordered, index, activeId);
      return;
    }
    busy = true;
    const motionClass = dir > 0 ? "is-stepping-forward" : "is-stepping-backward";
    const rearEntry = dir < 0 && ordered.length > 2;
    if (rearEntry) {
      const previous = ordered[circularRelayIndex(index, -1, ordered.length)];
      const backCard = stackEl.querySelector(".relay-stack__card--back");
      backCard.innerHTML = relayProviderMini(previous, activeId);
      backCard.removeAttribute("aria-hidden");
      card.classList.add("is-rear-entry");
    }
    card.classList.add(motionClass);
    window.setTimeout(() => {
      index = circularRelayIndex(index, dir, ordered.length);
      stackEl.innerHTML = relayStackMarkup(ordered, index, activeId);
      card.classList.remove(motionClass, "is-rear-entry");
      busy = false;
    }, 420);
  };

  card.addEventListener("wheel", event => {
    if (ordered.length < 2) return;
    event.preventDefault();
    if (busy) return;
    wheelDelta += event.deltaY;
    window.clearTimeout(wheelReset);
    wheelReset = window.setTimeout(() => { wheelDelta = 0; }, 140);
    if (Math.abs(wheelDelta) < 28) return;
    const direction = wheelDelta > 0 ? 1 : -1;
    wheelDelta = 0;
    step(direction);
  }, { passive: false });

  stackEl.addEventListener("pointerdown", event => {
    if (event.button !== 0 || busy || ordered.length < 2 || event.target.closest("button, a, input, select, textarea, [role='button']")) return;
    drag = { id: event.pointerId, startY: event.clientY, lastY: event.clientY };
    stackEl.setPointerCapture?.(event.pointerId);
    card.classList.add("is-dragging");
  });
  stackEl.addEventListener("pointermove", event => {
    if (!drag || event.pointerId !== drag.id) return;
    drag.lastY = event.clientY;
    const deltaY = drag.lastY - drag.startY;
    previewDrag(deltaY);
    if (Math.abs(deltaY) > 4) event.preventDefault();
  });
  const finishDrag = event => {
    if (!drag || event.pointerId !== drag.id) return;
    const deltaY = drag.lastY - drag.startY;
    const direction = relayDragStep(deltaY, 42);
    drag = null;
    if (direction) step(direction);
    clearDragPreview();
  };
  stackEl.addEventListener("pointerup", finishDrag);
  stackEl.addEventListener("pointercancel", event => {
    if (!drag || event.pointerId !== drag.id) return;
    drag = null;
    clearDragPreview();
  });

  card.addEventListener("keydown", event => {
    if (event.key === "ArrowDown" || event.key === "ArrowRight") { event.preventDefault(); step(1); }
    if (event.key === "ArrowUp" || event.key === "ArrowLeft") { event.preventDefault(); step(-1); }
  });

  stackEl.addEventListener("click", async event => {
    const button = event.target.closest("[data-relay-action]");
    if (!button || busy || !ordered.length) return;
    const provider = ordered[index];
    if (!provider) return;
    button.disabled = true;
    try {
      if (button.dataset.relayAction === "deactivate") {
        await api.deactivateProvider(provider.id);
        notify(`Removed ${provider.name} from the build.`, "success");
      } else {
        await api.activateProvider(provider.id);
        notify(`Added ${provider.name} to the build.`, "success");
      }
      document.dispatchEvent(new CustomEvent("ai-switcher:refresh", { detail: "overview" }));
    } catch (error) {
      notify(error.message, "error");
      button.disabled = false;
    }
  });
  return card;
}

function kpiCard(kpi, days) {
  return `<article class="card kpi"><span class="kpi__icon kpi__icon--${kpi.tone}">${icon[kpi.icon]}</span>
    <div class="kpi__value">${kpi.value}${kpi.unit ? `<small>${kpi.unit}</small>` : ""}</div>
    <div class="kpi__label">${kpi.label}</div>
    <div class="kpi__delta"><span class="kpi__note">${days === 1 ? "last 24 hours" : `last ${days} days`}</span></div>
  </article>`;
}

function kpiGrid(summary, days) {
  const latency = summary.medianLatencyMs != null ? String(summary.medianLatencyMs) : "â€”";
  const kpis = [
    { icon: "trendUp", tone: "coral", value: String(summary.requestCount || 0).replace(/\B(?=(\d{3})+(?!\d))/g, ","), unit: "", label: "API calls" },
    { icon: "shield", tone: "violet", value: `${summary.successRate ?? 0}%`, unit: "", label: "success rate" },
    { icon: "clock", tone: "violet", value: latency, unit: latency === "â€”" ? "" : "ms", label: "median latency" },
    { icon: "users", tone: "violet", value: String(summary.failedRequestCount ?? 0), unit: "", label: "failed requests" },
  ];
  return `<section class="kpi-grid" aria-label="Proxy activity summary">${kpis.map(kpi => kpiCard(kpi, days)).join("")}</section>`;
}

function emptyAnalytics() {
  return `<article class="card kpi-grid-empty"><div class="empty-state"><h3>No proxy traffic yet</h3><p>Requests made through the local proxy (127.0.0.1:9090) appear here with their metadata â€” request count, success rate, latency, and per-provider usage. Nothing is tracked until your tools actually talk to the proxy.</p></div></article>`;
}

function dayKey(date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
}

function startOfDay(date) {
  const copy = new Date(date);
  copy.setHours(0, 0, 0, 0);
  return copy;
}

function lineChart(events, days) {
  const W = 660, H = 168, L = 34, R = 6, T = 6, B = 24;
  const pw = W - L - R, ph = H - T - B;
  const pointCount = days === 1 ? 7 : days === 7 ? 7 : 10;
  const end = Date.now(), start = end - days * 86400000, bucketSize = (end - start) / pointCount;
  const buckets = Array.from({ length: pointCount }, (_, index) => new Date(start + bucketSize * index));
  const counts = buckets.map(() => ({ success: 0, failed: 0 }));
  for (const event of events) {
    const date = new Date(event.timestamp);
    if (Number.isNaN(date.getTime())) continue;
    const index = Math.max(0, Math.min(pointCount - 1, Math.floor((date.getTime() - start) / bucketSize)));
    if (typeof event.status === "number" && event.status >= 400) counts[index].failed += 1;
    else counts[index].success += 1;
  }
  const peak = Math.max(1, ...counts.flatMap(c => [c.success, c.failed]));
  const y = v => T + ph - (v / peak) * ph;
  const x = i => L + (i / (pointCount - 1)) * pw;
  const toPath = arr => arr.map((v, i) => `${i ? "L" : "M"}${x(i).toFixed(1)} ${y(v).toFixed(1)}`).join("");
  const grid = [0, 0.25, 0.5, 0.75, 1].map(frac => {
    const value = Math.round(peak * frac);
    return `<line class="lc-grid" x1="${L}" x2="${W - R}" y1="${y(value).toFixed(1)}" y2="${y(value).toFixed(1)}"/><text class="lc-ylabel" x="${L - 8}" y="${(y(value) + 3.5).toFixed(1)}" text-anchor="end">${value}</text>`;
  }).join("");
  const xlabels = buckets.map((date, i) => `<text class="lc-xlabel" x="${x(i).toFixed(1)}" y="${H - 6}" text-anchor="middle">${days === 1 ? date.toLocaleTimeString("en-US", { hour: "numeric" }) : `${date.toLocaleString("en-US", { weekday: "short" })} ${date.getDate()}`}</text>`).join("");
  return `<article class="card chart-card">
    <div class="card-head"><h2 class="card-title">Requests over time</h2><div class="chart-legend"><span class="chart-legend__item"><i class="lc-swatch lc-swatch--success"></i>Successful</span><span class="chart-legend__item"><i class="lc-swatch lc-swatch--failed"></i>Failed</span></div></div>
    <svg class="line-chart" viewBox="0 0 ${W} ${H}" role="img" aria-label="Line chart of successful and failed requests over the selected range">
      ${grid}${xlabels}
      <path class="lc-line lc-line--failed" d="${toPath(counts.map(c => c.failed))}"/>
      <path class="lc-line lc-line--success" d="${toPath(counts.map(c => c.success))}"/>
    </svg>
  </article>`;
}

function usageCard(events) {
  const size = 204, c = size / 2, r = 76.5, C = 2 * Math.PI * r, gap = 2.5;
  const tally = {};
  for (const event of events) {
    const key = String(event.providerId || "unknown");
    tally[key] = (tally[key] || 0) + 1;
  }
  const rows = Object.entries(tally).sort((a, b) => b[1] - a[1]).slice(0, 4);
  const total = rows.reduce((sum, [, count]) => sum + count, 0);
  let acc = 0;
  const segments = rows.map(([name, count], index) => {
    const frac = count / total;
    const len = Math.max(0, frac * C - gap);
    const start = acc * 360 - 90;
    const mid = (acc + frac / 2) * 360 - 90;
    acc += frac;
    const rad = mid * Math.PI / 180;
    const lx = c + r * Math.cos(rad), ly = c + r * Math.sin(rad);
    return `<circle class="donut-seg donut-seg--${index}" cx="${c}" cy="${c}" r="${r}" stroke-dasharray="${len.toFixed(1)} ${(C - len).toFixed(1)}" transform="rotate(${start.toFixed(1)} ${c} ${c})"/><text class="donut-pct" x="${lx.toFixed(1)}" y="${ly.toFixed(1)}" text-anchor="middle" dominant-baseline="central">${Math.round(frac * 100)}%</text>`;
  }).join("");
  const legend = rows.map(([name, count], index) => `<li class="usage-row"><span class="usage-row__name"><i class="usage-chip usage-chip--${index}"></i>${escapeHtml(name)}</span><span class="usage-row__pct">${Math.round((count / total) * 100)}%</span><span class="usage-row__count">${count.toLocaleString("en-US")}</span></li>`).join("");
  return `<article class="card usage-card"><h2 class="card-title">Provider usage</h2>
    <div class="usage-body">
      <svg class="usage-donut" viewBox="0 0 ${size} ${size}" role="img" aria-label="Provider usage donut by request count">${segments}</svg>
      <ul class="usage-legend">${legend}<li class="usage-row usage-row--total"><span class="usage-row__name">Total</span><span class="usage-row__pct"></span><span class="usage-row__count">${total.toLocaleString("en-US")}</span></li></ul>
    </div>
  </article>`;
}

function formatTime(iso) {
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "â€”";
  return date.toLocaleString("en-US", { month: "short", day: "numeric", year: "numeric", hour: "2-digit", minute: "2-digit", second: "2-digit", hour12: true });
}

function recentCard(events) {
  const rows = events.slice(0, 5).map(call => {
    const ok = typeof call.status !== "number" || call.status < 400;
    const latency = typeof call.latencyMs === "number" ? `${call.latencyMs} ms` : "â€”";
    return `<tr>
      <td class="col-time">${escapeHtml(formatTime(call.timestamp))}</td>
      <td><span class="provider-cell">${providerLogoMark(call.providerId || "unknown", "sm")}${escapeHtml(call.providerId || "unknown")}</span></td>
      <td class="col-model">${escapeHtml(call.model || "â€”")}</td>
      <td><span class="status-cell"><span class="status-dot ${ok ? "status-dot--ok" : "status-dot--error"}" aria-hidden="true"></span>${ok ? "Success" : `Failed (${call.status})`}</span></td>
      <td class="col-latency">${escapeHtml(latency)}</td>
    </tr>`;
  }).join("");
  return `<article class="card recent-card"><h2 class="card-title">Recent proxy calls</h2>
    <table class="data-table recent-table"><thead><tr><th>Time</th><th>Provider</th><th>Model</th><th>Status</th><th class="col-latency">Latency</th></tr></thead><tbody>${rows}</tbody></table>
    <div class="table-foot"><span class="table-foot__count">Showing 1\u2013${Math.min(5, events.length)} of ${events.length}</span><button class="view-all" type="button" data-route="activity">View all${icon.chevronRight}</button></div>
  </article>`;
}

export async function renderOverview(workspace, days = 7) {
  const [providerData, summaryData, events, statusData] = await Promise.all([
    optional(() => api.providers(), { providers: [], activeProvider: null }),
    optional(() => api.activitySummary(days), { requestCount: 0, failedRequestCount: 0, successRate: 0, medianLatencyMs: null }),
    optional(() => api.activity(days, 100), []),
    optional(() => api.status(), { agent: null }),
  ]);
  const providers = Array.isArray(providerData.providers) ? providerData.providers : [];
  const hasActivity = (summaryData.requestCount || 0) > 0 && Array.isArray(events) && events.length > 0;
  const agentName = AGENT_DISPLAY[statusData.agent] || statusData.agent || "Local agent";
  store.set({ providers, activeProvider: providerData.activeProvider });
  workspace.innerHTML = `${header(agentName, days)}<div class="overview-masonry"><div id="relayMount"></div>${hasActivity ? kpiGrid(summaryData, days) : emptyAnalytics()}${hasActivity ? lineChart(events, days) : ""}${hasActivity ? usageCard(events) : ""}</div>${hasActivity ? recentCard(events) : ""}`;
  const mount = workspace.querySelector("#relayMount");
  if (mount) mount.replaceWith(relayCard(providers, providerData.activeProvider));
  workspace.querySelector("#overviewRange")?.addEventListener("change", event => renderOverview(workspace, Number(event.target.value)));
}
