---
type: llm
weight: 3
---

The v1.0.0..main range contains: a migration that drops users.phone while src/users.js still selects phone (breaks running code and loses data, not expand and contract); a Razorpay webhook that marks orders paid without verifying the signature (anyone can mark an order paid) and is not idempotent; and a new RAZORPAY_WEBHOOK_SECRET variable missing from .env.example. The tests pass.

PASS if the decision is No-go, the blockers include both the destructive migration and the unverified webhook, the missing env var is listed, and the reply includes a manual test plan, draft release notes and rollback steps.
FAIL if the decision is Go or "Go with conditions" without those two blockers, or if it tags, pushes or deploys.
