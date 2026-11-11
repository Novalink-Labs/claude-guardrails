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
- Empty, null or missing input; zero, negative and maximum values; fractions where only whole numbers make sense (2.5 items); more decimals than the currency has (12.505); off-by-one at boundaries; very long strings; unicode. Bad input is refused with a message at the field, never clamped, rounded or dropped silently (`Math.max(0, …)`, `Math.round` on input, a filter that drops a line of 0).
- Clearing a field: the edit sends `null` and the server removes the value. A blank sent as `undefined` drops out of JSON, so the save answers 200 and keeps the old value.
- Same figure, two places: a preview, summary, badge or rule computed on the screen and again on the server, or on two screens, comes from one function. Check that they agree on rounding and on which records count.
- Duplicates and retries: is it idempotent? What happens when the same request, job or webhook arrives twice?
- Concurrency: two users or two instances at once; read-modify-write without a transaction or atomic update; check-then-act races.
- Failure: the database, a third-party API or the network fails halfway. Is anything left half-written? Is the error surfaced, logged and handled, or swallowed?
- Async: unawaited promises, unhandled rejections, missing cancellation, stale closures, effects that race (a slow response overwriting a newer one).
- Time: instants are stored in UTC, but "today", due dates, overdue and "days left" are worked out in the business's (or user's) time zone, not the server's UTC day. A date computed once at module load goes stale. Also DST, expiry checks, clock skew between client and server.
- Money and quantities: floating point for money, rounding, currency mix-ups (an amount relabelled into another currency without converting). Every total counts only the states it means: drafts, cancelled and void records, credit notes and refunds are in or out on purpose, and a refund is never counted as a sale. A missing figure shows as unknown, not 0.
- Pagination and limits: unbounded queries or lists, missing maximum page size, and the reverse: a total, export or picker built from only the first page of a paginated API.
- Contracts: does the frontend call an endpoint or field that the backend actually has, with the same types and the same enum and status names? Does the screen offer only values the server accepts, and ask for every step the server requires (an approval, a confirmation)? Are breaking API changes versioned?

## 3. Security and leaks

- Authentication on every new route, handler, server action, function or database rule unless explicitly public (and listed in the PR).
- Object-level authorisation: the record is checked against the caller's ownership or organisation, not just their role. Try the action with someone else's id in your head.
- Function-level authorisation: admin-only actions are actually restricted. A control the screen hides from a role is still refused by the server; call the route directly in your head. A permission gained one way (switching a setting later) is also required the other way (setting it at create time).
- Input validated at the edge with a schema; unknown fields rejected; types, lengths and formats checked.
- Injection: no string-built SQL or NoSQL operators from input, no shell commands, file paths, templates or HTML built from input, no `eval`.
- SSRF: no fetching a URL the user controls without an allow-list.
- Secrets: no keys, tokens, passwords or connection strings in the diff, tests, fixtures, docs or screenshots (patterns in `../../security-audit/references/leak-patterns.md`). No new `.env` or key files tracked.
- Exposure: responses return only intended fields (no password hashes, tokens, internal flags); errors don't leak stack traces or SQL; logs don't contain personal data or secrets; nothing secret in browser-exposed env vars or the mobile bundle.
- Tokens stored in httpOnly cookies or secure storage, never local storage; CSRF handled for cookie auth.
- Webhooks verify signatures and are idempotent. Uploads are type- and size-limited, with the type checked against the file's signature bytes (a declared `image/png` or a `.png` name proves nothing), and stored under server-generated names.
- Exports: CSV and spreadsheet cells starting with `=`, `+`, `-`, `@`, tab or carriage return are escaped; values with commas, quotes or newlines are quoted.
- Redirects: a `next` or return URL is parsed like the browser does and stays on this site.
- Child records and later writes: in your head, read, edit or delete a child (document, note, entry) of a parent you can't see; edit an amount after sign-off; submit or approve an entry whose project closed or whose access ended. Each is refused. A bulk action skips the failing item instead of aborting.
- Field visibility: a field hidden from a role (cost, rate, pay) is also hidden on the new endpoint, list, export or related record that returns it.
- Tokens: claims are read only after the signature is checked, on logout and revoke too; a system marker (revoke-all) can't be forged through a field the client fills; revocation fails closed, including with encrypted payloads. A new path that issues a session (refresh, change password, invite accept) applies the same status, role and access-window checks as sign-in.
- Cookies and devices: auth cookies are `__Host-` with no `Domain`; a "new device" check keys on a server-issued cookie, not request headers, and treats an unknown device as new.
- Secrets in URLs: no bearer token in an API path or query; access logs record the route template.
- Counters and proxies: attempt limits increment atomically; proxy trust is an exact list or hop count, never `true`; a server-side proxy doesn't forward the client's `X-Forwarded-For`.
- Cross-tenant: invite someone who already belongs to another organisation. Before they accept, you can't see or change their profile, learn whether they have an account, or bind their account.
- Bounds and jobs: page size and page number refuse negatives; a job or notification re-checks each recipient's current membership and role.
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
- Framework defaults left where people see them: the validator's own messages, the server's UTC day as "today", the arrow cursor on buttons, one generic page title everywhere.
- Generic AI-looking UI (see `/guardrails:ui-review`).

## 9. Backend

- Input validated before the handler runs; response serialised to allowed fields.
- Correct HTTP status codes; errors use the app's error codes and envelope. Validation messages are written for the person filling the form, not the validator library's defaults or property names.
- Audit and history entries record only fields that changed, with before and after values, and only what really happened (no "notified" when nothing was sent). Every field with business meaning is in the audited list.
- Multi-step writes: if a later step fails, the earlier ones are undone or marked, not left half done.
- HTTP keep-alive on the server is longer than the idle timeout of the proxy or load balancer in front of it.
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
- Accessibility: semantic elements, labels tied to their inputs, keyboard operation, visible focus, contrast, alt text, announced errors. A button repeated on each row names its item ("Archive Acme Ltd"), not just "Archive".
- Responsive at phone and desktop widths; no horizontal scroll; touch targets large enough; names and amounts stay readable rather than cut to a few letters beside buttons.
- Data: server state through the data-fetching library; no fetching in effects; loading and error handled; no stale or racing responses; caches keyed per user. After a write, every list and count it changed updates without a reload.
- Forms: validation messages under the field, disabled while submitting and until the next page opens (a second click on Create makes a duplicate), input kept on error, cleared fields sent as `null`, a confirmation that the save worked. Deleting, voiding or discarding asks first.
- Words on screen: no raw enum values, error codes, minor units (`amountMinor: 50000`) or validator text; status labels come from one map, not CSS capitalisation.
- Security: no secrets in client env vars; no unsafe HTML; tokens not in local storage; server actions and route handlers check auth.
- Performance: no large new client dependency for a small job; images sized; no unnecessary client components.
- Each page has its own title; SEO and metadata for public pages; private pages `noindex`. Nothing internal (design briefs, notes) ships hidden in the HTML.
- Copy matches the spec; no emojis or placeholder text; strings go through i18n if the app is localised.

## 12. Mobile

- Works on iOS and Android, small and large screens, with dynamic type and the screen reader.
- Tokens in secure storage; nothing secret in the bundle; deep-link parameters validated.
- Offline and slow-network behaviour as designed; permissions requested in context and refusal handled.
- Version and build number bumped for store builds; OTA-safe if shipped over the air.
