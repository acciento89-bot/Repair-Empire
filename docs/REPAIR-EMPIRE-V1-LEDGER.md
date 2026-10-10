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
- [x] P10-T09 TestFlight signed archive + internal-only upload (build2; physical acceptance remains open)
- [x] P10-T10 TestFlight processing + internal tester assignment
- [ ] P10-T11 TestFlight install/smoke test on physical iPhone
- [ ] P10-T12 staged release

## Current open acceptance
Actual tester invitation acceptance/physical installation, genuine purchase/restore/video and approved privacy URL, physical device smoke/thermal feedback, and actual Duo landscape/inner-display acceptance. Earlier task checklists below are historical; current 2026-10-08 delivery evidence is recorded at the end.


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

## Visual acceptance continues after18:00
At18:00 all four full Unity projects were already remotely backed up. Repair remains unfinished; source review/functional Mac593 and native diagnostic502/freshreload6 are evidence, not final QA2/release acceptance. Native visual inspection shows the current city remains substantially simpler than the supplied concept. Continue authored materials, foliage and branded van polish before calling it complete or preparing final internal packages.
Original generated city material atlas45efbe92 copied unchanged to WorldMaterialsAtlas.png. Actual editor RED missing city shader→GREEN resource and three avenue bindings; fresh Unity MacQA6 passed593. Atlas repeat edges rendered unwanted thin bright grid lines despite actual material tile0 on asphalt (diagnostic magenta/tile/bounds verified). Hypothesis: fract UV discontinuities inflate implicit texture derivatives/mip choice; use gradients of the unwrapped coordinates and verify the actual next render before accepting. Generated transparent foliage4e17b7de is RGBA1254² with alpha0..255; source integration remains pending.

Fresh Unity Mac art QA9 passes593 actual checks, including four Rigidbody customer routes, all repair interactions, restore/consent/retry regression fixtures and portrait/landscape/reserved-pane captures. Visual inspection confirms independent Texture2DArray layers remove bright atlas grid bleed; crossed transparent leaf planes render, sky cloud mapping and branded navy/orange rear livery render with the gear ring facing the camera. Final materials use high-resolution shadows, 4x MSAA and two cascades; actual native frame/memory acceptance remains open. Original generated atlas/foliage and the Unity-derived texture array are included in the complete source backup. This improves the concept direction but does not assert photographic parity or latest-source native completion.

Native QA2 (source68c31ae, actual arm64 IL2CPP with current materials/foliage/input/commerce/capture/orientation corrections) passes593 on iPhone SE3/iOS26.5. All four actual driven category repairs, genuine UI taps/holds, portrait/landscape/reserved pane, future-save/restore/retry fixtures pass. Independent screenshot check confirms excluded center column uniformly black. Fresh native process reload passes6 and restores the four paid calls/frontier/company. First Xcode pass failed only explicit ENOSPC writing the extra simulator dSYM; removing that incomplete generated package and using DEBUG_INFORMATION_FORMAT=dwarf yields BUILD SUCCEEDED. Simulator app saved and49 regular files compared byte-for-byte before removing native intermediates; distribution archives must still include normal symbols.
User explicitly requests top quality before final handoff. Native render inspection exposes bare return elevations and stretched service photos. Actual Mac runtime photo-aspect regression fails on original sampled UV/rectangle ratio; cover-cropping each atlas quadrant while retaining proportion passes, including refreshed home photo and wide detail cards. Current source over original QA9 runtime/assets passes604 actual checks, adding independent displayed-photo aspect assertions. Authored return windows/corner bands/store signs/street benches/bins/signals, rounded held controls and detailed rear seals/hinges/roof light render in actual captures. This lightweight Mono run does not compile the newly adjusted sky shader; fresh Unity build and all final native gates remain required.
Ruling: finish requested Repair quality/native delivery first, then address user's physical Perfect Drop landscape top-bar overlap and Rising Steps automatic jump rotation — user explicitly sets this priority — cost if wrong: those two defects remain pending meanwhile, so earlier internal versions cannot be called final regression-free.

