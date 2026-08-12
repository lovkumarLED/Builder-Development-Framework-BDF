import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const css = readFileSync(new URL("../assets/css/components.css", import.meta.url), "utf8");
const dialog = readFileSync(new URL("../assets/js/core/dialog.js", import.meta.url), "utf8");

test("shared dialogs use a polished layered shell", () => {
  assert.match(css, /\.dialog-backdrop[\s\S]*backdrop-filter:\s*blur\(/);
  assert.match(css, /\.dialog[\s\S]*grid-template-rows:\s*auto minmax\(0, 1fr\) auto/);
  assert.match(css, /\.dialog[\s\S]*linear-gradient/);
  assert.match(css, /\.dialog__body[\s\S]*overflow:\s*auto/);
  assert.match(css, /\.dialog__actions[\s\S]*border-top/);
});

test("shared dialogs animate without ignoring reduced motion", () => {
  assert.match(css, /@keyframes dialog-enter/);
  assert.match(css, /@media \(prefers-reduced-motion:\s*reduce\)[\s\S]*\.dialog/);
});

test("dialog close control has a stable hook and real multiplication sign", () => {
  assert.match(dialog, /dialog__close/);
  assert.match(dialog, />×<\/button>/);
});
