---
name: security-audit
description: Repo-wide security and leak audit for any stack, aimed at the problems vibe-coded apps ship with. Scans the working tree and full git history for leaked secrets, finds keys exposed in client bundles and env files, unauthenticated routes and missing ownership checks, injection and SSRF, open Supabase or Firebase rules, data leaking through responses and logs, risky CI workflows, and vulnerable dependencies. Read-only; reports findings by severity with a rotate-now list first. Use before a release, after onboarding an inherited or AI-generated codebase, after a suspected leak, or when someone asks for a security audit, a secrets scan, "are we leaking anything" or "is this safe to launch". For a review of only the pending changes, Claude Code's built-in /security-review fits better.
argument-hint: "[path or area to focus on]"
---

# Security audit

Look for what an attacker would find first. Vibe-coded apps fail in predictable places: secrets committed or bundled into the client, routes with no auth, records anyone can read by changing an id, database rules left in test mode, and errors that print internals. Cover those thoroughly before anything exotic.

This skill is read-only. Don't change code, rotate keys or rewrite history; report, and let the user decide.

## Work efficiently

Search before reading: use the patterns in `references/leak-patterns.md` and targeted searches to find candidates, then open only those files. Read route and rule definitions, not every file. Run each scanner once. If `$ARGUMENTS` names a path or area, stay inside it.

## 1. Map the attack surface

- Stacks and entry points: HTTP routes, server actions, route handlers, functions, webhooks, queues, cron jobs, GraphQL resolvers, and BaaS rules (`supabase/migrations`, `firestore.rules`, `storage.rules`).
- Where secrets come from: env files, config modules, CI secrets, mobile and web build config.
- What's deployed to clients: web bundles, mobile apps, public folders, source maps.

## 2. Secrets and leaks

1. **Git history:** if gitleaks is installed, `gitleaks git --redact --no-banner -v .` (full history). Otherwise search the working tree with the patterns in `references/leak-patterns.md`, and `git log -p` for the highest-risk patterns (private keys, live payment keys, cloud keys, database URLs with passwords).
2. **Tracked secret files:** `git ls-files` matched against `.env`, `*.pem`, `*.key`, `*.p12`, keystores and service-account JSON, ignoring `.env.example`.
3. **Client exposure:** browser- and app-exposed env prefixes (`NEXT_PUBLIC_`, `VITE_`, `REACT_APP_`, `NUXT_PUBLIC_`, `PUBLIC_`, `EXPO_PUBLIC_`) holding anything secret; server-only SDKs or keys imported into client code; if a build output exists (`.next/static`, `dist`, `build`), search it for the leak patterns; public source maps in production.
4. **Data exposure:** responses returning whole records (password hashes, tokens, internal flags); error handlers returning stack traces or SQL; logs with tokens, OTPs, passwords or personal data; analytics events carrying personal data. Bearer tokens in a route's path or query (invites, resets, share links) end up in every access log that writes the concrete path; check what the request logger writes.
5. **Field-level exposure:** a field hidden from a role on one endpoint (costs, rates, pay, totals) but returned by another: lists, related records, exports, partner or referral views, PDFs.

A secret found in history or a bundle is leaked, even if it's gone from the latest commit. It goes on the rotate-now list.

Never print a secret's value, in the report or in quoted command output: give its type and location, and at most its first 4 characters.

## 3. Access control

- List every entry point with its auth requirement. Flag any without authentication that isn't clearly meant to be public.
- For entry points that take a record id, check that the code verifies ownership or organisation membership before reading or changing it (broken object-level authorisation). Check admin actions are restricted by more than the UI hiding a button.
- Child records (documents, notes, entries, milestones): read, edit and delete apply the parent's access rule. Every write path (edit, submit, approve, bulk), not just create, re-checks scope and state; an edit after sign-off or approval doesn't keep the sign-off.
- Sessions and tokens: storage (httpOnly cookies or secure storage), expiry, refresh and revocation, password reset and OTP flows rate-limited, CSRF for cookie auth.
  - Logout and revoke: is any claim read with an unverified decode and then stored? Can a client-made token plant a system marker (a `revoke-all:` jti)? Does the revocation check skip itself when payloads are encrypted?
  - Every token-issuing path (refresh, code verify, invite accept, password change, SSO) applies sign-in's status, role and access-window checks.
  - Attempt counters are read, then incremented in a separate step: concurrent guesses all pass.
  - Auth cookies set with a parent `Domain` reach every sibling subdomain; they should be `__Host-`.
  - New-device alerts that hash request headers can be spoofed; an unknown device that counts as known fails open.
