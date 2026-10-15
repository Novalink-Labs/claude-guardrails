# Node.js backends: NestJS, Express, Fastify, Hono

Copy the parts that apply into AGENTS.md under "Project structure" and a platform heading. Library choices not already in the repo (validator, ORM, queue) need an ADR.

## Structure: NestJS

```
src/
├── app/                      bootstrap, root module, global pipes, filters and interceptors
├── common/<area>/            shared infrastructure: database, auth, request, response, pagination, logger, helpers
│   └── constants/
├── configs/                  one registerAs namespace per area, validated at startup
├── languages/en/             i18n messages, if the API is localised
└── modules/<feature>/
    ├── constants/            <feature>.constant.ts, <feature>.enum.constant.ts,
    │                         <feature>.error-message.constant.ts, <feature>.status-code.constant.ts
    ├── controllers/<feature>.controller.ts
    ├── dtos/<feature>.create.dto.ts
    ├── serializations/<feature>.get.serialization.ts
    ├── repository/
    │   ├── entities/<feature>.entity.ts
    │   ├── repositories/<feature>.repository.ts
    │   └── <feature>.repository.module.ts
    ├── services/<feature>.service.ts, <feature>.service.spec.ts
    └── <feature>.module.ts
```

- Constructor injection only; never `new` a provider. Export only what other modules use. Avoid `forwardRef`.
- Guards for authentication and authorisation, pipes for validation, interceptors for response shaping, filters for errors. Don't rebuild these inside handlers.
- A global `ValidationPipe` with `whitelist`, `forbidNonWhitelisted` and `transform`; every DTO property has a validator decorator.
- Controllers return plain objects built from serializations, never ORM documents.
- Document every endpoint (Swagger decorators). Swagger is off or behind auth in production.

## Structure: Express, Fastify, Hono

```
src/
├── app.ts                    security headers, body limits, CORS, routers, central error handler
├── server.ts                 listen and graceful shutdown
├── config/                   env schema validated at startup; the only reader of process.env
├── common/                   db client, auth middleware, validation middleware, errors, logger, pagination
└── modules/<feature>/
    ├── constants.ts
    ├── <feature>.routes.ts   route table with auth and validation middleware
    ├── <feature>.controller.ts
    ├── schemas/<feature>.schema.ts        request schemas; unknown keys rejected
    ├── serializers/<feature>.serializer.ts
    ├── services/<feature>.service.ts
    ├── repositories/<feature>.repository.ts
    └── models/<feature>.model.ts
```

- Validate body, params and query in middleware (or Fastify route schemas) before the handler runs.
- One central error handler that maps known errors to status codes and hides internals. On Express 4, wrap async handlers so rejections reach it; Express 5 forwards them itself.
- Security headers (helmet or the framework's equivalent), body-size limits, a CORS allow-list, and `trust proxy` set to the exact proxy hops.
- On SIGTERM: stop accepting connections, finish in-flight requests, close the database, exit.

## Rules for every Node backend

- **TypeScript:** `strict`; no `any` (use `unknown` and narrow); no `!` or `@ts-ignore` to silence errors.
- **Data:** index every query path, with compound indexes matching filter and sort. Enforce invariants and idempotency with unique constraints, not application checks. Rules spanning several records run in a transaction. Paginate every list with a maximum page size. Store dates in UTC and money as integers in the smallest unit with a currency code.
- **Queries:** parameterised only. No string-built SQL, no `$where` or server-side JavaScript, no raw request objects passed into queries.
- **Migrations:** every schema change has a reviewed migration that stays compatible with the running version: add, backfill, switch, then remove.
- **Responses and errors:** one response envelope. Meaningful HTTP status codes. Error bodies never contain stack traces, SQL or internal ids. App-specific error codes use a range per module.
- **Config:** one config module, validated at startup, injected where needed.
- **Logging:** the framework logger or pino, JSON in production, with a request id. No `console.log` in application code. Redact secrets and personal data.
- **Outbound calls:** set timeouts; retry with backoff only idempotent calls.
- **Background work:** slow or heavy work (exports, bulk email, webhooks out) goes to a queue; jobs are idempotent and safe to retry.
- **Webhooks in:** verify the signature over the raw body, reject replays, dedupe on the provider's event id with a unique index.
- **Rate limits:** on sign-in, OTP, password reset and expensive endpoints, counted in a shared store (Redis) when more than one instance runs.
- **Health:** liveness (process up) and readiness (dependencies reachable) endpoints.
- **Performance:** no N+1 queries; batch with `IN` or `$in`; run independent calls with `Promise.all`; cache only after measuring, with explicit keys and TTLs.
- **Tests:** unit-test services with repositories mocked; end-to-end test routes against a disposable database; never call real third-party APIs.
