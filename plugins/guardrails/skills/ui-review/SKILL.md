---
name: ui-review
description: Review implemented UI against the product's design language (DESIGN.md, tokens, design references) and flag anything that looks generic or AI-generated, such as default fonts, purple gradients, centred everything, identical card grids, emoji icons, invented states and inconsistent spacing. Also checks every designed state, accessibility, responsiveness at phone and desktop widths, light and dark themes, and copy. Uses screenshots when a browser is available. Read-only; reports findings with the token or rule each one breaks and the fix. Use when someone asks to review a screen, page, component or UI PR, says "this looks AI-made", "make it look less generic", "does this match the design", or before shipping a UI change.
argument-hint: "[route | component path | PR number]"
---

# UI review

UI goes generic when nobody committed to a design language, so every screen falls back on the model's habits. This review holds the UI to the language the team chose, and calls out the habits by name so they stop recurring.

It's read-only. Fixes come afterwards, from the person or from a follow-up change.

## Work efficiently

Read DESIGN.md and the token files once. Review the changed screens and components, not the whole app. Take each screenshot once per width and theme.

## 1. Gather the design truth

- `DESIGN.md` and the token source (CSS variables, Tailwind theme, theme objects), the design references (Figma links, `docs/design/`), and the relevant AGENTS.md sections.
- If there is no design language yet, say so and suggest `/guardrails:design-language`. You can still review against `../design-language/references/anti-slop.md` and accessibility, and say that's what you did.
- The spec for the screen: what states and copy it should have.

## 2. Look at it

If a browser tool or Playwright is available, open the screens and capture them at a phone width (about 390 px) and a desktop width (about 1440 px), in light and dark if both exist, and in each state you can reach (loading, empty, error, disabled). Otherwise review the code and say screenshots weren't taken.

## 3. Check

1. **Design language:** every colour, font, size, spacing value, radius, shadow and duration comes from the tokens. Hardcoded values, off-scale sizes and one-off colours are findings. Typography follows the scale and the chosen families, with tabular numbers where digits line up.
2. **Generic-AI tells:** go through `../design-language/references/anti-slop.md`. Name each tell you find.
3. **Craft:** go through DESIGN.md's Craft section, or `../design-language/references/craft.md` if there isn't one: feedback on every action, skeletons without layout shift, real content shapes, specific copy, locale formatting, keyboard behaviour, form details, purposeful motion, data alignment, polish. Missing craft is a finding with the concrete fix, not a matter of taste.
4. **States:** every state the design defines exists and matches; nothing invented where the design is silent (raise it instead).
5. **Layout:** alignment to the grid, consistent spacing rhythm, a clear hierarchy (one primary action per view), no horizontal scroll, content-driven heights, long text wrapping instead of clipping.
6. **Accessibility:** semantic elements, labels, keyboard order and visible focus, contrast (4.5:1 text, 3:1 large text and UI parts), target size, reduced-motion respected, errors announced.
7. **Responsive and themes:** phone and desktop both designed, not just squeezed; dark theme uses the dark tokens with the same care.
8. **Copy:** matches the spec, plain and specific, no placeholder text, no emojis unless the design includes them, consistent capitalisation and terms.

## 4. Report

```markdown
## UI review: <screen or PR>

**Against:** DESIGN.md, tokens in `<path>`, <design link> · **Screenshots:** phone and desktop, light and dark (or "code only")
**Verdict:** Matches the design | Needs changes | Off-language (needs a design decision)

### Findings
1. **<title>** · `path:line` · <category: language, generic tell, state, layout, accessibility, responsive, copy>
   What's wrong, and the token or rule it breaks.
   Fix: <the specific token, component or change>

### Missing design decisions
- <States or patterns the design doesn't define, to raise with Design.>
```

Off-language means the screen needs something the design language doesn't cover; that's a decision for the team (`/guardrails:adr`), not something to improvise.
