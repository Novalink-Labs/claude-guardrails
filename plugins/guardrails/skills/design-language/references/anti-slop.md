# Generic-AI tells

Patterns that make UI read as machine-made. None is forbidden if DESIGN.md chose it on purpose; each one is a finding when it appears by default. When reviewing, name the tell and the token or rule that fixes it.

## Typography

- One sans-serif everywhere (Inter, Roboto, Arial or the system font) with no reason given; or a "safe characterful" pick reused across unrelated products.
- No type scale: sizes picked per screen; headings that barely differ from body text.
- One weight for everything, or bold used for emphasis all over the page.
- Long centred paragraphs; lines longer than about 75 characters; display faces used for body text.
- Numbers in tables and stats without tabular figures, so columns don't line up.

## Colour

- Purple-to-blue gradients, especially behind a hero.
- A single neon accent on near-black; cream backgrounds with a serif and a terracotta accent. Both are now default looks.
- Pure grey neutrals with no relationship to the accent.
- Several accents competing; gradient text; colour as the only signal of state.
- Low-contrast grey text on grey or tinted backgrounds.

## Layout

- Everything centred.
- A full-viewport hero with nothing else visible.
- Three equal feature cards with an icon in a coloured circle; a bento grid by default.
- Every block in a card with the same radius and shadow; cards inside cards.
- Uniform spacing with no rhythm, so nothing groups and nothing stands out.
- Numbered markers (01, 02, 03) on things that aren't a sequence.
- More than one primary action competing on a screen.

## Components

- The component library's default theme left unchanged (the stock shadcn/ui look is the commonest).
- Hand-rolled controls with no focus state, no keyboard support or no disabled state.
- Emojis as icons, bullets or decoration.
- Pill badges, glass blur or drop shadows applied to everything.
- Icons from several sets mixed together.

## Motion

- Every section fading up on scroll; infinite looping micro-animations.
- Bouncy easing on utilitarian UI; slow transitions that make the app feel laggy.
- No reduced-motion handling.

## Copy and content

- Lorem ipsum, "John Doe", fake logos, fake testimonials and invented metrics.
- Stock phrasing: "unlock", "seamless", "revolutionise", "elevate", "supercharge", "all-in-one", exclamation marks.
- Headlines that could belong to any product.
- Emojis in headings, buttons or system messages.

## Imagery

- Abstract gradient blobs or 3D shapes as hero art.
- AI-generated images with artefacts or a mismatched style; mixed illustration styles.

## States

- Missing loading, empty or error states; a single spinner for everything.
- Jokey empty states the design never asked for.

## The fix

Commit to DESIGN.md; take every value from tokens; use the chosen library's components; use real content; spend boldness in one place and keep everything around it quiet.
