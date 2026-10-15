## What and why

<!-- One purpose per PR. What changes for the user or the system, and why now. -->

Spec / design / ticket:

## Decisions

<!-- Does this change architecture, a data model, product behaviour, a UI pattern or security logic?
     Link the ADR (accepted, or proposed in this PR). Otherwise write "None". -->

ADRs:

## Automated tests

<!-- Tests added or changed. Coverage of the changed files before and after, if CI reports it. -->

## Manual testing

<!-- Steps you ran by hand and what you saw: UI against the design at mobile and desktop widths (screenshots),
     real devices, payment or email flows in sandbox, migrations on realistic data, keyboard and screen reader.
     If none was needed, say why. -->

## Checklist

- [ ] Builds only what the spec asks for: no "for later" code, flags or abstractions
- [ ] Reuses existing helpers, components and constants; no duplicated logic
- [ ] No magic strings or numbers; environment values go through config
- [ ] Follows the project structure (thin entry points, rules in services, data access in repositories)
- [ ] Business rules have tests; a bug fix has a test that failed before the fix
- [ ] Docs and ADRs updated in this PR
- [ ] No secrets, keys or personal data in code, logs, fixtures or screenshots
- [ ] `/security-review` run if this touches auth, payments, personal data, data isolation, secrets or uploads
- [ ] `/guardrails:pr-review` run and its blocking findings resolved
- [ ] No AI attribution in commits or this description

## New dependencies and public routes

<!-- Each new dependency with its reason, and each new unauthenticated route. Otherwise "None". -->
