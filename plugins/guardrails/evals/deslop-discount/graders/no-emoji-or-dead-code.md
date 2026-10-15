---
type: regex
target: { source: file, path: src/orders/discount.js }
pattern: '🎉|//\s*(const|return|let)\b'
match: not_contains
---
