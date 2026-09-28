# Repair Empire

Roblox tycoon/simulator project by Kamilunavo.

## Product thesis
Repair Empire combines short repair missions with company-building progression. The player starts as a solo technician and grows into a multi-crew service company. The experience targets Roblox mobile, desktop, tablet and controller users.

## Current implementation status
The V1 implementation is active and the repository is CI-green.

Implemented core systems include:
- Rojo/Luau project foundation and GitHub Actions CI
- versioned player profiles, session locks, autosave and migrations
- 30 data-driven launch jobs across Plumbing, Heating, Climate and Energy
- server-authoritative job offers, staged repair interactions and rewards
- player/company progression, district unlocks and Prestige
- 20 tools with tier gates and speed modifiers
- 8 vehicle definitions with purchase/select/spawn and a self-contained procedural driving controller
- workshop/company progression, 12 employee definitions and bounded passive income
- three procedural districts with reusable tagged job anchors
- 1-6 player co-op contracts with discovery, contribution tracking and validated reward splits
- daily jobs, login streaks and achievements
- Roblox-native analytics hooks, economy telemetry and balance versioning
- server-side security/rate limits/spatial checks
- purchase/receipt infrastructure with idempotent Developer Product grants
- responsive menu/HUD/input paths for touch, keyboard/mouse and controller

The authoritative status is always:
- [V1 Ledger](docs/REPAIR-EMPIRE-V1-LEDGER.md)
- [External Roblox Blockers](docs/EXTERNAL-ROBLOX-BLOCKERS.md)

## Core loop
Accept job -> travel -> diagnose -> perform interaction sequence -> earn Cash/XP -> upgrade tools/company -> unlock harder districts/jobs -> repeat.

## V1 principles
- Fun before simulation accuracy.
- Server-authoritative economy and progression.
- No energy gate and no mandatory paywall.
- Monetization is convenience/acceleration and never required access.
- Mobile-first UI with PC/controller support.
- Data-driven jobs, tools, vehicles and upgrades.
- Co-op is additive; solo play remains complete.
- No external backend is required for V1.

## Repository layout
```text
src/
  client/       Roblox client controllers and UI
  server/       authoritative services, datastore and security
  shared/       configs, definitions, validation and pure rules
tests/          pure-Luau invariant/unit tests
scripts/        CI/test entrypoints
docs/           product, architecture, security, release and phase plans
default.project.json
rokit.toml
```

## Local development
Install the pinned toolchain:

```sh
rokit install
```

Run Rojo for Roblox Studio:

```sh
rojo serve default.project.json
```

Build a place file:

```sh
rojo build default.project.json --output build.rbxlx
```

Run the same verification gates as CI:

```sh
stylua --check src tests scripts
selene src tests scripts
lune run scripts/run-tests
```

## Roblox platform status
Repair Empire is configured in Roblox and remains private while QA is incomplete.

Configured:
- Universe ID: `10768475286`
- production Start Place ID: `79925227687072`
- development/test Place ID: `138882349802835`
- five Game Passes
- six Developer Products
- isolated development/production DataStores

Remaining Roblox-side gates are runtime/device/security/Marketplace sandbox verification plus final store assets and release declarations.

Use:
- [Roblox Dashboard Setup](docs/ROBLOX-DASHBOARD-SETUP.md)
- [Project Metadata](docs/PROJECT-METADATA.md)
- [External Roblox Blockers](docs/EXTERNAL-ROBLOX-BLOCKERS.md)

## Canonical product documents
1. [Product Specification](docs/PRODUCT-SPEC.md)
2. [Game Design](docs/GAME-DESIGN.md)
3. [Technical Architecture](docs/TECHNICAL-ARCHITECTURE.md)
4. [Economy & Monetization](docs/ECONOMY-MONETIZATION.md)
5. [UI/UX](docs/UI-UX.md)
6. [Security & Anti-Cheat](docs/SECURITY-ANTI-CHEAT.md)
7. [Data & Analytics](docs/DATA-ANALYTICS.md)
8. [Content Catalog](docs/CONTENT-CATALOG.md)
9. [Release & LiveOps](docs/RELEASE-LIVEOPS.md)
10. [Master Plan](docs/MASTER-PLAN.md)
11. [V1 Ledger](docs/REPAIR-EMPIRE-V1-LEDGER.md)

## Execution rule
Do not redesign the approved V1 while implementing. Work from the ledger/detail plans, keep value-bearing logic server-authoritative, run CI-equivalent verification, commit completed work and update the ledger truthfully.

## Release rule
Public release remains blocked until the external/runtime acceptance criteria in the ledger are genuinely verified. A green repository build is necessary but does not substitute for Roblox Studio multi-client, device, DataStore and Marketplace sandbox tests.
