let openInstance = null;
let selectCounter = 0;
const selectInstances = new WeakMap();

function shouldCloseSelectOnScroll(target, instance) {
  if (!instance) return false;
  const { menu } = instance;
  return target !== menu && !menu.contains(target);
}

function closeOpen({ focus = false } = {}) {
  if (!openInstance) return;
  const { trigger, menu } = openInstance;
  trigger.setAttribute("aria-expanded", "false");
  menu.hidden = true;
  if (focus && trigger.isConnected) trigger.focus();
  openInstance = null;
}

function positionMenu(trigger, menu) {
  const rect = trigger.getBoundingClientRect();
  const preferredWidth = menu.dataset.selectId === "settingsModel" ? 320 : rect.width;
  const width = Math.min(window.innerWidth - 16, Math.max(190, rect.width, preferredWidth));
  menu.style.width = `${width}px`;
  menu.style.left = `${Math.max(8, Math.min(window.innerWidth - width - 8, rect.left))}px`;
  menu.hidden = false;
  const menuHeight = menu.getBoundingClientRect().height;
  const below = window.innerHeight - rect.bottom;
  menu.style.top = `${below >= menuHeight + 8 ? rect.bottom + 6 : Math.max(8, rect.top - menuHeight - 6)}px`;
}

function enhanceSelect(nativeSelect) {
  if (nativeSelect.dataset.customSelectReady === "true") return;
  nativeSelect.dataset.customSelectReady = "true";

  const wrapper = document.createElement("span");
  wrapper.className = "custom-select";
  const trigger = document.createElement("button");
  trigger.className = "custom-select__trigger";
  trigger.type = "button";
  trigger.setAttribute("role", "combobox");
  trigger.setAttribute("aria-haspopup", "listbox");
  trigger.setAttribute("aria-expanded", "false");
  trigger.disabled = nativeSelect.disabled;

  const value = document.createElement("span");
  value.className = "custom-select__value";
  const chevron = document.createElement("span");
  chevron.className = "custom-select__chevron";
  chevron.setAttribute("aria-hidden", "true");
  chevron.innerHTML = '<svg viewBox="0 0 20 20"><path d="m5.5 7.5 4.5 4.5 4.5-4.5"/></svg>';
  trigger.append(value, chevron);

  const menu = document.createElement("div");
  menu.className = `custom-select__menu${nativeSelect.closest(".onboarding-window") ? " custom-select__menu--dark" : ""}`;
  menu.id = `customSelectMenu${++selectCounter}`;
  menu.dataset.selectId = nativeSelect.id;
  menu.setAttribute("role", "listbox");
  menu.hidden = true;
  trigger.setAttribute("aria-controls", menu.id);

  const label = nativeSelect.getAttribute("aria-label") || document.querySelector(`label[for="${CSS.escape(nativeSelect.id)}"]`)?.textContent.trim();
  if (label) trigger.setAttribute("aria-label", label);

  let options = [];

  const sync = () => {
    value.textContent = nativeSelect.selectedOptions[0]?.textContent || "Select";
    options.forEach((option, index) => option.setAttribute("aria-selected", String(index === nativeSelect.selectedIndex)));
  };
  const buildOptions = () => {
    menu.replaceChildren();
    options = [...nativeSelect.options].map((nativeOption, index) => {
      const option = document.createElement("button");
      option.className = "custom-select__option";
      option.type = "button";
      option.setAttribute("role", "option");
      option.dataset.value = nativeOption.value;
      option.dataset.index = String(index);
      option.disabled = nativeOption.disabled;
      const optionText = document.createElement("span");
      optionText.textContent = nativeOption.textContent;
      const check = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      check.setAttribute("viewBox", "0 0 20 20");
      check.setAttribute("aria-hidden", "true");
      check.innerHTML = '<path d="m4.5 10 3.3 3.3 7.7-7.6"/>';
      option.append(optionText, check);
      menu.append(option);
      return option;
    });
    sync();
  };
  const focusOption = index => options[Math.max(0, Math.min(options.length - 1, index))]?.focus();
  const open = initialIndex => {
    closeOpen();
    trigger.setAttribute("aria-expanded", "true");
    positionMenu(trigger, menu);
    openInstance = { trigger, menu };
    requestAnimationFrame(() => focusOption(initialIndex ?? Math.max(0, nativeSelect.selectedIndex)));
  };
  const choose = option => {
    nativeSelect.value = option.dataset.value;
    sync();
    closeOpen({ focus: true });
    nativeSelect.dispatchEvent(new Event("change", { bubbles: true }));
  };

  trigger.addEventListener("click", event => {
    event.preventDefault();
    event.stopPropagation();
    if (openInstance?.trigger === trigger) closeOpen();
    else open(nativeSelect.selectedIndex);
  });
  trigger.addEventListener("keydown", event => {
    if (event.key === "ArrowDown") { event.preventDefault(); open(nativeSelect.selectedIndex + 1); }
    if (event.key === "ArrowUp") { event.preventDefault(); open(nativeSelect.selectedIndex - 1); }
    if (event.key === "Home") { event.preventDefault(); open(0); }
    if (event.key === "End") { event.preventDefault(); open(options.length - 1); }
    if (event.key === "Escape") closeOpen();
  });
  menu.addEventListener("click", event => {
    const option = event.target.closest(".custom-select__option");
    if (option && !option.disabled) choose(option);
  });
  menu.addEventListener("keydown", event => {
    const current = Number(event.target.closest(".custom-select__option")?.dataset.index ?? nativeSelect.selectedIndex);
    if (event.key === "ArrowDown") { event.preventDefault(); focusOption((current + 1) % options.length); }
    if (event.key === "ArrowUp") { event.preventDefault(); focusOption((current - 1 + options.length) % options.length); }
    if (event.key === "Home") { event.preventDefault(); focusOption(0); }
    if (event.key === "End") { event.preventDefault(); focusOption(options.length - 1); }
    if (event.key === "Escape") { event.preventDefault(); closeOpen({ focus: true }); }
    if (["Enter", " "].includes(event.key)) { const option = event.target.closest(".custom-select__option"); if (option) { event.preventDefault(); choose(option); } }
  });
  nativeSelect.addEventListener("change", sync);
  nativeSelect.addEventListener("ai-switcher:options-changed", buildOptions);

  nativeSelect.before(wrapper);
  wrapper.append(trigger, nativeSelect);
  document.body.append(menu);
  selectInstances.set(nativeSelect, { trigger, menu });
  nativeSelect.hidden = true;
  buildOptions();
}

