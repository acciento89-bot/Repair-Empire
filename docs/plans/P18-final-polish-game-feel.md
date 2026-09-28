# P18 - Final Polish & Game Feel

## Goal
Repair Empire is not release-ready merely because systems exist. This phase closes the gap between functional implementation and a coherent, attractive, satisfying game.

Public launch gate: P18-T01 through P18-T06 must be verified before P16-T05 may move from blocked to complete.

### P18-T01 Visual design system and shell
Replace prototype/dev-looking presentation with a coherent Repair Empire visual language across HUD, menu shell, tabs, cards, states and focus treatment.

Acceptance:
- menu/HUD no longer read as default grey developer UI
- consistent palette, hierarchy, spacing, corners, strokes and selected states
- active tab is visually obvious
- touch/mouse/controller states remain readable
- responsive guardrails remain green

### P18-T02 Retention loop completeness
Audit and polish Daily Jobs, daily login rewards, achievements and playtime/online rewards.

Acceptance:
- every retention reward has clear locked/ready/claimed state
- a server-authoritative playtime reward track exists if absent
- reward timing and claim rules are exploit-safe and persisted where appropriate
- reward feedback is visible and understandable

### P18-T03 Jobs and quest experience
Play through the launch job catalog and co-op contract loop as player-facing content rather than only validating service logic.

Acceptance:
- objectives, stage text, requirements and rewards are understandable
- no dead-end or contradictory stage sequence
- completion, failure and unavailable states have polished feedback
- representative early/mid/late jobs are runtime-verified

### P18-T04 Vehicles and garage presentation
Polish vehicle selection, ownership, spawn state and visual presentation.

Acceptance:
- garage screen uses vehicle-specific presentation instead of plain text-only rows
- selected/owned/locked states are unmistakable
- representative vehicles are runtime-verified for spawn, seat, travel and despawn
- visual variants are identifiable in play

### P18-T05 World, workshop, audio and effects pass
Improve environmental readability, workshop identity, interaction feedback, reward moments and final audio/VFX consistency.

Acceptance:
- residential/downtown/industrial areas remain visually distinct in actual play
- workshop/company area has a clear identity and upgrade readability
- repair/reward/unlock/error moments have appropriate feedback
- no temporary/debug-looking presentation remains in core flow

### P18-T06 Full player-journey acceptance
Run a final player-oriented pass from first join through onboarding, jobs, tools, vehicles, company systems, retention, shop and Prestige preview.

Acceptance:
- phone, tablet and desktop presentation is coherent
- keyboard/mouse, touch and controller core navigation remains usable
- no P0/P1 usability or visual defect remains
- final screenshots/evidence are recorded
- Ledger explicitly records remaining external-only blockers

## Definition of Done
The game is attractive, coherent and understandable without developer context. Functional correctness alone is insufficient for this phase.
