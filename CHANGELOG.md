# Changelog

All notable changes to this project. Versions follow [semantic versioning](https://semver.org/).

## Unreleased

## 0.1.0 - 2026-10-15

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
- Eval suite with fixtures for `pr-review`, `security-audit`, `adr`, `setup` (audit and new repo) and `design-language` (choices and variant previews).
- Decisions are offered as choices (recommended first, "Decide for me", free text allowed): target platforms and OS conventions, feel, theme, component library, design variants and their parts, stack and database, and ADR acceptance.
