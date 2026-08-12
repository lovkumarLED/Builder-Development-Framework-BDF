import test from "node:test";
import assert from "node:assert/strict";

import { desktopSidebarAvailable, nextSidebarCollapsed } from "../assets/js/core/sidebar.js";

test("sidebar collapse is available only on desktop layouts", () => {
  assert.equal(desktopSidebarAvailable(1538), true);
  assert.equal(desktopSidebarAvailable(1200), true);
  assert.equal(desktopSidebarAvailable(1199), false);
});

test("sidebar edge handle toggles the collapsed state", () => {
  assert.equal(nextSidebarCollapsed(false), true);
  assert.equal(nextSidebarCollapsed(true), false);
});
