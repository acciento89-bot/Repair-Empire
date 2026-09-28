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

### P04-T06 Category Skill Tree
Four category branches: Plumbing, Heating, Climate and Energy.
Each branch has five V1 ranks.
Players earn one Skill Point every five levels; level 100 provides exactly enough points to max all 20 launch ranks.
Bonuses are server-authoritative and bounded: repair speed plus small Cash/XP category bonuses.
Prestige resets earned Skill Tree progress.

Acceptance:
- schema/migration includes branch ranks;
- points cannot be client-created;
- branch max is enforced;
- solo and co-op use the same server multipliers;
- Skill Tree has a responsive player-facing screen.

## Balance fixtures
Provide representative early/mid/late profiles to test pacing and price curves.

## Definition of Done
All future systems consume economy/progression APIs rather than inventing their own balances.
