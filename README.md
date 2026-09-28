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
1. docs/PRODUCT-SPEC.md
2. docs/GAME-DESIGN.md
3. docs/TECHNICAL-ARCHITECTURE.md
4. docs/ECONOMY-MONETIZATION.md
5. docs/UI-UX.md
6. docs/SECURITY-ANTI-CHEAT.md
7. docs/DATA-ANALYTICS.md
8. docs/CONTENT-CATALOG.md
9. docs/RELEASE-LIVEOPS.md
10. docs/MASTER-PLAN.md
11. docs/REPAIR-EMPIRE-V1-LEDGER.md
12. the detail plan for the next open phase under docs/plans/

## Execution rule
Do not redesign the approved V1 while implementing. Determine the next open ledger task, read its detail plan, implement only that task and its explicit dependencies, test it, commit it, then update the ledger.

## Status
Planning baseline: COMPLETE
Implementation status: NOT STARTED
