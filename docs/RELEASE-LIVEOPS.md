# Repair Empire - Release and LiveOps

## Environments
Development place/universe as appropriate.
Private QA/test access.
Public release only after release checklist.

## Release gates
Gameplay:
- tutorial complete
- 30 jobs configured
- progression has no dead end
- solo path complete
- co-op large job tested

Data:
- schema version defined
- migration tested
- save/rejoin tested
- failure handling tested

Monetization:
- product/pass IDs configured outside hardcoded logic
- sandbox purchase tests complete
- receipt duplication tests complete
- free path verified

Security:
- remote audit complete
- rate limits active
- exploit attempts tested

UX:
- small-phone test
- tablet test
- desktop test
- controller test
- accessibility basics checked

Operations:
- version/balance version recorded
- rollback plan documented
- launch metrics dashboard checklist ready

## Launch strategy
1. Private test.
2. Small controlled public exposure.
3. Fix critical onboarding/save/economy issues.
4. Expand only after telemetry is healthy.

## LiveOps cadence
Prefer content/balance updates over constant new systems.
Potential rotations:
- featured contract
- double XP weekend only when economy impact is modeled
- seasonal cosmetic workshop themes
- limited non-paywalled challenges

## Incident priorities
P0: data loss, duplicated paid rewards, broad economy exploit.
P1: blocked progression, widespread job failure, purchase grant failure.
P2: balance/UX defect.
P3: cosmetic polish.

## Rollback
Config-driven balance should permit quick revert.
Schema changes must be backward-aware; never ship destructive migration without tested recovery path.
