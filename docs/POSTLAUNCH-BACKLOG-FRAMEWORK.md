# Repair Empire - Post-launch Backlog Framework

## Intake categories
Every post-launch item must be tagged as one primary problem:
- activation/onboarding
- retention
- progression/economy
- gameplay/content
- multiplayer
- UX/accessibility
- performance/reliability
- security/abuse
- monetization
- visual/audio polish

## Evidence fields
Before prioritizing a non-critical item, record where possible:
- affected player segment
- affected version/balance version
- frequency
- severity
- funnel/retention/economy metric affected
- reproducibility
- workaround availability
- implementation/risk estimate

## Priority rules
1. P0/P1 incidents override backlog scoring.
2. Data loss, purchase safety and broad exploits outrank growth work.
3. Progression blockers outrank new content.
4. Repeated evidence across telemetry and reports outranks isolated preferences.
5. Prefer improving an existing weak loop before adding a new large system.

## Decision record
For each selected change:
- problem statement
- evidence
- expected metric/player outcome
- smallest coherent change
- affected configs/systems
- rollback plan
- measurement window

## Balance experiments
Never change several major sources/sinks simultaneously unless the variables are inseparable.
Always increment `BalanceConfig.Version` for a deployed economy change.

## Status
Framework: ready before launch.
Evidence-based prioritization: blocked until real post-launch data exists.
