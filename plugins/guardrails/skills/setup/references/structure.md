# Feature structure

Every stack uses the same shape, taken from the team's NestJS template: one folder per business feature, thin entry points, business rules in services, data access in repositories, validated input, explicit output, and named constants. The names change per platform; the layers and the rules between them don't. Each platform file in `platforms/` shows the concrete folder tree.

## Backend layers

| Layer | Its job | It must not |
|---|---|---|
| Entry point (controller, router, handler, view) | Read the input, check access, call one service method, return the result | Hold business rules or query the database |
| Request schema (DTO) | Declare and validate every input field at the edge; reject unknown fields | Double as the response shape |
| Service | Business rules, orchestration, transactions | Know about HTTP, the request object or the UI |
| Repository (data access) | The only code that queries the database or an external store | Make business decisions |
| Entity / model | The stored shape with its indexes and constraints | Reach clients directly |
| Response shape (serialization, presenter) | Exactly the fields a client may see | Include secrets or internal fields |
| Constants | Named values and enums for the feature | Hold environment-specific values |
| Config | Environment values, validated at startup, read in one place | Be bypassed with raw environment reads |
| Module / wiring | Registers the feature's pieces | Export what other features don't use |

- Shared infrastructure (database, auth, logging, pagination, mail, storage, HTTP clients) lives in one shared area (`common/`, `platform/`, `core/`, `lib/`) and is reused, never copied into features.
- Features talk to each other through the other feature's service, never through its repository or tables. A circular dependency means a responsibility is in the wrong feature.
- Create only the files a feature needs.

## Backend mapping

| Layer | NestJS | Express / Fastify / Hono | FastAPI | Django (+ DRF) | Go | Spring Boot |
|---|---|---|---|---|---|---|
| Entry | `controllers/x.controller.ts` | `x.routes.ts`, `x.controller.ts` | `router.py` | `views.py` | `handler.go` | `XController` |
| Request schema | `dtos/x.create.dto.ts` | `schemas/x.schema.ts` | `schemas.py` (`XCreate`) | `serializers.py` (input) | request structs in `dto.go` | `dto/XCreateRequest` |
| Service | `services/x.service.ts` | `services/x.service.ts` | `service.py` | `services.py` (writes), `selectors.py` (reads) | `service.go` | `XService` |
| Repository | `repository/repositories/x.repository.ts` | `repositories/x.repository.ts` | `repository.py` | ORM queries kept in `services.py` / `selectors.py` | `repository.go` | `XRepository` |
| Entity | `repository/entities/x.entity.ts` | `models/x.model.ts` | `models.py` | `models.py` | `model.go` | `XEntity` |
| Response shape | `serializations/x.serialization.ts` | `serializers/x.serializer.ts` | `schemas.py` (`XRead`) | `serializers.py` (output) | response structs in `dto.go` | `dto/XResponse` |
| Constants | `constants/x.constant.ts`, `x.enum.constant.ts` | `constants.ts` | `constants.py` | `constants.py`, `TextChoices` | `constants.go` | `XConstants`, `enum XStatus` |
| Wiring | `x.module.ts` | `index.ts` exporting the router | `include_router` in the app | `apps.py`, `urls.py` | constructors in `cmd/<app>/main.go` | component scan, `@Configuration` |

## Frontend layers

| Layer | Its job | It must not |
|---|---|---|
| Route / page / screen | Compose the feature's components for one URL or screen; fetch initial data where the framework does it | Hold business logic or styling decisions |
| Feature components | Render one feature's UI from design tokens and shared primitives | Call the backend directly or invent states |
| Hooks / state | Server state through the data-fetching library; client state where it's needed | Duplicate server data into client state |
| API client | One typed function per endpoint, types from the API contract | Be re-implemented per component |
| Schemas | Validate forms, URL params and responses you don't control | Drift from the backend's validation |
| Constants | Routes, query keys, limits, storage keys, event names | Hold design values (those are tokens) |
| Design system | Shared primitives and tokens (`components/ui/`, theme) | Be forked per feature |

## Frontend mapping

| Layer | Next.js (App Router) | React SPA (Vite) | Vue / Nuxt | React Native (Expo Router) |
|---|---|---|---|---|
| Route | `src/app/**/page.tsx`, `layout.tsx` | `src/routes/` | `pages/` | `app/` |
| Feature folder | `src/features/<x>/` with `components/`, `hooks/`, `api.ts`, `schemas.ts`, `constants.ts` | same | `features/<x>/` with `components/`, `composables/`, `api.ts` | `src/features/<x>/` with `components/`, `hooks/`, `api.ts` |
| Shared UI | `src/components/ui/` | `src/components/ui/` | `components/ui/` | `src/components/ui/` |
| API client | `src/lib/api/` | `src/lib/api/` | `lib/api/` | `src/lib/api/` |
| Config | `src/config/env.ts` (only place reading env) | `src/config/env.ts` | `runtimeConfig` | `src/config/env.ts` |

Tests sit next to the code they test (`x.service.spec.ts`, `test_service.py`, `service_test.go`, `XServiceTest`), with end-to-end tests in their own folder.
