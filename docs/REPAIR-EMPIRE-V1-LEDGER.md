# Repair Empire V1 Ledger

Status: [ ] open · [~] implemented/not device verified · [x] verified · [!] blocked

## P00 Reset/product
- [x] P00-T01 native iOS/Android direction
- [x] P00-T02 driving/service core loop locked
- [x] P00-T03 portrait concept composition
- [x] P00-T04 bundle IDs
- [x] P00-T05 legacy runtime removed from current tree

## P01 Unity foundation
- [x] P01-T01 Unity/C# structure
- [x] P01-T02 editor scene bootstrap
- [x] P01-T03 portrait + 60 FPS
- [x] P01-T04 safe-area Canvas
- [x] P01-T05 first editor compile
- [ ] P01-T06 iOS dev build
- [ ] P01-T07 Android dev build

## P02 Vehicle
- [x] P02-T01 Rigidbody van controller
- [x] P02-T02 touch steering left/right
- [x] P02-T03 accelerator/brake
- [x] P02-T04 keyboard fallback
- [x] P02-T05 speed clamp/lateral damping
- [x] P02-T06 follow camera
- [~] P02-T07 runtime no-stuck drive test
- [ ] P02-T08 physical iPhone drive test
- [ ] P02-T09 physical Android drive test

## P03 City/navigation
- [x] P03-T01 wide central road vertical slice
- [x] P03-T02 sidewalks/building corridor
- [x] P03-T03 workshop landmark
- [x] P03-T04 customer destination marker
- [x] P03-T05 cyan route arrows
- [x] P03-T06 live distance HUD
- [ ] P03-T07 final district network
- [ ] P03-T08 minimap/map screen

## P04 Job engine
- [x] P04-T01 data-driven JobDefinition
- [x] P04-T02 four launch service calls in vertical slice
- [x] P04-T03 select/start job
- [x] P04-T04 arrival detection
- [x] P04-T05 Complete Repair reward action
- [x] P04-T06 Cash/XP mutation
- [~] P04-T07 repeated-loop runtime verification
- [ ] P04-T08 final launch job catalog
- [ ] P04-T09 repair minigame stages

## P05 Tablet/UI
- [x] P05-T01 Cash/Level/Tool HUD
- [x] P05-T02 active service-call card
- [x] P05-T03 Tablet open/close
- [x] P05-T04 driving disabled while Tablet open
- [x] P05-T05 Jobs tab
- [x] P05-T06 Tools tab shell
- [x] P05-T07 Vehicles tab shell
- [x] P05-T08 Workshop tab shell
- [x] P05-T09 Employees tab shell
- [x] P05-T10 Daily Jobs tab shell
- [~] P05-T11 compact-phone readability
- [ ] P05-T12 DE/EN
- [ ] P05-T13 accessibility/reduced motion

## P06 Progression/company
- [ ] P06-T01 versioned profile
- [ ] P06-T02 tool tiers
- [ ] P06-T03 vehicle ownership/upgrades
- [ ] P06-T04 workshop upgrades
- [ ] P06-T05 employees/passive income
- [ ] P06-T06 districts
- [ ] P06-T07 save migration tests

## P07 Production art
- [~] P07-T01 city material/palette foundation
- [~] P07-T02 procedural workshop/building foundation
- [~] P07-T03 composite van foundation
- [ ] P07-T04 final van model/interior
- [ ] P07-T05 authored city kit
- [ ] P07-T06 repair props/tool assets
- [ ] P07-T07 characters/customers
- [ ] P07-T08 final lighting/post FX
- [ ] P07-T09 screenshot-quality gate

## P08 Audio/haptics
- [ ] P08-T01 engine
- [ ] P08-T02 UI
- [ ] P08-T03 repair interactions
- [ ] P08-T04 rewards
- [ ] P08-T05 haptics
- [ ] P08-T06 audio settings

## P09 Retention/monetization
- [ ] P09-T01 persistent daily jobs
- [ ] P09-T02 login reward
- [ ] P09-T03 achievements
- [ ] P09-T04 cosmetic catalog
- [ ] P09-T05 StoreKit sandbox
- [ ] P09-T06 Play Billing sandbox
- [ ] P09-T07 restore/retry