- Multi-tenant accounts: an invite or email lookup that returns another organisation's user profile or account status, writes to that shared profile, or binds the account before the person accepts.
- Background jobs and notifications that send to a stored user id (creator, assignee) without re-checking current membership and role.
- BaaS: Supabase tables in exposed schemas without RLS or with permissive policies, service-role key in client code; Firebase rules with `if true`, test-mode rules, or no ownership check (`../setup/references/platforms/baas.md`).

## 4. Injection and unsafe input

- SQL or NoSQL built from strings or raw request objects; `$where`; ORM raw queries without parameters.
- Shell commands, file paths, templates, regexes or HTML built from input; `eval` and dynamic `require` or `import`.
- SSRF: server-side fetches of user-supplied URLs without an allow-list.
- Deserialisation of untrusted data (`pickle`, unsafe YAML).
- Spreadsheet formula injection: CSV or Excel exports that don't escape cells starting with `=`, `+`, `-`, `@`, tab or carriage return.
- Open redirects: `next` or return URLs that can leave the site (`//evil.example`, `/\evil.example`, a path the router resolves off-site).
- Missing schema validation, size limits or type checks on bodies, uploads and query params, including negative or zero page sizes and page numbers that slip under a maximum-only cap.

## 5. Configuration and platform

- Security headers, CORS (no `*` with credentials), cookie flags, HTTPS-only settings, debug modes off in production, admin panels and API docs protected.
- Rate limits on sign-in, OTP, reset and expensive endpoints.
- Proxy trust: `trust proxy` set to `true`, or falling back to it when unset, lets clients forge `X-Forwarded-For` and dodge per-IP limits. It should be an exact list or hop count that fails closed in production. A server-side proxy (Next.js middleware, BFF) should set the header itself, not relay the client's.
- Webhooks: signature verification over the raw body, replay protection, idempotency.
- Uploads: type and size allow-lists with the type checked against the file's signature bytes, not the declared type or extension; private storage; server-generated names.

## 6. Dependencies and CI

- Run the ecosystem's audit once (`npm audit --omit=dev`, `pnpm audit --prod`, `yarn audit --groups dependencies`, `pip-audit`, `govulncheck ./...`) and keep high and critical findings in production dependencies.
- Workflows: `pull_request_target` running PR code, `${{ github.event.* }}` interpolated into `run:`, broad `permissions`, unpinned third-party actions, secrets passed to steps that don't need them.

## 7. Verify, then report

Confirm each finding at its file and line, and say how it would be exploited in one sentence. Drop what you can't confirm, or list it under "Couldn't verify". Label evidence FACT or INFERENCE.

```markdown
## Security audit: <repo> (<date>)

**Scope:** <what was covered> · **Not covered:** <what wasn't, and why>
**Scanners:** gitleaks <version or "not installed, pattern search used"> · <audit command and result>

### Rotate now
- <secret type> in `path:line` (or commit <sha>): rotate with <provider>, then remove. Exposed since <date or commit>.

### Critical
1. **<title>** · `path:line`
   Exploit: <one sentence> · Evidence: FACT <what you saw>
   Fix: <smallest fix>

### High
### Medium
### Low
### Couldn't verify
### Next steps
```

Severity: **Critical** means exploitable now with serious impact (leaked live secret, unauthenticated data access, open database rules). **High** means exploitable with some effort or limited scope. **Medium** is defence in depth missing. **Low** is hardening.

After the report, offer to fix findings one PR at a time, starting with the rotate-now list. Purging a secret from git history rewrites everyone's history, so it needs the team's explicit go-ahead.
