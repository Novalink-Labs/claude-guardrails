---
name: adr
description: Draft a new Architecture Decision Record, or update an existing one, in docs/adr using the team format (numbered file; Status, Date and Deciders; Context, Options, Decision, Open questions, Consequences; dated Updates). AI drafts the options and a recommendation; people accept. Use whenever work needs a decision on architecture, data models, product behaviour, UI patterns or security logic, when someone says "write an ADR", "record this decision", "why did we choose X" or "document this trade-off", or when a review flags a missing ADR.
argument-hint: "[decision to record | ADR number to update]"
---

# Decision records

Some decisions shouldn't be made by whoever happens to be typing, human or AI: architecture, data models, product behaviour, UI patterns and security logic. An ADR puts the options and a recommendation in front of the people who own the decision, then records what they chose so every later change and review can check against it. Accepted ADRs are binding; Proposed ones are not yet.

## Steps

1. **Look at what exists.** List `docs/adr/` with each title and status (read the status lines, not whole files). The next number is the highest existing number plus one, four digits, even if there are gaps. Read in full only the records related to this decision.
   - If one already covers the topic, update it instead of starting another.
   - If the new decision would reverse an accepted one, the new record says it supersedes that one if accepted.
2. **Get the facts.** What triggered the decision, what the code does today (cite `path:line`), constraints from the spec and other ADRs. Ask the user, in one message, for what you can't find: who decides, hard constraints (deadline, budget, compliance), options already ruled out.
3. **Lay out real options.** Two to four, each with what it gives and what it costs. Include "keep what we have" when that's a real option. Then a recommendation with the reasoning. Write it as a recommendation, never as a decision already made. When the decision is contested or costly to reverse, run `/guardrails:council` on the options first and build the recommendation from its conclusion, so it doesn't rest on one viewpoint.
4. **Write the file** `docs/adr/NNNN-short-kebab-title.md` from `references/adr-template.md`. Status `Proposed`, today's date, and the deciders (`TBD (team)` if nobody is named). Keep it as long as the decision needs and no longer.
5. **Accept only on a person's word.** Set `Accepted` only when someone with the authority says so in the conversation, and record who and when in Deciders. When a superseding record is accepted, change the old one's status to `Superseded by [NNNN](NNNN-title.md)`.
6. **Report:** the file path, the question being decided, the recommendation, and exactly what the user needs to decide.

## Updating an existing record

History stays readable, so don't rewrite accepted text:
- A change to an accepted decision gets a dated section at the end: `## Update (YYYY-MM-DD): <what changed>`.
- A resolved open question is struck through with the answer added: `- ~~Question?~~ **Decided YYYY-MM-DD: answer.**`
- Status changes happen on the status line, with the reason in an update section.

## After acceptance

If the decision creates a rule agents must follow, add it to AGENTS.md in the relevant section with a pointer, for example `## State and data (decided: docs/adr/0003-data-fetching.md)`, and remove it from "Decisions pending an ADR".
