---
name: council
description: Evidence-first council for decisions and verdicts, so a recommendation isn't one viewpoint's bias. Builds an evidence ledger, has an independent defender and skeptic argue only from it, reviews their disagreements claim by claim, lets an independent judge weigh the evidence, audits for invented facts, and concludes with a status (Supported, Likely, Uncertain, Unlikely, Unsupported) and a confidence, where "insufficient evidence" is a valid answer. Use for stack, database and architecture choices, ADR options, choosing between design variants, go or no-go disputes, root-cause questions, "should we", "which is better", "is this true, safe or fixed", or any decision that is expensive to reverse.
argument-hint: "[question or decision]"
---

# Council

One line of reasoning tends to argue for whatever it thought of first. The council separates gathering evidence from arguing, and arguing from judging, so the conclusion rests on evidence rather than on the most persuasive wording. Agreement between viewpoints, or between agents, is not evidence; only the ledger is.

## When it's worth it

Use it for decisions that are contested or costly to reverse. For a small, reversible choice, a short options-and-recommendation answer is enough: say so and skip the council.

## Work efficiently

Gather evidence once, in phase 1, and hand the ledger to every later phase instead of researching again. Keep each phase short. If subagents are available, run the defender and the skeptic as two independent subagents that receive only the question and the ledger, never each other's output. Otherwise write the defender, then the skeptic, without revising the first after writing the second.

## Rules for every phase

- Never invent facts, sources, numbers, quotes or technical details. If something can't be established, write UNKNOWN.
- Label the claims that matter: **FACT** (seen in a source you actually checked: code, docs, command output, a page you fetched), **INFERENCE** (follows from facts), **ASSUMPTION** (needed because information is missing), **OPINION**, **UNKNOWN**.
- Prefer primary evidence (the repo, official docs, measurements) over summaries and memory.
- When evidence conflicts, show the conflict instead of quietly picking a side.
- "Insufficient evidence" is a valid conclusion, and so is "both options are wrong".

## Phase 1: Researcher

State the exact question. Break it into claims C1, C2 and so on. For each claim, find the evidence for and against, its source, how reliable and current it is, and whether it's established or inferred. For repo decisions, look in the code, the ADRs, AGENTS.md and any measurements; for options, include the constraints the team gave.

| ID | Claim | Evidence | Source | Reliability | Status |
|---|---|---|---|---|---|
| C1 | | | | High / Medium / Low | Fact / Inference / Unknown |

Don't argue for or against a conclusion yet.

## Phase 2: Defender

The strongest case for the proposition, or for each option when comparing. Every argument cites its claim IDs, the evidence, the assumptions it needs, and how strong it honestly is. No new facts.

## Phase 3: Skeptic

Try to disprove it. Look for unsupported assumptions, weak or outdated sources, logical gaps, correlation taken for causation, alternative explanations, selection or survivorship bias, missing context, overgeneralisation, and conclusions stronger than the evidence. Cite claim IDs. The aim is to find where the reasoning could be wrong, not to win.

## Phase 4: Adversarial review

For each disputed claim: what the defender says, what the skeptic challenges, the evidence on each side, which is stronger and why, and whether the dispute is factual, methodological or interpretive. If the evidence doesn't settle it, mark it **UNRESOLVED**. Never settle a dispute by which side is better worded.

## Phase 5: Judge

Weigh the original evidence yourself, not the two sides' rhetoric: directness, reliability, recency, independence, consistency, method quality, and whether it actually addresses the claim. Three weak sources don't outweigh one strong primary source. Give each major claim one status: SUPPORTED, PARTIALLY SUPPORTED, UNCERTAIN, PARTIALLY REFUTED, REFUTED or UNSUPPORTED, with the evidence behind it.

## Phase 6: Hallucination audit

Before concluding, check: did anything get invented; was any source cited without being checked; did an inference become a fact; was outdated information used as current; was an unproven premise accepted; did the conclusion grow stronger than the evidence? Fix the reasoning if so.

## Phase 7: Conclusion

```markdown
## Council: <question>

**Status:** Supported | Likely | Uncertain | Unlikely | Unsupported
**Confidence:** Low | Medium | High

### What we know
### Strongest evidence
### Strongest counter-evidence
### What remains uncertain
### Key assumptions
### Reasoning
### What would change the conclusion
```

When comparing options, end with the recommended option, its status and confidence, and the runner-up with what would make it win.

## Hand-off

The council recommends; people decide. For architecture, data model, product, UI or security decisions, continue with `/guardrails:adr`: the ledger becomes the Context, the options and phases inform Options, and the conclusion is the recommendation, still Proposed until someone accepts it.
