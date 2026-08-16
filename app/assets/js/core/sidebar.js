const DESKTOP_MIN_WIDTH = 1200;
const STORAGE_KEY = "ai-switcher-sidebar-collapsed";

export const desktopSidebarAvailable = width => Number(width) >= DESKTOP_MIN_WIDTH;
export const nextSidebarCollapsed = collapsed => !collapsed;

export function applyCapabilityNavigation(capabilities) {
  const claude = Boolean(capabilities) && capabilities.providerMode === "scalar-route";
  document.querySelectorAll(".primary-nav [data-route]").forEach(button => {
    const label = button.querySelector("span:last-child");
    if (button.dataset.route === "providers" && label) {
      label.textContent = claude ? "Routes" : "Providers";
    }
    if (button.dataset.route === "integrations") {
      button.hidden = claude;
      button.setAttribute("aria-hidden", String(claude));
    }
  });
  const buildButton = document.getElementById("globalBuildButton");
  if (buildButton) {
    const available = Boolean(capabilities) && capabilities.builderAvailable === true;
    buildButton.hidden = !available;
    buildButton.setAttribute("aria-hidden", String(!available));
  }
}

export function initDesktopSidebar({ shell, sidebar, toggle, win = window }) {
  let collapsed = false;
  try { collapsed = win.localStorage.getItem(STORAGE_KEY) === "true"; } catch { /* private mode */ }

  const apply = () => {
    const available = desktopSidebarAvailable(win.innerWidth);
    shell.classList.toggle("is-sidebar-collapsed", available && collapsed);
    toggle.hidden = !available;
    toggle.setAttribute("aria-expanded", String(!(available && collapsed)));
    toggle.setAttribute("aria-label", available && collapsed ? "Expand sidebar" : "Collapse sidebar");
    sidebar.dataset.collapsed = String(available && collapsed);
  };

  toggle.addEventListener("click", () => {
    if (!desktopSidebarAvailable(win.innerWidth)) return;
    collapsed = nextSidebarCollapsed(collapsed);
    try { win.localStorage.setItem(STORAGE_KEY, String(collapsed)); } catch { /* private mode */ }
    apply();
  });
  win.addEventListener("resize", apply);
  apply();

  return { apply, isCollapsed: () => collapsed };
}
