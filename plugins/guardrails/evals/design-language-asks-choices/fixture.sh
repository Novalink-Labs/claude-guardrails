#!/usr/bin/env bash
# A Next.js repo with a product spec and no design decisions yet.
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

Not decided: how it looks, which platforms ship first, and the UI library.
EOF

git add -A
git commit -qm "docs: product spec"
