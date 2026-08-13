import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

import { toastPresentation } from "../assets/js/core/dialog.js";

const css = readFileSync(new URL("../assets/css/components.css", import.meta.url), "utf8");

test("toast types have clear user-facing presentation", () => {
  assert.deepEqual(toastPresentation("success"), { title: "Change saved", symbol: "check" });
  assert.deepEqual(toastPresentation("error"), { title: "Action needed", symbol: "alert" });
  assert.deepEqual(toastPresentation("info"), { title: "Switcher", symbol: "info" });
});

test("toast cards expose a dismiss control and timed progress", () => {
  const source = readFileSync(new URL("../assets/js/core/dialog.js", import.meta.url), "utf8");
  assert.match(source, /toast__close/);
  assert.match(source, /toast__progress/);
  assert.match(source, /aria-label="Dismiss notification"/);
});

test("toast motion and stacking match the polished interface", () => {
  assert.match(css, /\.toast-region[\s\S]*pointer-events:\s*none/);
  assert.match(css, /\.toast[\s\S]*backdrop-filter:\s*blur/);
  assert.match(css, /@keyframes toast-enter/);
  assert.match(css, /@keyframes toast-progress/);
  assert.match(css, /@media \(prefers-reduced-motion:\s*reduce\)[\s\S]*\.toast/);
});

test("success toast uses the coral-plum theme without a status rail", () => {
  assert.doesNotMatch(css, /\.toast::before/);
  assert.match(css, /\.toast--success\s*\{\s*--toast-accent:\s*var\(--coral\)/);
  assert.match(css, /\.toast__progress[\s\S]*linear-gradient\(90deg,\s*var\(--toast-accent\),\s*var\(--toast-secondary\)/);
  assert.match(css, /\.toast--success\s*\{[^}]*--toast-secondary:\s*var\(--plum\)/);
});
