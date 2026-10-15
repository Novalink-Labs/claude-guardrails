---
type: regex
target: { source: file, path: .github/workflows/ci.yml }
pattern: 'run:[^\n]*\$\{\{\s*github\.event\.pull_request\.title'
match: not_contains
---
