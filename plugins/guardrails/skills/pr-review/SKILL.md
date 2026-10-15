---
name: pr-review
description: In-depth pull request review for backend and frontend changes against the repo's own rules. First gathers AGENTS.md, the decision records (ADRs), the spec and the design, and asks for anything missing; then hunts for critical bugs, silent product or architecture decisions, security holes and leaked secrets, structure and ponytail/YAGNI/KISS/DRY violations, magic values, missing tests and coverage; and lists the manual testing still needed. Reports verified findings with file:line evidence and a verdict. Use whenever someone asks to review a PR, a branch, a diff or their changes, gives a PR number or GitHub PR URL, asks "is this ready to merge", or wants a check before opening a PR, even without the word "review".
argument-hint: "[PR number | PR URL | branch] [--post]"
---

# PR review

Review like the senior engineer on a team that doesn't accept vibe-coded changes. The spec, the design and the ADRs decide what gets built; code implements them. A good review here catches three things: code that is wrong, code that leaks, and code that quietly decides something the team never decided. Generic reviews miss the third, so it gets its own step.

The review is read-only: don't edit code, push, approve or merge. Approval and merge stay with a person.

## Work efficiently

Reviews are long and context is expensive. Read the diff once, then only the surrounding code you need to judge a change (callers, the helper it might duplicate, its test). List ADR titles and statuses before opening any, and read in full only the relevant ones. Load the checklist sections for the stacks this diff touches, not all of them. Run each check once. Report only verified findings, tersely.

## 1. Find the change

From `$ARGUMENTS`:
- **PR number or URL**, with `gh` installed and signed in: `gh pr view <n> --json number,title,body,url,baseRefName,headRefName,files,commits` and `gh pr diff <n>`.
- **Branch name:** `git diff $(git merge-base origin/<default> <branch>)...<branch>`.
- **Nothing:** the current branch against the default branch, plus uncommitted changes (`git diff HEAD`).

If `gh` isn't available for a PR number, ask for the branch name. Note the size (files, lines added and removed) and which areas it touches: backend, frontend, mobile, database, infrastructure, CI.

## 2. Gather the context (readiness gate)

1. Repo rules: `AGENTS.md` (and `CLAUDE.md`, which usually imports it).
2. ADRs: `docs/adr/*.md` titles and statuses; then the ones touching this change's areas.
3. What the change is supposed to do: the PR description, a linked issue, the spec, the design reference, `docs/feature-map.md` or product docs.
4. Known traps: `docs/known-issues.md`, if present.

Decide whether you're ready:
- **No `AGENTS.md` and no `docs/adr/`:** there's nothing team-specific to review against. Say so and suggest `/guardrails:setup`. Continue with a general review only if the user asks; then use `../setup/references/` (agents base, structure, platform files) as the standard and say so in the report.
- **The change adds or changes behaviour and you can't find what it's meant to do:** ask for the spec, design or ticket. Don't infer intent from the code; that is exactly how invented behaviour gets approved.
- **UI changes with no design reference:** ask for it.

Ask for everything missing in one message, saying why each matters, then wait. If the user says to go ahead without something, do, and list it under "Reviewed without". A missing ADR for an architecture change is not a reason to stop; it becomes a blocking finding.

## 3. Review

Read the whole diff, then enough surrounding code to understand each change. Work through `references/checklist.md`: the general sections always, and the backend, frontend, mobile and database sections when the diff touches them. In order of weight:

1. **Silent decisions:** architecture, data model, product behaviour, UI pattern or security logic that no spec, design or accepted ADR covers.
2. **Critical bugs:** for each changed function, walk the inputs and states it can meet (empty, null, boundary, duplicate, concurrent, dependency down, partial failure, retry) and what the code does with each.
3. **Security and leaks:** access control, input handling, secrets in the diff, data exposed in responses, logs or client bundles. Run `gitleaks git --log-opts="<base>..<head>" --redact --no-banner -v` if gitleaks is installed; otherwise search the added lines with `../security-audit/references/leak-patterns.md`.
4. **Structure and keep-it-small:** the repo's feature layout and layer rules; ponytail, YAGNI, KISS and DRY. For a DRY finding, find and cite the existing helper.
5. **Named values:** magic strings and numbers, environment reads outside config.
6. **Tests and coverage:** business rules tested, regression tests for fixes, coverage of changed code not dropping.
7. **Docs and hygiene:** docs and ADRs updated, PR scope and title, no AI attribution, no leftovers.

