import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const selectSource = readFileSync(new URL("../assets/js/core/custom-select.js", import.meta.url), "utf8");
const mainSource = readFileSync(new URL("../assets/js/main.js", import.meta.url), "utf8");
const css = readFileSync(new URL("../assets/css/custom-select.css", import.meta.url), "utf8");

test("custom select replaces the native popup with an accessible listbox", () => {
  assert.match(selectSource, /role", "combobox"/);
  assert.match(selectSource, /role", "listbox"/);
  assert.match(selectSource, /aria-expanded/);
  assert.match(selectSource, /nativeSelect\.hidden = true/);
  assert.match(selectSource, /new Event\("change", \{ bubbles: true \}\)/);
});

test("custom select supports keyboard navigation and escape", () => {
  for (const key of ["ArrowDown", "ArrowUp", "Home", "End", "Enter", "Escape"]) assert.match(selectSource, new RegExp(key));
});

test("workspace initializes one reusable custom-select system", () => {
  assert.match(mainSource, /initCustomSelects\(document\)/);
  assert.match(css, /\.custom-select__menu/);
  assert.match(css, /\.custom-select__option\[aria-selected="true"\]/);
});

test("custom select removes detached popup menus and never parses option text as HTML", () => {
  assert.match(selectSource, /removedNodes/);
  assert.match(selectSource, /menu\.remove\(\)/);
  assert.doesNotMatch(selectSource, /innerHTML = `<span>\$\{nativeOption\.textContent\}/);
});

test("scrolling inside an open menu does not close it before option selection", () => {
  assert.match(selectSource, /function shouldCloseSelectOnScroll/);
  assert.match(selectSource, /shouldCloseSelectOnScroll\(event\.target, openInstance\)/);
  assert.match(selectSource, /menu\.contains\(target\)/);
});

test("long Settings model choices use a wider compact menu", () => {
  assert.match(selectSource, /menu\.dataset\.selectId = nativeSelect\.id/);
  assert.match(css, /data-select-id="settingsModel"/);
  assert.match(css, /width:\s*min\(320px,\s*calc\(100vw - 16px\)\)/);
  assert.match(css, /overflow-x:\s*hidden/);
  assert.match(css, /box-sizing:\s*border-box/);
  assert.match(css, /grid-template-columns:\s*minmax\(0,\s*1fr\)/);
  assert.match(css, /::-webkit-scrollbar/);
});

test("custom select refreshes its visible list when native options change", () => {
  assert.match(selectSource, /ai-switcher:options-changed/);
  assert.match(selectSource, /buildOptions/);
  assert.match(selectSource, /options = \[\.\.\.nativeSelect\.options\]/);
});
