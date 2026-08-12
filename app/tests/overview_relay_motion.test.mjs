import test from "node:test";
import assert from "node:assert/strict";

import { circularRelayIndex, relayDragStep, relayLayerProviders } from "../assets/js/pages/overview.js";

test("relay index loops forward and backward", () => {
  assert.equal(circularRelayIndex(2, 1, 3), 0);
  assert.equal(circularRelayIndex(0, -1, 3), 2);
  assert.equal(circularRelayIndex(1, 1, 3), 2);
});

test("vertical relay drag chooses one step only after the threshold", () => {
  assert.equal(relayDragStep(18, 42), 0);
  assert.equal(relayDragStep(58, 42), 1);
  assert.equal(relayDragStep(-58, 42), -1);
});

test("the decorative empty card remains the deepest relay layer", () => {
  const providers = [{ id: "one" }, { id: "two" }, { id: "three" }];
  assert.deepEqual(relayLayerProviders(providers, 0), {
    front: providers[0],
    middle: providers[1],
    back: null,
  });
  assert.deepEqual(relayLayerProviders(providers, 2), {
    front: providers[2],
    middle: providers[0],
    back: null,
  });
});
