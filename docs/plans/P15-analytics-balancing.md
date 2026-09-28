# P15 - Analytics and Balancing

## Goal
Instrument the launch build and make one evidence-based balance pass before public exposure.

### P15-T01 Event schema
Define stable names/properties and avoid high-cardinality noise.

### P15-T02 Funnel events
Instrument tutorial -> first job -> first upgrade -> district/company milestones.

### P15-T03 Economy events
Every source/sink reports reason, amount, level band and balance version.

### P15-T04 Monetization events
Track shop/prompt/grant funnel without treating client prompt completion as payment truth.

### P15-T05 Balance versioning
Config release carries a balance version visible in analytics/debug logs.

### P15-T06 Full launch economy pass
Model/test early, mid, late and prestige pacing. Inspect passive vs active income.

## Required questions
- Where do players stall?
- Is first meaningful upgrade fast enough?
- Are any sinks irrelevant?
- Does passive play dominate?
- Can non-payers complete progression?
- Do paid accelerators create excessive progression gaps?

## Definition of Done
Launch values have documented rationale and can be attributed to a balance version.
