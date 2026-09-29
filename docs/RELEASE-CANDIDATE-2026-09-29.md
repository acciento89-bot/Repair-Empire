# Repair Empire V1 Release Candidate

Date: 2026-09-29

## Candidate identity
- Repository: `acciento89-bot/Repair-Empire`
- Production-art/code baseline: `6e7b920f703b5a3aad26832f20c32a3f11c8c7cb`
- Documentation/release-status head at candidate capture: `47451f7e1f8399377eba1b1302fef6a0d3c54bb6`
- Private development place: `138882349802835`
- Universe: `10768475286`
- Cloud development revision: **v70**
- Local green build SHA-256: `daa175f1d919c25531ab0b4cbf3b70a9d694807fbd713cc7bda71be253d92798`
- Local green build size: **474070 bytes**

## Final verification
- StyLua: pass
- Selene: 0 errors / 0 warnings / 0 parse errors
- Rojo build: pass
- Pure Luau suite: **45 tests passed**
- Release-readiness: **Sandbox-ready: yes**
- GitHub Actions on current documentation/release status: green
- P19 Production Art & World Quality: all T01-T10 verified complete
- WorldReachabilityProbe: 112/112 job anchors valid plus 12/12 representative routes
- WorldVerticalLayerProbe: 122 samples / 1098 raycasts; zero elevated broad surfaces and zero foreign map layers
- Authoritative vehicle drive QA: old compact van moved 68.59 studs at throttle 1.00
- Compact-device evidence: iPhone XR runtime persisted under `docs/evidence/p19/`

## Cloud publish evidence
Roblox Studio successfully published the final P19 development build on 2026-09-29:
- `PublishSuccessful`
- `Place published. Editors can now play this place in Roblox.`
- `Published new changes in "Reparatur-Imperium-Entwickler" to Roblox.`
- revision reported by Studio: **v70**

The previous Studio upload incident is therefore resolved for this project.

## Remaining pre-public gate
Exactly one pre-public acceptance item remains:
- an owner-approved real-Robux Developer Product purchase followed by receipt/rejoin verification.

This gate intentionally remains blocked because Roblox's current test path charges real Robux. No real-money purchase is performed automatically.

## Post-launch-only work
The following cannot be completed before real users exist:
- first telemetry review
- first evidence-based balance patch

## Release rule
Do not expose the production experience publicly until the paid Developer Product receipt/rejoin gate is verified. The current build, assets, QA evidence, rollback preparation and private dev publication are otherwise release-candidate complete.
