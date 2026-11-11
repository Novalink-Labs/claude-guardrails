# Readiness checklist

Use the sections for the areas the release touches. Each item is pass, fail, or not applicable, with evidence.

## Backend

- New and changed endpoints have authentication, authorisation (object and function level), input validation and serialised responses.
- New env vars are in `.env.example`, in the config schema (validated at startup), and set in every target environment.
- Backward compatibility: clients on the previous version keep working during and after the deploy (no removed fields, renamed routes or changed meanings without versioning).
- Outbound calls have timeouts; retries only for idempotent operations; failure of a third party degrades gracefully.
- Jobs and webhooks are idempotent and safe to retry; queues have a dead-letter or failure path.
- Rate limits on new sensitive or expensive endpoints.
- Health endpoints still reflect real readiness (database, cache, queue).
- Error responses hide internals; validation messages are written for people; logs carry a request id and no personal data.
- Dates stamped and compared ("today", due, overdue, expiry) use the business's time zone; tried just after midnight there.
- Audit entries for new writes record only real changes, with before and after values.
- Uploads checked by their content bytes; exports escape formula cells.
- Load: new queries indexed; no unbounded lists; heavy work off the request path.

## Database

- Every migration in the range runs forward on production-shaped data, in an acceptable time, without locking hot tables.
- Expand and contract respected: nothing removed that the running version still uses.
- Rollback: each migration has a down path, or a written recovery plan (backup restore point, forward fix).
- A backup exists from before the deploy, and a restore has been tested recently (ask).
- Backfills run in batches and can resume.
- BaaS rules (RLS policies, security rules) updated and tested for new tables and collections.

## Frontend

- Every new or changed screen matches the design at phone and desktop widths, in every designed state (loading, empty, error, disabled, offline).
- Error boundaries and not-found pages show the designed states; nothing renders a raw error, enum value, code or minor-unit amount.
- Each new form tried with odd input (2.5, -1, blank, too many decimals, a huge number), a double click, and a cleared field saved; bad input is refused at the field, never silently changed.
- Each new screen tried as every role that can reach it and one that can't; hidden actions are also refused by the API.
- Totals and counts on new screens match the same figure elsewhere (list, detail, dashboard, export, portal), and count only the right states (no drafts, voids or refunds as money).
- Accessibility: automated checks pass; keyboard and screen-reader pass on changed flows.
- Performance: Core Web Vitals and bundle size within the agreed budgets (or measured and noted if no budget exists); images sized; no new heavy client dependency.
- The production build contains no secrets: search the build output (`.next/static`, `dist`, `build`) with the leak patterns; no public source maps unless intended.
- API contract: every endpoint and field the frontend calls exists in the backend version being deployed.
- SEO and metadata for public pages; private pages `noindex`; analytics only with consent where the law requires it.
- Browser support: checked on the browsers the product supports.

## Mobile

- Version and build number bumped; release notes ready for the stores.
- Store requirements met (target SDK, privacy manifest and data-safety answers match what the app collects).
- Tested on a real iOS and Android device, small and large screens, slow network and offline.
- Crash reporting on, with personal data scrubbed.
- OTA updates: only changes that are safe without a native build; a rollback path for the update.
- Minimum supported app version: does the backend still serve older app versions? Is a forced update needed?

## Operations

- Monitoring: errors, latency and saturation visible for the new paths; alerts route to someone.
- Feature flags or a kill switch for risky features, with the default state decided.
- Deploy order written down (migrations, backend, frontend, mobile, flags) with a rollback for each step.
- Someone owns the release and watches it for the first hour.
- Communication: support and stakeholders know what's changing; user-facing changes have copy approved.
