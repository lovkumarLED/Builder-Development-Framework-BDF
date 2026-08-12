import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const mainSource = await readFile(new URL("../assets/js/main.js", import.meta.url), "utf8");
const aboutSource = await readFile(new URL("../assets/js/core/about.js", import.meta.url), "utf8");
const guiSource = await readFile(new URL("../gui.html", import.meta.url), "utf8");

test("sidebar help button opens the local AI Switcher version popup", () => {
  assert.doesNotMatch(mainSource, /window\.open\("\/docs"/);
  assert.match(mainSource, /openAboutDialog/);
  assert.match(aboutSource, /About AI Switcher/);
  assert.match(aboutSource, /APP_VERSION = "1\.0\.0"/);
  assert.match(aboutSource, /Version \$\{APP_VERSION\}/);
  assert.match(guiSource, /aria-label="About AI Switcher"/);
});
