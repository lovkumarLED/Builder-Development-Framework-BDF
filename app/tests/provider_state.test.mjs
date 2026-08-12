import test from "node:test";
import assert from "node:assert/strict";

import { providerState } from "../assets/js/pages/providers.js";

test("provider state distinguishes primary route from build inclusion", () => {
  assert.equal(providerState({ id: "primary", active: true }, "primary"), "primary");
  assert.equal(providerState({ id: "secondary", active: true }, "primary"), "included");
  assert.equal(providerState({ id: "available", active: false }, "primary"), "available");
});
