---
name: deslop
description: Clean AI-generated slop out of a diff or a set of files while keeping behaviour identical, the ponytail way. Removes narrating comments, dead and commented-out code, unused parameters and options, single-implementation interfaces and factories, defensive checks for impossible states, swallowed errors, duplicated helpers (by reusing the existing one), magic values, emojis, debug leftovers and `any` casts, and moves code into the repo's structure. Edits code, then proves nothing changed by running typecheck, lint and tests. Use when someone says "clean this up", "deslop", "this looks AI-written", "simplify my changes", "make this production quality", or after generating a large change and before opening a PR.
argument-hint: "[path | branch | 'staged']"
---

# Deslop

Generated code tends to work and still be wrong for the codebase: it narrates itself, guards against things that can't happen, invents helpers that already exist, wraps one implementation in three layers, and ignores the conventions every neighbouring file follows. This skill makes the code look like a careful teammate wrote it, without changing what it does.

## Scope

- Default: the current branch's changes against the default branch (`git diff $(git merge-base HEAD origin/<default>)`), plus uncommitted changes.
- `$ARGUMENTS` can narrow it to a path, a branch, or `staged`.
- Touch only code inside that scope. Pre-existing slop elsewhere goes in the report as a suggestion, not into the diff.

## Work efficiently

Read the diff, the repo's AGENTS.md, and one or two neighbouring files per area to learn the local conventions. Search for existing helpers before deciding something is duplicated. Make the edits in one pass per file, then run the checks once at the end, and again only if something failed.

## What to fix

In order of value:

1. **Duplicated logic:** a new helper, hook, component, type or constant that already exists in the repo. Switch to the existing one and delete the new one.
2. **Needless structure:** an interface, factory, strategy, wrapper class or config option with one implementation or one caller; layers that only pass arguments through. Inline it.
3. **Speculative code:** unused parameters, options, flags, exports and branches; "for later" scaffolding; code the spec doesn't ask for. Delete it.
4. **Error handling that hides errors:** broad `try/catch` that swallows or returns a default, `catch` that only logs and continues where the caller needs to know. Let it propagate or handle it the way the repo does.
5. **Defensive noise:** checks for states the types or callers already rule out, repeated validation inside the core after the edge validated it.
6. **Type escapes:** `any`, unnecessary `as` casts, non-null `!`, `@ts-ignore`. Use proper types or narrowing.
7. **Magic values:** literals for statuses, limits, durations, keys and routes. Move them into the feature's constants, reusing existing ones.
8. **Structure:** business rules in controllers, handlers or components; database access outside repositories. Move them to the right layer when it's a contained move; otherwise report it.
9. **Comments:** delete comments that narrate what the code plainly does, restate names, or describe the change history. Where the code isn't obvious or departs from the repo's usual pattern, leave one precise line that says why. Keep `ponytail:` notes.
10. **Leftovers:** `console.log` and debug prints, commented-out code, unused imports, `TODO`s without a ticket, placeholder text, emojis in code, logs, copy or commit messages.
11. **Naming and style:** match the surrounding code's naming, file layout and idioms.

## Rules

- Behaviour stays identical. If a cleanup would change behaviour (for example, a swallowed error that some caller relies on), don't make it; report it.
- Don't touch public APIs, database schemas or anything other features import, unless every caller is in scope and updated.
- Don't add abstractions, dependencies or new files while cleaning up. The diff should shrink.
- Don't reformat untouched lines.

## Prove it

Run the repo's typecheck, lint and the tests covering the changed files. If anything fails because of a cleanup, revert that cleanup rather than patching around it. If tests for the changed code don't exist, say so: a cleanup without tests is a judgement call, so keep those cleanups conservative and list them.

## Report

```markdown
## Deslop: <scope>

**Result:** −142 / +38 lines across 9 files · typecheck passed · lint passed · tests 64 passed

### Changes
- `path/file.ts`: reused `formatMoney` from `src/common/helpers/money.ts` instead of the new `toRupees`; removed 3 narrating comments.

### Left alone (would change behaviour or is out of scope)
- `path/other.ts:88`: the `catch` returns `[]` on failure; callers may rely on it. Decide whether to surface the error.

### Not covered by tests
- <Cleanups in files without tests.>
```

Leave the changes uncommitted for the user to review, unless they asked for a commit.
