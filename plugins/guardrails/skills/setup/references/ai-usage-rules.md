# AI-assisted development policy

<Default policy from the guardrails plugin. Edit it to match your team; it's yours once it's in the repo.>

## Objective

- The product spec, the design and the decision records (`docs/adr/`) are the source of truth.
- AI speeds up implementation.
- We don't do vibe coding: AI doesn't make product or architecture decisions as it goes.

## Workflow

Product spec, then a design ready for development, then the developer breaks the work into components and endpoints, then AI-assisted implementation, then verification against the spec and design, then PR review, then merge.

### AI is used for

- Implementing screens, components and API endpoints from the spec and design
- Tests, mock data for tests, and documentation
- Refactoring and debugging
- Research, reviews and audits

### AI does not decide

- Architecture
- Product behaviour
- Data models
- UI patterns
- Security logic

When a task needs one of these decisions, AI lays out the options with a recommendation and waits. Accepted decisions become ADRs. A person may delegate a decision explicitly; the ADR records who delegated it and when.

## Golden rule

If something isn't defined in the spec or the design, AI doesn't invent it.

Missing states (loading, empty, error, hover, disabled, offline) either reuse an existing pattern from the design system, or get clarified with Product or Design.

## Repository standards

- `AGENTS.md`: the rules every agent and developer follows. `CLAUDE.md` imports it.
- `DESIGN.md`: the design language, for repos with a UI.
- `/docs`: engineering and product documentation.
- `/docs/ai`: this policy and any shared prompts.
- `/docs/adr`: architecture decision records, numbered.

## How standards are enforced

By the system, not by memory or discipline:

- Repository instructions in `AGENTS.md`
- Required CI checks: typecheck, lint, tests with coverage, build, secret scan, PR-title check
- Branch protection: pull requests only, one human approval, squash merge
- Reviews: `/guardrails:pr-review` on every PR, `/guardrails:ui-review` on UI changes, Claude Code's `/security-review` on sensitive changes
- Releases: `/guardrails:security-audit` and `/guardrails:ship-check` before tagging

The goal is to make the correct approach the easiest approach.
