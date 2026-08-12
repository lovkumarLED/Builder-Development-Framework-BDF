const destinations = new Set(["overview", "providers", "activity", "integrations", "settings"]);
let renderDestination = null;

export function mobileSidebarInert(viewportWidth, open) {
  return viewportWidth < 900 && !open;
}

export function currentRoute() {
  const route = new URL(window.location.href).searchParams.get("view");
  return destinations.has(route) ? route : "overview";
}

export function navigate(route, { replace = false, focus = true } = {}) {
  if (!destinations.has(route)) route = "overview";
  const url = new URL(window.location.href);
  url.searchParams.set("view", route);
  window.history[replace ? "replaceState" : "pushState"]({ route }, "", url);
  document.querySelectorAll("[data-route]").forEach(button => {
    if (button.dataset.route === route) button.setAttribute("aria-current", "page");
    else button.removeAttribute("aria-current");
  });
  renderDestination?.(route, { focus });
}

export function initRouter(render) {
  renderDestination = render;
  document.addEventListener("click", event => {
    const control = event.target.closest("[data-route]");
    if (!control) return;
    navigate(control.dataset.route);
  });
  window.addEventListener("popstate", () => navigate(currentRoute(), { replace: true }));
  navigate(currentRoute(), { replace: true, focus: false });
}