Fresh Unity quality build compiles all shaders and passes135Core/21interaction/25commerce plus input/boundary/HUD/art validations; actual fresh Mac player passes604 and the final sky/material/UI rendering is inspected. Source update is not just a hot-replaced assembly anymore.
Ruling: simulator QA keeps Development/runtime QA/profiling but disables the unused interactive C# debugger — its extra IL2CPP method/debug metadata caused excessive simulator compilation size on this8GB host; no attachment workflow is needed — cost if wrong: interactive script-debugger attachment to this QA binary is unavailable. Final native functional/performance acceptance must run against this actual new binary; shipping device archives retain ordinary distribution symbols. Xcode simulator QA uses dwarf without the redundant giant dSYM package; this does not change the distribution archive requirement.

Final quality native QA3, source2675cbb (later catalog-only document1dfda5b does not change Assets/Packages/ProjectSettings), passes606 on iPhone SE3/iOS26.5 with a real1800.0418-second repeated-driving soak.107763 rendered frames, p95 17.26688ms, Unity allocated memory114223435→114178582 bytes, peak114223435, errors0. Authoritative PASS count606 includes full functional/review/photo-aspect/pose/recovery checks plus the real driving-lap/error soak gates. No physical thermal/battery claim. Fresh native process reload passes6. Independent final screenshot check confirms entire excluded center column is black. All actual logs/screens/profile/binary file hashes retained under work/repair-native-qa3-* and outputs/RepairEmpire-Simulator-QA3.app. Larger iPad/Duo-outer native functional/rendered validation and signed internal packages still pending.


## 2026-10-08 final native matrix and host recovery
Current QA3 source2675cbb: compact actualIL2CPP606PASS/1800.041814458seconds/107763frames/p95 17.26688ms/Unityallocated114223435→114178582peak114223435/errors0; freshprocess6PASS. iPad actual604PASS/freshprocess6PASS. Final source assets/settings/packages remain identical to2675cbb through3bd937b. No physical thermal/battery or genuine store/video claim.
Duo outer first full run failed actual isolation hold for category3 while host disk was117Mi. After stopping a lingering obsolete Mac player and removing only shutdown-device compiled media caches, fresh companyduoouter4 passed allfour actual driven repairs and daily bonus, then failed actual landscape dimension assertion. Thus first hold failure did not reproduce, but landscape/fold acceptance remains OPEN; real inner display unavailable in current simulator. Preserve both failed runs, do not count either as fullPASS. The nested Poses coroutine exception logs toerrors/console but bypasses top-levelMoveNext FAIL marker; external harness stopped player, shut down device and preserved exacterrors asFAIL.txt with provenance. No gameplay/timer loosening.
Recovered1.88GB from three Xcode Organizer copies only after SHA256 equality of every regular file exceptInfo.plist against existing private draft archive proofs. Current Xcode-addedInfo.plist metadata saved to each existing unpublished draft and server digest verified before deletion. Compressed lossless archive backups and all Unity source retained. Receipt work/repair-organizer-duplicate-cleanup.json, additional compiled cache receipt work/repair-cache-recovery-20261008.json. Android signed release and iOS distribution archive remain pending.

Android release1 native compile/graphics/135Core+21interaction+25commerce checks passed. Unity packaging failed writing libil2cpp.so into lintAAR at128Mi free; exact compiled Gradle inputs retained (104main payload hashes),2.86GB regenerable compiler artifacts removed after remote source backup, packaging retried unchanged with JVM1536m/maxworkers2 and succeeded28s. UnsignedSHA1088301811a3e29669ae0ab70214ed0be973a47bbdf7245b2acf48aa5eeec2c9. Actual566entries, package1.0(1), ownAdMob and six ELF libraries with≥16KBload alignment independently checked. Central signing run37830216005SUCCESS; signedSHA7e176d64b01bc42167363f8c7aa43cd61ef9b4af12605341260c39e3141695e3. Actual local jarsigner plus SHA1/SHA256pins and allpayloadbytes match. Unpublished draft407175909 holds unsigned/signed/nativepayload/validation/provenance. No Play upload or productionads claim. Androidsourceb71c170; iOS source changes only automatic-signing flag and platform-specific array importer fingerprint.


