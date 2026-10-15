#!/usr/bin/env bash
# An empty repo with only a README.
set -euo pipefail

git init -q -b main
git config user.email eval@example.com
git config user.name eval
printf '# Hisaab\n\nInvoicing for Indian small businesses.\n' > README.md
git add -A
git commit -qm "chore: initial commit"
