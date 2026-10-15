#!/usr/bin/env bash
# A Next.js repo with a real DESIGN.md and a listings page that ignores it.
set -euo pipefail

git init -q -b main
git config user.email eval@example.com
git config user.name eval
mkdir -p src/app/listings src/features/listings src/components/ui src/styles

cat > package.json <<'EOF'
{ "name": "khoj-web", "private": true, "dependencies": { "next": "^16.0.0", "react": "^19.0.0", "tailwindcss": "^4.0.0", "@radix-ui/react-dialog": "^1.1.0" } }
EOF

cat > DESIGN.md <<'EOF'
# DESIGN.md

## Design read
Operate surface for families searching for a home in Pune, mostly on phones. Should feel calm, trustworthy and family-friendly.

## Foundation
- shadcn/ui on Tailwind, restyled through the tokens below. Use library components (Dialog, Sheet, Button, Card) before writing new ones.
- Icons: Lucide, 1.5 px stroke, 16 and 20 px.

## Typography
- Display: Newsreader 600. Body: Instrument Sans 400 and 600. Nothing else.
- Scale (px): 13 caption, 15 body-sm, 17 body, 21 title, 28 heading. Tabular numerals for prices.

## Colour (tokens in src/styles/tokens.css)
- `--bg`, `--surface`, `--text`, `--muted`, `--border`, `--accent` (deep teal), `--on-accent`, `--danger`. No other colours in components. No gradients.

## Craft
- Every list has loading (skeleton cards), empty (what will appear and a "Clear filters" action) and error (what failed and "Try again") states.
- Prices use Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).
- Interactive things are buttons or links, keyboard reachable, with a visible focus ring.
- Real alt text for every listing photo.

## Voice and copy
Plain, specific, sentence case. No emojis.
EOF

cat > src/styles/tokens.css <<'EOF'
:root { --bg: #f6f7f5; --surface: #ffffff; --text: #1b2321; --muted: #5b6763; --border: #d9dfdc; --accent: #0f5e57; --on-accent: #ffffff; --danger: #a3271b; }
EOF

cat > src/components/ui/dialog.tsx <<'EOF'
export { Root as Dialog, Trigger as DialogTrigger, Content as DialogContent } from '@radix-ui/react-dialog';
EOF

cat > src/features/listings/ListingCard.tsx <<'EOF'
import { Inter } from 'next/font/google';

const inter = Inter({ subsets: ['latin'] });

type Listing = { id: string; title: string; area: string; price: number; photo: string };

export function ListingCard({ listing, onOpen }: { listing: Listing; onOpen: () => void }) {
  return (
    <div onClick={onOpen} className={`${inter.className} rounded-2xl shadow-xl p-6 text-center`} style={{ background: '#faf5ff' }}>
      <img src={listing.photo} />
      <div className="text-[19px] font-bold" style={{ color: '#7c3aed' }}>🏠 {listing.title}</div>
      <p className="text-[13.5px] text-gray-500">{listing.area}</p>
      <p className="text-[22px]">₹{listing.price}</p>
    </div>
  );
}
EOF

cat > src/app/listings/page.tsx <<'EOF'
'use client';
import { useEffect, useState } from 'react';
import { ListingCard } from '@/features/listings/ListingCard';

export default function ListingsPage() {
  const [listings, setListings] = useState<any[]>([]);
  const [open, setOpen] = useState<string | null>(null);

  useEffect(() => {
    fetch('/api/listings').then((r) => r.json()).then(setListings);
  }, []);

  return (
    <main className="flex flex-col items-center text-center">
      <section className="w-full py-24 bg-gradient-to-r from-purple-600 to-blue-500 text-white">
        <h1 className="text-5xl font-extrabold">Unlock your dream home ✨</h1>
        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
      </section>
      <div className="grid grid-cols-3 gap-6">
        {listings.map((l) => <ListingCard key={l.id} listing={l} onOpen={() => setOpen(l.id)} />)}
      </div>
      {open && (
        <div className="fixed inset-0 bg-black/50" onClick={() => setOpen(null)}>
          <div className="bg-white m-auto mt-40 w-96 p-8 rounded-3xl">Book a visit for {open}</div>
        </div>
      )}
    </main>
  );
}
EOF

git add -A
git commit -qm "feat(listings): listings page"
