let savedPreference = "system";
export const motionIsReduced = (preference, osReduced) => preference === "reduce" || (preference === "system" && osReduced);
export function setMotionPreference(preference = "system") { savedPreference = preference === "reduce" ? "reduce" : "system"; document.documentElement.dataset.motion = savedPreference; }
export const reducedMotion = () => motionIsReduced(savedPreference, window.matchMedia?.("(prefers-reduced-motion: reduce)").matches ?? false);

export function startupPointerPose(clientX, clientY, rect) {
  const clamp = value => Math.max(-1, Math.min(1, value));
  return {
    x: clamp(((clientX - rect.left) / rect.width) * 2 - 1),
    y: clamp(((clientY - rect.top) / rect.height) * 2 - 1),
  };
}

export function startupAtmospherePose(clientX, clientY, rect, dragging = false) {
  const { x, y } = startupPointerPose(clientX, clientY, rect);
  return { x, y, force: dragging ? 1 : .42, cursorX: (x + 1) * 50, cursorY: (y + 1) * 50 };
}

export function initStartupAtmosphere(host, atmosphere) {
  if (!host || !atmosphere) return;
  let frame = 0;
  let dragging = false;
  let target = { x: 0, y: 0, force: .42 };
  let current = { x: 0, y: 0, force: .42 };

  const schedule = () => { if (!frame) frame = requestAnimationFrame(render); };
  const render = () => {
    frame = 0;
    current.x += (target.x - current.x) * .075;
    current.y += (target.y - current.y) * .075;
    current.force += (target.force - current.force) * .09;
    const x = current.x * 64 * current.force;
    const y = current.y * 46 * current.force;
    atmosphere.style.setProperty("--ambient-x", `${x.toFixed(2)}px`);
    atmosphere.style.setProperty("--ambient-y", `${y.toFixed(2)}px`);
    atmosphere.style.setProperty("--ambient-x-reverse", `${(-x * .72).toFixed(2)}px`);
    atmosphere.style.setProperty("--ambient-y-reverse", `${(-y * .58).toFixed(2)}px`);
    atmosphere.style.setProperty("--ambient-energy", current.force.toFixed(3));
    atmosphere.style.setProperty("--ambient-cursor-x", `${(50 + current.x * 48).toFixed(2)}%`);
    atmosphere.style.setProperty("--ambient-cursor-y", `${(50 + current.y * 48).toFixed(2)}%`);
    atmosphere.style.setProperty("--ambient-cursor-x-reverse", `${(50 - current.x * 38).toFixed(2)}%`);
    atmosphere.style.setProperty("--ambient-cursor-y-reverse", `${(50 - current.y * 34).toFixed(2)}%`);
    atmosphere.style.setProperty("--ambient-cursor-alpha", (.2 + current.force * .34).toFixed(3));
    if (Math.abs(target.x - current.x) > .001 || Math.abs(target.y - current.y) > .001 || Math.abs(target.force - current.force) > .001) schedule();
  };
  const track = event => {
    if (reducedMotion() || event.pointerType === "touch") return;
    target = startupAtmospherePose(event.clientX, event.clientY, host.getBoundingClientRect(), dragging);
    schedule();
  };
  const release = () => {
    dragging = false;
    atmosphere.classList.remove("is-dragging");
    target.force = .42;
    schedule();
  };

  host.addEventListener("pointermove", track);
  host.addEventListener("pointerdown", event => {
    if (reducedMotion() || event.pointerType === "touch" || event.target.closest("button, a, input, select, textarea")) return;
    dragging = true;
    atmosphere.classList.add("is-dragging");
    target = startupAtmospherePose(event.clientX, event.clientY, host.getBoundingClientRect(), true);
    schedule();
  });
  host.addEventListener("pointerleave", release);
  window.addEventListener("pointerup", release);
}

export function sidebarBrandBurstPlan(count = 8, random = Math.random) {
  return Array.from({ length: count }, (_, index) => ({
    angle: random() * Math.PI * 2,
    distance: 18 + random() * 26,
    size: 3 + random() * 4,
    delay: random() * 55,
    duration: 430 + random() * 250,
    color: index % 2 ? "var(--plum)" : "var(--coral)",
  }));
}

