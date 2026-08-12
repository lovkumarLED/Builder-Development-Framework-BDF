# AI Switcher Typography Decision

Status: Approved project typography direction  
Reference: `hdfashf2026-08-10 013738.png`

## Identification

The reference image uses Formula 1's proprietary 2025 **Formula One** sans-serif family. Its key characteristics are:

- clean neo-grotesk construction;
- large, tightly spaced display headlines;
- open counters and highly legible numerals;
- neutral UI text paired with confident broadcast-scale typography.

Formula 1 states that its header fonts are copyright-protected and may not be used without express written permission. The original font files must therefore not be downloaded, copied, embedded, or shipped with AI Switcher unless BDF obtains an appropriate license.

## Binding AI Switcher Choice

Use **Inter Tight** as the legal, offline-capable visual match for the Hybrid Studio interface.

```css
font-family: "Inter Tight", "Segoe UI Variable", "Segoe UI", sans-serif;
```

- Bundle the required Inter Tight `.woff2` files locally; do not load fonts from a CDN.
- Use weights `400`, `500`, `600`, and `700` only.
- Use `600` or `700` for large page titles and dashboard values.
- Use `400` or `500` for navigation, labels, controls, tables, and body copy.
- Keep large display headings tight, approximately `-0.035em` to `-0.02em` letter spacing.
- Keep small UI text between `-0.01em` and `0`, prioritizing readability.
- Use tabular numerals for logs, latency, token counts, and analytics values.

Inter Tight is the project font decision. Formula One is a visual reference only and must not be presented as an AI Switcher asset or bundled dependency.