## Internal delivery — 2026-10-08 21:33 Berlin
Native iOS release source27a642d archived and AppStore-exported successfully. IPA93116284bytes SHA256bf6d81dc8ec68dc704b5c4da1e2f36cfd317e23f76e83614147cf475e9ed1de5; strict/deep AppleDistribution signature, teamTKG684N5GL, get-task-allowfalse, ownAdMob, all3orientations and internal-only export verified. CLIupload failed nilActor/provider credentials; existing XcodeOrganizer then successfully uploaded viaTestFlightInternalOnly, observed UploadedtoApple/Today21:33/Build1. Nonfatal vendorUnityRuntime missingdSYM UUID392D7A7F-6A4F-3A7A-8788-4089FA96FF38, no complete-symbol claim. SafariASC remains login page, so processing/ImTest/groupassignment are OPEN.
Lossless nativearchive backup180929688bytes SHA7a69ff725bd20dd60796ebc74956e3e93b827c22ce064024f9189c3ac6f07cd5: all61regularfiles and symlinks verified. Private draft407175909 assetsIPA622784897, central-signedAAB622762295, archive622797213/proof622797217, currentOrganizerInfo622822320; cloudserverdigests match before removal of5.44GB generatedexports/Derived/uncompressedcopies. User Unity project remains fully remote-backed.
Limited normal native startup with QA_MODE/QA_ID empty oncompact: realplayer active, normalprofilecreated, actualiOSStoreKitcontroller initialization logged, no consoleexception observed; optionalOnStoreConnectedcallbackwarning and simulatorStoreKit1 noted. No verifiedprice/nativeconsent/adsready or genuinepurchase/reward claim.
Task3 remains OPEN for external acceptance rather than falsely complete. Technical delivery/backups are done; proceed with user-authorized physical-feedback fixes inPerfectDrop (landscapeupperHUD) andRisingSteps (automaticjumpturning), then shared deferred commerce regressions while waiting for required Apple/privacy/device evidence.

### Apple processing / internal assignment verified — 2026-10-08 22:55–22:58Berlin

After user restored the correct ASC Safari session, actual UI confirmed processed build1.0(1) d2ae127f-2a6d-473a-9b6c-7dd91c8f6d50, initially blocked by missing compliance and no internal group. No first-party custom encryption found; following Apple's operating-system encryption documentation and the existing SDK release baseline, completed the questionnaire with none of the additional/proprietary algorithms. Saved UI changed to Bereit zum Testen.

Created internal Kamilunavo Intern group fcf307c1-0813-448b-b80d-d5469d74d290 with automatic Xcode-build distribution; added only the existing owner/admin tester requested by the user. UI confirms Interne Gruppe · 1 Tester:in · 1 Build, tester Eingeladen on8Oct2026, assigned1.0(1) Bereit zum Testen, build detail group row shows1 tester. German concrete driving/jobs/tablet/save/audio/haptics/orientation notes saved (Gesichert). Public/external release was not started. Actual invitation acceptance, physical installation and gameplay feedback remain pending; do not claim ImTest/physical smoke from the invitation.

## Apple catalog drafts, 2026-10-08

Restored owner session used to create the two existing native product IDs as non-consumables: com.kamilunavo.repairempire.starter / Apple6820717888 (500Cash once +style4), Germany1.99EUR; com.kamilunavo.repairempire.vancollection / Apple6820719843 (styles5–7), Germany2.99EUR. Both price plans cover175regions, availability is allregions, German and en-US display name/description rows saved and verified. Status remains In Vorbereitung zur Übermittlung. Family sharing unchanged. No App Review/public submission, agreement acceptance or genuine purchase/restore/revenue claim. Review screenshots and actual native sandbox purchase/cancel/restore remain open; local receipt work/repair-apple-catalog-20261008.json. Earlier expired-session catalog blocker is historical.

TestFlight follow-up,2026-10-09: authenticated ASC iOS table now shows1.0(1) **Im Test**, Kamilunavo Intern,1invitation, installations“–”. This supersedes the prior Ready observation only; no physical installation or actual purchase/ads claim. Delivery receipt work/repair-testflight-status-20261009.json.

## 2026-10-09 build 2 service tablet, first-call guide and paid-contract correction

User-authorized quality follow-up after physical screenshots: the large two-row pill navigation, full-width settings actions, oversized repeated faucet card and stale no-job HUD are corrected in the existing RepairHud owner. The tablet now has a single horizontally scrollable dispatch strip on phones and a scrollable service rail on wide displays, a short branded header, compact label/action rows and a compact selected-call card. Selected contracts are not repeated in the list. Completed contracts are marked paid. Job-specific vector service diagrams cover faucet/toilet/sink/switch and the remaining service families; job selection/HUD no longer reuse an unrelated category photo. With no active call, destination symbol/distance/map are hidden and the action opens dispatch/tools rather than pretending to navigate.

