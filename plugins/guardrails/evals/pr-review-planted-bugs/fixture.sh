#!/usr/bin/env bash
# Builds a small Express repo: main is clean, feature/orders carries the planted problems.
set -euo pipefail

git init -q -b main
git config user.email eval@example.com
git config user.name eval
mkdir -p src/common/helpers src/modules/orders docs/adr

cat > AGENTS.md <<'EOF'
# AGENTS.md

## Non-negotiables
- AI must not decide architecture, data models, product behaviour, UI patterns or security logic.
- Every route requires authentication unless it is explicitly public. Check ownership of every record.
- No magic strings or numbers; constants live in the feature's constants.ts.
- Reuse helpers in src/common before writing new ones.
- No emojis in code, logs or copy. No personal data in logs.

## Project structure
src/modules/<feature>/ holds <feature>.routes.ts, <feature>.controller.ts, services/, repositories/ and constants.ts.
Business rules live in services; routes stay thin.
EOF

cat > docs/adr/0001-orders-api.md <<'EOF'
# 0001. Orders API

- **Status:** Accepted
- **Date:** 2026-09-01
- **Deciders:** Product and engineering leads

## Context
Customers view and manage their own orders.

## Decision
Orders are readable and refundable only by their owner, through authenticated routes using requireAuth.
Amounts are stored in paise as integers and formatted with formatMoney.

## Consequences
Every orders route uses requireAuth and checks order.userId against the caller.
EOF

cat > src/common/helpers/money.ts <<'EOF'
export function formatMoney(paise: number): string {
  return `₹${(paise / 100).toFixed(2)}`;
}
EOF

cat > src/common/auth.ts <<'EOF'
import type { NextFunction, Request, Response } from 'express';

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  if (!req.headers.authorization) return res.status(401).end();
  next();
}
EOF

cat > src/common/db.ts <<'EOF'
export const db = {
  orders: {
    async findById(id: string) {
      return { id, userId: 'u1', total: 120000, paymentIntentId: 'pi_1', email: 'a@example.com' };
    },
  },
};
EOF

cat > package.json <<'EOF'
{ "name": "orders-api", "private": true, "dependencies": { "express": "^5.1.0", "stripe": "^18.0.0" } }
EOF

git add -A
git commit -qm "chore: initial orders api"

git checkout -q -b feature/orders

# Assembled at runtime so the fixture source never contains a key-shaped string.
suffix="$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')"
key="sk_""live_${suffix}"

cat > src/modules/orders/orders.service.ts <<'EOF'
import { db } from '../../common/db';

export async function getOrder(id: string) {
  return db.orders.findById(id);
}

export function toRupees(paise: number): string {
  return '₹' + (paise / 100).toFixed(2);
}
EOF

cat > src/modules/orders/orders.routes.ts <<EOF
import { Router } from 'express';
import Stripe from 'stripe';
import { getOrder, toRupees } from './orders.service';

const stripe = new Stripe('${key}');

export const ordersRouter = Router();

// get the order by id
ordersRouter.get('/orders/:id', async (req, res) => {
  const order = await getOrder(req.params.id);
  console.log('🚀 order fetched', order);
  res.json({ ...order, totalLabel: toRupees(order.total) });
});

ordersRouter.post('/orders/:id/refund', async (req, res) => {
  const order = await getOrder(req.params.id);
  if (order.total > 500000) {
    return res.status(400).json({ error: 'too big' });
  }
  await stripe.refunds.create({ payment_intent: order.paymentIntentId });
  res.json({ ok: true });
});
EOF

git add -A
git commit -qm "feat(orders): add order routes"
