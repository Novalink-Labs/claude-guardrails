---
name: setup
description: Set up a repository so AI-assisted work follows specs, decision records and team rules instead of vibe coding. Works for any stack (Node, NestJS, Express, Next.js, React, Vue, React Native, Python, Go, JVM, Supabase or Firebase, monorepos). Writes AGENTS.md with a feature folder structure and the stack's best practices, CLAUDE.md importing it, the AI usage rules, docs/adr with the first decision records, a git workflow (branch names, Conventional Commits, squash merges, branch protection), a PR template, CI checks, secret scanning and dependency updates. On an existing or vibe-coded codebase it audits first and drafts ADRs for decisions already baked into the code. Use when starting a repo, onboarding an existing codebase, or when someone asks to set up the repo, add guardrails or standards, or stop the vibe coding.
argument-hint: "[audit]"
disable-model-invocation: true
---

# Set up guardrails

AI-written code goes wrong when nobody wrote down what was decided: the agent decides on the fly, and every session decides differently. This skill fixes that at the repo level. It puts the rules where agents read them (`AGENTS.md`), the decisions where reviewers find them (`docs/adr/`), and the checks where nothing merges without them (CI and branch protection).

It writes documents and configuration. It does not change application code.

## Ground rules for this run

- **Never overwrite.** If a file exists, read it, show the user what you would add or change, and ask. Conventions the repo already follows (a release-tag scheme, Yarn instead of npm, a folder layout) win over the defaults here; record them instead of replacing them.
- **Don't decide for the team.** Architecture, data models, product behaviour, UI patterns and security logic go into an ADR with status Proposed and real options. They go into AGENTS.md as rules only once someone accepts them.
- **Only write what you can verify.** Commands come from the repo's own scripts; versions come from its manifest or lockfile. Where a human has to fill something in, write `TODO(team): <what is needed>` and list it in the summary.
- **Ask before anything outward-facing.** Changing GitHub settings, branch protection, or pushing is the user's call. Prepare the commands; let them run or approve them.

## 1. Survey the repo

Look before asking. Collect:

- **Git:** default branch (`git symbolic-ref refs/remotes/origin/HEAD` or `git branch --show-current`), remote (`git remote -v`), branch and tag naming in use (`git branch -a`, `git tag --sort=-creatordate | head`), commit style (`git log --oneline -20`).
- **Stack, per package in a monorepo:** read the manifests (`package.json` plus lockfile, `pyproject.toml` / `requirements*.txt`, `go.mod`, `pom.xml` / `build.gradle*`, `pubspec.yaml`, `Gemfile`, `composer.json`, `Cargo.toml`, `*.csproj`), the framework dependencies, and BaaS clients (`@supabase/supabase-js`, `firebase`, `firebase-admin`).
- **Existing guardrails:** `AGENTS.md`, `CLAUDE.md`, `docs/`, `docs/adr/`, `docs/ai/`, `.github/workflows/`, PR template, `CODEOWNERS`, `.github/dependabot.yml`, `.gitignore`, `.env*`, `.claude/settings.json`.
- **Current structure:** how features are laid out today, compared with `references/structure.md`.
- **Risk signals to flag immediately:** tracked secret files (`git ls-files | grep -iE '(^|/)\.env($|\.)|\.pem$|\.p12$|\.key$|service-?account.*\.json$'`, ignoring `.env.example`), hardcoded credentials (patterns in `../security-audit/references/leak-patterns.md`), no tests at all, no CI.

Pick the mode:
- **New:** little or no application code. Set up everything.
- **Audit:** application code exists and the guardrails are missing or thin, which is typical of a vibe-coded app. Set up everything and also do step 4. `$ARGUMENTS` containing `audit` forces this mode.

