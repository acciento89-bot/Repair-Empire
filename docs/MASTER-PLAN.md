# Repair Empire V1 - Master Implementation Plan

## Execution protocol
For every task:
1. Read canonical specs.
2. Read ledger.
3. Read current phase detail plan.
4. Implement only the next open task plus explicit dependencies.
5. Test against acceptance criteria.
6. Commit with phase/task identifier.
7. Mark ledger only after verification.

Do not silently reduce scope to an MVP.

## Phases
P00 Product Definition - freeze decisions and terminology.
P01 Technical Foundation - project/source structure, config, remotes, service skeleton.
P02 Player Foundation - profile, spawn, HUD, input.
P03 Job Engine - offer/accept/stages/complete/reward.
P04 Economy & Progression - Cash, XP, levels, unlocks and four-branch Skill Tree.
P05 Tools - ownership, equip, tiers, gating.
P06 Vehicles - ownership, spawn, travel integration.
P07 Company Tycoon - workshop, employees, passive systems.
P08 World - three districts, building/job anchors, streaming/performance.
P09 Multiplayer & Co-op - parties/contribution/large contracts.
P10 Monetization - passes, products, receipts.
P11 Retention - daily jobs, login reward, achievements.
P12 Prestige & Endgame - reset/meta progression.
P13 UI/UX Polish - responsive layouts, controller, accessibility and complete progression/management screens.
P14 Security Hardening - remote audit, rate limits, exploit tests.
P15 Analytics & Balancing - event schema, dashboards/checklists, pacing passes.
P16 Release - QA matrix, store presentation checklist, staged launch.
P17 Post-launch - incident handling, content cadence, measured iteration.
P18 Final Polish & Game Feel - visual design, retention completeness, jobs/quests, vehicles, world/audio/effects and full player-journey acceptance. P18 is a mandatory pre-public-launch gate despite its corrective phase number.
P19 Production Art & World Quality - final environment art, repair-scene assets, tool/vehicle/workshop art, VFX/audio, lighting/material polish and screenshot-quality acceptance. P19 is mandatory before public launch.

## Milestone gates
M1 Playable Core: P00-P04.
M2 Progression Build: P05-P08.
M3 Social/Commercial Build: P09-P12.
M4 Release Candidate: P13-P16 plus P18 and P19.
M5 Live Product: P17 operational after the P18/P19 quality gates.

## Change control
Any scope change must:
- state reason
- identify affected docs/phases
- update master plan and ledger
- avoid retroactively marking incomplete work as done

## Definition of Done - global
Code/config committed.
Acceptance criteria pass.
No known P0/P1 defect introduced.
Documentation updated if interface/data contract changed.
Ledger reflects verified reality.
Functional implementation alone does not satisfy final-polish acceptance; player-facing presentation and runtime journey quality must also be verified.
Production-art acceptance requires normal player-view screenshot evidence; procedural blockout geometry alone is not sufficient.
