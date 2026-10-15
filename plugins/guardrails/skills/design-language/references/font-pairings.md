# Font pairings

Pairings for design-language variants. Every family below is open source and on Google Fonts; families, axes and weights were checked against `https://fonts.google.com/metadata/fonts` on 2026-10-15, and x-heights (x/em) and tabular figures (`tnum`) were measured on the 400 weight. Re-check before relying on a detail. "Why" notes are judgement unless a source is named.

## Rules first

- **Two families plus a mono at most.** "Most documents can tolerate a second font. Few can tolerate a third." ([Butterick](https://practicaltypography.com/mixing-fonts.html)); Apple's HIG also says to minimise typefaces.
- **Pair by contrast with something in common.** Choose a second face "different enough from our primary choice, but not too different"; when unsure, a serif with a sans ([Google Fonts Knowledge](https://fonts.google.com/knowledge/choosing_type/pairing_typefaces)). Low contrast between fonts often works better than high ([Butterick](https://practicaltypography.com/mixing-fonts.html)).
- **Match x-heights** when two faces sit on one line; size the one with the larger x-height down.
- **Line length** 45 to 75 characters, about 66 ideal ([webtypography.net, after Bringhurst](http://webtypography.net/2.1.2)); set `max-width: 65ch` on running text.
- **Line height** about 1.15 to 1.5 for Latin text, more for scripts with tall marks such as Devanagari ([Google Fonts Knowledge](https://fonts.google.com/knowledge)); WCAG AAA asks for at least 1.5 for body text.
- **Body text at least 16 px** on the web; iOS defaults to 17 pt.
- **Numbers in data** use `font-variant-numeric: tabular-nums`. Inter, Geist and Archivo default to proportional digits; faces marked "no tnum" below can't align digits at all.
- **Load fonts fast:** only the weights you use, WOFF2, preconnect, `font-display: optional` (or `swap` when the font arrives early), and fallback metrics (`size-adjust`) to avoid layout shift ([web.dev](https://web.dev/articles/font-best-practices)).
- **Avoid Thin and Light weights** for text (Apple HIG).

## Pairings by personality

| # | Fonts | For | Why | Caveat |
|---|---|---|---|---|
| 1 | Newsreader (opsz, 200–800) + Instrument Sans (wdth, 400–700) | Editorial, content | A news serif with optical sizes over a narrow grotesque for UI | x-heights 0.43 vs 0.51: set the sans a step smaller |
| 2 | Fraunces (opsz, soft, wonk, 100–900) + Commissioner (100–900) | Editorial, brand | Soft old-style display over a calm sans | No tnum in either; not for tables |
| 3 | Instrument Serif + Instrument Sans | Editorial landing pages | Designed together | The serif has one weight (plus italic) |
| 4 | IBM Plex Sans (wdth, 100–700) + IBM Plex Mono | Fintech | One superfamily; Plex Sans digits are tabular by default | Recognisably "IBM" |
| 5 | Public Sans (100–900) + Source Serif 4 (opsz, 200–900) | Fintech, trust, public services | Neutral sans with a serif for statements; both have tnum | Can feel governmental |
| 6 | Geist + Geist Mono (100–900) | Developer tools | Matched metrics across sans and mono | A common default for developer products; restyle hard to avoid a template look |
| 7 | Red Hat Display + Red Hat Text + Red Hat Mono | Developer, infrastructure | Display and text optical split plus mono, one foundry | Recognisably Red Hat |
| 8 | Mona Sans (wdth 75–125, 200–900) + Martian Mono (wdth, 100–800) | Developer marketing | Width axis for expressive headings; an uncommon mono | Martian Mono has no italics |
| 9 | Bricolage Grotesque (opsz, wdth, 200–800) + Figtree (300–900) | Consumer, friendly | Characterful display over a plain body | Figtree is very popular; the display face carries the identity |
| 10 | Bodoni Moda (opsz, 400–900) + Jost (100–900) | Luxury | Didone with a geometric sans, same designer | Hairlines break up when small; use the optical-size axis |
| 11 | Cormorant Garamond (300–700) + Hanken Grotesk (100–900) | Premium | Delicate display over a sturdy sans | x-height 0.386: display sizes only |
| 12 | Unbounded (200–900) + Onest (100–900) | Playful, expressive | Very wide display against a compact sans | Long headlines wrap; no italics |
| 13 | Archivo (wdth 62–125, 100–900) + JetBrains Mono (100–800) | Dashboards | One family from condensed table cells to wide KPI figures | Turn on tabular-nums |
| 14 | Sofia Sans + Sofia Sans Condensed (1–1000) | Dense data | Condensed width for cells, with tnum | Stay in the middle weights |
| 15 | Atkinson Hyperlegible Next + Atkinson Hyperlegible Mono (200–800) | Accessibility-first | Designed for legibility with the Braille Institute; Next has tnum | Google Fonts files the Mono under "Sans Serif" |
| 16 | Lexend (100–900) + Literata (opsz, 200–900) | Reading, education | A sans designed for reading ease with a text serif | Lexend's reading-ease claims are its makers'; no tnum |
| 17 | Anek Latin + Anek Devanagari, Bangla, Tamil, Telugu, Kannada, Malayalam, Gujarati, Gurmukhi or Odia (wdth, 100–800) | Indian multi-script products | One design across Latin and nine Indic scripts | Sans only |
| 18 | Mukta (with Mukta Malar, Vaani, Mahee) + Eczar (400–800) | Indic content | A sans and a serif that both cover Latin and Devanagari | Mukta is static (no variable axes) |
| 19 | Tiro Devanagari Hindi, Marathi or Sanskrit (and Tiro Bangla, Tamil, Telugu, Kannada, Gurmukhi) + Anek for UI | Indic editorial | A serif drawn for each script | 400 and italic only; no tnum |
| 20 | IBM Plex Sans + IBM Plex Sans Devanagari + IBM Plex Mono | Indic fintech | Same x-height across Latin and Devanagari | Devanagari is the only Indic script in Plex on Google Fonts |

For any other script, the Noto Sans and Noto Serif families for that script are the safe fallback.

## Faces that read as defaults

These are good typefaces. They read as "nobody chose this" when picked without a reason, because they are what templates and AI output reach for first. Google Fonts popularity ranks on 2026-10-15: Roboto 2, Open Sans 3, Poppins 4, Inter 5, Lato 5, Montserrat 7, Oswald 15, DM Sans 17, Raleway 18, Nunito 20, Outfit 24, Playfair Display 24, Plus Jakarta Sans 27, Manrope 31, Space Grotesk 49.

- Of Inter: "in headings it soon looks very generic or dull" ([Pimp my Type](https://pimpmytype.com/inter-pairings/)).
- A high-contrast serif display on a warm cream background with a terracotta accent, and small monospace data labels, have become recognisable AI looks too; pairings 2, 3 and 10 need care if styled that way.
- Popular isn't the same as bad: curated lists still recommend several of these faces. The tell is choosing one by habit. If the brand already uses one, keep it and build identity elsewhere.
