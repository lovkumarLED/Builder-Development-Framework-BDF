# AI Switcher Hybrid Studio UI Design

**Date:** 2026-08-10  
**Status:** Approved visual direction; written specification awaiting review  
**Scope:** AI Switcher GUI, interactions, responsive behavior, and privacy-safe request analytics

## 1. Purpose

This specification translates the approved Hybrid Studio reference boards into the existing AI Switcher application without replacing the BDF architecture.

The application remains a local-first GUI over the existing BDF engine. It must continue to discover and manage supported coding agents, edit their source configuration through the existing backup-first APIs, run the bundled scaffold/builders, and expose the local OpenAI-compatible proxy at `127.0.0.1:9090`.

The visual goal is a dark, immersive first-run experience that transitions into a warm, highly legible operational workspace. The interaction goal is purposeful motion that clarifies state and makes the application feel responsive without becoming distracting.

## 2. Approved Direction

### 2.1 Brand

- Product name remains **AI Switcher**.
- The approved BDF Counterphase mark replaces the flame/shield artwork.
- The mark contains no letters or words.
- The master mark consists of two rounded opposing paths:
  - coral `#EF523F`
  - plum `#3E193B`
- The product wordmark is always separate from the symbol.
- No 3D bevel, metallic finish, shield, flame, robot, neural-network motif, or stock-AI treatment is permitted.

### 2.2 Hybrid Studio visual system

The startup and onboarding experience use a dark cinematic surface. Operational screens use a warm-cloud workspace.

Core tokens:

| Token | Value | Use |
|---|---:|---|
| Startup background | `#0B0D12` | Welcome and onboarding canvas |
| Workspace background | `#F8F4EE` | Dashboard and management screens |
| Workspace surface | `#FFFDFC` | Cards, panels, tables |
| Ink | `#1B191B` | Primary text |
| Muted stone | `#746D70` | Secondary text |
| Border | `#DED7D2` | Dividers and card outlines |
| Coral | `#F16E5B` | Primary action and active provider |
| Plum | `#6842AE` | Supporting selection and data hierarchy |
| Success | `#3C9A63` | Status only, always paired with text/icon |
| Warning | `#C98928` | Status only, always paired with text/icon |
| Error | `#D34F45` | Status only, always paired with text/icon |

- Use system fonts only. Segoe UI is the Windows-first UI font; the system monospace stack is reserved for endpoints, trace IDs, code, and build output.
- Cards use 16px radii, 1px warm-gray borders, modest shadows, and content-driven sizing.
- Controls are at least 44px high.
- Coral identifies the primary action or active state. Plum supports hierarchy and data visualization.
- The existing `rule.md` theme injection remains the token source. Its visual rules must be updated in the same implementation change to document this approved hybrid exception to the previous dark-only, one-accent rule.

## 3. Product Truth and Scope Boundaries

The interface must follow implemented capabilities rather than copying inaccurate sample data from the reference images.

- Only **OpenCode** and **Kilo** are advertised as verified builder targets.
- Codex, Claude Code, Aider, and Goose must not be presented as supported setup choices until the engine supports and verifies them.
- Plugins are stored plugin identifiers. The UI must not claim installation, running state, version resolution, or health monitoring.
- MCP entries are stored server configurations. The UI may say `Configured` and show the declared type, but must not claim connectivity, discovered tools, or health.
- Provider connection status comes only from the existing explicit connection test. It is not continuous monitoring.
- The application remains local-only and account-free.
- Generated agent files (`opencode.json`, `kilo.json`) are never edited by the UI.
- No `.jsonc` sibling is created.
- All configuration writes remain backup-first and preserve unknown content.

## 4. Information Architecture

Operational navigation has five top-level destinations:

1. **Overview**
2. **Providers**
3. **Activity**
4. **Integrations**
5. **Settings**

The current active-agent context is visible in the application shell. Switching or managing agents remains a global operation and does not become an integration.

### 4.1 First-run flow

The guided flow is:

1. Welcome
2. Connect your agent
3. Review the read-only workspace scan
4. Add a provider
5. Test the provider
6. Generate or locate the builder
7. Ready

The visible progress system may group these into the approved four labels: Welcome, Workspace, Provider, Complete. Existing scaffold/build behavior is preserved.

### 4.2 Overview

The dashboard contains:

- active-agent and local-proxy status
- provider relay deck
- explicit `Switch provider` and `View details` actions
- provider count and test-derived status
- request count, success rate, median latency, and failed request count when activity data exists
- requests-over-time chart
- provider-usage chart
- recent proxy-call list

Empty analytics states must explain that data appears after traffic passes through the local proxy. The UI must never invent production data.

### 4.3 Providers

- Provider cards are software configuration cards, never payment cards.
- Arrow controls bring a card forward without activating it.
- Selection and activation are separate operations.
- The active provider is fully saturated and forward; inactive providers remain readable and recessed.
- `Details` reveals endpoint, SDK, reasoning format, configured models, and key-presence status without returning or displaying the key.
- Add-provider becomes a guided flow: Choose, Configure, Models, Test, Save.
- Edit, delete, test, and switch continue to call the existing backend contracts.

### 4.4 Activity

The Activity page provides privacy-safe observability for requests passing through `/v1/*`.

Stored fields:

- timestamp in UTC
- provider identifier
- model identifier when available
- route and HTTP method
- HTTP status
- latency in milliseconds
- input/output/total token counts when an upstream non-streaming response reports them
- sanitized error category
- generated trace ID

Never stored:

- API keys or authorization headers
- prompt or message content
- response content
- raw request or response bodies

Streaming requests may have unknown token counts. The UI displays an em dash rather than fabricating a value.

Default retention is 30 days with a bounded record count. Retention and redaction preferences are app-owned runtime preferences, not agent configuration. Activity persistence must be local, atomic where rewritten, and ignored by Git.

### 4.5 Integrations

Integrations is a configuration hub, not a marketplace.

- **Plugins:** list plugin IDs; add and remove; no health or installed badge.
- **MCP servers:** list name, declared type, and `Configured`; add and remove.
- **AI provider connection:** show primary provider, explicit `Test connection`, and link to Providers.
- **Use AI Switcher with another tool:** show the copyable local endpoint `http://127.0.0.1:9090/v1` and `Local only` status.
- A build-required notice explains when configuration changes need a builder run.

MCP creation is guided by default. Common local/remote fields are presented as structured inputs. An explicitly labelled `Expert JSON` disclosure exposes the existing JSON configuration editor for advanced cases. JSON is validated before save. There is no orphaned `Advanced` footer link.

### 4.6 Settings

Settings uses local section navigation:

- Models & reasoning
- Build output
- Developer settings
- Appearance and accessibility
- Managed agents
- About and privacy

Plugins and MCP servers live in Integrations, not Settings.

Developer settings include activity retention and request-content redaction. Redaction is mandatory and cannot be disabled in this release; the control communicates the invariant rather than weakening it.

## 5. Interaction Design

### 5.1 Startup Counterphase interaction

The large right-side mark is the primary immersive interaction.

Pointer behavior:

- Pointer position is normalized relative to the mark.
- Each path translates at most 4px toward or away from the pointer.
- The paths rotate no more than 1.5 degrees.
- The negative-space aperture opens slightly as the pointer approaches the center.
- Movement uses `requestAnimationFrame` and transform-only animation.

Click, Enter, or Space behavior:

1. Coral and plum paths separate by at most 14px.
2. The paths counter-rotate by at most 6 degrees and scale to at most 1.03.
3. Eight to twelve small coral/plum bubbles emit from the aperture.
4. Bubbles vary from 3px to 10px and resolve within 450-900ms.
5. The paths spring back and rejoin within approximately 650ms.

The effect is throttled to one full burst every 600ms. Bubble nodes are removed after animation, and no more than 24 may exist at once. Repeated clicks must not degrade performance.

Idle behavior is limited to a very small aperture-breathing cycle. There are no perpetual embers or background particles.

Reduced motion:

- no pointer tracking
- no path separation, rotation, bubbles, flips, or chart entrance animation
- click/keyboard activation uses a short opacity/focus-ring acknowledgement only

Touch devices keep the mark static until a direct tap.

### 5.2 Shared motion language

- Page transitions: 160-220ms fade and small translate.
- Cards: maximum 2px lift on hover/focus; no floating loops.
- Provider deck: directional slide with clear focus transfer.
- Provider details: deliberate flip only when motion is allowed; otherwise expand inline.
- Wizard: forward/back slide matching navigation direction.
- Charts: focusable series and restrained tooltip transitions.
- Log rows: expandable sanitized metadata panel.
- Toasts: brief status feedback, never the only error explanation.
- Every pointer interaction has a keyboard equivalent.

