# Repair Empire V1 Release Candidate

Date: 2026-09-29

## Source
- repository: `acciento89-bot/Repair-Empire`
- source baseline before release-status documentation: `6e7b920f703b5a3aad26832f20c32a3f11c8c7cb`
- current documentation head at RC creation: `2e102913995f5cf433fd399799a6a2c22fab7cb0`

## Green build
- Rojo build: pass
- StyLua: pass
- Selene: 0 errors / 0 warnings / 0 parse errors
- pure Luau suite: 45 tests pass
- release-readiness: `Sandbox-ready: yes`
- configuration blockers: none
- build size: `474070` bytes
- build SHA-256: `daa175f1d919c25531ab0b4cbf3b70a9d694807fbd713cc7bda71be253d92798`
- canonical local artifact: `build.rbxlx` (no persistent QA/mainQA/backup place copies)

## Runtime acceptance
- P19 Production Art & World Quality: complete
- 112/112 job-anchor ground/clearance checks pass
- 12/12 representative route checks pass
- vertical-layer probe: 122 samples / 1098 raycasts with zero elevated broad surfaces and zero foreign map layers
- authoritative vehicle drive QA: old compact van moved 68.59 studs at throttle 1.00
- compact iPhone XR runtime evidence persisted under `docs/evidence/p19/`
- workshop, district, repair-scene, vehicle and device screenshots persisted in the repository

## Roblox publish
The development place `138882349802835` was successfully published twice on 2026-09-29:
- 16:15:49 UTC: `PublishSuccessful`
- 16:18:55 UTC: `PublishSuccessful`

The production start place `79925227687072` was then explicitly overwritten from the canonical `build.rbxlx`:
- 19:49:57 UTC: `PublishSuccessful`

Production was reopened directly from Roblox and runtime-verified immediately afterward. The current production session reported:
- Repair audio preload: `ready=true assets=10`
- DataRecoveryProbe: pass
- WorldReachabilityProbe: `112` anchors and `12/12` representative routes pass
- Studio world baseline: `2593` parts / `2730` descendants
- Studio client baseline: approximately `54.9 FPS` at `1919x1079`

Both Roblox places remain private. Publishing content did not make the experience public.

## Remaining pre-public gate
Exactly one external pre-public acceptance item remains:
- owner-approved real-Robux Developer Product transaction
- verify successful receipt grant
- rejoin and verify persistence/idempotency

No public exposure is authorized by this RC record itself.

## Post-launch only
The following P17 tasks intentionally require real users and are not pre-public implementation blockers:
- first telemetry review
- first evidence-based balance patch
