# Security policy

## Supported versions

The latest released version gets security fixes.

## Reporting a vulnerability

Please don't open a public issue. Report it privately through GitHub: the repository's **Security** tab, then **Report a vulnerability**.

Useful details: the skill and version, what an attacker could make Claude do (for example leak a secret, run a destructive command, post somewhere it shouldn't), and steps to reproduce.

We'll acknowledge the report, keep you updated while we fix it, and credit you in the release notes unless you'd rather stay anonymous.

## Scope

- Skill instructions that could lead Claude to expose secrets or personal data, take destructive or outward-facing actions without the user's consent, or follow instructions planted in a repository it is reviewing.
- This repository's CI workflows.
- Guidance in the skills that would leave users' projects insecure.
