import { openDialog } from "./dialog.js";

export const APP_NAME = "AI Switcher";
export const APP_VERSION = "1.0.0";

export function openAboutDialog(trigger) {
  openDialog({
    title: "About AI Switcher",
    trigger,
    content: `<div class="about-product"><img src="/assets/bdf-counterphase-logo.svg" alt=""><div><strong>${APP_NAME}</strong><span>Version ${APP_VERSION}</span></div></div>`,
    actions: '<button class="button button--primary" type="button" data-dialog-close>Close</button>',
  });
}