## P10 QA/release
- [ ] P10-T01 EditMode economy/job tests
- [ ] P10-T02 PlayMode drive/job tests
- [ ] P10-T03 iPhone safe-area/drive matrix
- [ ] P10-T04 Android aspect/drive matrix
- [ ] P10-T05 30-minute driving stability
- [ ] P10-T06 memory/thermal pass
- [ ] P10-T07 App Store package
- [ ] P10-T08 Play Store package
- [ ] P10-T09 TestFlight RC archive + upload
- [ ] P10-T10 TestFlight processing + internal tester assignment
- [ ] P10-T11 TestFlight install/smoke test on physical iPhone
- [ ] P10-T12 staged release

## Next open task
P01-T05: first Unity compile/import and Play Mode verification.


## Unity 6.6 bootstrap verification - 2026-10-06
- [x] Project imported and compiled successfully with Unity 6000.6.4f1.
- [x] Canonical Assets/Scenes/Main.unity generated and registered in Build Settings.
- [x] iOS and Android application identifiers are configured in PlayerSettings.


## Mobile platform build verification - 2026-10-07
- [x] Android IL2CPP development APK builds successfully with Unity 6000.6.4f1.
- [x] Android manifest verified: application ID `com.kamilunavo.repairempire`, versionName `1.0`, versionCode `1`.
- [x] Unity iOS Xcode export builds successfully.
- [x] Generic iOS device Debug build succeeds in Xcode 27.0 with automatic signing.
- [x] Code signature verified: identifier `com.kamilunavo.repairempire`, Apple Team `TKG684N5GL`.
- [ ] Store-ready 1024x1024 app icon and final release/archive validation remain release tasks.
- [ ] Local iOS Simulator QA is blocked by the currently installed CoreSimulator runtime mismatch; device builds are not blocked.

## 2026-10-08 completion foundation
Approved native completion design/plan in docs/superpowers. 24 authored calls, ordered ticket-bound three-phase repairs, atomic persist-before-reward acknowledgment, tool/vehicle/workshop/employee progression, UTC daily/offline rules implemented in pure Core. Bundled Mono executes132 checks PASS; missing-type RED and hire-retroactive/nonce-overflow regressions RED→GREEN retained in task evidence. Actual file replacement/reload and future/corrupt profile preservation tested. Full Unity editor integration/native gameplay acceptance pending; this is not a final completion claim.
Original generated blue daytime panorama, four-category repair atlas and van icon now in Assets/Resources/Art with provenance; native rendered van/city integration pending.
Rulings: switch prototype110cash→120 meets approved range (cost10extra); new hire resets fractional accrual baseline while respecting future clocks (rounding loss at most2cash per hire); task-heading spacing changed for workflow parser only.
Own unpublished AdMob apps created and confirmed14:24Berlin: iOSca-app-pub-8944085355624754~7806988119, voluntaryrewardunit/3268977305; Android~7615416420, voluntaryrewardunit/3101367057.50Cash reward, no partnerbidding or forced ads. SDK integration/internaltestunits pendingTask2; approvedprivacy/liveconsent/genuine reward gate open. Applecatalog pending becauseASCsessionexpired; userreauthenticationrequestqueued.

Actual Unity import/compiler and RepairValidation.Run now PASS132, matching the bundledMono suite. Task1 foundation verified. Separate Task2 input regression fails on the untouched baseline: disabling a held button retains gas/steer; actual editor fixture in work/repair-editor-core-input-red.log. This failing Task2 behavior is not hidden or counted as passing.
Task2 input/control boundary slice: actual Unity132CorePASS; disabled lifecycle callback clears held controls, paused FixedUpdate zeros actual Rigidbody velocity (RED→GREEN). Editor fixture corrected to invoke disable callback directly because EditMode ordinary lifecycle/SendMessage on inactive object doesn't deliver it; no physical lifecycle claim. Game boundary missing APIsRED→actualUnityGREEN for lateral arrival rejection, moving-van rejection, stopped repair/modal pause, skipped-phase rejection and close/unpause. Pure ordered hold/four-tap/finalhold interaction17PASS after missingtypeRED. Actual world/tablet repair binding/native driving/visual QA remains pending. Shared authored UI/native-region/mesh-lifetime helpers and licensed fonts imported from own verified OMF source; new GameBootstrap/VanArt/City/UI follows.

Ruling 2026-10-08 Task 2: Workshop upgrades affect repair hold efficiency (+12% per level above 1, bounded +48% at 5), never contact ordering, payouts or capped-frame safety. Earned cargo/electric vehicles raise maximum speed from 22 to 25/28 m/s; electric acceleration 22 versus 18. This makes approved expansion functional without changing cosmetic IAP rewards. Pure interaction/progression tests failed for missing implementations before the change; now run against actual capped hold progression.

