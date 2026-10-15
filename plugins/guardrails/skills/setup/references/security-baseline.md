# Security baseline

The minimum every repo gets at setup. The repo-wide check is `/guardrails:security-audit`; this file is about prevention.

## Keep secrets out of git

Add to `.gitignore`, merged with what's there:

```gitignore
# Secrets and local config
.env
.env.*
!.env.example
*.pem
*.key
*.p12
*.pfx
*.keystore
*.jks
service-account*.json
*-credentials.json
.npmrc.local
```

- `.env.example` lists every variable the app reads, with a comment each and no real values.
- Configuration is validated at startup (Joi, zod, pydantic-settings, envconfig, `@ConfigurationProperties` with validation), so a missing secret stops the app instead of failing later.
- If a tracked secret file or hardcoded credential exists, the order is: rotate the secret with the provider, remove it from the code, then decide with the team whether to purge history (`git filter-repo`). Purging rewrites history for everyone, so never do it without the team's go-ahead.
- A local pre-commit scan is optional and catches leaks before they leave the laptop: `gitleaks git --pre-commit --staged --redact -v`.

## Client bundles are public

Anything shipped to a browser or a phone can be read by anyone:

- Browser-exposed env prefixes (`NEXT_PUBLIC_`, `VITE_`, `REACT_APP_`, `NUXT_PUBLIC_`, `PUBLIC_`, `EXPO_PUBLIC_`) never hold secrets.
- Server-only keys (payment secret keys, database URLs, service-role keys, AI provider keys, signing secrets) stay on the server.
- Public identifiers that are meant to be public (Supabase anon key, Firebase web config, Stripe publishable key) are safe only when the server-side rules behind them are right (see `platforms/baas.md`).

## Dependencies

`.github/dependabot.yml`, one entry per detected ecosystem plus GitHub Actions:

```yaml
version: 2
updates:
  - package-ecosystem: "npm"          # npm covers Yarn and pnpm; others: pip, gomod, maven, gradle, pub, bundler, composer, cargo, nuget, docker
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      minor-and-patch:
        update-types: ["minor", "patch"]
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

- The CI dependency audit is described in `ci.md`.
- Every new dependency is justified in its PR: what it does that the platform or an existing dependency can't, its maintenance state, and its licence.
- Lockfiles are committed. Installs in CI use the lockfile.

## GitHub

- Branch protection and merge settings: `git-workflow.md`.
- Turn on where the plan allows: secret scanning with push protection, Dependabot alerts and security updates, CodeQL default setup, and private vulnerability reporting for public repos.
- Actions hardening: read-only `permissions` by default, pinned actions, no untrusted input interpolated into `run:`, no `pull_request_target` running PR code, secrets only in the jobs that need them (`ci.md`).

## Application rules

These go into AGENTS.md (Security section) and are what `/guardrails:pr-review` and `/guardrails:security-audit` check:

- Authentication on every non-public route, handler, server action and database rule.
- Object-level authorisation on every access (owner or organisation), not role alone.
- Input validated at the edge with a schema; unknown fields rejected.
- Parameterised queries only; no shell, path or HTML built from input.
- Tokens in httpOnly, Secure, SameSite cookies or the `Authorization` header; never in URLs, local storage or logs.
- Rate limits on sign-in, OTP, password reset and expensive endpoints, counted in a shared store when there is more than one instance.
- Webhooks verify the signature over the raw body, reject replays and are idempotent on the provider's event id.
- File uploads: allow-listed types and sizes, server-generated names, private storage with signed URLs.
- Security headers and a strict CORS allow-list; no `*` with credentials.
- No stack traces, internal ids or personal data in error responses or logs.
