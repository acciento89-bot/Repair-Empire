# Repair Empire - Prelaunch Balance Review

## Current balance version
`v1-prelaunch-001`

## Guardrails already enforced
- Vehicle purchase costs rise by progression tier.
- Each tool family rises in cost by tier.
- Offline passive income is capped to 240 minutes.
- Prestige reward bonus is capped at +50%.
- Paid Cash multiplier is capped at 2x.
- Main progression has no energy/lives gate.
- Job rewards are server-configured and cannot be supplied by the client.

## Launch pacing assumptions
These are prelaunch hypotheses, not observed player behavior:
- first job should complete within roughly the first few minutes after onboarding;
- first meaningful paid-with-Cash tool upgrade should be visible in the first session;
- Downtown unlock is at player level 15;
- Industrial unlock is at player level 40;
- Prestige requires player level 100, company level 10 and workshop tier 5.

## Metrics required after real tests
- median time to first completed job
- median time to first tool purchase
- median time to Downtown and Industrial unlock
- active vs passive income share
- Cash balance by level band
- job abandon rate by definition
- payer vs non-payer progression gap
- time to first Prestige

## Change rule
Do not change several core economy variables at once without a specific hypothesis. Increment `BalanceConfig.Version` on every deployed balance change.
