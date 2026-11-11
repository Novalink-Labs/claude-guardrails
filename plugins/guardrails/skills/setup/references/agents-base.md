# AGENTS.md base

Copy this into the repo's `AGENTS.md`, fill the angle-bracket parts from the survey, and add the project structure and platform sections. Delete any line that doesn't apply rather than leaving it vague.

---

# AGENTS.md

Instructions for every AI agent and every new developer in this repo. `CLAUDE.md` imports this file, so there is one copy. This file holds the rules; the details live in `docs/`.

## What this repo is

<One short paragraph: the product, who uses it, what this repo contains (API, web app, mobile app, library), and what it talks to.>

## Commands

<Only commands that exist in this repo: install, run locally, typecheck, lint, test, build, format. Say where the runtime and package-manager versions are pinned.>

- CI runs <the checks>. All of them must pass before a merge.

## Non-negotiables

### Source of truth

- The product spec (<where>), the design (<where>) and the decision records in `docs/adr/` are the source of truth. AI implements them; it doesn't invent.
- AI must not decide architecture, product behaviour, data models, UI patterns or security logic. Lay out the options with a recommendation and wait for sign-off. Record accepted decisions as an ADR (`/guardrails:adr`).
- For missing states or behaviour (loading, empty, error, limits, edge cases), reuse a pattern that already exists in this repo, or ask. Never fill the gap silently.
- If something isn't in the spec or the design, don't build it. Raise it.
- UI follows `DESIGN.md` and the chosen component library. A new screen starts by looking at how comparable shipped products solve it (`/guardrails:design-language screen`). <Keep this line only in repos with a UI.>
- Full policy: `docs/ai/ai-usage-rules.md`.

### Keep it small

- **Ponytail:** ship the simplest thing that works.
- **YAGNI:** build only what the current spec needs. No scaffolding "for later", no speculative options, flags or abstractions.
- **KISS:** boring code beats clever code.
- **DRY:** one source for each fact. Search for an existing helper, component, hook, constant or type before writing a new one.
- Related principles, and how they rank here:
  - Single responsibility and separation of concerns: one reason to change per module, function or component (see Project structure).
  - Explicit over implicit: no hidden global state.
  - Fail fast, fail closed: validate configuration at startup; when an access check can't decide, deny.
  - Least privilege for code, credentials and CI tokens.
  - Composition over inheritance.
  - Interfaces, factories and strategies only once there are two real implementations. When a principle and ponytail disagree, the shorter correct code wins.
- Don't add a dependency when the language, the framework or an installed package already does the job. Justify every new dependency in the PR.
- Aim for the shortest correct diff. Delete dead code; don't comment it out.
- Comments are one precise line, and only where the code isn't obvious or departs from the usual pattern; they say why, not what. No comments that narrate the code, no banner blocks, no commented-out code.
- Mark a deliberate shortcut with a known limit with a `ponytail:` comment that names the limit and how to lift it.
- Fix a bug where every caller passes through, not only on the path the ticket mentions.

### No magic strings or numbers

- Every fixed value gets a named constant or enum: statuses, roles, types, limits, durations, error codes, header, cookie and query names, routes, cache and storage keys, event names, regexes.
- They live in the owning feature's constants file. Values shared across features go in one shared constants module.
- Values that change per environment come from configuration, validated at startup and read in one config module only.
- Put the unit in duration and size names (`OTP_EXPIRY_MINUTES`, `MAX_UPLOAD_BYTES`).
- Define each enum once and use it everywhere: database schema, validation and API docs.
- Tests use named values too; no unexplained literals in assertions.

### Off the happy path

Most bugs that reach QA live here. Before calling a change done, decide what it does with each case it can meet:

