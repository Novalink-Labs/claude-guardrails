# Review checklist

Use the general sections for every review, and the stack sections only when the diff touches that area. The repo's AGENTS.md and accepted ADRs override anything here.

## Contents

1. Silent decisions
2. Critical bugs
3. Security and leaks
4. Structure and keep-it-small
5. Named values and style
6. Tests and coverage
7. Docs and hygiene
8. Vibe-coding tells
9. Backend
10. Database and migrations
11. Frontend
12. Mobile

## 1. Silent decisions (blocking)

Is each of these covered by the spec, the design or an accepted ADR? If not, it's a silent decision.
- Architecture: a new service, module boundary, queue, cache, datastore, external provider, background job, or a dependency that shapes the design.
- Data model: a new table or collection, fields with business meaning, changed enums or statuses, changed uniqueness, money or date representation.
- Product behaviour: new rules, limits, defaults, pricing, notification triggers, edge-case handling the spec doesn't describe, copy that promises something.
- UI patterns: a new component pattern, an invented loading, empty or error state, colours, spacing or motion outside the tokens.
- Security logic: who can access what, token handling, rate limits, validation rules, retention, what gets logged.

## 2. Critical bugs

For each changed function or component, walk the cases:
- Empty, null or missing input; zero, negative and maximum values; off-by-one at boundaries; very long strings; unicode.
- Duplicates and retries: is it idempotent? What happens when the same request, job or webhook arrives twice?
- Concurrency: two users or two instances at once; read-modify-write without a transaction or atomic update; check-then-act races.
- Failure: the database, a third-party API or the network fails halfway. Is anything left half-written? Is the error surfaced, logged and handled, or swallowed?
- Async: unawaited promises, unhandled rejections, missing cancellation, stale closures, effects that race (a slow response overwriting a newer one).
- Time: time zones (store UTC), DST, expiry checks, clock skew between client and server.
- Money and quantities: floating point for money, rounding, currency mix-ups.
- Pagination and limits: unbounded queries or lists, missing maximum page size.
- Contracts: does the frontend call an endpoint or field that the backend actually has, with the same types? Are breaking API changes versioned?

## 3. Security and leaks

- Authentication on every new route, handler, server action, function or database rule unless explicitly public (and listed in the PR).
- Object-level authorisation: the record is checked against the caller's ownership or organisation, not just their role. Try the action with someone else's id in your head.
- Function-level authorisation: admin-only actions are actually restricted.
- Input validated at the edge with a schema; unknown fields rejected; types, lengths and formats checked.
- Injection: no string-built SQL or NoSQL operators from input, no shell commands, file paths, templates or HTML built from input, no `eval`.
- SSRF: no fetching a URL the user controls without an allow-list.
- Secrets: no keys, tokens, passwords or connection strings in the diff, tests, fixtures, docs or screenshots (patterns in `../../security-audit/references/leak-patterns.md`). No new `.env` or key files tracked.
- Exposure: responses return only intended fields (no password hashes, tokens, internal flags); errors don't leak stack traces or SQL; logs don't contain personal data or secrets; nothing secret in browser-exposed env vars or the mobile bundle.
- Tokens stored in httpOnly cookies or secure storage, never local storage; CSRF handled for cookie auth.
- Webhooks verify signatures and are idempotent. Uploads are type- and size-limited with server-generated names.
- New dependencies: needed, maintained, licence acceptable, no known high or critical vulnerabilities.
- CI changes: no `pull_request_target` running PR code, no untrusted `${{ }}` in `run:`, minimal `permissions`.
- Sensitive areas (auth, payments, personal data, data isolation, secrets, uploads): recommend `/security-review` before merge.

## 4. Structure and keep-it-small

- Follows the repo's feature layout: thin entry points, business rules in services, data access only in repositories, request schemas and response shapes separate.
- YAGNI: no unused parameters, options, flags or config; no "for later" scaffolding; nothing the spec didn't ask for.
- KISS: no interface, factory or strategy with a single implementation; no clever one-liners where plain code is clearer; no needless layers.
- DRY: search for an existing helper, component, hook, type or constant before accepting a new one, and cite it if found. No copy-pasted blocks within the diff.
- A bug fix sits where all callers pass through; check the other callers.
- No dead or commented-out code. Deliberate shortcuts have a `ponytail:` comment naming the limit.
- New dependency justified when the platform or an installed package could do the job.

## 5. Named values and style

