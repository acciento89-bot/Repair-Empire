# Mobile regression revalidation — 2026-10-03

## Scope

Corrective pass based on real small-phone gameplay findings: Error 267 under driving input, oversized compact HUD, vehicle tunnelling through buildings and under-detailed service-vehicle presentation.

## Implemented corrections

- Rate-limit throttling no longer increments the kick-worthy anomaly counter for normal bursty mobile/controller vehicle input.
- Vehicle input now applies analog deadzone, quantisation and a bounded send cadence.
- Server-authoritative vehicle movement blockcasts the chassis footprint before translation so PivotTo movement cannot tunnel through collidable buildings.
- Compact-phone HUD, tutorial, navigation and action controls were reduced and repositioned while preserving jump-control clearance.
- Service-vehicle body treatment was improved with roof/body/rear-door details.

## Verification

- StyLua, Selene and Rojo build: pass, 0 warnings/errors.
- Pure Luau suite: 45 tests passed.
- Release-readiness: sandbox-ready; no configuration blockers.
- Studio touch viewport: 801x392.
- WorldVerticalLayerProbe: 122 samples / 1098 collision-respecting rays, zero elevated/foreign broad surfaces.
- WorldReachabilityProbe: 112 anchors and 12 representative routes passed.
- JobCatalogRuntimeProbe: 30 jobs / 76 stages / 14 scene variants passed.
- Deliberate high-frequency UpdateVehicleInput stress remained connected: `alive=true`; throttled packets did not trigger Error 267.
- Building-collision regression probe stopped the test van outside the collidable shell with 4.04 studs face clearance.

The existing real Developer Product receipt/rejoin launch gate is unchanged by this corrective pass.

## Live refresh

- Revalidated canonical main immediately before release: 45 pure-Luau tests, Selene 0/0, Rojo build and release-readiness all passed.
- iPhone XR smoke confirmed the compact HUD/tablet layout in the existing production place.
- Existing production place 79925227687072 was republished after this corrective pass.
- Studio returned PublishSuccessful and Published new changes in Reparatur-Imperium to Roblox.

## Follow-up visual correction — HUD and starter vehicle

A second real-phone review exposed two remaining presentation defects: the compact Work Tablet/HUD still consumed too much of the landscape viewport, and the starter van was vertically compressed with wheel cylinders rotated onto the wrong axis.

Corrections:
- compact-phone HUD now keeps only Cash + Level/XP persistent; company/skill detail remains available inside the tablet;
- compact tablet panel/header/tabs/content and open button were reduced while preserving touch readability;
- unpublished local Studio runs use an in-memory profile adapter so full world/vehicle QA can execute without DataStore publication errors;
- starter-van wheels/rims use the correct horizontal cylinder axis and were visually revalidated as upright circles from a direct side view;
- starter-van height/proportions, wheel diameter, cab-to-cargo ratio, glass area, front fascia, roof/rear treatment and branding were rebuilt to remove the vertically-squashed placeholder silhouette.

Verification:
- StyLua: pass; Selene: 0 errors / 0 warnings / 0 parse errors;
- pure Luau suite: 45 tests passed;
- release-readiness: Sandbox-ready, no configuration blockers;
- Rojo canonical build: pass;
- iPhone XR Studio runtime: 801x392 touch viewport, 0 CreatorErrors;
- WorldReachabilityProbe: 112 anchors / 12 representative routes pass;
- JobCatalogRuntimeProbe: 30 jobs / 76 stages / 14 scene variants pass;
- vehicle QA: forced starter-van spawn succeeded and front-3/4 plus side camera reviews confirmed upright wheels and corrected body proportions.

## Production publish and runtime verification

- Canonical source commit: `93031ee` (`main`, pushed to `origin/main`).
- Final canonical `build.rbxlx` SHA-256: `4efa1724885b6363407bdaef54b28d283a44ab0fb14bc779cbde24fa41c7251f`.
- Existing production Place `79925227687072` was opened directly with Studio `EditPlace`; no new Place/Experience was created.
- Rojo synced the canonical `RepairEmpire` project into that existing Place.
- Roblox returned one transient 504/503 publish-service failure under server load; retry succeeded.
- Studio then reported `PublishSuccessful` and `Published new changes in "Reparatur-Imperium " to Roblox.`
- Post-publish production Studio play initialized server/client successfully with no new runtime CreatorErrors after the successful publish.
- DataRecoveryProbe passed; WorldReachabilityProbe passed 112 anchors / 12 representative routes; JobCatalogRuntimeProbe passed 30 jobs / 76 stages / 14 scene variants.
- Production iPhone XR runtime remained `801x392`, touch enabled, ~58.1 FPS sampled.
- Production `SpawnVehicle` invocation succeeded (`ok=true`, active vehicles 1 / max 2); the published starter van rendered with upright wheels and the corrected non-squashed body proportions.
