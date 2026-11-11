#!/usr/bin/env bash
# Builds a small Express repo: main is clean, feature/team-access works on the happy path and carries the planted security problems.
set -euo pipefail

git init -q -b main
git config user.email eval@example.com
git config user.name eval
mkdir -p src/common src/modules/invoices docs/spec

cat > AGENTS.md <<'EOF'
# AGENTS.md

## Non-negotiables
- The spec in docs/spec/ is the source of truth. AI must not decide architecture, data models, product behaviour, UI patterns or security logic.
- Every route requires authentication unless the spec says it is public, and is scoped to the caller's workspace (orgId).
- Reuse helpers in src/common before writing new ones.

## Project structure
src/modules/<feature>/ holds <feature>.routes.ts and <feature>.service.ts. Business rules live in services; routes stay thin.
EOF

cat > docs/spec/team-access.md <<'EOF'
# Team access

- Signing out ends the current session. Changing a password signs the person out of every session.
- People join a workspace through an emailed invite link. The link is a secret: whoever holds it can accept the invite.
- Managers see only the invoices of projects they manage. Notes on an invoice are visible to, and can be added by, whoever can see the invoice.
- A sign-in code allows 5 tries.
- The API runs behind one load balancer at 10.0.0.2. Rate limits are per client IP.
- Lists return at most 100 rows per page.
- Contract renewal reminders go to the workspace owners and to the contract's author.
- A disabled member loses all access to the workspace, including its emails.
EOF

cat > src/common/db.ts <<'EOF'
export type Role = 'owner' | 'manager' | 'member';

export interface Member { userId: string; orgId: string; role: Role; status: 'active' | 'disabled'; email: string }
export interface Invoice { id: string; orgId: string; projectId: string; number: string; totalMinor: number }
export interface Project { id: string; orgId: string; managerIds: string[] }
export interface Note { id: string; invoiceId: string; authorId: string; body: string }
export interface Contract { id: string; orgId: string; title: string; counterparty: string; endDate: string; createdBy: string }
export interface Otp { email: string; codeHash: string; attempts: number; expiresAt: number }
export interface Invitation { tokenHash: string; orgId: string; email: string; role: Role }
export interface BlacklistRow { jti: string; userId: string; createdAt: number }

function table<T extends object>() {
  const rows: T[] = [];
  return {
    rows,
    async find(match: Partial<T>) {
      return rows.filter((r) => Object.entries(match).every(([k, v]) => (r as Record<string, unknown>)[k] === v));
    },
    async findOne(match: Partial<T>) {
      return (await this.find(match))[0];
    },
    async insert(row: T) {
      rows.push(row);
      return row;
    },
    async update(match: Partial<T>, patch: Partial<T>) {
      for (const r of await this.find(match)) Object.assign(r, patch);
    },
  };
}

export const db = {
  members: table<Member>(),
  invoices: table<Invoice>(),
  projects: table<Project>(),
  notes: table<Note>(),
  contracts: table<Contract>(),
  otps: table<Otp>(),
  invitations: table<Invitation>(),
  blacklist: table<BlacklistRow>(),
};
EOF

