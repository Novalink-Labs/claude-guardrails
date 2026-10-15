# Contributing

Thanks for helping. Guardrails is maintained by Novalink Labs; issues and pull requests from anyone are welcome.

## Try your changes locally

```sh
git clone https://github.com/Novalink-Labs/claude-guardrails.git
cd claude-guardrails
claude --plugin-dir ./plugins/guardrails        # loads your working copy for one session
```

Before opening a PR:

```sh
claude plugin validate --strict .
claude plugin validate --strict plugins/guardrails
```

Behaviour checks live in `plugins/guardrails/evals/`. `claude plugin eval plugins/guardrails` runs them; it makes real model calls on your own account, so run the cases you touched (`--case <glob>`).

## Writing a skill

- One job per skill. The `description` says what it does and when to use it, in the words people actually type.
- Explain why a rule exists rather than shouting MUST; the model follows reasons better than capitals.
- Keep `SKILL.md` focused and move detail into `references/`, loaded only when a step needs it. Every skill has a short "Work efficiently" section: read less, run checks once, report tersely.
- Stack-neutral by default. Stack specifics go in `skills/setup/references/platforms/`.
- Verify every tool name, package name, command, flag and version you add, and say in the PR how you checked it. Don't add advice you can't source.
- Reviews and audits stay read-only. Nothing in this plugin approves, merges, tags, deploys, rotates keys or rewrites history on its own.
- No emojis, and no text copied from other projects unless their licence allows it and it's credited.

## Pull requests

- Branch from `main`: `feat/...`, `fix/...`, `docs/...`.
- PR titles follow Conventional Commits (`feat(pr-review): check coverage of changed files`); CI checks this, and PRs are squash-merged.
- Update `CHANGELOG.md` under "Unreleased".
- One maintainer approval is required.

## Releasing (maintainers)

1. Move "Unreleased" in `CHANGELOG.md` to the new version and bump `version` in `plugins/guardrails/.claude-plugin/plugin.json` (semantic versioning).
2. Merge, then tag from `main` with `claude plugin tag plugins/guardrails` and push the tag.
3. Publish GitHub release notes from the changelog.

## Code of conduct

Everyone taking part follows the [Code of Conduct](CODE_OF_CONDUCT.md).
