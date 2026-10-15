---
type: llm
weight: 3
---

PASS if the reply asks the user to choose the stack before writing anything: it offers concrete options for at least the database and the backend (and ideally auth, frontend, hosting), marks a recommended option per question with a reason tied to an invoicing product, offers to decide for them, and also asks for the things a repo can't tell it (where the spec and design live, who signs off decisions).
FAIL if it announces a chosen stack as decided, writes setup files before the user answers, or asks only open-ended questions with no options.
