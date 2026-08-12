import test from "node:test";
import assert from "node:assert/strict";

import { mobileSidebarInert } from "../assets/js/core/router.js";

test("closed tablet navigation is removed from keyboard order", () => {
  assert.equal(mobileSidebarInert(768, false), true);
  assert.equal(mobileSidebarInert(768, true), false);
  assert.equal(mobileSidebarInert(1024, false), false);
});
