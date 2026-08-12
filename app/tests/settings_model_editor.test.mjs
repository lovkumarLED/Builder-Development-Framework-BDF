import assert from "node:assert/strict";
import test from "node:test";

let editor = {};
try { editor = await import("../assets/js/pages/settings-model-editor.js"); } catch { /* RED: module not implemented yet */ }

test("model editor normalizes a multi-model batch with provider-supported reasoning levels", () => {
  assert.equal(typeof editor.normalizeModelBatch, "function");
  const result = editor.normalizeModelBatch(
    [{ model: "existing/model", name: "Existing", thinking: ["high", "max"] }],
    [
      { model: " new/model ", name: " New model ", thinking: ["minimal", "high", "unknown"] },
      { model: "second/model", name: "", thinking: ["max"] },
    ],
    ["default", "minimal", "high", "max"],
  );
  assert.deepEqual(result.added, [
    { model: "new/model", name: "New model", thinking: ["minimal", "high"] },
    { model: "second/model", name: "", thinking: ["max"] },
  ]);
  assert.equal(result.models.length, 3);
});

test("model editor overwrites an existing model with the same ID", () => {
  assert.equal(typeof editor.normalizeModelBatch, "function");
  const result = editor.normalizeModelBatch(
    [{ model: "same", name: "Original", thinking: ["high"] }],
    [{ model: "same", name: "Duplicate", thinking: ["minimal", "max"] }],
    ["minimal", "high", "max"],
  );
  assert.equal(result.models.length, 1);
  assert.deepEqual(result.models[0], { model: "same", name: "Duplicate", thinking: ["minimal", "max"] });
  assert.deepEqual(result.added, [{ model: "same", name: "Duplicate", thinking: ["minimal", "max"] }]);
});

test("model editor allows the same model ID twice in one batch - last wins", () => {
  assert.equal(typeof editor.normalizeModelBatch, "function");
  const result = editor.normalizeModelBatch(
    [],
    [
      { model: "same", name: "First", thinking: ["high"] },
      { model: "same", name: "Second", thinking: ["minimal"] },
    ],
    ["minimal", "high", "max"],
  );
  assert.equal(result.models.length, 1);
  assert.deepEqual(result.models[0], { model: "same", name: "Second", thinking: ["minimal"] });
});

test("model editor includes both provider format and per-model reasoning choices", () => {
  assert.equal(typeof editor.modelEditorMarkup, "function");
  const markup = editor.modelEditorMarkup(
    { id: "tokenrouter", name: "TokenRouter", reasoningFormat: "opencode" },
    [{ id: "opencode", label: "OpenCode", levels: ["default", "minimal", "high", "max"] }],
  );
  assert.match(markup, /placeholder="model-id"/);
  assert.match(markup, /placeholder="Display Name"/);
  assert.match(markup, /Add another model/);
  assert.doesNotMatch(markup, /model-editor-columns/);
  assert.match(markup, /Reasoning format/);
  assert.match(markup, /data-reasoning-format="opencode"/);
  assert.match(markup, /OpenAI \/ ChatGPT/);
  assert.match(markup, /data-reasoning-format="claude"/);
  assert.match(markup, /data-reasoning-format="gemini"/);
  assert.match(markup, /No reasoning/);
  assert.match(markup, /Reasoning choices/);
  assert.match(markup, /data-reasoning-level="default"/);
  assert.match(markup, /data-reasoning-level="minimal"/);
  assert.match(markup, /data-reasoning-level="high"/);
  assert.match(markup, /data-reasoning-level="max"/);
  assert.match(markup, /Adding models to <strong>TokenRouter<\/strong>/);
});

test("reasoning choices follow the selected model format", () => {
  assert.equal(typeof editor.thinkingLevelMarkup, "function");
  assert.match(editor.thinkingLevelMarkup("openai"), /data-reasoning-level="xhigh"/);
  assert.doesNotMatch(editor.thinkingLevelMarkup("openai"), /data-reasoning-level="max"/);
  assert.match(editor.thinkingLevelMarkup("claude"), /data-reasoning-level="max"/);
  assert.match(editor.thinkingLevelMarkup("none"), /No reasoning choices/);
});
