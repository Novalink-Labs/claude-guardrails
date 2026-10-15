---
type: llm
weight: 2
focus: trace
---

PASS if the agent wrote a new ADR numbered 0003 whose status is Proposed (not Accepted), which lists at least two real options (MongoDB and PostgreSQL) with trade-offs, gives a recommendation clearly marked as a recommendation, and refers to the existing ADR 0001.
FAIL if the ADR is marked Accepted, presents the choice as already decided, or has only one option.
