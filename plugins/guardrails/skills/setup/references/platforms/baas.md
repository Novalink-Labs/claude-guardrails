# Supabase and Firebase

Apps built on a backend-as-a-service let the client talk to the database directly. That makes the database rules the security boundary, and it's where vibe-coded apps leak data most often. Add this section alongside the app's own stack.

## Supabase

- Row Level Security is enabled on every table in an exposed schema, with a policy per operation (select, insert, update, delete) that checks `auth.uid()` against the row's owner or organisation.
- The anon key is public by design; it is safe only because of RLS. The service-role key bypasses RLS: server code only, never in the client, the bundle, the repo or logs.
- Storage buckets are private unless the content is truly public, with policies like tables.
- Edge Functions verify the caller's JWT and re-check authorisation.
- Schema, policies and functions live in `supabase/migrations/`, reviewed like code. Policies have tests (for example pgTAP) covering both allowed and denied access.
- Views and functions created with `security definer` bypass RLS; use them only deliberately, and review them as security logic.

## Firebase

- Firestore, Realtime Database and Storage rules never ship in test mode or with `allow read, write: if true`. Rules check `request.auth` and ownership, and validate the shape of written data.
- The web config (`apiKey`, project id) is an identifier, not a secret. Restrict the API key in Google Cloud and turn on App Check.
- The Admin SDK and service-account JSON are server-only (Cloud Functions or your backend), never in the client or the repo.
- Rules and indexes live in the repo (`firestore.rules`, `storage.rules`, `firestore.indexes.json`), are deployed from CI, and have emulator tests for allowed and denied access.
- Cloud Functions validate input and check `context.auth`; callable functions aren't private just because the client doesn't link to them.

## Both

- Anything the client can do with the public key, an attacker can do with a script. Test the rules as that attacker: unauthenticated, as another user, and with extra fields.
- Business rules that must not be bypassed (pricing, credits, roles) run on the server, not in client code.
