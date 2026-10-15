#!/usr/bin/env bash
# A small vibe-coded Express + MongoDB app: everything in one file, a tracked .env, no docs, no CI.
set -euo pipefail

git init -q -b main
git config user.email eval@example.com
git config user.name eval
mkdir -p src docs

# Assembled at runtime so the fixture source never contains a credential-shaped string.
secret="$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')"
printf 'MONGO_URL=%s://%s:%s@%s/chai\nJWT_SECRET=%s\n' mongodb chai_admin "$secret" cluster0.example.mongodb.net "$secret" > .env

cat > package.json <<'EOF'
{
  "name": "chaiwala",
  "private": true,
  "scripts": { "start": "node src/index.js", "test": "node --test" },
  "dependencies": { "express": "^5.1.0", "mongoose": "^8.9.0", "jsonwebtoken": "^9.0.0", "dotenv": "^16.4.0" }
}
EOF

cat > src/index.js <<'EOF'
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');

const app = express();
app.use(express.json());

const Order = mongoose.model('Order', new mongoose.Schema({ userId: String, items: Array, total: Number, status: String }));

app.post('/login', (req, res) => {
  const token = jwt.sign({ id: req.body.phone }, process.env.JWT_SECRET);
  res.json({ token });
});

app.get('/orders/:id', async (req, res) => {
  res.json(await Order.findById(req.params.id));
});

app.post('/orders', async (req, res) => {
  if (req.body.items.length > 20) return res.status(400).send('too many');
  res.json(await Order.create({ ...req.body, status: 'NEW' }));
});

mongoose.connect(process.env.MONGO_URL).then(() => app.listen(3000));
EOF

cat > docs/spec.md <<'EOF'
# Chaiwala

Customers order tea and snacks from a neighbourhood tea shop on their phones and pick them up. Sign-in with a phone number and OTP. One shop for now.
EOF

git add -A
git commit -qm "first version"