- No magic strings or numbers for statuses, roles, limits, durations, codes, keys, routes or event names; the constant exists once and is reused.
- Environment values read only through the config module.
- Units in duration and size names.
- No emojis in code, comments, log messages, commit messages, PR text or UI copy, unless the design explicitly includes them.
- Comments are one precise line saying why, and appear only where the code isn't obvious or departs from the repo's usual pattern. A departure with no comment is a finding; so is a comment that narrates the code.
- Naming matches the surrounding code.

## 6. Tests and coverage

- Business rules and decision branches have unit tests. A bug fix has a test that fails without the fix.
- Tests assert behaviour, not implementation details; no assertions on unexplained literals.
- Unit tests don't hit the network or a real database and control the clock.
- No `.only`, skipped tests, weakened assertions, or lowered coverage thresholds to get green.
- Coverage of the changed files didn't drop, and new business logic is covered. If the repo has a coverage script, run it and report the numbers; if it doesn't, say so.
- Critical flows touched by the change still have an end-to-end test.

## 7. Docs and hygiene

- Docs, ADRs and `known-issues.md` updated in the same PR as the behaviour they describe.
- One purpose per PR; Conventional Commit title; reasonable size.
- No AI attribution (`Co-Authored-By` trailers, "Generated with" lines).
- No `console.log`, debug flags, `TODO` without a ticket, placeholder text, lorem ipsum, or mock data wired into production paths.
- Lockfile changes match manifest changes.

## 8. Vibe-coding tells

Signs code was generated without understanding the codebase. Each one is worth a closer look:
- Imports, functions or APIs that don't exist in the installed versions (check `node_modules`, the lockfile or the docs).
- A new helper that duplicates one in the shared folder; a pattern that differs from every neighbouring file.
- Comments that narrate the obvious, or a comment that disagrees with the code.
- Broad `try/catch` that swallows errors or returns defaults; defensive checks for impossible states.
- `any`, type assertions or `!` to silence the compiler.
- Endpoints, fields or enum values the backend or spec doesn't have.
- Hardcoded sample data, fake ids or placeholder URLs.
- Generic AI-looking UI (see `/guardrails:ui-review`).

## 9. Backend

- Input validated before the handler runs; response serialised to allowed fields.
- Correct HTTP status codes; errors use the app's error codes and envelope.
- Transactions around multi-record changes; atomic operators for counters; unique indexes for idempotency.
- Queries indexed; no N+1; lists paginated with a maximum.
- Outbound calls have timeouts; retries only for idempotent operations.
- Slow work moved off the request path; jobs idempotent.
- Rate limits on sensitive or expensive endpoints.
- Config validated at startup; new env vars added to `.env.example` and the config schema.
- Logs structured with the request id; no personal data.
- Backward compatibility: clients running the previous version still work during deploy.

## 10. Database and migrations

- Every schema change has a migration, and it runs forward cleanly on existing data.
- Expand and contract: add, backfill, switch, then remove in a later release; no destructive change in the same deploy as the code that stops using it.
- Long-running migrations or backfills don't lock hot tables; large backfills run in batches.
- Indexes for new query paths; constraints for new invariants.
- Rollback is possible, or the PR says why it isn't and what the recovery plan is.
- BaaS: row-level security or security rules updated for new tables and collections, with tests for allowed and denied access.

## 11. Frontend

- Matches the design: layout, tokens, typography, and every designed state (loading, empty, error, disabled, offline). No invented states.
- Uses the chosen component library (DESIGN.md or its ADR) instead of hand-rolled dialogs, menus, selects, comboboxes, tabs, toasts, tooltips or date pickers; no literal colours, sizes or fonts in components. For deeper UI checks, suggest `/guardrails:ui-review`.
- Accessibility: semantic elements, labels, keyboard operation, visible focus, contrast, alt text, announced errors.
- Responsive at phone and desktop widths; no horizontal scroll; touch targets large enough.
- Data: server state through the data-fetching library; no fetching in effects; loading and error handled; no stale or racing responses; caches keyed per user.
- Forms: validation messages, disabled while submitting, no double submit, input kept on error.
- Security: no secrets in client env vars; no unsafe HTML; tokens not in local storage; server actions and route handlers check auth.
- Performance: no large new client dependency for a small job; images sized; no unnecessary client components.
- SEO and metadata for public pages; private pages `noindex`.
- Copy matches the spec; no emojis or placeholder text; strings go through i18n if the app is localised.

## 12. Mobile

- Works on iOS and Android, small and large screens, with dynamic type and the screen reader.
- Tokens in secure storage; nothing secret in the bundle; deep-link parameters validated.
- Offline and slow-network behaviour as designed; permissions requested in context and refusal handled.
- Version and build number bumped for store builds; OTA-safe if shipped over the air.
