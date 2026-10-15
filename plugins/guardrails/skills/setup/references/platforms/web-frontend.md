# Web frontends: Next.js, React, Vue, Nuxt, Angular, Svelte

Copy the parts that apply into AGENTS.md. The examples use Next.js App Router; for other frameworks keep the same layers and follow the framework's official style guide (Vue style guide, Angular style guide). Library choices (data fetching, state, UI kit, forms) need an ADR.

## Structure

```
src/
├── app/                      routes only: page.tsx, layout.tsx, loading.tsx, error.tsx, not-found.tsx, route handlers
├── features/<feature>/
│   ├── components/
│   ├── hooks/
│   ├── api.ts                typed endpoint functions and query keys
│   ├── schemas.ts            schemas for forms, URL params and responses you don't control
│   └── constants.ts
├── components/ui/            design-system primitives
├── lib/                      API client, query client, small utilities
├── config/env.ts             the only place that reads env vars, validated at startup
└── constants/                shared routes, query keys, storage keys, event names
```

- Pages compose feature components; they hold no business logic.
- One typed API client. Each endpoint gets one function, with request and response types taken from the API contract (OpenAPI or shared types), never redefined per component.

## Source of truth

- The design is the source of truth. Colour, spacing, radius, type, shadow, z-index and motion come only from design tokens; no literals in components.
- Every state the design defines (loading, empty, error, disabled, offline) is built; a state the design doesn't define is raised with Design, not invented.

## Next.js

- Server Components by default. `'use client'` only on leaf components that need state, effects, event handlers or browser APIs. Pass only serialisable props to client components.
- Mark server-only modules with `server-only`; never import them into client code.
- Fetch initial data on the server, or prefetch it into the data-fetching library and hydrate. No data fetching in `useEffect`.
- Declare caching and revalidation explicitly on every data read. Per-user data is never cached across users.
- Server Actions and Route Handlers are public endpoints: validate input and check authentication and authorisation inside every one.
- Gate authenticated routes in middleware (or `proxy.ts`), and check again on the server; the middleware is not the only guard.
- Every route segment that can load, fail or 404 has `loading.tsx`, `error.tsx` and `not-found.tsx`, as designed.
- `next/link`, `next/image` with explicit sizes, `next/font`. Titles and SEO through the Metadata API; private pages are `noindex`.
- Next.js changes between majors. Read the docs that ship with the installed version before using an API you remember.

## React

- Follow the Rules of Hooks. Derive values during render instead of syncing them with effects; effects are only for real side effects.
- Stable keys, never the array index for lists that reorder.
- Memoise only for a measured problem.
- Small components with one responsibility. Lift state only as far as it needs to go; don't copy server data into client state.
- Error boundaries show the designed error state; never swallow an error.

## TypeScript

- `strict`; no `any`; no `!` or `@ts-ignore` to silence errors.
- Validate untrusted data at the boundaries with a schema (URL params, form input, env, third-party responses) and derive types from the schemas.
- Model variants as discriminated unions and switch over them exhaustively.

## Security

- Only browser-exposed env vars (`NEXT_PUBLIC_`, `VITE_`, `REACT_APP_`, `NUXT_PUBLIC_`, `PUBLIC_`) reach the bundle, and everything in the bundle is public. No secrets in them.
- Auth tokens live in httpOnly, Secure, SameSite cookies, never in `localStorage` or `sessionStorage`. Cookie auth needs CSRF protection on state-changing requests.
- No `dangerouslySetInnerHTML`, `v-html` or `innerHTML` with untrusted content; sanitise if there's no alternative.
- Browser-to-backend calls go through a same-origin proxy or a strict CORS allow-list.
- A Content Security Policy for production, tightened over time.

## Forms

- Every field has a visible label and an error message tied to it. Validate on the client for speed and on the server for truth.
- Disable submit while submitting; prevent double submission; keep the user's input on error.

## Accessibility (WCAG 2.2 AA)

- Semantic HTML first; ARIA only where HTML can't express it.
- Everything works with the keyboard, with a visible focus state and a logical order.
- Text contrast at least 4.5:1; touch targets at least 24 by 24 CSS pixels.
- Automated checks (axe) in component and end-to-end tests; manual keyboard and screen-reader passes on key flows.

## Responsive and performance

- Mobile-first. Check every screen at a phone width and a desktop width.
- Budgets for Core Web Vitals and bundle size are an ADR; measure them before release.
- Images sized and lazy-loaded; code split by route; no large client libraries for small jobs.

## Tests

- Unit-test pure logic. Component-test interactive pieces with accessible queries. End-to-end test critical flows at mobile and desktop sizes.
- Mock the API at the network boundary; tests never hit a real backend.
