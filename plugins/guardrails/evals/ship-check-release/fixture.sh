#!/usr/bin/env bash
# A small Node API tagged v1.0.0, then three commits for v1.1.0 with release-blocking problems. Tests pass.
set -euo pipefail

git init -q -b main
git config user.email eval@example.com
git config user.name eval
mkdir -p src migrations test

cat > package.json <<'EOF'
{ "name": "chai-api", "private": true, "type": "module", "scripts": { "test": "node --test" } }
EOF

cat > .env.example <<'EOF'
# Postgres connection string
DATABASE_URL=
# Secret used to sign session tokens
JWT_SECRET=
EOF

cat > migrations/001_users.sql <<'EOF'
create table users (id uuid primary key, name text not null, phone text not null unique);
EOF

cat > src/users.js <<'EOF'
export async function getUser(db, id) {
  const { rows } = await db.query('select id, name, phone from users where id = $1', [id]);
  return rows[0] ?? null;
}
EOF

cat > src/total.js <<'EOF'
export function orderTotal(items) {
  return items.reduce((sum, item) => sum + item.price * item.qty, 0);
}
EOF

cat > test/total.test.js <<'EOF'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { orderTotal } from '../src/total.js';

test('adds price times quantity', () => {
  assert.equal(orderTotal([{ price: 1500, qty: 2 }, { price: 800, qty: 1 }]), 3800);
});
EOF

git add -A
git commit -qm "feat: users and order totals"
git tag v1.0.0

cat > migrations/002_users_email.sql <<'EOF'
alter table users add column email text;
alter table users drop column phone;
EOF
git add -A
git commit -qm "feat(users): switch contact from phone to email"

cat > src/webhooks.js <<'EOF'
export async function handleRazorpayWebhook(req, db) {
  const event = req.body;
  if (event.event === 'payment.captured') {
    await db.query('update orders set status = $1 where id = $2', ['paid', event.payload.order_id]);
  }
  return { ok: true, secret: process.env.RAZORPAY_WEBHOOK_SECRET ? 'set' : 'missing' };
}
EOF
git add -A
git commit -qm "feat(payments): mark orders paid from razorpay webhook"

cat >> src/total.js <<'EOF'

export function orderTotalWithTax(items, taxRate) {
  return Math.round(orderTotal(items) * (1 + taxRate));
}
EOF
cat >> test/total.test.js <<'EOF'

import { orderTotalWithTax } from '../src/total.js';

test('adds tax and rounds to the nearest paisa', () => {
  assert.equal(orderTotalWithTax([{ price: 1000, qty: 1 }], 0.18), 1180);
});
EOF
git add -A
git commit -qm "feat(orders): totals with tax"