Then run the repo's own checks once (typecheck, lint, tests with coverage if the script exists), using commands from AGENTS.md or the manifest. Report failures as findings. Don't install tools to do it.

**Large changes** (more than about 25 files or 800 changed lines): split the files by area and review the areas in parallel with subagents if you can, at most three, each returning findings with evidence; then verify them yourself (step 4). Note that the PR should have been smaller.

## 4. Verify every finding

Before reporting, go back to the code for each finding: open the file at the line, check the claim against what the code really does, and check it's in the changed lines or directly caused by them. Cite the rule (AGENTS.md section or ADR number) or the evidence (a command's output, the existing helper's path). Drop anything you can't point to; a short review of real problems beats a long one with guesses. Problems that predate this change go in one line under "Outside this PR".

Label evidence: **FACT** (seen in code, a doc or command output), **INFERENCE** (follows from facts), **UNKNOWN** (can't tell from here; becomes a question for the author).

## 5. Decide what needs manual testing

Automated tests don't prove everything. List the manual checks this change needs, and only those, as concrete steps someone can follow. Typical triggers:
- UI: compare with the design at phone and desktop widths, keyboard-only use, screen reader on the changed flow, browsers the product supports.
- Mobile: a real iOS and Android device, a small screen, slow network and offline, permission refused.
- Money, email, SMS, push, webhooks or third-party APIs: one end-to-end run in the provider's sandbox.
- Migrations and data backfills: run on a copy of production-shaped data and check the result and the rollback.
- Auth and permissions: try the action as the wrong user, as a signed-out user, and with a tampered id.
- Performance-sensitive paths: measure on a low-end device or with production-sized data.

If nothing needs manual testing, say "None: covered by automated tests" and name the tests.

## 6. Report

```markdown
## Review: <PR title or branch>

**Verdict:** Ready to merge | Changes requested | Blocked: needs a team decision
**Reviewed against:** AGENTS.md, ADR 0003, ADR 0007, <spec link>
**Reviewed without:** <anything missing the user chose to skip, or "nothing">
**Checks:** typecheck passed · lint 2 errors · tests 148 passed · coverage of changed files 81% (was 84%)
**Size:** 14 files, +420 / −85 · backend, frontend

### Blocking
1. **<short title>** · `path/to/file.ts:42` · <category>
   <What is wrong and what it causes, in one or two sentences.>
   Rule: <AGENTS.md section or ADR NNNN> · Evidence: FACT <what you saw>
   Fix: <the smallest change that resolves it>

### Should fix
### Nits
<At most five. Leave the section out if there are none.>

### Manual testing needed
- [ ] <Concrete step and expected result>

### Questions for the author
### Outside this PR
```

- **Verdict:** any silent decision means "Blocked: needs a team decision"; name the decision and offer `/guardrails:adr`. Otherwise any blocking finding or failing check means "Changes requested". Otherwise "Ready to merge", with any manual testing listed as a condition.
- **Blocking:** wrong behaviour, a critical-path bug, a security hole or leaked secret, data loss, a silent decision, a violated accepted ADR, a failing required check, business logic without tests.
- **Should fix:** breaks an AGENTS.md rule (structure, duplication, magic values, missing docs, coverage drop) without breaking behaviour.
- **Nit:** naming, small readability. Never block on these.
- A leaked secret goes first in Blocking with "rotate it now": deleting it in a later commit doesn't un-leak it.

## 7. Posting to GitHub (only when asked)

With `--post` or when the user asks, post the report as one review comment: `gh pr review <n> --comment --body-file <file>`. Never `--approve` and never merge; those calls belong to the human reviewer. Without `gh`, give the user the report to paste.
