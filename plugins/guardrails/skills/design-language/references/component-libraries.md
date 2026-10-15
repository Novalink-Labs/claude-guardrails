# Component foundations

Options per stack for the team to choose from. Package names and versions were checked on npm in October 2026; check the current version and licence before adopting. Whatever is chosen gets restyled through the design language's tokens.

## How to choose

| If the team wants | Lean towards |
|---|---|
| Its own distinct look, full control of the component code | Copy-in components on accessible primitives: shadcn/ui and its ports (shadcn-vue, shadcn-svelte, spartan/ui, react-native-reusables) |
| Accessibility as the top priority, custom styling | React Aria Components, Radix primitives, Ark UI, Reka UI, Bits UI, Angular CDK |
| A complete, themeable kit to move fast | Mantine, Chakra UI, HeroUI, Radix Themes, Nuxt UI, PrimeVue / PrimeNG |
| Dense admin and data screens | Mantine, Ant Design, PrimeVue / PrimeNG, plus TanStack Table |
| Material Design as the brand language | MUI, Angular Material, Vuetify, React Native Paper |
| One codebase styled across web and native | Tamagui, gluestack-ui, NativeWind with react-native-reusables |

Things to weigh: accessibility record, how far theming can go, bundle size, server-component support (Next.js), maintenance activity, licence, and whether the team will own copied code or depend on a package.

## React (web)

| Library | npm package | What it is |
|---|---|---|
| shadcn/ui | `shadcn` (CLI) | Components copied into the repo, built on accessible primitives and Tailwind. You own and restyle the code. |
| Radix Themes | `@radix-ui/themes` | Ready-styled, themeable components on Radix primitives. |
| React Aria Components | `react-aria-components` | Adobe's unstyled, strongly accessible components. |
| Ark UI | `@ark-ui/react` | Unstyled headless components (state machines), also for Vue, Solid and Svelte. |
| Headless UI | `@headlessui/react` | Small set of unstyled accessible components from the Tailwind team. |
| Mantine | `@mantine/core` | Full-featured kit with many components and hooks. |
| Chakra UI | `@chakra-ui/react` | Themeable component kit with style props. |
| HeroUI | `@heroui/react` | Styled kit built on Tailwind (formerly NextUI). |
| MUI | `@mui/material` | Material Design implementation. |
| Ant Design | `antd` | Enterprise kit, strong for dense admin screens. |

## Vue and Nuxt

| Library | npm package | What it is |
|---|---|---|
| shadcn-vue | `shadcn-vue` | shadcn/ui port: copy-in components on Reka UI. |
| Reka UI | `reka-ui` | Unstyled accessible primitives (formerly Radix Vue). |
| Nuxt UI | `@nuxt/ui` | Styled components for Nuxt and Vue on Reka UI and Tailwind. |
| PrimeVue | `primevue` | Large kit, styled or unstyled modes. |
| Vuetify | `vuetify` | Material Design for Vue. |
| Naive UI | `naive-ui` | Themeable kit written in TypeScript. |

## Angular

| Library | npm package | What it is |
|---|---|---|
| Angular Material and CDK | `@angular/material` | Material components; the CDK gives unstyled behaviour primitives. |
| spartan/ui | `@spartan-ng/brain` | shadcn-style copy-in components for Angular. |
| PrimeNG | `primeng` | Large kit with themes. |

## Svelte

| Library | npm package | What it is |
|---|---|---|
| shadcn-svelte | `shadcn-svelte` | shadcn/ui port on Bits UI. |
| Bits UI | `bits-ui` | Unstyled accessible primitives. |
| Skeleton | `@skeletonlabs/skeleton` | Design system and components on Tailwind. |

## React Native

| Library | Package or source | What it is |
|---|---|---|
| react-native-reusables | github.com/founded-labs/react-native-reusables | shadcn-style copy-in components with NativeWind. |
| NativeWind | `nativewind` | Tailwind-style styling for React Native. |
| Tamagui | `tamagui` | Styled components and an optimising compiler for native and web. |
| gluestack-ui | `@gluestack-ui/core` | Universal components for native and web. |
| React Native Paper | `react-native-paper` | Material Design for React Native. |

## Supporting pieces

- **Data tables:** TanStack Table (`@tanstack/react-table`, with ports for other frameworks), styled with the chosen kit.
- **Charts:** Recharts (`recharts`, used by shadcn/ui charts), Tremor (`@tremor/react`) for dashboards. Colour charts from tokens, with a palette checked for colour-blind safety.
- **Icons:** pick one set and stick to it: Lucide (`lucide-react`), Phosphor (`@phosphor-icons/react`), Tabler (`@tabler/icons-react`), or the kit's own.
- **Forms:** the form library the stack's ADR names, with schema validation shared with the API where possible.