export function initSidebarBrandMark(mark) {
  if (!mark) return;
  let frame = 0;
  let target = { x: 0, y: 0 };
  let current = { x: 0, y: 0 };
  let lastBurst = 0;

  const schedule = () => { if (!frame) frame = requestAnimationFrame(render); };
  const render = () => {
    frame = 0;
    current.x += (target.x - current.x) * .18;
    current.y += (target.y - current.y) * .18;
    const energy = Math.min(1, Math.hypot(current.x, current.y));
    mark.style.setProperty("--brand-x", `${(current.x * 2.4).toFixed(2)}px`);
    mark.style.setProperty("--brand-y", `${(current.y * 2).toFixed(2)}px`);
    mark.style.setProperty("--brand-tilt-x", `${(-current.y * 8).toFixed(2)}deg`);
    mark.style.setProperty("--brand-tilt-y", `${(current.x * 10).toFixed(2)}deg`);
    mark.style.setProperty("--brand-glow", `${(7 + energy * 8).toFixed(1)}px`);
    if (Math.abs(target.x - current.x) > .002 || Math.abs(target.y - current.y) > .002) schedule();
  };

  mark.addEventListener("pointermove", event => {
    if (reducedMotion() || event.pointerType === "touch") return;
    target = startupPointerPose(event.clientX, event.clientY, mark.getBoundingClientRect());
    schedule();
  });
  mark.addEventListener("pointerleave", () => {
    target = { x: 0, y: 0 };
    schedule();
  });
  mark.addEventListener("click", event => {
    if (reducedMotion()) {
      mark.animate([{ opacity: .78 }, { opacity: 1 }], { duration: 120 });
      return;
    }
    const now = Date.now();
    if (now - lastBurst < 320) return;
    lastBurst = now;
    const rect = mark.getBoundingClientRect();
    const hasPointer = Number.isFinite(event.clientX) && event.clientX > 0;
    const originX = hasPointer ? Math.max(12, Math.min(88, ((event.clientX - rect.left) / rect.width) * 100)) : 50;
    const originY = hasPointer ? Math.max(12, Math.min(88, ((event.clientY - rect.top) / rect.height) * 100)) : 50;

    mark.classList.remove("is-pulsing");
    void mark.offsetWidth;
    mark.classList.add("is-pulsing");
    window.setTimeout(() => mark.classList.remove("is-pulsing"), 650);

    const ripple = document.createElement("span");
    ripple.className = "sidebar-brand-ripple";
    ripple.style.setProperty("--origin-x", `${originX}%`);
    ripple.style.setProperty("--origin-y", `${originY}%`);
    mark.append(ripple);
    ripple.addEventListener("animationend", () => ripple.remove(), { once: true });

    sidebarBrandBurstPlan().forEach(particle => {
      const bubble = document.createElement("span");
      bubble.className = "sidebar-brand-bubble";
      bubble.style.setProperty("--origin-x", `${originX}%`);
      bubble.style.setProperty("--origin-y", `${originY}%`);
      bubble.style.setProperty("--size", `${particle.size}px`);
      bubble.style.setProperty("--x", `${Math.cos(particle.angle) * particle.distance}px`);
      bubble.style.setProperty("--y", `${Math.sin(particle.angle) * particle.distance}px`);
      bubble.style.setProperty("--delay", `${particle.delay}ms`);
      bubble.style.setProperty("--duration", `${particle.duration}ms`);
      bubble.style.setProperty("--bubble", particle.color);
      mark.append(bubble);
      bubble.addEventListener("animationend", () => bubble.remove(), { once: true });
    });
  });
}

export function enterPage(element) {
  element.classList.remove("page-enter");
  if (reducedMotion()) return;
  requestAnimationFrame(() => element.classList.add("page-enter"));
}

