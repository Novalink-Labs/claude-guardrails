# Changelog

All notable changes to this project. Versions follow [semantic versioning](https://semver.org/).

## 0.1.0 - 2026-11-11

### Added

- `setup`: repo guardrails for any stack: AGENTS.md with feature structure and platform best practices, AI usage policy, ADRs, stack interview with best-practice defaults, git workflow and branch protection, CI with coverage, secret scanning and PR-title check, Dependabot, PR template, audit mode for existing codebases.
- `adr`: decision records in a numbered, reviewable format.
- `design-language`: category research, inspiration, component-library choice, design-language variants with previews, DESIGN.md and tokens; screen mode for single screens.
- `pr-review`: readiness gate for docs, then an in-depth review with verified findings, coverage and a manual test list.
- `ui-review`: UI checked against the design language, generic-AI tells, states, accessibility and responsiveness.
- `deslop`: behaviour-preserving cleanup of AI-style code.
- `security-audit`: repo-wide secrets, access-control, injection, BaaS rules, CI and dependency audit.
- `ship-check`: release go or no-go for backend, frontend and mobile, with release notes and rollback.
- `council`: evidence-first decision council used by `adr`, `setup`, `design-language` and `ship-check` for contested or hard-to-reverse decisions.
- Eval suite with fixtures for `pr-review`, `security-audit`, `adr`, `setup` (audit and new repo), `design-language` (choices and variant previews), `ui-review`, `deslop` and `ship-check`.
- Decisions are offered as choices (recommended first, "Decide for me", free text allowed): target platforms and OS conventions, feel, theme, component library, design variants and their parts, stack and database, and ADR acceptance.
- Off-the-happy-path rules, drawn from 166 bugs that visual QA found across three production apps. `setup` writes them into AGENTS.md, so code is written with them, and `pr-review`, `ship-check` and `security-audit` check them. They cover:
  - odd numbers refused rather than clamped;
  - cleared fields sent as `null`;
  - one function for a figure the screen and server both compute;
  - totals that count only the right states (drafts, voids, credit notes, refunds);
  - totals and pickers read from every page;
  - screen and server agreeing on options and steps;
  - "today" in the business's time zone, never fixed at module load;
  - audit entries that record only real changes;
  - words for people, not validator defaults or raw codes;
  - defaults chosen on purpose;
  - per-row button names;
  - upload types checked by their bytes;
  - CSV formula escaping;
  - redirects kept on-site;
  - permissions enforced on the server, not by hiding controls.
- `pr-review` manual test list: odd input, double submit, clearing a field, totals compared across screens, and each role (and one that can't reach the change).
- Eval `pr-review-off-happy-path`: an invoices branch that works on the happy path but carries seven of these bugs.
