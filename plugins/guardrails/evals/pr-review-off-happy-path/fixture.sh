#!/usr/bin/env bash
# Builds a small Express repo: main is clean, feature/invoices works on the happy path and carries the planted problems.
set -euo pipefail

git init -q -b main
git config user.email eval@example.com
git config user.name eval
mkdir -p src/common src/modules/invoices web/invoices docs/spec

cat > AGENTS.md <<'EOF'
# AGENTS.md

## Non-negotiables
- The spec in docs/spec/ is the source of truth. AI must not decide architecture, data models, product behaviour, UI patterns or security logic.
- Every route requires authentication and is scoped to the caller's workspace (orgId).
- No magic strings or numbers; constants live in the feature's constants.ts.
- Reuse helpers in src/common before writing new ones.

## Project structure
src/modules/<feature>/ holds <feature>.routes.ts, <feature>.service.ts and constants.ts. web/<feature>/ holds the screens.
Business rules live in services; routes stay thin.
EOF

cat > docs/spec/invoices.md <<'EOF'
# Invoices

- Invoices go draft -> sent -> paid. A sent invoice can be voided.
- The dashboard shows Still owed (what clients still owe us) and Overdue (how many invoices are past their due date).
- Each workspace sets its time zone in Settings; its people see dates in that zone.
- Each line has a description, a quantity (a count of items) and a unit price.
- People can edit an invoice's notes, including removing them.
- A PDF or an image can be attached to an invoice.
- Invoices can be exported as CSV to open in Excel.
- Every change to an invoice shows in its history.
EOF

cat > src/common/db.ts <<'EOF'
export type InvoiceStatus = 'draft' | 'sent' | 'paid' | 'void';

export interface Invoice {
  id: string;
  orgId: string;
  number: string;
  clientName: string;
  status: InvoiceStatus;
  dueDate: string; // YYYY-MM-DD
  totalMinor: number;
  paidMinor: number;
  notes?: string;
}

export interface Org {
  id: string;
  timeZone: string; // IANA, e.g. Africa/Nairobi
}

const rows: Invoice[] = [];

export const db = {
  invoices: {
    async findAll(filter: { orgId: string }) {
      return rows.filter((r) => r.orgId === filter.orgId);
    },
    async findOne(orgId: string, id: string) {
      return rows.find((r) => r.orgId === orgId && r.id === id);
    },
    async update(id: string, patch: Partial<Invoice>) {
      const row = rows.find((r) => r.id === id);
      if (row) Object.assign(row, JSON.parse(JSON.stringify(patch)));
    },
    async addLine(id: string, line: { description: string; quantity: number; unitPriceMinor: number }) {
      return { invoiceId: id, ...line };
    },
  },
  history: {
    async insert(entry: Record<string, unknown>) {
      return entry;
    },
  },
  files: {
    async put(invoiceId: string, name: string, bytes: Buffer, type: string) {
      return { invoiceId, name, size: bytes.length, type };
    },
  },
};
EOF

cat > src/common/auth.ts <<'EOF'
import type { NextFunction, Request, Response } from 'express';

export interface AuthedRequest extends Request {
  user: { id: string; orgId: string };
}

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  if (!req.headers.authorization) return res.status(401).end();
  (req as AuthedRequest).user = { id: 'u1', orgId: 'o1' };
  next();
}
EOF

cat > package.json <<'EOF'
{ "name": "invoices-app", "private": true, "dependencies": { "express": "^5.1.0", "multer": "^2.0.0", "react": "^19.0.0" } }
EOF

git add -A
git commit -qm "chore: initial invoices app"

git checkout -q -b feature/invoices

cat > src/modules/invoices/constants.ts <<'EOF'
export const ALLOWED_FILE_TYPES = ['application/pdf', 'image/png', 'image/jpeg'];
export const MAX_FILE_BYTES = 10 * 1024 * 1024;
export const CSV_HEADER = 'number,client,total';
EOF

cat > src/modules/invoices/invoices.service.ts <<'EOF'
import { db, Invoice } from '../../common/db';
import { CSV_HEADER } from './constants';

const TODAY = new Date().toISOString().slice(0, 10);

