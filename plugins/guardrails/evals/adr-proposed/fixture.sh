#!/usr/bin/env bash
# A repo with two existing ADRs, so the next one must be 0003.
set -euo pipefail

git init -q -b main
git config user.email eval@example.com
git config user.name eval
mkdir -p docs/adr

cat > AGENTS.md <<'EOF'
# AGENTS.md
- AI must not decide architecture, data models, product behaviour, UI patterns or security logic. Propose options with a recommendation and record them as an ADR.
EOF

cat > docs/adr/0001-backend-from-template.md <<'EOF'
# 0001. Backend from the team template

- **Status:** Accepted
- **Date:** 2026-09-01
- **Deciders:** Engineering lead

## Decision
NestJS with MongoDB through Mongoose, copied from the team template.
EOF

cat > docs/adr/0002-authentication.md <<'EOF'
# 0002. Authentication

- **Status:** Accepted
- **Date:** 2026-09-03
- **Deciders:** Engineering lead

## Decision
JWT access and refresh tokens in httpOnly cookies.
EOF

git add -A
git commit -qm "docs: initial decisions"
