---
name: design-language
description: Create the product's design language, or research a single new screen, before UI gets built, so the result doesn't look vibe-coded. Researches how the product's competitors and the best apps in its category actually look, gathers the team's inspiration references, has the team choose a UI component foundation (shadcn/ui, Radix, React Aria, Mantine, MUI, Nuxt UI, Angular Material, Tamagui and others per stack), proposes two or three distinct design-language variants with real font pairings, contrast-checked colour tokens, type, spacing, shape and motion, renders a preview page per variant, and records the choice in DESIGN.md, token files and an ADR. Use when starting a web or mobile frontend, before a redesign, when designing a new screen or flow, when the UI looks generic, AI-made or inconsistent, or when someone asks about a design system, theme, fonts, colours, component library or UI inspiration.
argument-hint: "[product | 'screen' <screen or flow to research>]"
---

# Design language

Most AI-made UI looks alike for one reason: nobody committed to a design language, so the model's defaults fill the gap. Choosing that language is a UI-pattern decision, and those belong to the team. This skill does the research and lays out real options; the team chooses; the choice gets written down where every later screen and review can follow it.

Two modes:
- **Language** (default): the whole product's design language. Steps 1 to 7.
- **Screen** (`$ARGUMENTS` starts with `screen`): one new screen or flow inside an existing language. Steps 1 and 2 for that screen only, then propose layouts that use the existing DESIGN.md and component library, and record the pick in the spec or design notes.

## Work efficiently

Load only the reference file each step needs. Look at references once and keep notes short. Use one preview skeleton for all variants so they're compared on the language, not the layout. Don't build product screens in language mode; it ends at the language.

## 1. Read the brief

- What the product is, who uses it, where and how (on a phone between tasks, at a desk all day), and what kind of surface this is:
  - **Persuade:** marketing, landing and pricing pages, where the visitor decides.
  - **Operate:** app screens, dashboards, admin and settings, where the visitor gets a task done.
  - **Read:** docs, articles and help, where the visitor understands something.
  - **Showcase:** portfolios and galleries, where the work leads.
  One product can have several surface kinds sharing tokens but differing in expression.
- What already exists: logo, brand colours and fonts, tone of voice, an existing DESIGN.md or tokens, the current UI. A refinement keeps the existing identity; a redesign replaces it. Ask which, if it isn't clear.
- Constraints: accessibility needs, trust-first or regulated audiences, the scripts the product must render (Devanagari, Tamil, Arabic...), low-end devices, dark mode.

Write a one-line design read: "<surface kind> for <audience>, should feel <three specific adjectives>, constrained by <constraints>." Ask one question only if the read is genuinely ambiguous.

## 2. Research what this product and its category look like

Never design from memory. Users carry expectations from the apps they already use, and the category's best products show what good looks like.

1. **The category:** list 4 to 8 shipped products: direct competitors, and best-in-class apps from adjacent categories that solve the same jobs (for a pharmacy app: other pharmacy apps, plus the best grocery-delivery and banking apps for checkout and trust). Ask the user to add or remove names.
2. **Look at real screens:** the live sites and apps, app-store screenshots, and the shipped-product libraries in `references/inspiration-sources.md`. If a browser tool is available, look yourself and capture screens; otherwise ask the user for screenshots. Concept sites such as Dribbble show mood, not tested patterns; treat them that way.
3. **The team's references:** ask for 3 to 6 products or pages they like and 1 to 3 they dislike, with a word on why.
4. **Extract, don't copy.** For each reference note navigation, layout and density, type, colour use, imagery, motion, component style and copy tone. Then summarise:
   - **Conventions to keep:** what users of this category will expect (where things are, what things are called, how key flows go).
   - **Room to differ:** where the category is generic and this product can be distinct.
   - **What to avoid:** the dislikes, and the category's clichés.

In screen mode, do this for the specific screen (for example, how five comparable apps do onboarding, search filters or checkout) and propose two or three layouts in the existing language.

## 3. Choose the component foundation (the team decides)

