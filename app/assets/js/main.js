import { api } from "./core/api.js";
import { store } from "./core/store.js";
import { initRouter, navigate, mobileSidebarInert } from "./core/router.js";
import { initDesktopSidebar } from "./core/sidebar.js";
import { openAboutDialog } from "./core/about.js";
import { enterPage, initSidebarBrandMark, setMotionPreference } from "./core/motion.js";
import { escapeHtml, notify, openDialog } from "./core/dialog.js";
import { initCustomSelects } from "./core/custom-select.js";
import { initStartup, startupCanvasWidth, startupLayoutScale, welcomePreviewRequested } from "./pages/startup.js";
import { initOnboarding, onboardingPreviewScreen } from "./pages/onboarding.js";
import { renderOverview } from "./pages/overview.js";
import { renderProviders } from "./pages/providers.js";
import { renderActivity } from "./pages/activity.js";
import { renderIntegrations } from "./pages/integrations.js";
import { renderSettings } from "./pages/settings.js";

const pages = { overview: renderOverview, providers: renderProviders, activity: renderActivity, integrations: renderIntegrations, settings: renderSettings };
const startupView = document.querySelector("#startupView");
const appShell = document.querySelector("#appShell");
const workspace = document.querySelector("#workspace");

const AGENT_DISPLAY = { opencode: "OpenCode", kilo: "Kilo" };
const agentDisplayName = name => AGENT_DISPLAY[name] || name || "Local agent";

async function refreshAgentContext() {
  try {
    const [status, agents] = await Promise.all([api.status(), api.agents()]);
    store.set({ status });
    document.querySelector("#activeAgentName").textContent = agentDisplayName(agents.active || status.agent || "Local agent");
  } catch {
    document.querySelector("#activeAgentName").textContent = "Local agent";
  }
}

async function renderRoute(route, { focus = true } = {}) {
  store.set({ route });
  workspace.setAttribute("aria-busy", "true");
  try {
    await (pages[route] || renderOverview)(workspace);
  } catch (error) {
    workspace.innerHTML = `<div class="empty-state"><h1 class="page-title">This page could not load</h1><p>${escapeHtml(error.message)}</p><button class="button button--primary" type="button" data-route="${escapeHtml(route)}">Try again</button></div>`;
  } finally {
    workspace.removeAttribute("aria-busy");
    enterPage(workspace);
    if (focus) workspace.focus({ preventScroll: true });
    document.querySelector("#sidebar").classList.remove("is-open");
    document.querySelector("#sidebar").inert = mobileSidebarInert(window.innerWidth, false);
    document.querySelector("#menuButton").setAttribute("aria-expanded", "false");
  }
}

function showWorkspace() {
  startupView.hidden = true;
  appShell.hidden = false;
  refreshAgentContext();
  initRouter(renderRoute);
}

function openBuildDialog(trigger) {
  const { dialog } = openDialog({ title: "Run builder", trigger, content: `<p>The active agent's real builder will merge source files, back up the existing generated configuration, and show its complete output here.</p><pre id="buildOutput" class="terminal" aria-live="polite">Ready.</pre>`, actions: `<button class="button button--quiet" type="button" data-dialog-close>Close</button><button id="runBuild" class="button button--primary" type="button">Run build</button>`, wide: true });
  dialog.querySelector("#runBuild").addEventListener("click", async event => {
    const output = dialog.querySelector("#buildOutput");
    event.currentTarget.disabled = true;
    output.textContent = "Starting builderâ€¦";
    try {
      const result = await api.build("coding");
      output.textContent = result.output || (result.ok ? "Build complete." : "Build did not complete.");
      notify(result.ok ? "Build complete." : "Build reported a problem.", result.ok ? "success" : "error");
    } catch (error) { output.textContent = error.message; notify(error.message, "error"); }
    finally { event.currentTarget.disabled = false; }
  });
}

function fitStartup() {
  const scale = innerWidth < 900 ? 1 : startupLayoutScale(innerWidth, innerHeight);
  const onboardingScale = innerWidth < 900 ? 1 : Math.min(innerWidth / 1130, innerHeight / 503);
  document.documentElement.style.setProperty("--sf", String(scale));
  document.documentElement.style.setProperty("--startup-canvas-width", `${startupCanvasWidth(innerWidth, scale)}px`);
  document.documentElement.style.setProperty("--of", String(onboardingScale));
}

function bindShell() {
  fitStartup();
  window.addEventListener("resize", fitStartup);
  initSidebarBrandMark(document.querySelector("#sidebarBrandMark"));
  const menu = document.querySelector("#menuButton"), sidebar = document.querySelector("#sidebar");
  initDesktopSidebar({ shell: appShell, sidebar, toggle: document.querySelector("#sidebarCollapse") });
  const syncSidebar = open => {
    sidebar.classList.toggle("is-open", open);
    sidebar.inert = mobileSidebarInert(window.innerWidth, open);
    menu.setAttribute("aria-expanded", String(open));
  };
  syncSidebar(false);
  menu.addEventListener("click", () => syncSidebar(!sidebar.classList.contains("is-open")));
  window.addEventListener("resize", () => syncSidebar(window.innerWidth >= 900 ? false : sidebar.classList.contains("is-open")));
  document.querySelector("#globalBuildButton").addEventListener("click", event => openBuildDialog(event.currentTarget));
  document.querySelector('.sidebar-tool[aria-label="Toggle color theme"]').addEventListener("click", () => {
    const root = document.documentElement;
    const dark = root.getAttribute("data-theme") !== "dark";
    root.setAttribute("data-theme", dark ? "dark" : "light");
    try { localStorage.setItem("ai-switcher-theme", dark ? "dark" : "light"); } catch { /* private mode */ }
  });
  document.querySelector('.sidebar-tool[aria-label="About AI Switcher"]').addEventListener("click", event => openAboutDialog(event.currentTarget));
  try {
    if (localStorage.getItem("ai-switcher-theme") === "dark") document.documentElement.setAttribute("data-theme", "dark");
  } catch { /* private mode */ }
  document.addEventListener("ai-switcher:refresh", event => { if (event.detail === store.get().route || event.detail === "providers") renderRoute(store.get().route, { focus: false }); });
  document.addEventListener("ai-switcher:agent-changed", () => { refreshAgentContext(); navigate("overview"); });
}

async function boot() {
  bindShell();
  initCustomSelects(document);
  const onboardingScreen = onboardingPreviewScreen(window.location.search);
  if (onboardingScreen) {
    setMotionPreference("system");
    initOnboarding(startupView, showWorkspace, { screen: onboardingScreen, preview: true });
    return;
  }
  if (welcomePreviewRequested(window.location.search)) {
    setMotionPreference("system");
    initStartup(startupView, showWorkspace, { previewOnly: true });
    return;
  }
  try { const data = await api.preferences(); setMotionPreference((data.preferences || data).reducedMotion); } catch { setMotionPreference("system"); }
  try {
    const status = await api.status();
    store.set({ status });
  } catch (error) {
    notify("The local backend is not responding. Keep the AI Switcher window open and retry.", "error");
  }
  initStartup(startupView, showWorkspace);
}

boot();