Paid-contract exploit reproduced in the actual pure rules: after faucet payout, BeginJob("faucet") returned another nonce. Regression failed before correction. Each authored contract now persists its ID in CompletedContracts atomically with its reward, and CanTake/BeginJob reject paid IDs. Selecting the already-active contract resumes the same ticket and phase. An in-flight payment guard rejects reentrant callbacks; failed persistence retains unpaid state. Clone/copy/normalization preserve independent identity sets. Existing schema-1 saves accept the additive fields and retain company/commerce data; unsupported saves remain protected. Old builds did not record contract IDs, so historical paid IDs cannot be reconstructed. A real 20-metre dispatch departure boundary rejects accepting a new contract while still at its customer, including old saves. Ruling: the 24 authored contracts each pay once; the current slice has no regenerated-contract catalogue. Exhaustion is shown honestly rather than reopening paid contracts.

First-call guide observes actual held steering, throttle with movement, progress toward destination, stopped arrival, actual repair modal and ordered hold/tap/test payout, then the earned voltage-tester purchase. It never grants money/XP, teleports the van or resets a paid ticket. Fresh unplayed companies start the guide; established companies retain normal play. Later skips and persists completion; Settings → First service call replays against an available unpaid real contract. Guide hints fit the existing service card and existing repair controls, leaving the road/input clear. DE/EN covered. TutorialCompleted is additive and normal save protection applies.

World pass: facade materials now vary by neighbourhood, with vertical reveals and selected glass balcony ledges; parked coloured passenger vehicles remain strictly outside the central road corridor and join the existing static batch. Van body is pearl white with side emblems, a detailed roof case and service pipe carrier. Panel shader now uses restrained 9-unit corners, subtle gradient and border rather than thick glowing pill chrome. Orange buttons use navy text to keep small compact actions readable. No road collider/vehicle input, scenes, packages, commerce adapters or project settings were changed.

Lightweight verification: bundled Mono pure suite PASS152 (paid identity/file reload/reentrant callback/legacy defaults/departure and observed guide flow included). Roslyn compiles all current runtime scripts against actual bundled Unity engine and UI references with test-only commerce interface stubs; existing FindFirstObjectByType deprecation warnings and unused stub events only. This proves runtime C# syntax/UI engine API binding, not genuine SDK/native/build validation. git diff --check passes. No Unity import, player build, simulator, CUA or screenshot acceptance was run by this source worker.

Root-coordinated acceptance remains required: actual Unity real packages compile + all validation; actual compact/large portrait and landscape/usable panes; short DE/EN settings with no clipping; horizontally scrolled and wide-rail navigation touch/reachability; actual first call → voltage-tool flow, skip/reload/replay; fresh-process paid IDs retained, old saved company retained, repeated customer contract rejected without money/XP/phase changes; all four repair categories + native pause/commerce regressions; actual world/van/shader renders and memory/frame budget. REPAIR_QA_MODE=showcase with a fresh isolated REPAIR_QA_ID captures home guide, all eight tablet pages in DE/EN, replay entry and portrait/landscape/reserved-pane states. Existing functional QA additionally tests repeated paid-contract rejection and actual JsonUtility paid-ID reload for every category.

Cross-game actual Unity MissingComponentException review: Repair custom JobSymbol and steering-wheel objects now create CanvasRenderer explicitly, and both custom Graphic classes declare that requirement. ValidateHud checks actual Graphic objects including inactive hierarchy children for render components. BuildAutomation.ValidateAll records Error/Exception/Assert messages throughout all fixtures and fails if any were logged even when individual assertions pass; runtime QA already gates its logged error count. Lightweight pure152 and runtime compilation still pass. This preventive correction was not reproduced in Repair Unity by this worker; the actual gate remains root-coordinated.

Actual Unity build-2 editor gate reached152 Core/21 interaction/HUD/art/25 commerce, then correctly failed REPAIR_VALIDATION_LOG_FAIL on three engine ShouldRunBehaviour assertions. Every assertion stack points to pre-existing EditMode fixture SendMessage calls: ValidateInput Awake and FixedUpdate (line16), ValidateRepairBoundary Awake (line20). Ordinary runtime behaviours are not eligible for Unity lifecycle dispatch in EditMode. Fixtures now invoke those private callback bodies directly through an editor-only checked reflection helper, matching the existing OnDisable fixture; runtime code and the strict log gate stay intact. This verifies callback body boundaries rather than claiming engine lifecycle delivery; actual runtime QA retains that responsibility. Source/pure checks pass; root must rerun the real Unity gate to establish correction.


