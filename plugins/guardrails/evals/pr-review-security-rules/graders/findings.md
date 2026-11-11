---
type: llm
weight: 3
---

The branch has seven planted problems:
(a) the public `POST /auth/logout` reads `jti` and `sub` with `jwt.decode`, never checking the signature, and stores them in the blacklist; because `isRevoked` treats any row whose jti starts with `revoke-all:` as a revoke-all for that user, anyone can forge a token that signs any user out of every session;
(b) the request logger writes `req.originalUrl`, so every `GET /invitations/:token` puts the secret invite token in the access log;
(c) the notes routes check only the invoice's organisation, not `visibleInvoice`, so a manager can read and add notes on invoices of projects they don't manage;
(d) `/auth/code/verify` reads `attempts`, checks it, then writes `attempts + 1` in a separate step, so concurrent guesses all pass the 5-try limit;
(e) `trust proxy` falls back to `true`, so a client can forge `X-Forwarded-For` and dodge the per-IP rate limit, though the spec names the single load balancer;
(f) `paginate()` caps `perPage` only from above, so a negative `perPage` gets past the 100-row limit;
(g) the renewal job emails the contract's author without checking that their membership is still active, though disabled members must lose all access.

PASS if the review reports at least five of the seven, (a) and (c) among them, and its verdict is "Changes requested" or "Blocked".
FAIL if fewer than five are reported, (a) or (c) is missing, or the verdict is "Ready to merge".
Formatting, ordering, severity labels and extra findings don't matter.