## 6. Responsive Behavior

Breakpoints are content-driven:

- **Wide (>= 1200px):** 216px text sidebar and 12-column content grid.
- **Narrow desktop (900-1199px):** icon rail with accessible labels/tooltips; two-column cards; stacked charts as required.
- **Tablet/narrow window (640-899px):** compact top app bar and drawer; one-column content; provider cards become a horizontal snap carousel.
- **Very narrow (< 640px):** supported as a constrained Windows window, not marketed as a phone UI. Tables become labelled record lists; primary actions remain visible.

No page may require a minimum desktop width to reach its primary action.

## 7. Accessibility

- Minimum 4.5:1 text contrast.
- Visible 2px focus indicators.
- Minimum 44px targets.
- Semantic buttons, landmarks, headings, dialogs, tables, and form labels.
- Modal focus trap, Escape close, return focus, and background inert state.
- Status is never color-only.
- Charts have textual summaries and keyboard-accessible data points.
- Provider-card order and active state are announced to assistive technology.
- Windows forced-colors support is required.
- `prefers-reduced-motion` disables non-essential motion.

## 8. Backend and Data Design

The existing modular FastAPI architecture remains authoritative.

Planned additive backend responsibility:

- a dedicated activity module owns sanitized proxy-event recording, retention, summary calculations, and read-only activity API routes
- the proxy records metadata after the upstream result is known
- activity recording failures never break proxy traffic; they are reported locally without leaking request content
- an app-preferences module owns activity retention and accessibility/appearance preferences that require persistence

No provider, model, plugin, MCP, or agent data is duplicated into analytics storage.

## 9. Error and Empty States

- Startup discovery failure offers retry and manual folder selection.
- Unsupported agents are identified honestly and are not scaffolded as verified targets.
- Provider test failure shows reason and latency when available without exposing secrets.
- Activity storage failure leaves proxy traffic functional and shows analytics as temporarily unavailable.
- No activity data shows a first-use explanation.
- Invalid MCP expert JSON stays in the dialog with a specific validation message.
- Builder errors preserve full existing output in the Build panel.

## 10. Implementation Boundaries

Expected implementation files include:

- `app/gui.html`
- `app/assets/bdf-counterphase-logo.svg`
- additive activity and preference modules under `app/app/`
- `app/server.py` when router registration is needed
- unit tests under `app/tests/`
- `app/rule.md`
- `app/README.md`
- root `README.md` where the visible screen/feature description changes
- `PROJECT_STATE.md` after the additive module/file refactor
- session continuity files at session end

The implementation must not edit generated agent configuration or unrelated builder code.

## 11. Verification

Required verification before completion:

1. Existing and new Python unit tests pass.
2. Inline JavaScript extracts and passes `node --check`.
3. Browser walkthrough covers welcome, onboarding, every navigation destination, all dialogs, and provider actions.
4. Visual comparison is performed against all eight approved Hybrid Studio boards at wide, narrow, and tablet widths.
5. Keyboard-only walkthrough succeeds.
6. Reduced-motion behavior is verified.
7. Forced-colors/high-contrast behavior is checked.
8. Proxy traffic continues working for streaming and non-streaming requests.
9. Activity records contain metadata only and never prompt, response, or key content.
10. Existing write operations remain backup-first.
11. Documentation and project state are synchronized.

## 12. Non-Goals

- Implementing unverified agents such as Codex, Claude Code, Aider, or Goose.
- Adding accounts, cloud sync, OAuth, telemetry upload, or phone-home behavior.
- Building a plugin marketplace.
- Claiming MCP connectivity or discovered tools without a real handshake implementation.
- Storing prompt or response content.
- Editing generated agent configuration directly.
- Adding CDN or webfont dependencies.
- Replacing the BDF engine or the existing modular backend architecture.

## 13. Approval Record

The user approved:

- Hybrid Studio as the visual direction.
- the BDF Counterphase mark as the brand symbol.
- the complete reference pack covering startup, onboarding, dashboard, providers, activity, configuration, responsive layouts, and integrations.
- interactive behavior across the application, with special emphasis on a clickable, pointer-reactive startup symbol with bubbles and immersive motion.
- implementation in the current task while following all repository documentation and checkpoints.

