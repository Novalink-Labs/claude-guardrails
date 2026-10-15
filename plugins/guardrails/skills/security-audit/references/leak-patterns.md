# Leak patterns

Regexes for a first pass when gitleaks isn't installed, and for reviewing added lines in a diff. They find candidates; open each match and judge it. Skip obvious placeholders (`xxx`, `your-key-here`, `<...>`), `.env.example` values and test fixtures marked fake, but say you skipped them.

Use them with `git grep -nIE '<pattern>'` for the working tree, or `git log -p -G '<pattern>'` for history.

## Specific credentials

| What | Pattern |
|---|---|
| Private key block | `-----BEGIN ([A-Z]+ )?PRIVATE KEY-----` |
| AWS access key id | `\b(AKIA\|ASIA)[0-9A-Z]{16}\b` |
| GitHub token | `\b(ghp\|gho\|ghu\|ghs\|ghr)_[A-Za-z0-9]{36}\b` and `\bgithub_pat_[A-Za-z0-9_]{60,}\b` |
| GitLab token | `\bglpat-[A-Za-z0-9_-]{20}\b` |
| Slack token or webhook | `\bxox[abposr]-[A-Za-z0-9-]{10,}` and `hooks\.slack\.com/services/[A-Za-z0-9/]+` |
| Stripe secret or restricted key | `\b(sk\|rk)_live_[A-Za-z0-9]{20,}\b` |
| Razorpay live key id | `\brzp_live_[A-Za-z0-9]{14}\b` (the secret is usually stored next to it) |
| Google API key | `\bAIza[0-9A-Za-z_-]{35}\b` (a Firebase web key is public by design; check it's restricted) |
| Google service account | `"type":\s*"service_account"` |
| Anthropic API key | `\bsk-ant-[A-Za-z0-9_-]{20,}` |
| OpenAI API key | `\bsk-(proj-)?[A-Za-z0-9_-]{20,}` |
| SendGrid API key | `\bSG\.[A-Za-z0-9_-]{22}\.[A-Za-z0-9_-]{43}\b` |
| Twilio account SID with auth token nearby | `\bAC[0-9a-f]{32}\b` |
| JSON Web Token | `\beyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}` (decode the payload; a Supabase `service_role` JWT is critical) |
| Database URL with password | `\b(postgres(ql)?\|mysql\|mariadb\|mongodb(\+srv)?\|redis\|amqps?)://[^:/\s]+:[^@/\s]+@` |

## Generic assignments

Catches many custom secrets, with more false positives:

```
(?i)\b(api[_-]?key|secret|token|passw(or)?d|private[_-]?key|client[_-]?secret|access[_-]?key)\b\s*[:=]\s*['"][^'"\s]{12,}['"]
```

## Exposed to clients

Browser- or app-exposed variables that look secret:

```
(?i)\b(NEXT_PUBLIC|VITE|REACT_APP|NUXT_PUBLIC|PUBLIC|EXPO_PUBLIC)_[A-Z0-9_]*(SECRET|PRIVATE|SERVICE_ROLE|PASSWORD|TOKEN)[A-Z0-9_]*
```

Server-only SDKs or keys imported in client code: `firebase-admin`, `service_role`, `SUPABASE_SERVICE_ROLE_KEY`, `stripe` initialised with a secret key in a file marked `'use client'` or under a client folder.

## Tracked files that shouldn't be

```
git ls-files | grep -iE '(^|/)\.env($|\.)|\.pem$|\.key$|\.p12$|\.pfx$|\.jks$|\.keystore$|service-?account.*\.json$|credentials.*\.json$' | grep -v '\.env\.example$'
```

## Personal data in logs

Log calls that include whole request bodies, user objects, `password`, `otp`, `token`, `authorization`, `cookie`, card or identity numbers:

```
(?i)(console\.(log|info|warn|error)|logger\.\w+|log\.\w+|print)\(.*\b(password|otp|token|authorization|cookie|req\.body|request\.body|user)\b
```
