#!/usr/bin/env bash
# Builds a Next.js + Supabase repo whose worst leak only exists in git history.
set -euo pipefail

git init -q -b main
git config user.email eval@example.com
git config user.name eval
mkdir -p src/lib "src/app/api/users/[id]" supabase/migrations

# Assembled at runtime so the fixture source never contains a credential-shaped string.
password="$(od -An -N10 -tx1 /dev/urandom | tr -d ' \n')"
printf 'DATABASE_URL=%s://%s:%s@%s/app\n' postgres app_admin "$password" db.internal.example.com > .env

cat > package.json <<'EOF'
{ "name": "launch-app", "private": true, "dependencies": { "next": "^16.0.0", "@supabase/supabase-js": "^2.50.0" } }
EOF

git add -A
git commit -qm "chore: initial app"

git rm -q --cached .env
rm .env
printf '.env\n' > .gitignore
git add -A
git commit -qm "chore: stop tracking env file"

cat > .env.example <<'EOF'
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_SERVICE_ROLE_KEY=
EOF

cat > src/lib/supabase.ts <<'EOF'
'use client';
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_SERVICE_ROLE_KEY!,
);
EOF

cat > supabase/migrations/0001_profiles.sql <<'EOF'
create table public.profiles (
  id uuid primary key,
  email text not null,
  phone text,
  is_admin boolean default false
);
EOF

cat > "src/app/api/users/[id]/route.ts" <<'EOF'
import { supabase } from '@/lib/supabase';

export async function GET(_req: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const { data } = await supabase.from('profiles').select('*').eq('id', id).single();
  return Response.json(data);
}
EOF

git add -A
git commit -qm "feat: profiles api"
