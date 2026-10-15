# React Native and Expo

Copy the parts that apply into AGENTS.md. Expo versus bare React Native, navigation, state and update strategy are ADR decisions.

## Structure (Expo Router)

```
app/                          routes: thin screens that compose features
src/
├── features/<feature>/
│   ├── components/
│   ├── hooks/
│   ├── api.ts                typed endpoint functions and query keys
│   ├── schemas.ts
│   └── constants.ts
├── components/ui/            shared primitives and theme tokens
├── lib/api/                  the typed API client and token handling
├── config/env.ts             the only place reading EXPO_PUBLIC_* values
└── constants/
```

## Rules

- **The app bundle is public.** Everything in it, including `EXPO_PUBLIC_*` values and `app.json` extras, can be extracted. Secrets live on your server; the app calls your backend, never a third-party API with a secret key.
- **Tokens** go in secure storage (`expo-secure-store`, which uses the Keychain and Keystore), never in AsyncStorage.
- **Deep links** are untrusted input: validate every parameter and never perform an action from a link without the user's confirmation.
- **Network:** HTTPS only; don't add cleartext or App Transport Security exceptions.
- **Permissions:** ask at the moment of need, explain why, and handle refusal.
- **Lists:** `FlatList` or FlashList for anything long; no heavy work on the JS thread during interactions.
- **Platforms:** test on iOS and Android, a small screen and a large one, with dynamic type and the screen reader on. Every touchable has an accessibility label and role.
- **States:** loading, empty, error and offline as designed; no invented states.
- **Releases:** bump the version and build number on every store build. Over-the-air updates can't change native code; the policy for what ships OTA is an ADR. Keep up with store requirements (target SDK, privacy manifests).
- **Crashes:** a crash reporter in production builds, with personal data scrubbed.
- **TypeScript and tests:** as in `web-frontend.md`: strict types, schemas at the boundaries, component tests with accessible queries, and end-to-end tests for critical flows (tool choice in an ADR).
