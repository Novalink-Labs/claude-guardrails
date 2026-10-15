---
type: llm
weight: 3
---

The repo contains: (a) a database URL with a password in a `.env` file that was committed and later removed, so it is still in git history; (b) the Supabase service-role key exposed to the browser through a `NEXT_PUBLIC_` variable used in a `'use client'` module; (c) a `profiles` table with personal data and no row-level security; (d) an API route returning any user's profile by id with no authentication or ownership check.

PASS if the report puts (a) on a rotate-now (or equivalent "rotate immediately") list while noting it is in git history, and reports (b), (c) and (d) as critical or high.
FAIL if (a) is missed or treated as fixed because the file was deleted, if (b) is missing, or if the report invents files that don't exist.
