# Git workflow

Defaults for a team shipping from one main branch. If the repo already has a working convention (branch names, release tags such as `production/vX.Y.Z`), keep it and write it down instead.

## Branches

- The default branch (`main`) is always releasable. Nobody pushes to it directly; everything lands through a pull request.
- Work happens on short-lived branches cut from the default branch and merged within a few days.
- Branch name: `<type>/<ticket-or-scope>-<short-description>`, for example `feat/KH-42-otp-login`, `fix/checkout-rounding`, `chore/upgrade-node-24`. Types match the commit types below.
- Keep your branch current by merging or rebasing the default branch into it. Never rewrite the default branch's history.
- No long-lived `develop` or per-environment branches. Environments follow deployments and tags. If the team wants a different model, record it in an ADR.
- Delete branches after merge.

## Commits: Conventional Commits 1.0

Format: `<type>(<optional scope>)<optional !>: <summary>`

- Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`, `revert`.
- Summary in the imperative, lower case, no trailing period, about 72 characters at most: `fix(auth): reject expired refresh tokens`.
- `!` after the type, or a `BREAKING CHANGE:` footer, marks a breaking change.
- The body, if any, explains why, not what. Footers: `Refs: #123`, `BREAKING CHANGE: ...`.
- One logical change per commit. Unrelated formatting, generated files and secrets stay out.
- No AI attribution trailers.

## Pull requests

- One purpose per PR. Aim for under about 400 changed lines; split bigger work into reviewable steps.
- The title follows Conventional Commits. It becomes the squash commit on the default branch, so CI checks it.
- Open it as a draft early; mark it ready when CI is green and the template is filled in.
- The description links the spec, design or ticket, and the ADR for any decision. UI changes include screenshots at mobile and desktop widths.
- At least one human approval, and never the author's own. An AI review (`/guardrails:pr-review`) supports the human review; it doesn't replace it.
- Resolve every conversation before merging.

## Merging

- Squash merge only: one commit per PR on the default branch, linear history.
- Required before merge: CI green (checks, secret scan, PR-title check), one approval, conversations resolved, branch up to date with the default branch.

## Releases

- Tag releases on the default branch with semantic versions, `vMAJOR.MINOR.PATCH`. A `feat` bumps the minor version, a `fix` the patch version, and a breaking change the major version (from 1.0 on).
- Run `/guardrails:ship-check` before tagging.
- Keep `CHANGELOG.md` grouped by version, written from the merged PR titles.
- Hotfix: a `fix/...` branch from the default branch, reviewed and merged like any PR, then tagged.

## GitHub settings (prepared by the skill, applied by a repo admin)

Merge settings: squash only, PR title as the commit title, delete merged branches.

```sh
gh api -X PATCH repos/<owner>/<repo> \
  -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY
```

Branch protection for the default branch. Run CI once first, so the check names exist; `contexts` are the job names as GitHub shows them on a PR.

```sh
gh api -X PUT repos/<owner>/<repo>/branches/main/protection --input - <<'JSON'
{
  "required_status_checks": { "strict": true, "contexts": ["<check name>", "<check name>"] },
  "enforce_admins": true,
  "required_pull_request_reviews": { "required_approving_review_count": 1, "dismiss_stale_reviews": true },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
JSON
```

- Branch protection on private repositories needs GitHub Pro, Team or Enterprise; on GitHub Free it works only for public repositories.
- Also turn on, where the plan allows (Settings, then Code security): secret scanning with push protection, Dependabot alerts and security updates, and CodeQL default setup.
- A `CODEOWNERS` file can require review from the owners of sensitive paths (auth, payments, infrastructure). Add it once the team has named owners.
