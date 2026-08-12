import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const css = fs.readFileSync(new URL("../assets/css/base.css", import.meta.url), "utf8");

test("global pages remain scrollable without native scrollbar chrome", () => {
  assert.match(css, /html,\s*body\s*\{[^}]*scrollbar-width:\s*none[^}]*-ms-overflow-style:\s*none/is);
  assert.match(css, /html::-webkit-scrollbar,\s*body::-webkit-scrollbar\s*\{[^}]*display:\s*none[^}]*width:\s*0[^}]*height:\s*0/is);
});
