# DESIGN.md

<The product's design language. UI follows this file; anything it doesn't cover is a design decision to raise, not to improvise. Decided in docs/adr/NNNN-design-language.md.>

## Design read

<surface kind> for <audience>, should feel <three adjectives>, constrained by <constraints>.

## Principles

<Three to five, specific to this product. "Numbers first: every screen leads with the figure the user came for" rather than "clean and modern".>

## Foundation

- Component library: <name, version>, restyled through the tokens below.
- Use library components before writing new ones.
- Icons: <set>, <stroke>, sizes <list>.

## Typography

| Role | Family | Source and licence | Weights | Scripts |
|---|---|---|---|---|
| Display | | | | |
| Body | | | | |
| Mono / data | | | | |

| Step | Size / line height | Weight | Use |
|---|---|---|---|

- Body text at least 16 px on mobile; line length 45 to 75 characters.
- Tabular numerals for tables, stats and prices.

## Colour

| Token | Light | Dark | Use |
|---|---|---|---|
| `--bg` | | | page background |
| `--surface` | | | cards, panels |
| `--text` | | | body text |
| `--muted` | | | secondary text |
| `--border` | | | dividers, inputs |
| `--accent` | | | primary actions, links |
| `--on-accent` | | | text on accent |
| `--focus` | | | focus ring |
| `--success` / `--warning` / `--danger` / `--info` | | | status |

- Contrast: <ratios for text on bg and surface, accent on bg>.
- One accent; status colours never used as decoration.

## Space and layout

- Spacing scale: <values>.
- Grid and max content width: <values>. Breakpoints: <values>.

## Shape and elevation

- Radius scale: <values>, and which components use which.
- Borders versus shadows: <rule>. Elevation levels: <values>.

## Motion

- Durations: small <ms>, medium <ms>, large <ms>. Easing: <curves>.
- Reduced motion: <what changes>.

## Imagery

<Photography or illustration direction, with examples.>

## Components

<Rules per component family: buttons (hierarchy, sizes), forms (labels, help, errors), cards, tables, navigation, feedback (toasts, alerts, dialogs).>

## States

<Loading (skeleton or spinner, where), empty (structure and tone), error (inline vs page), disabled, offline.>

## Craft

<The practices every screen meets, chosen from the guardrails craft checklist: states and feedback, interaction, forms, motion, data display, mobile, polish, perceived speed. Write them as checkable rules: "Spinners appear only after 300 ms", "Money uses Intl with en-IN grouping".>

## Voice and copy

<Tone, capitalisation, terms the product uses, no emojis, how errors are worded.>

## Don't

<The anti-slop commitments for this product, from the guardrails anti-slop list.>

## References

<Inspiration and category research links, with what each one contributed.>
