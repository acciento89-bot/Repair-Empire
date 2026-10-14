# Repair Empire

Native iOS + Android service-business simulator by Kamilunavo.

## Current work — 2026-10-15

The original 3D workshop now has authored room geometry, tool storage, workbench details, warm local lights and two original generated material textures. Its larger company-dashboard photograph is rendered and cached by Unity. The van's front glass follows the curved body, correcting the visible body intersections. Fresh native Mac presentation, four-job driving/repair and fresh-process save runs pass 1,381 / 1,296 / 7 checks from the same verified source. [Current evidence and limits](docs/QA/repair-workshop-20261015.json), [implementation scope](docs/REPAIR-WORKSHOP-20261015.md).

The whole-game visual release gate remains **FAILED**: street composition, van/foliage/lighting and driving HUD still need further work against the approved Concept. No new Repair Empire TestFlight upload or version increment was made in this pass. The ledger remains canonical for previous deliveries.

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