export function initStartupMark(mark, signal = null) {
  if (!mark) return;
  const art = mark.closest(".startup-art") || mark;
  const paths = [...mark.querySelectorAll("svg > path")];
  const signalPaths = signal ? [...signal.querySelectorAll(".trace")] : [];
  const signalNodes = signal ? [...signal.querySelectorAll(".signal-node")] : [];
  let frame = 0;
  let active = false;
  let target = { x: 0, y: 0 };
  let current = { x: 0, y: 0 };
  let lastBurst = 0;

  const schedule = () => { if (!frame) frame = requestAnimationFrame(render); };
  const render = () => {
    frame = 0;
    current.x += (target.x - current.x) * .14;
    current.y += (target.y - current.y) * .14;
    const { x, y } = current;
    const energy = active ? .56 + Math.min(1, Math.hypot(x, y)) * .44 : Math.min(1, Math.hypot(x, y)) * .25;

    mark.style.setProperty("--mark-x", `${(x * 5).toFixed(2)}px`);
    mark.style.setProperty("--mark-y", `${(y * 4).toFixed(2)}px`);
    mark.style.setProperty("--tilt-x", `${(-y * 7).toFixed(2)}deg`);
    mark.style.setProperty("--tilt-y", `${(x * 9).toFixed(2)}deg`);
    mark.style.setProperty("--coral-glow", `${(12 + energy * 22).toFixed(1)}px`);
    mark.style.setProperty("--plum-glow", `${(12 + energy * 25).toFixed(1)}px`);

    if (paths[0]) paths[0].style.transform = `translate3d(${(x * 7).toFixed(2)}px, ${(y * 5).toFixed(2)}px, 22px) rotate(${(x * 2.2).toFixed(2)}deg)`;
    if (paths[1]) paths[1].style.transform = `translate3d(${(-x * 5).toFixed(2)}px, ${(-y * 3.5).toFixed(2)}px, 8px) rotate(${(-x * 2.6).toFixed(2)}deg)`;

    signalPaths.forEach((path, index) => {
      const direction = index ? 1 : -1;
      path.style.transform = `translate3d(${(x * 2.5 * direction).toFixed(2)}px, ${(y * 1.5).toFixed(2)}px, 0)`;
      path.style.opacity = (.76 + energy * .2).toFixed(2);
      path.style.filter = `drop-shadow(0 0 ${(5 + energy * 9).toFixed(1)}px ${index ? "rgb(132 72 113 / 75%)" : "rgb(255 97 85 / 78%)"})`;
    });
    signalNodes.forEach((node, index) => {
      const direction = index ? 1 : -1;
      node.style.transform = `translate3d(${(x * 5 * direction).toFixed(2)}px, ${(y * 3).toFixed(2)}px, 0)`;
      node.style.opacity = (.82 + energy * .18).toFixed(2);
    });

    if (Math.abs(target.x - current.x) > .002 || Math.abs(target.y - current.y) > .002) schedule();
  };

  const track = event => {
    if (reducedMotion() || event.pointerType === "touch") return;
    active = true;
    target = startupPointerPose(event.clientX, event.clientY, mark.getBoundingClientRect());
    signal?.classList.add("is-tracking");
    schedule();
  };

  const reset = () => {
    active = false;
    target = { x: 0, y: 0 };
    signal?.classList.remove("is-tracking");
    schedule();
  };

  const burst = event => {
    if (reducedMotion()) {
      mark.animate([{ opacity: .74 }, { opacity: 1 }], { duration: 120 });
      return;
    }
    const now = Date.now();
    if (now - lastBurst < 450) return;
    lastBurst = now;
    const rect = mark.getBoundingClientRect();
    const pointerOrigin = Number.isFinite(event?.clientX) && event.clientX > 0;
    const originX = pointerOrigin ? Math.max(8, Math.min(92, ((event.clientX - rect.left) / rect.width) * 100)) : 50;
    const originY = pointerOrigin ? Math.max(8, Math.min(92, ((event.clientY - rect.top) / rect.height) * 100)) : 50;

    mark.classList.remove("is-pulsing");
    signal?.classList.remove("is-energized");
    void mark.offsetWidth;
    mark.classList.add("is-pulsing");
    signal?.classList.add("is-energized");
    window.setTimeout(() => {
      mark.classList.remove("is-pulsing");
      signal?.classList.remove("is-energized");
    }, 900);

    paths.forEach((path, index) => {
      const direction = index ? 1 : -1;
      path.animate([
        { transform: path.style.transform || "none" },
        { transform: `translate3d(${direction * 18}px, ${index ? 7 : -7}px, 34px) rotate(${direction * 7}deg) scale(1.045)` },
        { transform: path.style.transform || "none" },
      ], { duration: 820, easing: "cubic-bezier(.16,1,.3,1)" });
    });

    for (let index = 0; index < 2; index += 1) {
      const ripple = document.createElement("span");
      ripple.className = "burst-ripple";
      ripple.style.setProperty("--origin-x", `${originX}%`);
      ripple.style.setProperty("--origin-y", `${originY}%`);
      ripple.style.setProperty("--delay", `${index * 90}ms`);
      ripple.style.setProperty("--ripple-scale", String(7 + index * 2.5));
      ripple.style.setProperty("--ripple-color", index ? "var(--plum)" : "var(--coral)");
      mark.append(ripple);
      ripple.addEventListener("animationend", () => ripple.remove(), { once: true });
    }

    const room = Math.max(0, 28 - mark.querySelectorAll(".burst-bubble").length);
    const count = Math.min(room, 14 + Math.floor(Math.random() * 5));
    for (let index = 0; index < count; index += 1) {
      const bubble = document.createElement("span");
      const angle = Math.random() * Math.PI * 2;
      const distance = 70 + Math.random() * 120;
      bubble.className = "burst-bubble";
      bubble.style.setProperty("--origin-x", `${originX}%`);
      bubble.style.setProperty("--origin-y", `${originY}%`);
      bubble.style.setProperty("--size", `${4 + Math.random() * 11}px`);
      bubble.style.setProperty("--x", `${Math.cos(angle) * distance}px`);
      bubble.style.setProperty("--y", `${Math.sin(angle) * distance}px`);
      bubble.style.setProperty("--duration", `${620 + Math.random() * 520}ms`);
      bubble.style.setProperty("--delay", `${Math.random() * 90}ms`);
      bubble.style.setProperty("--end-scale", `${.7 + Math.random() * .9}`);
      bubble.style.setProperty("--bubble", index % 2 ? "var(--plum)" : "var(--coral)");
      mark.append(bubble);
      bubble.addEventListener("animationend", () => bubble.remove(), { once: true });
    }
  };

  art.addEventListener("pointermove", track);
  art.addEventListener("pointerleave", reset);
  mark.addEventListener("click", burst);
  mark.addEventListener("keydown", event => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      burst(event);
    }
  });
}