## Coordinated presentation and paid-contract validation — 2026-10-09
Actual Unity 6000.6.4f1 editor/SDK validation and standalone Metal builds succeed after the strict logged-error gate and callback-fixture correction. Work logs repair-presentation-mac-build and build2: rules152, interaction21, input/boundary/HUD/art, commerce25. The actual player full run passes607: four production Rigidbody journeys, actual stopped arrival, hold/ordered touch/test repairs, exact-once payout, paid contract rejection at the same customer, JSON reload guard, DE/EN tablets, landscape/portrait, reserved pane, atomic save and no runtime exceptions. Rendered showcase passes354 before and354 after final icon correction. Job diagrams now use outlined switch/toilet/ventilation details; the repair header also uses the specific JobId instead of a mismatched category photograph.
Screenshots were reviewed from repair-presentation-showcase-mac2. Compact dispatch avoids the repeated selected-row card; settings use short horizontal rows; portrait tabs scroll and landscape tabs use the left rail. Updated facades, parked vehicles and pearl/orange van are visible improvements, not a claim of photoreal concept equivalence. Historical saves cannot reconstruct previously paid job IDs; retained20m departure guard prevents immediate local replay of unknown legacy contracts. New completions persist specific paid identities. No real-device touch/thermal, SDK purchase/ad revenue or TestFlight build2 acceptance is established by desktop QA. Both platform build numbers prepared as2; native delivery pending.


## Internal correction build2 delivered — 2026-10-09
Exact build source05f9cdf03e8b9f2130b579c0a63edb270162b573 (normalized iOS render setting and platform-specific generated import fingerprint; runtime correction7a2a71b). Device Release archive and internal-only distribution IPA succeed, strict deep Apple Distribution signature/TKG684N5GL/get-task-allow=false verified; IPA151decf4c472b2224e4018f58034ca03fdc23257f05f4520d73589fa86682784. Native IL2CPP excludes RepairRuntimeQa. Lossless61-file/symlink archivefcd8fe909e40c052e5843ae76ad3ddead4cc217bde478c2e22f37103aa074609, separately retained Organizer metadata, server digests verified on unpublished draft repairempire-build2-presentation-tutorial. Only proven generated caches/exports/archive duplicates removed.
The direct CLI upload encountered providerId credential metadata failure; authenticated Xcode Organizer completes InternalOnly upload20:26Berlin with known missing vendor UnityRuntime.framework dSYM warning, own UnityFramework archive symbols retained. Actual ASC1.0(2), build56a4f5c2-5299-44ec-a4d1-e8802be77a79 now **Im Test**, Kamilunavo Intern1tester/1invitation, detailed German notes **Gesichert**, installations–. Receipt work/repair-presentation-testflight-build2-status.json. Existing encryption declaration unchanged.
Native Android2 completes and bundletool/package/non-debug/own-AdMob/6ARM64ELF16KB validation passes. Existing central signing workflow37973806558 succeeds, pinned SHA1/SHA256 verified locally,566 payload entries and manifest byte-identical; signed AABad10c083ce07efd2ebe3b3f5a18c18b0e2df73f863eb981439e349cd41ea0a03 backed up to the same unpublished draft. First signing dispatch used a GraphQL asset ID and was correctly rejected before obtaining signing material; corrected numeric REST asset625809377 succeeds. Physical device installation/touch/thermal and real SDK purchase/ad acceptance remain user/device checks. No public App Store/Play release or key download.


## 2026-10-09 warm service dashboard and urban detail — source handoff

User directly approved implementation after asking for the overall menu/graphics quality seen in the supplied Rising Steps screenshot. Repair now opens into its own company dashboard: pale scenic hero with active-call/company progress, eight illustrated section cards, four permanent navigation destinations and a fixed orange drive/dispatch action. Page9 is Home; existing page0–7 identities and commerce/tutorial/progress APIs remain. Jobs have a compact selected-call hero, individual service diagrams, light readable cards, completed/paid state and a fixed AcceptSelected action outside the scroll view. Options/shop/upgrade rows use original vector illustrations with compact side actions, stacking on narrow panes. The navy driving overlays remain separate from the pale tablet.

