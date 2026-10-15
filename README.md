# Repair Empire

Native iOS + Android service-business simulator by Kamilunavo.

## Current work — 2026-10-15

Latest scope: the user reports Perfect Drop and Rising Steps approved. Leave both apps and their submissions untouched; current work is Repair Empire only.

The original road van now has a real modeled cabin: seats/headrests, dashboard/instruments, steering wheel, door panels and bulkhead. Three metal-shell window openings and open gaskets replace solid body behind dark panes. A serialized transparent-glass material keeps the correct Standard shader variant in native builds; a direct GPU background-transmission check verifies it. Paint, plastic and metal have separate finishes. The production van captures the actual street reflection once; no per-frame reflection camera.

Fresh exact-source Unity aggregate/Mac build and native presentation / four-driven-job / saved-profile reload pass **1,466 / 1,377 / 7** checks. Final moving model: **69,778 retained vertices / 27 active renderers / 9 materials**, inside unchanged ceilings. Closed metal-shell winding, finite normals, 35 real aperture/corner rays, 57 windshield/18 cargo rays, variants, ground contact and cleanup pass. All 314 native bundle files and ProjectSettings were reverified. Independent source review closed shader-variant, corner-alignment and tolerance-weld findings. [Current cabin evidence and actual comparisons](docs/QA/repair-cabin-20261015.json).

This completes the bounded cabin/material implementation. The actual city, overall material/light/detail finish and full Concept similarity remain below target. Whole-game visual gate **FAILED**, native icon review pending; no Repair upload, version increment or ASC operation. Approved Perfect Drop/Rising Steps and decorative workshop-menu artwork are untouched. [Previous road-van geometry/optical asset evidence](docs/QA/repair-road-van-20261015.json).

Previous service presentation slice:

The service presentation now has its own job-information board with actual customer/distance, pay, required tool, level and three job-specific stages. Ordered repair actions stay on a fixed shelf; a dedicated paid receipt exposes resume and Shop. A smaller driving card, separate Route/Start action and distinct modeled pedal icons clear more of the road. Two original stone/cloth material textures, folded towel and vanity props improve the real service photos, now rendered through an isolated cached HDR/filmic finish. Original clock/bridge geometry and a fitted two-row customer sign add district identity.

Fresh final-source native Mac presentation / four-driven-job / reload runs pass **1,422 / 1,371 / 7** checks. Actual image review caught tutorial-control overlap and customer-sign mirroring/overflow; native regressions reproduce and verify the corrections. All 314 bundle files were reverified; ProjectSettings, the 54 district colliders and height RNG remain unchanged. [Current art/UI evidence, original assets and actual Concept comparisons](docs/QA/repair-art-complete-20261015.json). The complete graphical gate remains **FAILED** for town/van/lighting/detail and full Concept finish; no new Repair upload or build-number change.

Earlier verified slices:

The street now uses two original brick/leaf material assets, broader layered trees, visible foreground brick terraces and mansards, finer asphalt and warmer daylight with amber route chevrons. All 54 district BoxColliders and the serialized height Random state match the pre-edit native baseline. Fresh native Mac presentation / four-driven-job / reload runs pass 1,422 / 1,311 / 7 checks. [Street evidence and actual Concept comparison](docs/QA/repair-street-concept-20261015.json). The overall graphical gate remains **FAILED**; the road composition, vehicle/fixture finish and driving UI still differ materially from the reference.

The workshop tablet now uses warm ivory surfaces, real rounded card/photo geometry, four original navigation icons and a direct header Shop with parent Back. The driving overlay has a smaller matching 3D call preview and retains vehicle controls; short reserved panes keep the van clear. Fresh exact-source native presentation / four-driven-job / reload runs pass 1,422 / 1,311 / 7 checks. [Current UI evidence](docs/QA/repair-ui-concept-20261015.json).

The original 3D workshop now has authored room geometry, tool storage, workbench details, warm local lights and two original generated material textures. Its larger company-dashboard photograph is rendered and cached by Unity. The van's front glass follows the curved body, correcting the visible body intersections. Fresh native Mac presentation, four-job driving/repair and fresh-process save runs pass 1,381 / 1,296 / 7 checks from the same verified source. [Current evidence and limits](docs/QA/repair-workshop-20261015.json), [implementation scope](docs/REPAIR-WORKSHOP-20261015.md).

The whole-game visual release gate remains **FAILED**: street composition, van/foliage/lighting and driving HUD still need further work against the approved Concept. No new Repair Empire TestFlight upload or version increment was made in this pass. The ledger remains canonical for previous deliveries.

Future uploads also require [accurate source/native icon and variant evidence](docs/QA/store-icon-review.json), following the user's report of Apple's separate One More Floor icon issue. The check remains pending; synthetic validator tests do not approve artwork or establish Apple acceptance.

## Initial internal delivery — 2026-10-08
Playable native internal test build1: 24 service calls, four ordered repair types, progression/tablet/shop, authored city/van/art/audio. Central-signed Android and strict AppleDistribution IPA are backed up in an unpublished draft; iOS uploaded through TestFlightInternalOnly at21:33Berlin. Final compact simulator606checks plus real30-minute driving soak, iPad604checks, fresh-processreload6checks each.
Apple processed1.0(1); export questionnaire completed and Kamilunavo Intern now has the build plus1 existing owner tester, invitation saved and build Bereit zum Testen (22:55–22:58Berlin). Actual invitation acceptance/physical installation, genuine commerce/privacy, physical hardware and Duo landscape/fold acceptance remain open. See [canonical delivery evidence](docs/REPAIR-EMPIRE-V1-LEDGER.md) and [art provenance](docs/ART-TEXTURE-PROVENANCE.md).


## Product
Drive a branded service van through a compact city, accept repair calls, navigate to customers, complete jobs, earn Cash/XP and grow the company.

## Platforms
- iOS
- Android
- Unity / C#
- Portrait
- 60 FPS target

## Bundle IDs
- iOS: com.kamilunavo.repairempire
- Android: com.kamilunavo.repairempire

## Current vertical slice
- Rigidbody service-van driving
- wide unobstructed road corridor
- left/right steering + brake/accelerator touch input
- follow camera
- Cash / Level / Tool HUD
- active service-call card
- live destination distance + route arrows
- functional Tablet
- Jobs / Tools / Vehicles / Workshop / Employees / Daily tabs
- selectable service calls
- Start Job + arrival detection + Complete Repair loop
- safe-area UI

Unity editor bootstrap creates Assets/Scenes/Main.unity.

## Canonical docs
1. docs/MASTER-PLAN.md
2. docs/ART-DIRECTION.md
3. docs/CONCEPT-SPEC.md
4. docs/REPAIR-EMPIRE-V1-LEDGER.md