Show the user a short inventory (stacks, what exists, what's missing, risk signals) before writing anything. A leaked secret goes at the top with "rotate it now": removing it from the code does not un-leak it.

## 2. Ask for what the repo can't tell you

One message, only the gaps (use AskUserQuestion if it's available):
- Product name and one line on what it does.
- Where the spec lives and where the design lives (doc path, Figma link, tracker).
- Who signs off decisions (names or roles).
- For branch protection: is the repo public, or on a paid GitHub plan? Protection rules on private repos need GitHub Pro, Team or Enterprise.

**Stack preferences.** If the stack isn't settled (a new repo, or an existing one missing a decision such as the database or the UI library), run the interview in `references/stack-defaults.md`: backend, database, data access, auth, frontend, UI library, mobile, hosting, tooling and constraints. Follow the team's preferences exactly. If they say "decide for me", recommend from the defaults in that file, one line of reasoning per choice tied to their product, and wait for their OK. Record the result as ADRs (`Accepted`, or `Accepted (delegated)` when they handed you the choice). Never pick a stack silently.

## 3. Write the guardrails

Create each piece only if it's missing; for existing files, propose a diff.

1. **`AGENTS.md`** from `references/agents-base.md`:
   - Fill "What this repo is" and "Commands" from the survey. List only commands that exist.
   - Add a "Project structure" section: the feature layout from `references/structure.md` for this stack, adapted to what the repo already does. In audit mode, describe the target layout and note where the current code differs; moving code is a separate, planned change, not part of this skill.
   - Add one platform section per stack from `references/platforms/` (table below). For a stack with no file there, write a short section from the platform's official documentation and mark the heading `(draft: needs team sign-off)`.
   - Keep it to rules an agent can act on. Link to docs for detail.
2. **`CLAUDE.md`:** one line, `@AGENTS.md`, so every agent reads one copy. If CLAUDE.md already has rules, move them into AGENTS.md (with the user's OK) and leave the import.
3. **`docs/ai/ai-usage-rules.md`:** copy `references/ai-usage-rules.md` unchanged. It is the team's policy; edits go through the team.
4. **`docs/adr/`:** create it with the first records, following `../adr/SKILL.md` and its template. New repo: `0001` records the starting point (stack, structure, how the repo was created), status Proposed unless the user confirmed it. Audit mode: step 4.
5. **Git workflow:** follow `references/git-workflow.md`. Add its rules to AGENTS.md's "Git and PRs" section, add `references/pull_request_template.md` as `.github/pull_request_template.md`, add the PR-title job to CI, and prepare (don't run) the merge-settings and branch-protection commands.
6. **CI:** follow `references/ci.md`. One workflow runs the repo's existing checks (typecheck, lint, tests with a coverage threshold, build) on every pull request and on pushes to the default branch, plus the secret scan and PR-title check.
7. **Security baseline:** follow `references/security-baseline.md`: `.gitignore` entries for secrets, `.env.example`, config validation at startup (as an AGENTS.md rule; the code change is a follow-up PR), `.github/dependabot.yml` for the detected ecosystems, and a dependency-audit step.
8. **`.claude/settings.json`:** merge in the team settings below so commits and PRs carry no AI attribution and teammates are prompted to install this plugin. If writing the file is blocked, print it for the user.

   ```json
   {
     "attribution": { "commit": "", "pr": "", "sessionUrl": false },
     "extraKnownMarketplaces": {
       "novalink-labs": { "source": { "source": "github", "repo": "Novalink-Labs/claude-guardrails" } }
     },
     "enabledPlugins": { "guardrails@novalink-labs": true }
   }
   ```

| Stack signals | Platform file |
|---|---|
| `@nestjs/core`, `express`, `fastify`, `hono`, `koa` | `platforms/node-backend.md` |
| `next`, `react`, `vite`, `vue`, `nuxt`, `@angular/core`, `svelte` | `platforms/web-frontend.md` |
| `react-native`, `expo` | `platforms/react-native.md` |
| `fastapi`, `django`, `flask` | `platforms/python.md` |
| `go.mod` | `platforms/go.md` |
| `pom.xml`, `build.gradle*` (Spring Boot, Kotlin, Android) | `platforms/jvm.md` |
| `@supabase/supabase-js`, `firebase`, `firebase-admin` | `platforms/baas.md`, in addition to the app's own stack |

A monorepo gets a root AGENTS.md with the shared rules and a short AGENTS.md per package with that package's commands, structure and platform section.

## 4. Audit mode: write down what the code already decided

A vibe-coded app is full of decisions nobody made on purpose. Find the significant ones and draft one ADR each, status `Proposed (documents existing code)`, so the team can ratify or reverse them:

- framework and project structure
- database, data model and migrations
- authentication, sessions and authorisation
- data isolation between users, organisations or tenants
- external services (payments, email, storage, AI providers)
- client state and data fetching (frontends)
- styling and design system (frontends)
- hosting, deployment and environments

Cite files for every claim. Describe; don't grade. Concerns go under the ADR's open questions. Aim for the 3 to 8 decisions that matter, not one per library.

Then offer to run `/guardrails:security-audit`: vibe-coded apps often ship with leaked keys, open database rules and unauthenticated routes.

## 5. Check your work

- `CLAUDE.md` imports `AGENTS.md`, and every command in AGENTS.md exists.
- Each workflow file parses as YAML (use any available parser, e.g. `ruby -ryaml -e 'YAML.load_file(ARGV[0])' <file>`), uses read-only `permissions` by default, and pins every action to a version.
- Nothing you wrote contains a secret or a real credential.
- `git status` shows only the files you meant to create or change.

## 6. Hand over

Summarise in this order:
1. Files created and changed.
2. Decisions waiting for sign-off: each Proposed ADR in one line.
3. Things only the user can do: apply the prepared GitHub settings, mark the CI jobs as required checks, turn on secret scanning with push protection, Dependabot alerts and CodeQL where the plan allows, and ask teammates to trust the folder so the plugin installs.
4. `TODO(team)` items.
5. Suggested next steps: commit on a branch such as `chore/guardrails` with the message `chore: add engineering guardrails`, and open it as a PR so the new flow reviews itself (no AI attribution). For a repo with a UI, run `/guardrails:design-language` before building screens. Before the first release, run `/guardrails:security-audit` and `/guardrails:ship-check`.
