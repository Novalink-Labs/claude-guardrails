# Guardrails for Claude Code

Stop vibe coding. Guardrails is a Claude Code plugin that makes AI-assisted work follow your specs, your decisions and your standards, on any stack.

It sets a repo up so agents know the rules, keeps decisions in reviewable records, gives UI a real design language, reviews every PR in depth, audits security and leaks, and gates releases so critical bugs don't ship.

Maintained by [Novalink Labs](https://novalinklabs.com). MIT licensed.

## Skills

| Command | What it does |
|---|---|
| `/guardrails:setup` | Sets up any repo: AGENTS.md with a feature structure and the stack's best practices, decision records, git workflow (branches, Conventional Commits, squash merges, branch protection), CI with coverage and secret scanning, Dependabot, PR template. Asks for your stack preferences, or recommends defaults if you ask it to decide. Audit mode documents the decisions an existing codebase already made. |
| `/guardrails:adr` | Drafts or updates an architecture decision record with real options and a recommendation. People accept; AI doesn't. |
| `/guardrails:design-language` | Researches how your competitors and the best apps in your category look, collects your references, has you pick a component library, proposes two or three design-language variants with font pairings and contrast-checked tokens, previews them, and records the choice in DESIGN.md. `screen` mode researches a single new screen. |
| `/guardrails:pr-review` | In-depth PR review. Gathers AGENTS.md, ADRs, spec and design first and asks for what's missing; then hunts critical bugs, silent decisions, security holes, leaked secrets, structure and YAGNI/KISS/DRY violations, magic values and missing tests; lists the manual testing still needed. |
| `/guardrails:ui-review` | Reviews UI against DESIGN.md and flags generic AI-looking patterns, missing states, accessibility and responsive problems. |
| `/guardrails:deslop` | Cleans AI-style code out of a diff without changing behaviour, then proves it with your checks. |
| `/guardrails:security-audit` | Repo-wide audit: secrets in history and client bundles, unauthenticated routes, broken object-level access, open Supabase or Firebase rules, injection, risky CI, vulnerable dependencies. |
| `/guardrails:ship-check` | Release gate for backend, frontend and mobile: checks and coverage, a critical-bug pass over the release, migrations, config, observability, rollback, and a manual test plan. Ends in Go, Go with conditions, or No-go. |
| `/guardrails:council` | Evidence-first decision council: an evidence ledger, an independent defender and skeptic, claim-by-claim review, a judge, and a hallucination audit, ending in a status and confidence. The other skills call it for decisions that are contested or costly to reverse. |

Platforms covered: Node (NestJS, Express, Fastify, Hono), web (Next.js, React, Vue, Nuxt, Angular, Svelte), React Native and Expo, Python (FastAPI, Django, Flask), Go, JVM (Spring Boot, Kotlin, Android), and Supabase or Firebase backends. Other stacks get the same structure with a section drafted from the platform's official guidance.

## Install

In Claude Code:

```
/plugin marketplace add Novalink-Labs/claude-guardrails
/plugin install guardrails@novalink-labs
```

From a shell:

```sh
claude plugin marketplace add Novalink-Labs/claude-guardrails
claude plugin install guardrails@novalink-labs
```

### Have your whole team use it

`/guardrails:setup` adds this to the repo's `.claude/settings.json`, so teammates are offered the plugin when they open the repo and trust the folder. It also turns off AI attribution in commits and PRs.

```json
{
  "attribution": { "commit": "", "pr": "", "sessionUrl": false },
  "extraKnownMarketplaces": {
    "novalink-labs": { "source": { "source": "github", "repo": "Novalink-Labs/claude-guardrails" } }
  },
  "enabledPlugins": { "guardrails@novalink-labs": true }
}
```

## How a team uses it

1. `/guardrails:setup` once per repo, then commit the result through a PR.
2. `/guardrails:design-language` before building UI, and `/guardrails:design-language screen <name>` for each new screen.
3. Build from the spec. Run `/guardrails:deslop` on large generated changes.
4. `/guardrails:pr-review` before asking a person to review, and `/guardrails:ui-review` for UI changes. A person approves and merges.
5. `/guardrails:security-audit` and `/guardrails:ship-check` before each release.

## What it believes

- The spec, the design and accepted decision records decide what gets built. AI implements; it doesn't decide architecture, data models, product behaviour, UI patterns or security logic on its own.
- Ponytail, YAGNI, KISS, DRY: the shortest correct change in the right place, reusing what exists.
- No magic values, no AI attribution, no emojis in code or copy.
- Reviews are read-only and report verified findings with evidence. Nothing approves, merges, tags or deploys on its own.
- Skills read only what they need, so runs stay fast and cheap.

## Running reviews in CI (optional)

[anthropics/claude-code-action](https://github.com/anthropics/claude-code-action) can load this plugin and run a review on every PR. It needs an Anthropic API key in your repository secrets; usage is billed to that key.

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    plugin_marketplaces: "https://github.com/Novalink-Labs/claude-guardrails.git"
    plugins: "guardrails@novalink-labs"
    prompt: "/guardrails:pr-review ${{ github.event.pull_request.number }} --post"
```

## Privacy

The skills run inside your own Claude Code session and read your repository locally. They post to GitHub only when you ask (`--post`), and never change GitHub settings, push, approve or merge on their own.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Report security issues privately as described in [SECURITY.md](SECURITY.md).
