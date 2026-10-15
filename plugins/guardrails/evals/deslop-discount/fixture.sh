#!/usr/bin/env bash
# A plain Node project (node --test, no installs) with a sloppy discount module on a branch.
set -euo pipefail

git init -q -b main
git config user.email eval@example.com
git config user.name eval
mkdir -p src/common src/orders test

cat > package.json <<'EOF'
{ "name": "orders", "private": true, "type": "module", "scripts": { "test": "node --test" } }
EOF

cat > AGENTS.md <<'EOF'
# AGENTS.md
- Reuse helpers in src/common before writing new ones.
- No magic numbers: constants live in the feature's constants.js.
- Comments only where code departs from the usual pattern, one line on why.
- No emojis in code or logs. No commented-out code.
EOF

cat > src/common/money.js <<'EOF'
export function formatMoney(paise) {
  return new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' }).format(paise / 100);
}
EOF

cat > src/orders/constants.js <<'EOF'
export const ORDER_STATUS = { NEW: 'new', PAID: 'paid' };
EOF

git add -A
git commit -qm "chore: initial orders module"
git checkout -q -b feature/discount

cat > src/orders/discount.js <<'EOF'
// This file handles discounts for orders

// Helper function to convert paise to rupees
function toRupees(paise) {
  return new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' }).format(paise / 100);
}

// Strategy interface for discounts
class LoyaltyDiscountStrategy {
  // calculate the discount
  calculate(total) {
    // check if total is above threshold
    if (total >= 50000) {
      return Math.round(total * 0.1);
    }
    return 0;
  }
}

// Factory to create the discount strategy
function createDiscountStrategy(type, options = {}) {
  return new LoyaltyDiscountStrategy();
}

// Apply the discount to an order and return the discount in paise
export function applyDiscount(order) {
  try {
    const strategy = createDiscountStrategy('loyalty');
    const discount = strategy.calculate(order.total);
    console.log('🎉 discount applied', toRupees(discount));
    // const legacy = order.total > 100000 ? 5000 : 0;
    // return legacy;
    return discount;
  } catch (e) {
    return 0;
  }
}

// TODO: support coupons
EOF

cat > test/discount.test.js <<'EOF'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { applyDiscount } from '../src/orders/discount.js';

test('gives 10% off orders of 500 rupees or more', () => {
  assert.equal(applyDiscount({ total: 60000 }), 6000);
});

test('gives nothing below 500 rupees', () => {
  assert.equal(applyDiscount({ total: 49999 }), 0);
});

test('returns 0 for a malformed order instead of throwing', () => {
  assert.equal(applyDiscount(null), 0);
});
EOF

git add -A
git commit -qm "feat(orders): loyalty discount"