Task 2 verified source slice: actual Mac player QA5 passed 498 checks (all four categories driven through real Rigidbody/held gas/brake/steering; hold/tap/hold UI; ticket replay rejection; paid customer stays in place; daily bonus; recovery; actual portrait/landscape/synthetic usable pane). QA2 straight-road assumption failed arrival; QA3 used actual steering into the customer bay and passed 449; QA4/5 passed 498. TextureImporter incorrectly produced Cubemap rather than Texture2D: actual resource load RED, explicit Texture2D import GREEN; oversized rear TextMesh bounds RED then authored scale GREEN. Excluded-pane stale-frame pixels failed independent screenshot check; fullscreen clear camera made excluded pixels black on QA5. Current iOS export editor compilation confirms 132 core, 21 interaction, 25 unique commerce checks plus actual input/boundary/HUD/art checks. Latest wide-detail scroll and stricter native touch containment are included for native acceptance, still pending. No native QA or release success claimed yet.
Own engine/step/success WAVs generated as audio synthesis (not edits to provided images); initial generated PNG originals remain unchanged.


## Current verified source slice, 2026-10-08 17:45 Berlin
All four complete Unity source projects have been pushed and their remote main HEADs compared, before cache cleanup. Repair source baseline 8a044054a015d9212f0d89d1fa407d09e0b39d41 is backed up; this correction pass follows it.
The fresh final whole-change reviewer found four Important defects. Each is corrected in one regression-backed pass: shop eligibility polling and replacement-ad preparation; native restore presentation ownership including an intervening purchases-refresh failure; independent held-control size/usable-region validation with an intentionally off-pane actual control rejected; unsupported saves presented through a bounded read-only current UI model while disk bytes and transaction lock remain preserved. Missing APIs and actual runtime failures were observed first. Review diagnostics passed58; full Mac Mono player using the original QA5 assets/native runtime and freshly compiled game scripts passed593 actual checks, including all four real Rigidbody routes, ordered repairs, the review fixtures and rendered portrait/landscape/reserved panes. Core135 and commerce25 pass. C# compilation against iOS and actual Android managed APIs passes; the first Android attempt used Mac stripped API references and failed for Handheld, then passed with Android module references. This is not a new Unity IL2CPP/native build.
Final: minor (deferred): failed repair-phase save requires close/reopen to retry; persistence and currency remain protected.
Final: minor (deferred): initial checklist/Next open task above is historical and awaits full reconciled native delivery.
Final: Ruling: native gameplay, fresh-process reload, 1800-second soak, genuine commerce/privacy, physical thermal/haptics, true Duo inner display, signed delivery/catalog/TestFlight and native visual acceptance remain open — the reviewer did not establish them and source/Mac evidence is insufficient — cost if wrong: these gates must be completed before claiming final delivery.
A native QA1 compact run actually drove all four categories but failed its strict landscape assertion. Root cause: the exported Info.plist allowed portrait only; batch executeMethod builds did not wait for the scheduled ProjectBootstrap delayCall. BuildAutomation now configures all three allowed orientations synchronously, committed settings use AutoRotation, and export validation rejects any missing orientation. A plist-only diagnostic derivative is being tested; it preserves the original failed binary and does not include the newer commerce/held-control QA fixes. Fresh full native QA2 remains required.
Simulator cache cleanup unexpectedly caused the first new-device boot to stall and pressure this 8GB host. All originals remained intact. Official shared-cache update --all now succeeds, and the owned fresh SE3 boots successfully. Source, signed final binaries, compressed archives/proof manifests and all failure evidence are retained. Removed verified duplicate IPA exports, superseded intermediate AAB/export outputs and bounded regenerable Homebrew download-cache files; never removed installed programs, signing material or user source. Avoid simultaneous heavy builds and simulator startup.

Native orientation-only derivative passed the strict landscape and restored-portrait assertions, but correctly failed its final no-error gate: Unity iOS CaptureScreenshot treated an absolute path as relative to Documents, so PNG writes failed. Source QA now captures a Texture2D, encodes PNG and writes the known absolute path, matching the already verified Rising/OMF approach. A further old-binary diagnostic precreates the duplicated destination path solely to inspect real images; do not count this workaround as latest-source native acceptance.
Storage recovery: removed six abandoned own RisingSteps bundle caches from shutdown simulator Dead cache (~974MB), verified CFBundleIdentifier matches an owned game before each removal; removed compiled media-model caches from shutdown simulators (~2.24GB). Simulator devices, installed apps, profiles, downloaded model assets, shared runtime caches and all source remain intact. Receipts retained in work/. Free space reached3.8GiB.
