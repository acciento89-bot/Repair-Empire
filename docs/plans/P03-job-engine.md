# P03 - Job Engine

## Goal
Build the reusable data-driven engine that powers all repair content.

### P03-T01 Job data schema and registry
Fields: id, category, district, player/company level gates, weighted rarity, reward, XP, expected duration, required tool tier, repetition cooldown, stages and co-op flag.
Acceptance: malformed content fails validation in development.

### P03-T02 Server job offer generation
Generate weighted offers from eligible config using server state and per-job repetition cooldowns.
Acceptance: locked districts/tools/jobs and cooling-down jobs never appear as eligible offers; weighted sampling does not repeat an offer.

### P03-T03 Accept/abandon lifecycle
One authoritative active-job model with unique instance ID.
Acceptance: duplicate accept and stale abandon requests are rejected.

### P03-T04 Staged interaction state machine
Server validates sequence, target, timing and state.
Acceptance: client cannot skip directly to final stage.

### P03-T05 Completion/reward transaction
Completion and reward are one guarded server transaction.
Acceptance: job reward values come only from server config/state.

### P03-T06 Reconnect/duplicate-completion protection
Define active-job persistence/recovery policy and consumed completion state.
Acceptance: reconnect or replay cannot double-grant.

### P03-T07 First 5 vertical-slice jobs
Implement representative jobs across increasing complexity, including at least Plumbing and Heating.

### P03-T08 Verification pass
Multi-client, reconnect, invalid remote payload, timing and reward tests.

## Definition of Done
Adding most future jobs is content/config + assets, not engine edits.
