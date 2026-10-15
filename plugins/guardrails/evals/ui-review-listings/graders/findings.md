---
type: llm
weight: 3
---

The listings page breaks its DESIGN.md in these ways: (1) a purple-to-blue gradient and hardcoded hex colours instead of tokens; (2) the Inter font instead of Newsreader and Instrument Sans; (3) emojis in the title and heading; (4) lorem ipsum and a generic "Unlock your dream home" headline; (5) no loading, empty or error states; (6) a clickable div instead of a button, with no keyboard access; (7) an image with no alt text; (8) off-scale text sizes such as 13.5 px and 19 px; (9) a hand-rolled modal instead of the Dialog component; (10) the price shown as ₹ plus a raw number instead of Intl en-IN currency formatting.

PASS if the review ties its findings to DESIGN.md (tokens, type, craft or library rules), reports at least seven of the ten problems with file paths and a concrete fix for each, and does not say the page matches the design.
FAIL if it reports fewer than seven, never refers to DESIGN.md, or says the page is ready to ship.