export async function summary(orgId: string) {
  const invoices = await db.invoices.findAll({ orgId });
  const outstandingMinor = invoices.reduce((sum, i) => sum + (i.totalMinor - i.paidMinor), 0);
  const overdue = invoices.filter((i) => i.dueDate < TODAY).length;
  return { outstandingMinor, overdue };
}

export async function addLine(
  invoiceId: string,
  input: { description: string; quantity: unknown; unitPriceMinor: number },
) {
  const quantity = Math.max(1, Math.round(Number(input.quantity)));
  return db.invoices.addLine(invoiceId, { ...input, quantity });
}

export async function update(invoiceId: string, userId: string, body: Partial<Invoice>) {
  await db.invoices.update(invoiceId, body);
  await db.history.insert({ invoiceId, userId, changes: body, at: new Date().toISOString() });
}

export function toCsv(invoices: Invoice[]): string {
  const lines = invoices.map((i) => [i.number, i.clientName, (i.totalMinor / 100).toFixed(2)].join(','));
  return [CSV_HEADER, ...lines].join('\n');
}
EOF

cat > src/modules/invoices/invoices.routes.ts <<'EOF'
import { Router } from 'express';
import multer from 'multer';
import { db } from '../../common/db';
import { AuthedRequest, requireAuth } from '../../common/auth';
import { ALLOWED_FILE_TYPES, MAX_FILE_BYTES } from './constants';
import { addLine, summary, toCsv, update } from './invoices.service';

const upload = multer({ limits: { fileSize: MAX_FILE_BYTES } });

export const invoicesRouter = Router();

invoicesRouter.get('/invoices/summary', requireAuth, async (req, res) => {
  res.json(await summary((req as AuthedRequest).user.orgId));
});

invoicesRouter.get('/invoices/export.csv', requireAuth, async (req, res) => {
  const invoices = await db.invoices.findAll({ orgId: (req as AuthedRequest).user.orgId });
  res.type('text/csv').send(toCsv(invoices));
});

invoicesRouter.post('/invoices/:id/lines', requireAuth, async (req, res) => {
  const invoice = await db.invoices.findOne((req as AuthedRequest).user.orgId, req.params.id);
  if (!invoice) return res.status(404).end();
  res.json(await addLine(invoice.id, req.body));
});

invoicesRouter.patch('/invoices/:id', requireAuth, async (req, res) => {
  const { user } = req as AuthedRequest;
  const invoice = await db.invoices.findOne(user.orgId, req.params.id);
  if (!invoice) return res.status(404).end();
  await update(invoice.id, user.id, { notes: req.body.notes });
  res.json({ ok: true });
});

invoicesRouter.post('/invoices/:id/files', requireAuth, upload.single('file'), async (req, res) => {
  const invoice = await db.invoices.findOne((req as AuthedRequest).user.orgId, req.params.id);
  if (!invoice || !req.file) return res.status(404).end();
  if (!ALLOWED_FILE_TYPES.includes(req.file.mimetype)) {
    return res.status(400).json({ error: 'Only PDF, PNG or JPEG files' });
  }
  res.json(await db.files.put(invoice.id, req.file.originalname, req.file.buffer, req.file.mimetype));
});
EOF

cat > web/invoices/notes-form.tsx <<'EOF'
import { useState } from 'react';

export function NotesForm({ invoiceId, initial }: { invoiceId: string; initial?: string }) {
  const [notes, setNotes] = useState(initial ?? '');
  const [saved, setSaved] = useState(false);

  async function save() {
    await fetch(`/invoices/${invoiceId}`, {
      method: 'PATCH',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ notes: notes.trim() || undefined }),
    });
    setSaved(true);
  }

  return (
    <form onSubmit={(e) => { e.preventDefault(); void save(); }}>
      <label htmlFor="notes">Notes</label>
      <textarea id="notes" value={notes} onChange={(e) => setNotes(e.target.value)} />
      <button type="submit">Save notes</button>
      {saved && <p role="status">Notes saved</p>}
    </form>
  );
}
EOF

git add -A
git commit -qm "feat(invoices): summary, lines, notes, files and CSV export"
