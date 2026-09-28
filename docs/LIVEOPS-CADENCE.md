# Repair Empire - LiveOps Cadence

## Principle
Prefer measured content and balance iteration over adding large systems after launch.

## Weekly
- Review critical errors and save failures.
- Review job completion/abandon rates.
- Review economy sources/sinks by level band.
- Review purchase grant failures.
- Triage player-reported blockers.

## Per balance patch
- Increment `BalanceConfig.Version`.
- State changed variables and hypothesis.
- Avoid changing several core economy variables at once without a reason.
- Compare before/after windows using the balance version.

## Content rotation
Supported hooks:
- featured category
- daily jobs
- featured contracts
- optional bounded bonus periods after economy modeling

## Expansion priority
1. Fix onboarding/progression blockers.
2. Improve weak existing jobs.
3. Add job/content variety.
4. Improve city/workshop art and feedback.
5. Add new systems only when evidence shows a missing loop.

## Protected invariants
- Paid entitlements persist.
- No mandatory energy gate.
- Solo progression remains viable.
- Server remains authoritative for value.
