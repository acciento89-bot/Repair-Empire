# P04 - Economy and Progression

## Goal
Centralize all value mutations and establish launch progression rules.

### P04-T01 EconomyService
Single API for grants/spends with reason codes.
Acceptance: no feature directly edits Cash/Company Points.

### P04-T02 XP and levels
Server-calculated XP grants and level thresholds.
Acceptance: multiple level-ups in one grant are handled.

### P04-T03 District/job unlock rules
Eligibility functions use config and authoritative profile.
Acceptance: UI can query/display locks without becoming authority.

### P04-T04 Company Points and company levels
Define earning sources, thresholds and unlock effects.
Acceptance: company progression is independent but coherently gated with player progression.

### P04-T05 Source/sink telemetry hooks
All value changes include normalized source/sink category and balance version.

## Balance fixtures
Provide representative early/mid/late profiles to test pacing and price curves.

## Definition of Done
All future systems consume economy/progression APIs rather than inventing their own balances.
