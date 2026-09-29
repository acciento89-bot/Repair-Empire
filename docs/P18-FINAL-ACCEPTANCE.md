# P18 Final Polish & Game Feel - Acceptance Record

Date: 2026-09-29

## Scope completed

### P18-T01 Visual design system and shell
- Repair Empire-specific navy/orange visual language replaces the prototype grey shell.
- Shared palette, surfaces, selected states, strokes, rounded cards and section hierarchy are centralized.
- HUD, Work Tablet, management screens, repair interaction and navigation marker use the same visual system.
- Automated contrast guardrails remain active.
- Existing phone/tablet/desktop/controller runtime coverage from P13 remains applicable because responsive/navigation contracts were preserved.

### P18-T02 Retention loop completeness
- Daily login, Daily Jobs and Achievements remain server-authoritative.
- Added daily online/playtime rewards at 5/15/30/60/90 minutes.
- Daily playtime and claim state persist in the profile and reset at the UTC day boundary.
- Claiming is rate-limited, milestone-allowlisted, server-time-gated and duplicate-safe.
- Daily screen exposes locked/ready/claimed states and reward amounts.
- Daily login, Daily Job, online reward and achievement claims emit visible/audio feedback.

### P18-T03 Jobs and quest experience
- Launch catalog audit covers all 30 jobs across plumbing/heating/climate/energy and residential/downtown/industrial progression.
- Every job is CI-guarded for stable IDs, valid rewards/XP/tool tier, multi-stage structure, unique stage IDs, named actions and deterministic duration summaries.
- Job cards expose district, trade, step count, estimated active repair time, reward, XP and tool tier.
- HUD objectives and repair actions are humanized instead of exposing underscore IDs.
- Existing runtime JobService verification covers accept/stage/complete, spatial/timing validation, stale/replay protection and real Studio boot.

### P18-T04 Vehicles and garage presentation
- All eight launch vehicles have distinct presentation styles.
- Garage now uses procedural 3D ViewportFrame previews rather than text-only rows.
- Selected/owned/locked states, level/tier/speed/seats and spawn/despawn controls are explicit.
- Runtime vehicle models now use style-specific body colors, glass, company stripe, lights and wheel treatment.
- Server-authoritative despawn only removes the caller's spawned vehicles.
- Existing P06 runtime travel integration remains intact and catalog invariants are CI-guarded.

### P18-T05 World, workshop, audio and effects
- Residential, Downtown and Industrial district identities remain distinct.
- Workshop presentation adds Repair Empire branding, service-bay markings, safety bollards and tool display dressing.
- Lighting receives restrained color-correction/bloom polish without changing gameplay geometry.
- Reward/job/error feedback uses the existing tween/audio system; Studio audio preload is verified.
- No external Marketplace art/audio dependency is required for V1.

### P18-T06 Player-journey acceptance
The complete first-join-to-endgame-preview path is represented by the already verified P02-P16 runtime/CI matrix plus the P18 presentation/retention additions:
- onboarding and first job
- jobs/co-op
- tools and Skill Tree
- vehicles/garage
- workshop/employees
- Daily Jobs/login/online rewards/achievements
- shop
- Prestige preview
- responsive phone/tablet/desktop layouts
- keyboard/mouse, touch and controller navigation

Final local verification after P18:
- StyLua check: pass
- Selene: 0 errors / 0 warnings / 0 parse errors
- Rojo build: pass
- pure Luau suite: 40 tests pass
- release-readiness: Sandbox-ready: yes

## Follow-up status after P19
The corrective P19 Production Art & World Quality gate is complete; persisted runtime screenshots and acceptance evidence are stored under `docs/evidence/p19/`.

Roblox Studio cloud publishing also recovered on 2026-09-29. After reconnecting the final Rojo/P19 source, the private development place published successfully as version **v70** and Studio logged `PublishSuccessful` / `Published new changes in "Reparatur-Imperium-Entwickler" to Roblox`.

## Remaining external-only pre-launch gate
One owner-approved real-Robux Developer Product purchase is still required to evidence the live receipt/rejoin path. This is not repository implementation work and must not be initiated without the owner's explicit approval.

P17 telemetry review and the first evidence-based balance patch are post-launch tasks that necessarily require real users/data.

Public exposure remains blocked only by the paid Developer Product receipt/rejoin gate.
