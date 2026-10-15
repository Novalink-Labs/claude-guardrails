# Go services

Copy the parts that apply into AGENTS.md. Router, SQL layer (database/sql, sqlc, an ORM) and migration tool are ADR decisions.

## Structure

```
cmd/<app>/main.go             wiring: config, logger, database, handlers, server, graceful shutdown
internal/
├── config/                   environment parsing and validation; the only os.Getenv reader
├── platform/                 database, HTTP middleware (auth, logging, recovery), logger
└── <feature>/
    ├── handler.go            decode and validate the request, call the service, encode the response
    ├── service.go            business rules
    ├── repository.go         queries
    ├── model.go
    ├── dto.go                request and response structs
    ├── constants.go          typed constants
    └── *_test.go
migrations/
```

## Rules

- `gofmt` and `go vet` clean; `golangci-lint` if the repo configures it.
- Check every error. Wrap with context (`fmt.Errorf("load order: %w", err)`) and inspect with `errors.Is` and `errors.As`. No `panic` for control flow.
- `context.Context` is the first parameter of anything that does I/O, and it's honoured for cancellation.
- Server timeouts set (`ReadHeaderTimeout`, `ReadTimeout`, `WriteTimeout`, `IdleTimeout`); request bodies capped with `http.MaxBytesReader`; outbound clients have a `Timeout`.
- No goroutine leaks: every goroutine has a way to stop. Tests run with `-race`.
- SQL with placeholders only. Constraints enforce invariants; multi-row rules run in a transaction.
- `log/slog` with structured fields; no secrets or personal data.
- Define an interface where it's consumed, and only when there are two implementations or a test needs one.
- Table-driven tests; `govulncheck` in CI.
