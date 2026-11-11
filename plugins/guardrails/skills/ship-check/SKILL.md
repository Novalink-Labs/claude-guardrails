---
name: ship-check
description: Release readiness gate for backend, frontend and mobile, so no critical bug ships. Runs the repo's checks and coverage, reviews what changed since the last release with a critical-bug and security lens, checks migrations, config, observability, rollback, designed states, accessibility, performance and client-bundle leaks, and writes the manual test plan for what automation doesn't cover. Ends with Go, Go with conditions, or No-go, plus release notes and rollback steps. Use before tagging or deploying a release, before a launch or demo to real users, or when someone asks "are we ready to ship", "release checklist", "go/no-go" or "what could break in production".
argument-hint: "[release range, e.g. v1.4.0..HEAD] [backend | frontend | mobile]"
---

# Ship check

A release fails in production for a handful of reasons: an untested path in new code, a migration that locks or breaks data, a missing environment variable, a secret in the bundle, a state the UI never handled, no way to roll back, or no way to see that it broke. This check looks for exactly those, in that spirit, and ends with a clear decision.

It doesn't deploy, tag or change code. It prepares the commands and the notes; a person ships.

## Work efficiently

Scope everything to the release range. Review the risky diffs in depth (auth, payments, data model, migrations, critical flows) and skim the rest. Diff output has no file line numbers, even when you read it back from a saved file: before citing `path:line`, open the file at the range's end or `git grep -n` it there. Reuse the checklists of the other skills instead of re-deriving them. Run each command once.

## 1. Scope the release

- Range: from `$ARGUMENTS`, or the last release tag to `HEAD` (`git describe --tags --abbrev=0`).
- What's in it: `git log --oneline <range>` and the merged PRs. Flag commits that reached the default branch without a PR, and PRs whose review was "Changes requested" or "Blocked".
- Which areas it touches: backend, frontend, mobile, database, infrastructure, CI. Load the matching sections of `references/readiness.md`.

## 2. Automated gate

Run the repo's own checks, as CI would: install from the lockfile, typecheck, lint, unit tests with coverage, build, and end-to-end tests if they exist and run locally. Any failure is a No-go until fixed.

Coverage: report overall and for the files changed in the range. A drop on changed business logic, or new business logic with no tests, is a blocker. If the repo has no coverage tooling, say so and list it as a condition.

## 3. Critical-bug and security pass on the risky changes

For each change in the range that touches auth, payments, data isolation, the data model, migrations, or a critical user flow, apply sections 2 and 3 of `../pr-review/references/checklist.md`: walk the edge cases, concurrency, failure and retry paths, and access control. Then:
- Secrets: `gitleaks git --log-opts="<range>" --redact --no-banner -v` if installed, otherwise the patterns in `../security-audit/references/leak-patterns.md` over the range's diff.
- Dependencies: the ecosystem audit for high and critical issues in production dependencies.
- If no full `/guardrails:security-audit` has run since the last release, recommend one.

## 4. Readiness by area

Go through `references/readiness.md` for each area the release touches: backend, database, frontend, mobile, and operations. Record each item as pass, fail, or not applicable, with evidence (file, command output, or the person who confirmed it). Items you can't check from the repo (production env vars set, backups tested, alerts configured) become questions for the user, not assumptions.

## 5. Manual test plan

Write the manual tests this release needs, only where automated tests don't reach, as steps with expected results someone can tick off on staging:
- each critical flow the release touches, end to end, at phone and desktop widths (and on a real iOS and Android device for mobile);
- payments, email, SMS, push and webhooks in the providers' sandbox;
- permissions: as the wrong user, signed out, with a tampered id;
- migrations on a copy of production-shaped data, and the rollback;
- accessibility on the changed screens with keyboard only and a screen reader;
- anything the automated gate couldn't run here.

## 6. Decide and report

```markdown
## Ship check: <version or range> (<date>)

**Decision:** Go | Go with conditions | No-go
**Range:** v1.4.0..HEAD · 23 commits · 9 PRs · backend, frontend, database
**Automated gate:** typecheck passed · lint passed · tests 412 passed · coverage 78% overall, changed files 85% · build passed · e2e not run (no local browser)

### Blockers
1. **<title>** · `path:line` or <check> · <why it stops the release> · Fix: <smallest fix>

### Conditions
- [ ] <What must be true before or right after deploying, and who confirms it>

### Manual test plan
- [ ] <Step> → <expected result>

### Readiness
| Area | Item | Status | Evidence |
|---|---|---|---|

### Release notes (draft)
<From the Conventional Commit titles: Features, Fixes, Breaking changes, Migrations, Config changes.>

### Deploy and rollback
<The deploy steps in order (migrations first or last, flags to flip), and how to roll back each step, including data.>
```

- **No-go:** any failing automated check, critical bug, security hole, leaked secret, untested business logic in the range, an irreversible migration without a recovery plan, or a missing production config the user can't confirm.
- **Go with conditions:** everything blocking is clear, but some items need a person to confirm (manual tests, env vars, alerts).
- **Go:** nothing outstanding.

If the go or no-go is disputed (someone wants to ship despite a blocker, or a risk is hard to size), run `/guardrails:council` on it and include the conclusion.

Offer to draft the tag command and changelog entry once the user decides. Never tag or deploy yourself.