Actual original vector scene geometry is implemented for city/customer/workshop/van/tools/earnings/daily/options/designs; this is not a relabeling of generic category artwork. World changes include lower initial-neighbourhood silhouettes, pitched roofs/chimneys or solar/parapet roofs, striped storefront awnings, cafe entries/furniture/flower boxes, planted verges and magazine kiosks. Van changes include side steps/treads, raised arch trim, mud flaps, reflectors, wipers and company lettering. Existing art lifetime/static batching is retained. Road topology/collision and vehicle control/physics are unchanged. No packages, build numbers or scenes changed.

Lightweight verification: actual bundled Roslyn compilation against Unity engine/uGUI references passes with test-only commerce interface stubs; known deprecation/unused-stub warnings only. Pure rules remain152PASS; diff whitespace checks pass. The new presentation checks have been authored but have NOT run in Unity by this source worker. No runtime/screenshot/performance/native acceptance, heavy build, signing, commit, push or publication was performed here.

Root-coordinated next validation: BuildAutomation.ValidateAll plus fresh actual standalone Metal build; REPAIR_QA_MODE=presentation (alias of showcase), isolated fresh REPAIR_QA_ID, REPAIR_QA_OUTPUT. Capture all DE/EN sections and dashboard top/bottom; actual jobs/settings/Home in landscape and portrait; usable pane; boot/dashboard pause and resume of the same active ticket. PresentationChecks require a primary action outside scrolling content and inside the usable region, ≥4.5 primary-card contrast and >100 actual hero mesh vertices. Existing Sizes retains ≥48 logical-point checks. Then full existing route/repair/exact-once payout/save/commerce regression run. Manually review long DE options actions, selected/locked/paid job cards, dashboard section access after scrolling, roadside/van detail and the road visibility/frame/memory budget.

## Coordinated dashboard/city engine acceptance — 2026-10-09
Actual Unity import, embedded engine/uGUI/commerce editor validations and Mac build succeed without Shader error or validation exceptions. Root's read-only review found ServiceIllustrationGraphic needed MaskableGraphic to obey the scrolling RectMask2D; corrected before the successful build. Fresh isolated presentation1042PASS captures German/English dashboard, all eight company destinations, current jobs/options in actual portrait/landscape, reserved pane and restored portrait. Original scalable artwork clips with the content; fixed orange customer/drive CTA stays outside ScrollRect. Root inspected dashboard, job list, settings, landscape dashboard and actual driving guide screenshots. Compact cards have distinct headings, smaller contextual actions and readable ink on cream, matching the requested gallery-navigation approach with Repair's orange identity.
Fresh full actual runtime1012PASS preserves four real Rigidbody trips/stops and ordered hold/tap repair completion, completed-contract exact-once rewards, ticket reselection rejection and save/reload guards, orientations and targets. Source changes do not alter road/van collision. The city/van art is improved but remains a stylized mobile scene; physical-device visual quality/performance and real ads/purchases are not proven by these desktop callbacks. New TestFlight build3 and native signed bundles have not yet been produced; current internal2 remains the old dashboard.


## Verified internal presentation revision — 2026-10-09
Fresh native **1.0(3)** delivery from source `0896a292134294373ee4ddfadb99903c98306188`. iOS Release archive/export succeeded, strict/deep Apple Distribution signature and teamTKG684N5GL verified, get-task-allow=false, QA runner excluded. IPA SHA256 `619565f63556bfe5cbca08d8ef7de0b010eb3ee79764e30e65f340f7374ecd12`. Compressed archive all61files byte-verified, SHA256 `e64d5c666c51c9bb85086daa1696428a07650ca558827352b8af6c7c10b78d5f`; full archive and upload metadata have verified durable digests in unpublished draft `repairempire-build3-presentation-tutorial`. Xcode GUI InternalOnly upload completed with the known vendor UnityRuntime.framework dSYM warning; own symbols preserved. Authenticated ASC UI confirms **Im Test**, existing Kamilunavo Intern group,1tester and saved DE test notes, build ID `5f271201-e514-4a85-a625-2595f97a1b85`.
Android manifest/version/own AdMob and all6ARM64 ELF16KB alignments validated. Central signing run37992507969success; both existing universal certificate pins match, all566non-signature payload entries and manifest byte-identical. Final signed AAB SHA256 `3b9403e99da1d1bb031f36f3488b86278f16683bdd50814cc84a5d25aa04e50c`; final package/provenance and proof asset digests freshly verified on durable unpublished draft.
All nine coordinated runtime acceptance receipts are retained locally at `/Users/piotrkaminski/Developer/KamilunavoDelivery-20261009/work/runtime-acceptance-manifest.json`; actual rendered screenshot checks and DE/EN portrait/landscape flows are documented above. Full Unity sources are on canonical main. Owned desktop/simulator QA output bundles, Library/export/DerivedData and duplicate uploaded archives removed only after newer acceptance and retained verified artifacts; original user simulator devices, player profiles, receipts and keys untouched.
No public App Review submission or Play publication. Real physical iPhone multi-finger input/performance and genuine provider purchase/reward acceptance remain distinct device gates. These builds implement specific tested graphics/UI improvements; they do not establish full cinematic equivalence to concept stills. Delivery record: `docs/INTERNAL-PRESENTATION-REVISION.json`.


