# JVM: Spring Boot, Kotlin, Android

Copy the parts that apply into AGENTS.md. Persistence, migration tool and build tool choices are ADR decisions.

## Structure: Spring Boot (package by feature)

```
src/main/java/com/<org>/<app>/
├── <App>Application.java
├── common/                   @RestControllerAdvice error handling, security config, pagination
├── config/                   @ConfigurationProperties classes, validated
└── <feature>/
    ├── XController.java      thin: @Valid request, call the service, return a response DTO
    ├── XService.java         business rules, @Transactional
    ├── XRepository.java
    ├── XEntity.java
    ├── dto/XCreateRequest.java, dto/XResponse.java     records
    └── XStatus.java, XConstants.java
src/main/resources/db/migration/                      Flyway (or Liquibase)
```

- Constructor injection with final fields; no field injection.
- `@Transactional` on service methods, not controllers. `spring.jpa.open-in-view=false`.
- Bean Validation (`@Valid`, constraint annotations) on every request DTO. Never return entities.
- Spring Security denies by default. Function-level checks with method security; ownership checks in the service.
- Actuator exposes only what's needed (health, info) and is secured.
- Avoid N+1 queries with fetch joins or entity graphs. Every schema change is a migration.
- Secrets from the environment or a secret manager, never in `application.yml`. Profiles per environment.
- Tests: JUnit 5, Testcontainers for integration tests against a real database engine.

## Kotlin

- Null safety is the point: no `!!`. Data classes for DTOs. Coroutines with structured concurrency; no `GlobalScope`.

## Android

- Layers per the Android architecture guide: UI (Compose or views plus ViewModel), optional domain, data (repositories and data sources).
- Nothing secret in the APK. Tokens and keys protected by the Android Keystore.
- Network security config without cleartext; certificate pinning only with a rotation plan.
- R8 minification for release builds; target SDK kept up to Google Play's yearly requirement.
