# Python backends: FastAPI, Django, Flask

Copy the parts that apply into AGENTS.md. ORM, migration tool, task queue and package manager are ADR decisions.

## Structure: FastAPI (Flask is similar, with blueprints)

```
app/
├── main.py                   create the app, middleware, routers, exception handlers
├── core/                     config (pydantic-settings), database session, security, logging
└── modules/<feature>/
    ├── constants.py          Enum / StrEnum and Final values
    ├── router.py             thin endpoints; auth and services through Depends
    ├── schemas.py            XCreate / XUpdate (input, extra="forbid"), XRead (output)
    ├── service.py
    ├── repository.py
    ├── models.py
    └── dependencies.py
migrations/                   Alembic
tests/modules/<feature>/
```

- Set `response_model` (or a return type) on every endpoint so only declared fields go out.
- Input models use `model_config = ConfigDict(extra="forbid")`.
- `async def` endpoints must not call blocking I/O; use async drivers, or plain `def` endpoints for blocking libraries.

## Structure: Django

```
config/settings/              base.py, local.py, production.py; values from the environment
apps/<feature>/
    constants.py              TextChoices and named values
    models.py                 fields, constraints, indexes
    services.py               business rules that write
    selectors.py              queries that read
    serializers.py            input and output serializers (DRF)
    views.py                  thin: validate, call a service or selector, respond
    urls.py
    admin.py
    tests/
```

- Business rules live in services, not in views, serializers or model `save()` overrides.
- Production settings: `DEBUG = False`, explicit `ALLOWED_HOSTS`, `SECRET_KEY` from the environment, secure cookie and HSTS settings. `python manage.py check --deploy` passes.
- Every model change has a migration, reviewed, and compatible with the running code.

## Rules for every Python backend

- Pin dependencies with a lockfile. Use the repo's formatter and linter (Ruff is common) and a type checker (mypy or pyright); type hints on public functions.
- Configuration through one settings object, validated at startup. No `os.environ` reads elsewhere.
- Queries through the ORM or with bound parameters; never format SQL strings.
- Never `pickle`, `yaml.load` (use `safe_load`) or `eval` untrusted data. No `subprocess` with `shell=True` on input.
- `logging`, not `print`; structured in production; no secrets or personal data.
- Constraints and unique indexes enforce invariants; multi-row rules run in a transaction.
- Outbound HTTP with explicit timeouts.
- Tests with pytest: no real network, time controlled, factories over fixtures with magic values.