- **Odd input:** refuse what doesn't fit; never clamp, round or drop it silently. Counts take no fractions, money takes no more decimals than its currency, and zero, negative, blank and very large values each get a decision. The message sits under the field, and the server refuses the same values.
- **One figure, one function:** a total, rounding or rule shown on screen and saved by the server comes from the same code, or the screen asks the server.
- **Totals name what they count:** drafts, cancelled and void records, credit notes and refunds are in or out on purpose. A figure that isn't known shows as unknown, not 0. A total or picker never reads just the first page of a paginated list.
- **Screen and server agree:** the screen offers only what the server accepts, asks for every step the server requires (approval, confirmation), and uses the server's names for fields, statuses and types.
- **Clearing clears:** a cleared field is sent as `null` and the server removes the value. `undefined` drops out of JSON, so the save reports success and changes nothing.
- **The business's day:** store instants in UTC, but work out "today", due dates and deadlines in the business's time zone, on each request. Never compute a date once when a module loads.
- **Twice at once:** a double click, a retry or two users at the same moment can't create twice, pay twice or skip a limit. Keep the form locked until the result or the next page arrives; use atomic updates, transactions and idempotency keys.
- **Half done:** if a later step fails, undo or mark the earlier ones.
- **Feedback:** every write says it worked and refreshes every list and count it changed. Deleting or voiding asks first.
- **Words for people:** no validator defaults ("must be shorter than or equal to"), raw enum values, codes or minor units on screen, and no status words reshaped with CSS. An error says what to do next.
- **History tells the truth:** audit entries record only what changed, with before and after values, and never claim something that didn't happen (an email "sent" that wasn't).
- **Defaults chosen, not inherited:** time zone, validation messages, server keep-alive (longer than the proxy's in front of it), cursor and focus styles, and each page's title and robots tag.

### Security

- Every route, handler, server action and database rule requires authentication unless it is explicitly public. A PR lists any new public ones.
- Authorise each access to a record by its owner or organisation, not by role alone. Hiding a control on screen is never the check: the server refuses it too.
- Validate all input at the edge with a schema. Never build queries, shell commands, file paths or HTML from raw input.
- Check uploads by their content (the file's signature bytes), not the declared type or extension.
- Escape exported CSV and spreadsheet cells that start with `=`, `+`, `-`, `@`, tab or carriage return.
- Keep sign-in and "return to" redirects on this site; parse the target the way the browser will.
- Secrets come only from the environment or a secret manager. Never commit `.env` files, keys or credentials. A leaked secret is rotated first, then removed.
- No secrets, tokens, passwords or personal data in logs, error messages, URLs or client bundles.
- Child records (documents, notes, entries, milestones) follow their parent's access rule on read, edit and delete. Every write path (edit, submit, approve, bulk) re-checks the caller's scope and the record's state, not just create. Editing something signed off or approved reopens it or is refused. A bulk action skips and reports the items that fail, rather than failing the batch.
- Field rules (costs, rates, margins, pay) hold on every endpoint that returns the record: lists, related records, exports and PDFs. Serialise responses from an allow-list of fields.
- Never store or act on claims from a token whose signature you haven't checked, logout and revoke included. System markers (revoke-all, admin) get their own field, never a prefix in a value input can fill. Revocation reads verified, decrypted claims and fails closed.
- Every path that issues a token (sign-in, refresh, code verify, invite accept, password change, SSO) applies the same checks: account and membership status, role, access window.
- Auth cookies are host-only: `__Host-` prefix, `Secure`, `Path=/`, no `Domain`. Moving to host-only expires the old parent-domain copy and rotates the signing secret.
- "New device" alerts key on a server-issued random cookie, never on client headers (User-Agent, language). A device with no record counts as new.
- Bearer secrets (invite, reset, share and form links) go in the URL fragment of the link and the body of the API call, never a path or query string. Access logs record the route template, not the concrete path.
- Attempt limits (OTP, codes, PINs) count and check in one atomic update.
- Behind a proxy, trust exactly its addresses or hop count, never `true`, and refuse to start in production without it. A server-side proxy sets `X-Forwarded-For` itself; it never relays the client's.
- A person's account is theirs: another organisation can't read or edit their shared profile by inviting them, so store what the inviter typed on the invite or membership. Email lookups (invite, sign-in, reset) don't reveal whether an account exists or its status, and never attach an existing account to an organisation before the person accepts.
- Page size and page number have a lower bound as well as a cap.
- Scheduled jobs, emails and notifications re-check each recipient's membership and role when they send.
- Run `/security-review` before merging anything that touches auth, payments, personal data, data isolation, secrets or file uploads. Run `/guardrails:security-audit` and `/guardrails:ship-check` before each release.

### No AI attribution, no emojis

- No `Co-Authored-By` trailers and no "Generated with ..." lines in commits, PRs, code or docs.
- No emojis in code, comments, log messages, commit messages, PR text, docs or UI copy, unless the design explicitly includes them.

## Working efficiently (for agents)

Climb this ladder and stop at the first rung that works:

1. Does it need to exist? If the spec doesn't ask for it, don't build it; say so in one line.
2. Is it already in this repo? Search before writing, and reuse the helper, component, type or constant.
3. Does the language's standard library or the platform do it?
4. Does an installed dependency do it?
5. Can it be one line?
6. Only then, write the minimum code that works.

- Understand before changing: read the task and the code it touches, trace the real flow, then make the smallest change in the right place.
- Read what you need, not everything: search first, open the matching files, read the relevant parts.
- Batch independent reads and searches. Run long commands once.
- Run a check once after a change; run it again only after changing code again.
- Don't add docs, changelogs, refactors or extra tests the task didn't ask for. Tests the rules below require are part of the task.
- Keep explanations short: what changed, what was skipped, and when to add it.
- Use subagents for independent parallel work or large searches, not for small lookups.

## Project structure

<From references/structure.md for this stack: the feature folder layout and the layer rules.>

## <Platform section, one per stack>

<From references/platforms/.>

## Testing

- Business rules (pricing, limits, permissions, state machines) get unit tests. A bug fix comes with a test that fails before the fix.
- Unit tests don't touch the network or a real database, and they control the clock.
- Critical user flows get an end-to-end test.
- Coverage is measured in CI with the test runner's coverage tool. Changed business logic is covered, and coverage of changed files never drops. The global threshold starts at today's number and only goes up.
- Before calling a feature done, try it the way QA will: odd input (2.5, -1, blank, 12.505, a huge number), a double click, as every role that can reach it and one that can't, just after midnight in the business's time zone, and at phone width. Check that its totals match the same figure wherever else the app shows it.
- Manual testing is required where automation can't reach: UI against the design at phone and desktop widths, real devices for mobile, payments, email and other third-party flows in their sandboxes, migrations on production-shaped data, and keyboard and screen-reader passes. The PR lists the manual checks done, or says none were needed and why.
- Never skip, weaken or delete a check, or lower a coverage threshold, to get a merge through.

## Git and PRs

<From references/git-workflow.md: branch names, Conventional Commits, PR rules, squash merge, releases.>

## Docs map

- `docs/adr/`: architecture decision records, numbered. Accepted ones are binding.
- `docs/ai/ai-usage-rules.md`: the team's AI-assisted development policy.
- <Other docs as they are created: architecture overview, feature guide, known issues.>

## Decisions pending an ADR (don't pick; propose options and wait)

- <From the Proposed ADRs and their open questions.>
