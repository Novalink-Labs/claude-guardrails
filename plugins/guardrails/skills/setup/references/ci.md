# CI

One workflow, `.github/workflows/ci.yml`, that runs on every pull request and on pushes to the default branch. It runs the repo's own checks plus two guards every repo gets: a secret scan and a PR-title check.

## Rules

- Use only scripts and tools the repo already has. If there is no lint or typecheck script, don't invent one; list it as `TODO(team)`.
- Look up the current major version of each action before writing it (`git ls-remote --tags https://github.com/actions/checkout`). The versions below were current in October 2026.
- `permissions: contents: read` at the top. Grant more only to the job that needs it.
- Pin GitHub's own `actions/*` to a major version. Pin third-party actions to a full commit SHA with the version in a comment.
- Never interpolate `${{ github.event.* }}` (PR titles, branch names, commit messages) straight into a `run:` script; that is a script-injection hole. Pass it through `env:` and quote it.
- Never use `pull_request_target` to run code from the PR.
- Set `timeout-minutes` on every job and cancel superseded runs.

## Checks job by stack

Pick the block for each stack in the repo (a monorepo gets one job per package, or a matrix).

**Node (npm, Yarn, pnpm):** install with the lockfile (`npm ci`, `yarn install --frozen-lockfile`, `pnpm install --frozen-lockfile`), then the scripts that exist.

```yaml
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version-file: .nvmrc        # or .node-version / package.json engines
          cache: npm                        # yarn or pnpm, matching the lockfile
      - run: npm ci
      - run: npm run typecheck
      - run: npm run lint
      - run: npm test
      - run: npm run build
```

**Python:** `actions/setup-python@v7` with `python-version-file`, install from the lockfile the repo uses (uv, Poetry, pip-tools), then its linter (`ruff check`), type checker (`mypy` or `pyright`) and `pytest`.

**Go:** `actions/setup-go@v7` with `go-version-file: go.mod`, then `go vet ./...`, `go test -race ./...`, and `golangci-lint` if the repo configures it.

**JVM:** `actions/setup-java@v6` with the repo's JDK version and build-tool cache, then `./gradlew check` or `./mvnw verify`.

**Mobile:** run typecheck, lint and unit tests in CI. Store builds (EAS, Gradle release, Xcode) are a release concern; record how they're done in an ADR.

## Coverage

Measure coverage in the checks job with the runner the repo already uses, and fail below a threshold:

- Jest: `jest --coverage`, with `coverageThreshold` in the Jest config.
- Vitest: `vitest run --coverage`, with `coverage.thresholds` in the config (needs `@vitest/coverage-v8`).
- pytest: `pytest --cov=<package> --cov-fail-under=<n>` (needs pytest-cov).
- Go: `go test -coverprofile=coverage.out ./...`, then a script step that compares the total from `go tool cover -func=coverage.out` with the threshold.
- JVM: JaCoCo, with `jacocoTestCoverageVerification` (Gradle) or the plugin's `check` goal (Maven).

Set the threshold to the current number on the day it's added, so the job passes, and raise it as tests are written. Never lower it to get a merge through. Point the effort at business logic, not the global percentage: covering getters proves nothing. A coverage package is a new dependency; justify it in the PR.

## Dependency audit

Fail on high or critical vulnerabilities in production dependencies:

- npm: `npm audit --omit=dev --audit-level=high`
- pnpm: `pnpm audit --prod --audit-level high`
- Yarn 1: `yarn audit --groups dependencies --level high`. Its exit code is a bitmask of the severities found, so check how the team wants to treat it.
- Python: `pip-audit` against the installed environment or the lockfile.
- Go: `govulncheck ./...`
- JVM: the OWASP dependency-check plugin, if the team adopts it (needs an ADR; it is slow).

New advisories can fail unrelated PRs. If that becomes noise, move the audit to a scheduled workflow and rely on Dependabot alerts for PRs; record the choice.

## Secret scan job

Gitleaks scans the full git history, so a secret committed and then deleted still fails the check. The binary is downloaded and verified against the release checksums; no third-party action or licence key is needed.

```yaml
  secret-scan:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0
      - name: Scan for secrets
        env:
          GITLEAKS_VERSION: 8.30.1
        run: |
          base="https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}"
          archive="gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz"
          curl -sSfLO "${base}/${archive}"
          curl -sSfL "${base}/gitleaks_${GITLEAKS_VERSION}_checksums.txt" | grep " ${archive}\$" | sha256sum -c -
          tar -xzf "${archive}" gitleaks
          ./gitleaks git --redact --no-banner -v .
```

A false positive is allowed with a `gitleaks:allow` comment on that line, or a `.gitleaksignore` entry, and the PR explains why.

## PR-title job

```yaml
  pr-title:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    timeout-minutes: 2
    steps:
      - name: Check the title follows Conventional Commits
        env:
          TITLE: ${{ github.event.pull_request.title }}
        run: |
          pattern='^(feat|fix|refactor|perf|test|docs|build|ci|chore|revert)(\([a-z0-9._/-]+\))?!?: .+'
          if [[ ! "$TITLE" =~ $pattern ]]; then
            echo "PR title must follow Conventional Commits, for example 'fix(auth): reject expired tokens'."
            echo "Got: $TITLE"
            exit 1
          fi
```

## Workflow header

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  checks:
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      # the stack block above
  secret-scan:
    # above
  pr-title:
    # above
```

After the first run, give the user the job names to mark as required checks in branch protection.
