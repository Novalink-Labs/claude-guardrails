#!/usr/bin/env bash
# The same Khoj repo, plus category research notes the team already gathered.
set -euo pipefail

git init -q -b main
git config user.email eval@example.com
git config user.name eval
mkdir -p docs

cat > package.json <<'EOF'
{ "name": "khoj-web", "private": true, "dependencies": { "next": "^16.0.0", "react": "^19.0.0", "tailwindcss": "^4.0.0" } }
EOF

cat > docs/spec.md <<'EOF'
# Khoj: product spec (excerpt)

Khoj helps families in Pune find a home to rent or buy. Listings are verified by our field team, so there are no fake listings and no broker spam.

Users: parents aged 30 to 50 searching together, mostly on their phones in the evening, comparing a handful of homes over a few weeks.

Core flows: search with filters (area, budget, BHK, school distance), a listing page with verified photos and a visit booking, and a shortlist the family shares.
EOF

cat > docs/research.md <<'EOF'
# Category research (done by the team)

- 99acres, MagicBricks, NoBroker, Housing.com: dense listing grids, banner ads, red and orange urgency badges, many competing calls to action, phone-number capture walls. Users told us they feel pushed and distrust the photos.
- Airbnb and Zillow: calm listing pages, large photos, one clear primary action, map plus list on desktop.
- We want the opposite of the Indian portals: calm, trustworthy, family-friendly, with the verification visible.
- Prices are in rupees with Indian grouping (e.g. 1,25,00,000) and most users also read Hindi or Marathi.
EOF

git add -A
git commit -qm "docs: spec and category research"
