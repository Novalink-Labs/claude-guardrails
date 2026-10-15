# Craft: what makes an app feel made with care

The positive counterpart to `anti-slop.md`. Vibe-coded apps aren't usually wrong; they're unconsidered. These practices are what consideration looks like. DESIGN.md decides the specifics; this file is the checklist of things to decide and do.

## Contents

1. Foundations
2. Content and copy
3. States and feedback
4. Interaction
5. Forms
6. Motion
7. Data display
8. Mobile and touch
9. Polish details
10. Perceived speed
11. Code that reads hand-written

## 1. Foundations

- One design language (DESIGN.md) and tokens for every colour, size, space, radius, shadow and duration.
- A type scale with clear steps; three or four sizes per screen is usually enough. Two families at most, plus a mono for code or data.
- Hierarchy through size, weight and colour together, not size alone. One primary action per view; secondary and tertiary actions look clearly lesser.
- Spacing with rhythm: tight inside a group, looser between groups, so structure reads without borders.
- A column grid and consistent maximum widths; edges line up across sections; running text is left-aligned.
- Neutrals tinted toward the accent; one accent; status colours reserved for status. Dark mode designed as its own palette (raised surfaces get lighter, accents slightly desaturated), not inverted.
- One icon set at consistent sizes and stroke; icons carry a label unless the meaning is universal.
- A signature: one memorable element (a typographic treatment, an illustration style, a motion moment) used consistently, with everything around it kept quiet.

## 2. Content and copy

- Design with real content and real data shapes from the start: long names, empty lists, hundreds of items, big numbers, translated strings that run longer.
- Buttons say what happens ("Send invoice", "Save changes"), never "Submit" or "OK" when a verb fits.
- Sentence case, consistent terms (one word per concept across the app), no jargon or filler.
- Errors say what happened and how to fix it, in the user's words, next to the thing that failed.
- Empty states explain what will appear here and offer the first action.
- Numbers, dates and money formatted for the user's locale with `Intl` (for India, `en-IN` grouping such as 1,00,000), units always shown, relative dates where they help ("2 hours ago") with the exact time on hover or tap.
- Proper typography in copy: real quotes and apostrophes, the ellipsis character, an en dash for ranges, a non-breaking space between a number and its unit.

## 3. States and feedback

- Every view has its states designed: loading, empty, error, partial data, offline, no permission, and success.
- Loading uses skeletons shaped like the content, so nothing jumps when data arrives; spinners only for actions, and only after a short delay (about 300 ms) so fast responses don't flash.
- Every action gets immediate feedback: a pressed state, then progress, then a clear result.
- Optimistic updates where failure is rare and reversible, with a visible rollback if it fails.
- Destructive actions offer undo where possible; otherwise a confirmation that names exactly what will be lost.
- Disabled controls explain why they're disabled, or stay enabled and explain on use.

## 4. Interaction

- Every interactive element has hover, focus-visible, active and disabled states; the focus ring is clearly visible.
- Keyboard works everywhere: logical tab order, Enter submits, Escape closes, arrow keys inside menus and lists; dialogs trap focus and return it when closed.
- Links look like links; buttons look like buttons; clickable areas are the whole row or card when that's what users expect.
- State survives navigation: filters, sort, scroll position and drafts aren't lost on back.
- Shareable state lives in the URL (filters, tabs, selected item) where users would want to link to it.

## 5. Forms

- Visible labels above fields (placeholders are examples, not labels); helper text for format rules before the user gets them wrong.
- The right input types and `autocomplete` values (`email`, `tel`, `one-time-code`, `street-address`) so keyboards and autofill help.
- Validate on blur and on submit, not on every keystroke; errors appear inline and are announced to screen readers; focus moves to the first error.
- Sensible defaults; optional fields marked as optional; long forms split into steps with progress.
- Input is never lost: on error, on navigation away (warn), or on session expiry.

## 6. Motion

- Motion explains change: where something came from, where it went, what changed. Not decoration.
- Short and consistent: about 150 to 250 ms for UI transitions, ease-out for things entering, ease-in for things leaving.
- Animate opacity and transform, not layout properties.
- Respect reduced motion by replacing movement with simple fades or nothing.

## 7. Data display

- Numbers right-aligned with tabular figures; units in the column header, not repeated in every cell.
- Tables have sticky headers when long, sortable columns where users compare, clear empty and loading rows, and pagination or virtualisation for large sets.
- Charts start from a meaningful baseline, label units, use colour from tokens with a colour-blind-safe palette, and show the exact value on hover or tap.
- Dense screens stay scannable: consistent row heights, zebra striping or dividers (one, not both), and the most important column first.

## 8. Mobile and touch

- Touch targets at least 44 by 44 points (Apple's guidance; WCAG's minimum is 24 by 24 CSS pixels), with space between them.
- Primary actions within thumb reach; content clear of notches and system bars (safe areas).
- Inputs at least 16 px so mobile browsers don't zoom; the right keyboard for each field.
- Respect platform conventions: back gestures, share sheets, system fonts where the design calls for native feel.

## 9. Polish details

- A designed favicon and app icons, a meaningful title on every page, Open Graph images for shared links, and a `theme-color`.
- Designed 404 and error pages with a way back.
- Images at the right aspect ratio with reserved space, a consistent treatment (crop, radius) and real alt text.
- Headings without orphaned last words (`text-wrap: balance`); paragraphs at 45 to 75 characters per line.
- Scrollbars, selection colour and focus styles that belong to the palette.
- Landmarks, a heading outline in order, and a skip link, so the structure is as considered as the look.

## 10. Perceived speed

- Fast first paint: server-render or prerender what's above the fold; fonts with fallback metrics so text doesn't jump.
- Prefetch the likely next route; respond to taps within 100 ms even if the work takes longer.
- No layout shift from images, ads, banners or late fonts.
- Long work moves to the background with a notification when done, instead of a blocking spinner.

## 11. Code that reads hand-written

- Names from the product's domain, consistent across layers (`invoice`, never `bill` in one file and `inv` in another).
- Small functions with one job; early returns over nesting; no clever one-liners where plain code is clearer.
- Types and validation at the boundaries, trusted data inside.
- Errors handled once, at the level that can do something about them.
- Comments only where the code departs from the usual pattern, one precise line on why.
- Tests named by behaviour ("refuses a refund above the order total"), arranged and asserted plainly.
- Commits that each do one thing, with messages that say why.
