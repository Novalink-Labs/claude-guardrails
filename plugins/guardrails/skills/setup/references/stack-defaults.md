# Stack interview and defaults

Use this when the stack isn't decided yet: a new repo, or an existing one missing a decision (no database chosen, no UI library). The team's preference always wins. When someone says "decide for me", recommend from the defaults below, explain each pick in one line tied to their product, and record it as an ADR once they agree.

## The interview

Ask in one message (AskUserQuestion if available), skipping anything the repo already answers. Offer "decide for me" on each question.

1. **Backend:** language and framework. Or "start from our template" if the team has one.
2. **Database:** relational (PostgreSQL, MySQL), document (MongoDB), embedded (SQLite), or a backend-as-a-service (Supabase, Firebase). Managed provider, if they have one.
3. **Data access:** ORM or query layer.
4. **Auth:** build on the framework (JWT and sessions) or use a provider (Auth0, Clerk, Supabase Auth, Firebase Auth, Cognito); sign-in methods needed.
5. **Frontend:** web framework, and whether pages need SEO (public) or sit behind sign-in.
6. **UI:** component library (see `../design-language/references/component-libraries.md`).
7. **Mobile:** none, cross-platform, or native.
8. **Hosting and deploys:** where it runs, and how releases reach it.
9. **Tooling:** package manager, test runner, monorepo or separate repos.
10. **Constraints:** expected scale, data residency or compliance, budget, team skills.

## Defaults when the team delegates

Pick what fits the product, not the newest thing. Say why in one line, and name what would change the choice. For the choices that are costly to reverse (database, auth, hosting, backend framework), run `/guardrails:council` on the top two options before recommending, so the default isn't accepted out of habit.

| Decision | Default | Choose differently when |
|---|---|---|
| Backend | TypeScript with NestJS (or the team's own template) | A small service or edge function (Fastify or Hono); data or ML-heavy work (Python with FastAPI); high-throughput infrastructure services (Go) |
| Database | PostgreSQL: transactions, constraints, mature tooling, JSONB for the few flexible fields | The team's template or skills are built on MongoDB and the data is document-shaped; offline or embedded (SQLite); the product needs realtime sync with little backend (Supabase or Firebase, with rules written and tested) |
| Data access | Prisma or Drizzle with migrations (TypeScript and PostgreSQL); Mongoose (MongoDB); SQLAlchemy 2 with Alembic (Python); sqlc (Go) | The team already uses another tool well |
| Cache, rate limits, queues | Redis, only when needed (more than one instance, background jobs) | A single instance with no jobs needs none of it |
| Auth | The framework's own JWT and refresh-token flow for standard email or OTP sign-in (the team template has it) | Enterprise SSO, many social providers, or compliance needs: a provider |
| Web frontend | Next.js App Router for public, SEO-relevant products; React with Vite for apps that live entirely behind sign-in; Astro for content sites | The team's skills are in Vue (Nuxt) or Angular |
| Server state | TanStack Query | The framework's own data layer covers it |
| UI library | shadcn/ui on Tailwind, restyled through the design language | Dense admin screens (Mantine or Ant Design); Material is the brand (MUI) |
| Mobile | Expo (React Native) for a TypeScript team | Heavy native features or performance needs: native Swift and Kotlin |
| Hosting | A managed platform (a PaaS for the API, a frontend host for the web app, a managed database) | Data residency, cost at scale or compliance: containers on the team's cloud |
| Package manager | What the template uses; otherwise pnpm | |
| Tests | The framework's standard runner (Jest or Vitest, pytest, go test, JUnit), Playwright for end-to-end | |

## Recording

- One ADR per significant choice, or one "Initial stack" ADR listing them all.
- When the team chose: status `Accepted`, deciders as named.
- When the team delegated: status `Accepted (delegated)`, with "Deciders: <name> asked for a recommendation on <date> and approved it". The recommendation's reasoning goes in the Decision section, so the team can revisit it later.
- Choices nobody has made yet stay `Proposed`, listed under "Decisions pending an ADR" in AGENTS.md.
