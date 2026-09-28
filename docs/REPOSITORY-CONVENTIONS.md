# Repository Conventions

## Repository
- Canonical repository: `acciento89-bot/Repair-Empire`
- Default/integration branch: `main`
- Planning and implementation state is tracked in `docs/REPAIR-EMPIRE-V1-LEDGER.md`.

## Branches
For implementation work, prefer short-lived task branches:
`pXX-tYY-short-description`

Examples:
- `p01-t01-rojo-layout`
- `p03-t04-job-state-machine`

Direct work on `main` is acceptable only when explicitly chosen for a small documentation/administrative change.

## Commits
Commit messages should identify the task when implementation begins:
`P03-T04: implement staged job state machine`

A completed task must include:
1. implementation/config/docs required by the detail plan,
2. applicable verification,
3. ledger update in the same work cycle.

## Source of truth
Read in this order:
1. README.md
2. canonical specs under `docs/`
3. `docs/MASTER-PLAN.md`
4. `docs/REPAIR-EMPIRE-V1-LEDGER.md`
5. detail plan for the next open phase

Do not silently reduce V1 scope or redesign approved systems while implementing.

## Pull requests
When PRs are used:
- one logical ledger task per PR unless tightly coupled dependencies require otherwise,
- include tests/checks run,
- mention affected task IDs,
- do not merge with known P0/P1 regressions.

## Generated/Studio assets
Source-controlled Luau/config stays reviewable in Git.
Roblox-managed binary/Studio assets must have their IDs/ownership assumptions documented when introduced.
