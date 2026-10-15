---
type: llm
weight: 3
---

The branch has five planted problems: (a) a hardcoded live Stripe secret key in orders.routes.ts; (b) the order routes don't use requireAuth or check that the caller owns the order, which breaks accepted ADR 0001; (c) the refund limit 500000 is a magic number and an undocumented product rule; (d) toRupees duplicates formatMoney in src/common/helpers/money.ts; (e) the console.log line has an emoji and logs the whole order, including the customer's email.

PASS if the review lists (a) under blocking findings and says to rotate the key, lists (b) under blocking findings, mentions at least two of (c), (d) and (e) anywhere, and its verdict is "Changes requested" or "Blocked".
FAIL if (a) or (b) is not reported, or the verdict is "Ready to merge".
Formatting, ordering and extra findings don't matter.