## 2026-10-10 approved workshop/city/repair visual direction — source handoff

User approved all three-view boards and directly authorized implementation. Repair's previous gallery Home has been replaced by a photographed owned 3D workshop/van hero, current-call and compact individual service cards. Four permanent bottom destinations are Aufträge / Ausrüstung / Werkstatt / Firma; tools expose vehicles contextually, company exposes team/daily/shop/options without an eight-tab strip. Narrow usable panes retain full-size targets via two navigation rows. Fixed dispatch/drive and repair actions stay outside scene/content scrolling.

New ServiceSceneArt constructs genuine faucet/toilet/switch/sink/heating/climate meshes. A curved chrome faucet has a separate lever, cartridge and washer; replacement contacts visibly remove/insert the washer. Electrical calls use an insulated screwdriver; other appropriate repairs show an adjustable wrench. Prüfen / Wechseln / Testen bind the original hold/four ordered taps/final hold callbacks and names. Separate cached source images match those same models. A scene-owned isolated camera renders only on requests, restores target/active render texture in finally, is disabled between renders, and releases owned targets/fixture materials; the main camera excludes layer30. No generated gameplay pixels or new provider/assets/packages.

World/van geometry adds real bevels, raised doors, curved rack rails, clamps, wheel caps/lugs/tread, masonry/window recess/sill/jamb/stone modules, dormers, visual curb/drain segments and modeled tree branch/crown masses. Daylight/shadows/material variation are refined. Existing ground/road collider network and each building's collider bounds are preserved. VehicleController, RepairGame, RepairRules, profile/commerce/persistence, IAP and payout/departure rules are unchanged. User-deleted docs/concepts/PRIMARY-CONCEPT.png remains deleted and unstaged.

Lightweight checks: Roslyn compiles current runtime/QA and full editor source against actual installed Unity/uGUI/IAP/GoogleMobileAds assemblies, no commerce stubs; known pre-existing deprecated-API warnings only. Bundled Mono actual pure suites PASS152 rules (paid-ID/reentrant/reload/departure/legacy),21 interaction,25 commerce. Source whitespace check passes. Source compiler caught and corrected a new editor fixture Transform lookup and review caught internal heating/climate photo-key remapping and a switch faceplate occlusion error. These are source/compiler checks, not Unity mesh/render/native success.

Root entrypoints: BuildAutomation.ValidateAll now includes RepairVisualChecks.Run through RepairValidation.ValidateArt; validates actual fixture geometry, faucet washer/spout, toilet/switch identity, no preview colliders and stable internal image keys. Fresh actual player REPAIR_QA_MODE=presentation (fresh isolated REPAIR_QA_ID/REPAIR_QA_OUTPUT) validates permanent nav, real nonblank/distinct service RenderTexture pixels, disabled studio camera/restored target and DE/EN/orientation/usable pane frames. Existing full mode now additionally captures all categories' inspect/replacement/test modeled scenes and verifies fixed repair actions; it retains actual Rigidbody trips/stop, exactly-once contract payout, repeated completed-job rejection/JSON reload, profile/commerce checks. Run full + reload after presentation.

Open acceptance: root must run actual Unity editor/package/shader validation, fresh Metal player, visual review of workshop hero/customer imagery/each repair phase and city/van, DE/EN compact/large portrait/landscape/reserved pane, route input/collision and frame/memory. Physical touch/thermal and genuine purchases/ads remain distinct external gates. No worker Unity/native builds, commit/push, signing/upload or completion claim for those gates.