A good component library fixes much of what makes UI look vibe-coded: consistent spacing, real focus states, keyboard support and accessible behaviour come built in. Present two or three options that fit the stack from `references/component-libraries.md`, with trade-offs and a recommendation. Keep the library the repo already uses unless the team wants to change it.

Two rules follow from the choice, and go into AGENTS.md:
- Use the library's components before writing new ones; never hand-roll a dialog, menu, select, combobox, tabs, toast, tooltip or date picker the library provides.
- The library is the foundation, not the look. Its default theme is a recognisable default too (the stock shadcn/ui look is one), so the chosen variant restyles it through tokens.

## 4. Propose variants

Two or three variants that are genuinely different directions, not three shades of one idea. Each one:

- **Name and idea:** one line, grounded in the product's own world: its materials, instruments, vocabulary and users.
- **Dials, 1 to 5:** expression (quiet to bold), density (airy to packed), motion (still to lively). Operate surfaces usually sit at low expression, medium to high density and low motion; persuade surfaces go higher on expression.
- **Typography:** a pairing from `references/font-pairings.md` or the brand's own fonts, with roles (display, body, mono for data), a type scale (sizes, line heights, weights), tabular numerals where digits align. Confirm the fonts are licensed for the use and cover the product's scripts.
- **Colour:** semantic tokens with light and dark values: background, surface, raised surface, text, muted text, border, accent, text on accent, focus ring, success, warning, danger, info. Neutrals tinted toward the accent; one accent, used sparingly. Compute contrast (text at least 4.5:1, large text and UI parts at least 3:1); don't eyeball it.
- **Space and shape:** spacing scale (for example a 4 px base), grid and maximum content width, radius scale, borders versus shadows and the elevation levels.
- **Motion:** durations and easing for small, medium and large transitions; what happens with reduced motion.
- **Icons and imagery:** one icon set (`references/component-libraries.md` lists options), its stroke and sizes; the photography or illustration direction.
- **Components:** how buttons, inputs, cards, tables, navigation and feedback look in this variant, through the library's theming.
- **Guards against:** the items in `references/anti-slop.md` this variant is most at risk of, and how it avoids them.

Check each variant against `references/anti-slop.md` (what to avoid) and `references/craft.md` (what to do) before showing it. A variant should state how it handles the craft decisions: states, feedback, motion, data display and the signature element.

## 5. Show them

Render one self-contained preview per variant at `docs/design/variants/<name>.html`: tokens as CSS custom properties, fonts loaded from Google Fonts (or the licensed source), and on the page:
- a type specimen showing the scale;
- the colour tokens with their contrast ratios;
- buttons, inputs, a card, a table and an alert in their states (default, hover, focus, disabled, error);
- one realistic screen from this product with real copy from the spec, never lorem ipsum;
- light and dark.

Open them for the user if a browser is available. The team picks one, or combines parts ("B's type with A's colours"); re-render a combination so it's judged as a whole. If the team is split, run `/guardrails:council` on the variants against the design read and the category research, rather than going with whoever argues hardest.

## 6. Record the choice

- `DESIGN.md` at the repo root, from `references/design-md-template.md`.
- Tokens in the stack's format, from one source: CSS custom properties (mapped into the Tailwind theme if Tailwind is used), the component library's theme config, or the React Native theme object. Components read tokens only.
- An ADR, "Design language and component foundation" (`/guardrails:adr`): the variants as options, the decision, the deciders.
- AGENTS.md, frontend section: "UI follows DESIGN.md. No literal colours, font sizes, spacing or fonts in components. Use <library> components before writing new ones. New screens start with `/guardrails:design-language screen`. Every screen meets the craft checklist in DESIGN.md." Copy the craft items that apply to this product from `references/craft.md` into DESIGN.md's Craft section, so the repo carries them without the plugin.
- Keep the previews in `docs/design/variants/` as the record, unless the team prefers to delete them.

## 7. Hand over

Summarise the decision, the files written, and the next step: build the first screen with the new language, then run `/guardrails:ui-review` on it.