export function initCustomSelects(root = document) {
  root.querySelectorAll("select").forEach(enhanceSelect);
  const observer = new MutationObserver(records => {
    for (const record of records) {
      for (const node of record.addedNodes) {
        if (!(node instanceof Element)) continue;
        if (node.matches("select")) enhanceSelect(node);
        node.querySelectorAll?.("select").forEach(enhanceSelect);
      }
      for (const node of record.removedNodes) {
        if (!(node instanceof Element)) continue;
        const removedSelects = [...(node.matches("select") ? [node] : []), ...node.querySelectorAll("select")];
        for (const select of removedSelects) {
          if (select.isConnected) continue;
          const instance = selectInstances.get(select);
          if (!instance) continue;
          if (openInstance?.trigger === instance.trigger) closeOpen();
          instance.menu.remove();
          selectInstances.delete(select);
        }
      }
    }
  });
  observer.observe(root === document ? document.body : root, { childList: true, subtree: true });
  document.addEventListener("pointerdown", event => { if (openInstance && !openInstance.trigger.contains(event.target) && !openInstance.menu.contains(event.target)) closeOpen(); });
  document.addEventListener("scroll", event => { if (shouldCloseSelectOnScroll(event.target, openInstance)) closeOpen(); }, true);
  window.addEventListener("resize", () => closeOpen());
  return observer;
}
