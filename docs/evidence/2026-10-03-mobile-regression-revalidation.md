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
