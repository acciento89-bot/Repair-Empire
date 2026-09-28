# Repair Empire

Roblox tycoon/simulator project by Kamilunavo.

## Product thesis
Repair Empire combines short repair missions with company-building progression. The player starts as a solo technician and grows into a multi-crew service company. The experience is designed for Roblox mobile, desktop, tablet and controller users.

## Core loop
Accept job -> travel -> diagnose -> perform interaction sequence -> earn Cash/XP -> upgrade tools/company -> unlock harder districts/jobs -> repeat.

## V1 principles
- Fun before simulation accuracy.
- Server-authoritative economy and progression.
- No energy gate and no mandatory paywall.
- Monetization is convenience, cosmetics and acceleration, not required access.
- Mobile-first UI with full PC/controller support.
- Data-driven jobs, tools, vehicles and upgrades.
- Co-op is additive; solo play remains complete.
- No external backend required for V1 unless a later phase explicitly changes this.

## Canonical planning documents
Read in this order before implementation:
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
12. the detail plan for the next open phase under [docs/plans](docs/plans/)

Repository rules and unresolved platform metadata:
- [Repository Conventions](docs/REPOSITORY-CONVENTIONS.md)
- [Project Metadata](docs/PROJECT-METADATA.md)
- [Agent Execution Contract](AGENTS.md)
- [Implementation Start Prompt](docs/IMPLEMENTATION-START-PROMPT.md)

## Execution rule
Do not redesign the approved V1 while implementing. Determine the next open ledger task, read its detail plan, implement only that task and its explicit dependencies, test it, commit it, then update the ledger.

## Status
Planning baseline: **COMPLETE**

Standalone repository initialization: **COMPLETE (P00-T01)**

Implementation/product-definition status: **P00 IN PROGRESS**

The next open ledger task is authoritative; do not rely on this README for task state.