cat > src/common/auth.ts <<'EOF'
import type { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { db, Role } from './db';

export interface Principal { userId: string; orgId: string; role: Role }
export interface AuthedRequest extends Request { user: Principal }

export const JWT_SECRET = process.env.JWT_SECRET as string;

export async function requireAuth(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace(/^Bearer /, '');
  if (!token) return res.status(401).end();
  try {
    const claims = jwt.verify(token, JWT_SECRET) as { sub: string; org: string; jti: string; iat: number };
    const member = await db.members.findOne({ userId: claims.sub, orgId: claims.org, status: 'active' });
    if (!member) return res.status(401).end();
    (req as AuthedRequest).user = { userId: member.userId, orgId: member.orgId, role: member.role };
    next();
  } catch {
    res.status(401).end();
  }
}
EOF

cat > src/modules/invoices/invoices.service.ts <<'EOF'
import type { Principal } from '../../common/auth';
import { db, Invoice } from '../../common/db';

/** Managers see only invoices of projects they manage; owners see all. */
export async function visibleInvoice(user: Principal, id: string): Promise<Invoice | undefined> {
  const invoice = await db.invoices.findOne({ orgId: user.orgId, id });
  if (!invoice || user.role === 'owner') return invoice;
  const project = await db.projects.findOne({ orgId: user.orgId, id: invoice.projectId });
  return project?.managerIds.includes(user.userId) ? invoice : undefined;
}
EOF

cat > src/modules/invoices/invoices.routes.ts <<'EOF'
import { Router } from 'express';
import { AuthedRequest, requireAuth } from '../../common/auth';
import { visibleInvoice } from './invoices.service';

export const invoicesRouter = Router();

invoicesRouter.get('/invoices/:id', requireAuth, async (req, res) => {
  const invoice = await visibleInvoice((req as AuthedRequest).user, req.params.id);
  if (!invoice) return res.status(404).end();
  res.json(invoice);
});
EOF

cat > src/app.ts <<'EOF'
import express from 'express';
import rateLimit from 'express-rate-limit';
import { invoicesRouter } from './modules/invoices/invoices.routes';

export const app = express();
app.use(express.json());
app.use('/auth', rateLimit({ windowMs: 60_000, limit: 10 }));
app.use(invoicesRouter);
EOF

cat > package.json <<'EOF'
{ "name": "team-app", "private": true, "dependencies": { "express": "^5.1.0", "express-rate-limit": "^7.5.0", "jsonwebtoken": "^9.0.2" } }
EOF

git add -A
git commit -qm "chore: initial team app"

git checkout -q -b feature/team-access
mkdir -p src/modules/auth src/modules/invitations src/modules/notes src/jobs

cat > src/common/request-logger.ts <<'EOF'
import type { NextFunction, Request, Response } from 'express';

export function requestLogger(req: Request, res: Response, next: NextFunction) {
  const started = Date.now();
  res.on('finish', () => {
    console.log(JSON.stringify({ msg: `${req.method} ${req.originalUrl} ${res.statusCode}`, ms: Date.now() - started }));
  });
  next();
}
EOF

cat > src/common/pagination.ts <<'EOF'
export const DEFAULT_PER_PAGE = 20;
export const MAX_PER_PAGE = 100;

export function paginate(query: { page?: string; perPage?: string }) {
  const perPage = Math.min(Number(query.perPage) || DEFAULT_PER_PAGE, MAX_PER_PAGE);
  const page = Math.max(Number(query.page) || 1, 1);
  return { limit: perPage, skip: (page - 1) * perPage };
}
EOF

cat > src/modules/auth/token-blacklist.ts <<'EOF'
import jwt from 'jsonwebtoken';
import { db } from '../../common/db';

const REVOKE_ALL = 'revoke-all:';

export async function revoke(token: string) {
  const claims = jwt.decode(token) as { jti?: string; sub?: string } | null;
  if (!claims?.jti || !claims.sub) return;
  await db.blacklist.insert({ jti: claims.jti, userId: claims.sub, createdAt: Date.now() });
}

export async function revokeAll(userId: string) {
  await db.blacklist.insert({ jti: `${REVOKE_ALL}${userId}:${Date.now()}`, userId, createdAt: Date.now() });
}

export async function isRevoked(claims: { jti: string; sub: string; iat: number }) {
  if (await db.blacklist.findOne({ jti: claims.jti })) return true;
  const rows = await db.blacklist.find({ userId: claims.sub });
  return rows.some((r) => r.jti.startsWith(REVOKE_ALL) && r.createdAt > claims.iat * 1000);
}
EOF

cat > src/modules/auth/auth.routes.ts <<'EOF'
import { createHash } from 'node:crypto';
import { Router } from 'express';
import { db } from '../../common/db';
import { revoke } from './token-blacklist';

const MAX_ATTEMPTS = 5;
const hash = (v: string) => createHash('sha256').update(v).digest('hex');

export const authRouter = Router();

authRouter.post('/auth/logout', async (req, res) => {
  const token = req.headers.authorization?.replace(/^Bearer /, '');
  if (token) await revoke(token);
  res.status(204).end();
});

authRouter.post('/auth/code/verify', async (req, res) => {
  const otp = await db.otps.findOne({ email: req.body.email });
  if (!otp || otp.expiresAt < Date.now() || otp.attempts >= MAX_ATTEMPTS) {
    return res.status(400).json({ error: 'That code has expired. Ask for a new one.' });
  }
  const ok = otp.codeHash === hash(String(req.body.code));
  await db.otps.update({ email: otp.email }, { attempts: otp.attempts + 1 });
  if (!ok) return res.status(400).json({ error: 'That code is not right. Check it and try again.' });
  res.json({ ok: true });
});
EOF

cat > src/modules/invitations/invitations.routes.ts <<'EOF'
import { createHash } from 'node:crypto';
import { Router } from 'express';
import { db } from '../../common/db';

const hash = (v: string) => createHash('sha256').update(v).digest('hex');

export const invitationsRouter = Router();

invitationsRouter.get('/invitations/:token', async (req, res) => {
  const invite = await db.invitations.findOne({ tokenHash: hash(req.params.token) });
  if (!invite) return res.status(404).json({ error: 'This invite link has expired or was already used.' });
  res.json({ role: invite.role });
});
EOF

cat > src/modules/notes/notes.routes.ts <<'EOF'
import { randomUUID } from 'node:crypto';
import { Router } from 'express';
import { AuthedRequest, requireAuth } from '../../common/auth';
import { db } from '../../common/db';
import { paginate } from '../../common/pagination';

export const notesRouter = Router();

notesRouter.get('/invoices/:id/notes', requireAuth, async (req, res) => {
  const invoice = await db.invoices.findOne({ orgId: (req as AuthedRequest).user.orgId, id: req.params.id });
  if (!invoice) return res.status(404).end();
  const { limit, skip } = paginate(req.query as Record<string, string>);
  const notes = await db.notes.find({ invoiceId: invoice.id });
  res.json(notes.slice(skip, skip + limit));
});

notesRouter.post('/invoices/:id/notes', requireAuth, async (req, res) => {
  const { user } = req as AuthedRequest;
  const invoice = await db.invoices.findOne({ orgId: user.orgId, id: req.params.id });
  if (!invoice) return res.status(404).end();
  res.status(201).json(await db.notes.insert({ id: randomUUID(), invoiceId: invoice.id, authorId: user.userId, body: String(req.body.body) }));
});
EOF

cat > src/jobs/renewal-reminders.ts <<'EOF'
import { db } from '../common/db';

export async function sendRenewalReminders(orgId: string, today: string, mail: (to: string, text: string) => Promise<void>) {
  const owners = await db.members.find({ orgId, role: 'owner', status: 'active' });
  const contracts = await db.contracts.find({ orgId, endDate: today });
  for (const contract of contracts) {
    const author = await db.members.findOne({ orgId, userId: contract.createdBy });
    const to = [...owners.map((o) => o.email), author?.email].filter(Boolean) as string[];
    for (const email of new Set(to)) {
      await mail(email, `${contract.title} with ${contract.counterparty} ends on ${contract.endDate}.`);
    }
  }
}
EOF

cat > src/app.ts <<'EOF'
import express from 'express';
import rateLimit from 'express-rate-limit';
import { requestLogger } from './common/request-logger';
import { authRouter } from './modules/auth/auth.routes';
import { invitationsRouter } from './modules/invitations/invitations.routes';
import { invoicesRouter } from './modules/invoices/invoices.routes';
import { notesRouter } from './modules/notes/notes.routes';

export const app = express();
app.set('trust proxy', process.env.TRUST_PROXY ?? true);
app.use(requestLogger);
app.use(express.json());
app.use('/auth', rateLimit({ windowMs: 60_000, limit: 10 }));
app.use(authRouter);
app.use(invitationsRouter);
app.use(invoicesRouter);
app.use(notesRouter);
EOF

cat > src/common/auth.ts <<'EOF'
import type { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { db, Role } from './db';
import { isRevoked } from '../modules/auth/token-blacklist';

export interface Principal { userId: string; orgId: string; role: Role }
export interface AuthedRequest extends Request { user: Principal }

export const JWT_SECRET = process.env.JWT_SECRET as string;

export async function requireAuth(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace(/^Bearer /, '');
  if (!token) return res.status(401).end();
  try {
    const claims = jwt.verify(token, JWT_SECRET) as { sub: string; org: string; jti: string; iat: number };
    if (await isRevoked(claims)) return res.status(401).end();
    const member = await db.members.findOne({ userId: claims.sub, orgId: claims.org, status: 'active' });
    if (!member) return res.status(401).end();
    (req as AuthedRequest).user = { userId: member.userId, orgId: member.orgId, role: member.role };
    next();
  } catch {
    res.status(401).end();
  }
}
EOF

git add -A
git commit -qm "feat(team): sign-out, sign-in codes, invites, invoice notes and renewal reminders"