## October 10 final coordinated desktop acceptance
The workshop dashboard has four permanent destinations and orange fixed actions, actual workshop/van photography and matching modeled faucet/toilet/switch/heating/climate fixtures. Repair scenes retain original ordered interactions and exactly-once paid-ID/departure guards. Independent review corrected replacement-phase switch contact occlusion and unsupported-schema/no-eligible-ticket empty-state claims.
Fresh runtime-reviewed-full/PASS.txt reports 1204 checks: four genuine Rigidbody trips/stops, ordered repair phases, repeat payout rejection, paid-ID/save guards, tools/daily and DE/EN navigation/poses. Fresh runtime-reviewed-reload/PASS.txt reports seven checks in a new process. Presentation runtime-reviewed-presentation/PASS.txt reports 1295 checks across actual distinct GPU fixtures, studio camera/target lifetime, navigation, orientations and 48-point targets.
Actual screenshot review then exposed rear van lettering visible through the front body. WorldText now uses a depth-tested, atlas-aware shared material with bounded reference-counted ownership; the imported GUI font material remains untouched. mac-world-text-final-build.log succeeds including actual geometry front/rear occlusion and material/atlas lifetime fixtures and compiled shaders. Fresh final runtime-depth-final/PASS.txt repeats all 1295 presentation checks. Root inspected showcase-de-dashboard.png: front van has no mirrored rear lettering; company sign and matching service thumbnails remain readable.
Evidence root: /Volumes/SSK SSD/Kamilunavo/Builds/VisualRevision-20261010/RepairEmpire. Original deleted PRIMARY-CONCEPT.png remains unstaged. This is verified desktop engine/rendered acceptance. New native upload/group assignment, physical input/thermal performance and genuine purchases/reward ads remain separate gates; illustrated cinematic concept equivalence is not claimed.


## Verified internal concept-polish delivery — 2026-10-10

Native **1.0(4)** is built from source `699c86f8231ef3a7a34d551bb374ae3307f6d931`. Fresh iOS Release archive/export, strict Apple Distribution signature, team TKG684N5GL, get-task-allow=false, ARM64 app/framework and excluded QA runner were verified. IPA SHA256 `62591f9166e4c478fa7bce472a5dc79917dc668c60a736cfba9b848f59bc20c1`. The compressed archive was verified byte-for-byte across 61 files and retained on the APFS SSD, with a server-digest-verified private draft backup `repairempire-build4-concept-polish`. Xcode InternalOnly upload completed. Authenticated App Store Connect UI confirms **Im Test**, the existing **Kamilunavo Intern** group with one tester and saved German test instructions. New build ID `ff586457-be05-4b29-87e7-33e0b3fdfa41`.

Android native export and bundle validation passed with the expected manifest, version, own AdMob ID and six ARM64 libraries aligned for 16 KiB pages. The existing central-signing workflow [38076747705](https://github.com/acciento89-bot/Repair-Empire/actions/runs/38076747705) succeeded from the exact source commit; the original universal certificate SHA1/SHA256 pins match and all 567 non-signature bundle entries are byte-identical. Signed AAB SHA256 `f5bb792ea3a0f1ac4559e6bdf86b930b15aded7753d7fa4cffedf225ed372a90`. Signed package/provenance/proofs and desktop evidence are retained on the SSD and in the same private draft, with fresh server asset digests checked. No local private keystore was created or downloaded.

The coordinated desktop acceptance receipts and actual rendered views are recorded in `docs/INTERNAL-PRESENTATION-REVISION.json`. [Three actual Unity views](QA/2026-10-10/actual-game-views.png) show the present implementation, not an illustrated concept or an iPhone capture. All Unity sources are backed up on canonical main; the original user-deleted historical `docs/concepts/PRIMARY-CONCEPT.png` remains unstaged. Native caches/exports/archives are retained now that the SSD has sufficient capacity.

Acceptance remains bounded: desktop event-driven input and rendered QA do not establish physical iPhone raw multi-touch, thermal or 60 FPS acceptance; genuine provider purchase/reward transactions and full cinematic equivalence to the concept illustrations remain open. The known vendor UnityRuntime.framework dSYM warning does not prevent internal delivery; the game's own and UnityFramework symbols remain retained. No public App Review submission or Play publication was performed.

Full driving/four-job/exact-once acceptance predates only the final decorative depth-tested world-font atlas binding. Final presentation acceptance exercises that binding and the unobstructed switch contacts. Four paid jobs were restored in a fresh process.
