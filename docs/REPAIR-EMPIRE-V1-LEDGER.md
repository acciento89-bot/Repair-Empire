# Repair Empire V1 Ledger

Status legend: [ ] open, [~] implemented/partially verified, [x] verified complete, [!] blocked by external Roblox/runtime dependency.

Implementation is active. Core systems are implemented and the repository is CI-green.

Verification baseline:
- Current main head: GitHub Actions verification green
- Current production-place runtime baseline after canonical-build publish: 2,593 world parts / 2,730 descendants; Studio client ~54.9 FPS at 1919x1079; reachability 112 anchors ground/clearance OK and 12/12 representative routes
- Head verified through formatting, Selene lint, Rojo build and 45 pure-Luau tests; release-readiness reports Sandbox-ready: yes; P19 production-art, vehicle-input and production-audio guardrails are included
- External/runtime-only blockers are documented in `docs/EXTERNAL-ROBLOX-BLOCKERS.md`

## P00 Product Definition
- [x] P00-T01 Initialize standalone implementation repository and project metadata
- [x] P00-T02 Confirm Roblox experience ownership/naming/place structure — Repair Empire created privately; Universe 10768475286, production start place 79925227687072, development place 138882349802835
- [x] P00-T03 Freeze V1 config identifiers and terminology

## P01 Technical Foundation
- [x] P01-T01 Initialize Rojo/Luau source layout
- [x] P01-T02 Add shared config/type/constants foundation
- [x] P01-T03 Add remotes registry and validation conventions
- [x] P01-T04 Add server service bootstrap/lifecycle
- [x] P01-T05 Add test/lint/static-check workflow

## P02 Player Foundation
- [x] P02-T01 Define versioned player profile schema
- [x] P02-T02 Implement load/save/session lifecycle
- [x] P02-T03 Implement schema migration harness
- [x] P02-T04 Implement base HUD and responsive input shell
- [x] P02-T05 Implement onboarding state foundation

## P03 Job Engine
- [x] P03-T01 Define job data schema and registry
- [x] P03-T02 Implement server job offer generation
- [x] P03-T03 Implement accept/abandon lifecycle
- [x] P03-T04 Implement staged interaction state machine
- [x] P03-T05 Implement completion/reward transaction
- [x] P03-T06 Implement reconnect/duplicate-completion protection — active jobs intentionally cancel on reconnect; stale/replayed instance IDs cannot grant again
- [x] P03-T07 Add first 5 vertical-slice jobs — launch catalog currently contains 30 jobs
- [x] P03-T08 Job engine verification pass — server rules for stale/replay/completion-race/wrong-order/spatial/timing requests are adversarial pure-tested and used by runtime JobService; single-client plus two-client Studio boot/disconnect smoke tests are verified

## P04 Economy & Progression
- [x] P04-T01 Central EconomyService
- [x] P04-T02 XP and player levels
- [x] P04-T03 district/job unlock rules
- [x] P04-T04 Company Points and company levels
- [x] P04-T05 source/sink telemetry hooks

## P05 Tools
- [x] P05-T01 Tool definitions and ownership
- [x] P05-T02 Equip flow
- [x] P05-T03 Tier requirements and modifiers
- [x] P05-T04 Tool shop UI
- [x] P05-T05 Launch tool catalog — 20 tool definitions

## P06 Vehicles
- [x] P06-T01 Vehicle definitions/ownership
- [x] P06-T02 Spawn/despawn rules
- [x] P06-T03 Vehicle shop/garage
- [x] P06-T04 Travel integration — navigation plus server-driven procedural vehicle controller
- [x] P06-T05 Launch vehicle catalog — 8 distinct self-contained procedural vehicle variants with geometry, seats and axle definitions

## P07 Company Tycoon
- [x] P07-T01 Workshop/company progression
- [x] P07-T02 Employee definitions/hiring
- [x] P07-T03 Passive job simulation
- [x] P07-T04 Employee slots/upgrades
- [x] P07-T05 Passive economy balancing guardrails

## P08 World
- [x] P08-T01 Residential district — connected procedural district with spawn, workshop, roads, sidewalks, lighting, street-facing facades, trees, signage and job locations; Studio visual pass verified
- [x] P08-T02 Downtown district — connected procedural district with distinct building scale, glass bands, roof crowns, streetscape dressing and job locations
- [x] P08-T03 Industrial district — connected procedural district with industrial dressing, tanks/vents/pipes and co-op-capable job locations
- [x] P08-T04 Job anchor/building system
- [x] P08-T05 Navigation markers — live job targets now render a persistent world beacon plus seven directional ground arrows and distance guidance; the first-job tutorial explicitly explains following the arrows to the JOB SITE
- [x] P08-T06 Performance/streaming pass — V1 acceptance met: StreamingEnabled is verified; server world baseline covers 572 parts / 614 descendants / 22.14 ms average Heartbeat; two simultaneous Studio clients have reproducible frame/memory baselines; compact-phone/tablet/desktop navigation is runtime-verified. Production-device telemetry remains a post-launch P17 concern rather than a P08 release blocker

## P09 Multiplayer & Co-op
- [x] P09-T01 Co-op contract state model
- [x] P09-T02 Contribution tracking
- [x] P09-T03 Reward split/validation
- [x] P09-T04 Four launch large contracts
- [x] P09-T05 Multi-client abuse/reconnect tests — real 2-client Studio boot and hard-disconnect survival verified; deterministic owner transfer, capacity, zero-contribution rewards, reconnect contribution restore, completion replay, simultaneous-stage serialization and server-timing/latency guards are runtime-used and pure-tested

## P10 Monetization
- [x] P10-T01 Monetization config and catalog IDs — 5 Game Passes and 6 Developer Products created with live Roblox IDs and configured prices
- [x] P10-T02 Game Pass entitlement service
- [x] P10-T03 Developer Product receipt handler
- [x] P10-T04 Idempotency/duplicate receipt protection
- [x] P10-T05 Shop UI and explicit purchase flow — real Roblox prices are read from MarketplaceService and live Studio Shop rendering with configured prices is runtime-verified
- [!] P10-T06 Sandbox verification — live Game Pass prompt wiring and existing ownership are runtime-verified in Studio (Roblox returned "already own this item" and confirmed no charge); code-side retry/duplicate/aborted-path protections are verified. A successful Developer Product receipt/rejoin still requires an owner-approved real Robux transaction

## P11 Retention
- [x] P11-T01 Daily jobs
- [x] P11-T02 Daily login reward
- [x] P11-T03 Achievement framework
- [x] P11-T04 Launch achievements
- [x] P11-T05 Rotating contract hooks

## P12 Prestige & Endgame
- [x] P12-T01 Prestige eligibility
- [x] P12-T02 Reset transaction
- [x] P12-T03 Permanent meta bonuses
- [x] P12-T04 Prestige UI
- [x] P12-T05 Endgame pacing verification — deterministic level-by-level model using unlocked districts/tools/jobs estimates 31.6 active hours to level 100 at 45s travel; CI enforces a 20–80h first-prestige pacing window and company-level gate does not trail level-100 gate

## P13 UI/UX Polish
- [x] P13-T01 Small-phone layouts — iPhone XR plus compact iPhone 7 (667x375) landscape/portrait runtime QA verified; Sensor orientation is enabled at StarterGui and active PlayerGui; compact Premium Workshop marker overflow found and fixed
- [x] P13-T02 Tablet/desktop layouts — iPad 6th Generation landscape/portrait runtime QA and desktop mouse runtime QA verified; deterministic wrapped keyboard/D-pad tab traversal is implemented and pure-tested
- [x] P13-T03 Controller navigation — Studio Generic Gamepad runtime verified: ButtonY opens Repair Empire menu with selected/focused tab, ButtonB closes it; wrapped D-pad traversal is shared with the pure-tested navigation rule; ButtonStart retained only as fallback because Roblox CoreUI intercepts it
- [x] P13-T04 Accessibility pass — text/context and non-color-only critical states implemented; explicit palette has automated 4.5:1 contrast guardrail; compact phone, XR, iPad and desktop visual audits completed
- [x] P13-T05 Feedback/audio/effects polish — contextual toast feedback, tween polish and self-contained Roblox audio cues implemented; Studio preload verified with FeedbackAudio ready=true
- [x] P13-T06 Progression and management screens — complete approved Jobs/Co-op/Tools/Skill Tree/Vehicles/Workshop/Employees/Daily Jobs/Achievements/Prestige/Shop hierarchy is implemented; the 2026-09-29 same-client runtime journey renders every tab successfully and the Work Tablet is positioned clear of Roblox CoreGui

## P14 Security Hardening
- [x] P14-T01 Remote inventory/audit
- [x] P14-T02 Rate limits
- [x] P14-T03 Spatial/state validation audit
- [x] P14-T04 Economy exploit tests — per-player mutation serialization plus runtime-used stale/replay/completion-race/order/timing/spatial guards are adversarial pure-tested, including boundary, NaN/infinite and extreme-coordinate position spoof cases
- [x] P14-T05 Purchase exploit tests — ProductId allowlisting, atomic grant rules, duplicate receipt idempotency, duplicate-analytics suppression, Prestige retention and receipt-vs-purchase mutation serialization are pure-test verified; live Marketplace purchase behavior is tracked separately under P10-T06/P16-T03
- [x] P14-T06 Security logging

## P15 Analytics & Balancing
- [x] P15-T01 Analytics event schema
- [x] P15-T02 Funnel events
- [x] P15-T03 Economy events — source/sink reason, amount, ending balance, balance version and progression context attached
- [x] P15-T04 Monetization events
- [x] P15-T05 Balance versioning
- [x] P15-T06 Full launch economy pass — executable Early/Mid/Late/Prestige model is CI-guarded: $504,420 hard sink subtotal, 39.1% max passive/active ratio, monotonic earning bands and 31.6h modeled level-100 pacing; post-launch behavior review is tracked under P17

## P16 Release
- [x] P16-T01 Full QA matrix — solo/multi-client, new/returning/migrated profile, compact phone/XR/iPad/desktop, mouse/keyboard/controller input, reconnect/disconnect, timing/race/spatial abuse, DataStore recovery and performance smoke coverage are executed. A fresh-profile Studio E2E now additionally passes UI mount, every Work Tablet tab, first and second tutorial jobs, waypoint/ground-arrow navigation, all repair stages, rewards, tool purchase/equip, vehicle spawn/seat/drive/despawn, workshop upgrade, employee hire, respawn camera follow and authoritative final state; a separate new-session rejoin verified Cash 14490, Lv2/24XP, Basic Screwdriver, Workshop Tier 2, company_intro, 1 employee and 2 completed jobs persisted. Purchase sandbox remains tracked separately under P16-T03
- [x] P16-T02 Data migration/recovery test — isolated development DataStore live-probe verified v1→v2 migration with value preservation, expired-lock acquisition, active foreign-lock acquisition rejection, foreign-lock write rejection and cleanup=true
- [!] P16-T03 Purchase release checklist — IDs/prices/free path plus live Game Pass ownership/prompt behavior are verified; final successful Developer Product receipt/rejoin checklist is blocked by the same owner-approved real Robux transaction required by P10-T06
- [x] P16-T04 Store metadata/assets checklist — final name/description reviewed in Creator Hub; custom Repair Empire icon and three custom thumbnails are uploaded and processed; 17-section content questionnaire is complete
- [!] P16-T05 Controlled public launch — build, metadata/assets, QA, rollback readiness and P19 Production Art & World Quality are complete. The canonical `build.rbxlx` was explicitly published to the production start place `79925227687072` on 2026-09-29 and production runtime verification confirmed the current P19 world. Both places remain private. Public exposure is blocked only by the owner-approved real Developer Product receipt/rejoin evidence.
- [x] P16-T06 Launch monitoring/rollback readiness — analytics, rollback and incident runbooks prepared

## P17 Post-launch
- [x] P17-T01 Incident process
- [!] P17-T02 First telemetry review — requires live user data
- [!] P17-T03 First balance patch — requires telemetry/player evidence
- [x] P17-T04 Content cadence
- [x] P17-T05 Backlog prioritization from evidence — repeatable categorization/prioritization framework exists; future ordering naturally consumes P17 telemetry when available


## P18 Final Polish & Game Feel — mandatory pre-public-launch corrective gate
- [x] P18-T01 Visual design system and shell — Repair Empire-specific navy/orange palette, shared styled controls, selected states, section hierarchy, redesigned HUD/Work Tablet and preserved responsive/controller contracts; contrast guardrails remain automated
- [x] P18-T02 Retention loop completeness — Daily Jobs/login/achievements plus new server-authoritative daily online rewards at 5/15/30/60/90 minutes; persisted daily state, UTC reset, duplicate-safe claims, locked/ready/claimed UI and reward feedback are implemented and tested
- [x] P18-T03 Jobs and quest experience — all 30 launch jobs are catalog-audited across trades/districts/early-mid-late progression; cards expose player-facing requirements/rewards and HUD/repair actions are humanized; existing JobService runtime verification covers accept/stage/complete and abuse guards
- [x] P18-T04 Vehicles and garage presentation — eight distinct vehicle styles, procedural 3D garage previews, explicit selected/owned/locked presentation, style-specific runtime visuals and server-authoritative spawn/despawn; P06 travel integration remains verified
- [x] P18-T05 World, workshop, audio and effects pass — district identity retained; workshop branding/service-bay/tool dressing, restrained lighting polish and expanded reward feedback/audio are implemented without external asset dependency
- [x] P18-T06 Full player-journey acceptance — P02-P16 runtime/device/input matrix plus P18 polish additions cover onboarding through Prestige preview; the 2026-09-29 deterministic Studio journey completes end-to-end with camera follow, navigation arrows/beacon, two full jobs, progression, vehicle, company systems, respawn and rejoin persistence verified. Final acceptance and external-only blockers remain recorded in docs/P18-FINAL-ACCEPTANCE.md


## P19 Production Art & World Quality — mandatory pre-public-launch gate
- [x] P19-T01 Art direction and asset language — Repair Empire production-art rules, trade colors, materials, scale, collision and screenshot-quality criteria are locked in docs/ART-DIRECTION.md
- [x] P19-T02 Environment production kit — legacy terrain/template cleanup, connected service-city rebuild, roads/cross streets/sidewalks/service aprons, facade detail kits, parking/service yards, landmarks, workshop yard, district-density props and horizon/wayfinding backdrop are implemented; ground-level Studio QA is complete and WorldReachabilityProbe verifies all 112 anchors have valid ground/clearance plus 12/12 representative district/trade routes
- [x] P19-T03 Repair scene library — plumbing/heating/climate/energy installations with faulty/active/completed states, animated trade VFX and readable service labels are implemented; representative plumbing, heating, climate and energy scenes are Studio-runtime-rendered at real reachable job anchors
- [x] P19-T04 Tool production art — 3D locker previews and replicated equipped-character visuals cover all launch tool families with tier accents; Tool Locker and equipped Basic Wrench are Studio-runtime-visual-verified
- [x] P19-T05 Vehicle production art — eight distinct silhouettes and garage previews include glass, mirrors, bumpers, grille, registration, branding, lights, roof equipment, cabin detail and style-specific equipment; grounded spawn raycasting, humanized driving HUD and explicit rate-limited client→server vehicle input are implemented. Studio authoritative drive QA moved the old compact van 68.59 studs with throttle=1.00, confirming runtime movement
- [x] P19-T06 Workshop production art — branded workshop and service yard include racks, tool storage, workbench, vehicle lift, compressor, canopy, office/solar, HQ mast, service van, pipe/material storage, fence/gate, charger, waste/material zones and practical bay lighting; Studio runtime tier probe confirms visible progression at Tier 1→5 with 0/27/52/61/63 tier-specific parts
- [x] P19-T07 VFX and audio production pass — reward/UI feedback, trade-specific repair cues, action/tool-family audio profiles, plumbing leak, heating steam/glow, climate airflow/fan and energy spark/glow are implemented; workshop ambience plus layered vehicle engine/road audio use validated Roblox built-in sound paths, and vehicle lighting/exhaust feedback follows authoritative driving state. Audio catalog/rules coverage is pure-test guarded
- [x] P19-T08 Lighting and material pass — centralized production lighting, restrained color correction/bloom/atmosphere/clouds, practical street lights and workshop bay lighting are implemented and Studio-runtime-visual-verified across the production-art world
- [x] P19-T09 Full visual/runtime QA — ground-level Studio visual passes cover workshop/residential/downtown/industrial; WorldReachabilityProbe passes 112/112 anchor ground/clearance and 12/12 representative routes; all four trade scene families, Tool Locker/equipped tool, workshop tiers and grounded vehicle presentation are runtime-rendered; authoritative vehicle movement is verified at 68.59 studs. WorldVerticalLayerProbe passes 122 samples / 1098 collision-respecting raycasts with zero elevated broad surfaces and zero foreign map layers, and iPhone XR runtime confirms the compact HUD/tutorial/job/menu entry remain inside the playable viewport
- [x] P19-T10 Screenshot quality gate — persisted evidence under docs/evidence/p19 covers workshop, residential, downtown, industrial, representative repair scenes, grounded vehicle presentation and iPhone XR compact-device runtime; docs/evidence/p19/README.md records the complete acceptance evidence

## 2026-10-03 Mobile regression corrective pass

- [x] Real-phone regressions repaired and revalidated: Error 267 vehicle-input false positives, vehicle/building collision tunnelling, compact HUD/control density and service-vehicle presentation. Static suite and touch-runtime probes are green. Evidence: `docs/evidence/2026-10-03-mobile-regression-revalidation.md`. Existing Developer Product receipt/rejoin blocker remains unchanged.

## 2026-10-03 HUD / starter-vehicle visual correction

- [x] Compact-phone HUD/tablet density reduced after real-device screenshot review; Cash + Level/XP remain persistent while Company/Skill detail moves to the tablet.
- [x] Starter compact van rebuilt after visual QA: corrected wheel cylinder axis, non-squashed body height, improved wheel/body ratio, shorter cab/longer cargo body, larger dark glass, slimmer fascia and refined roof/rear/branding details.
- [x] Unpublished local Studio QA no longer fails on DataStore access; in-memory profile fallback is restricted to `RunService:IsStudio()` with `PlaceId == 0`.
- [x] Revalidated through 45 pure-Luau tests, StyLua, Selene 0/0, release-readiness, Rojo build, iPhone XR 801x392 runtime, 0 CreatorErrors, 112-anchor/12-route reachability and 30-job catalog runtime probes.

## 2026-10-03 production verification after starter-vehicle correction

- [x] Canonical commit `93031ee` pushed to `origin/main`; final canonical build SHA-256 `4efa1724885b6363407bdaef54b28d283a44ab0fb14bc779cbde24fa41c7251f`.
- [x] Existing production Place `79925227687072` opened directly and synced from the canonical Rojo project; no replacement Place/Experience created.
- [x] Production publish completed successfully after a transient Roblox 504/503 service-side retry; Studio reported `PublishSuccessful`.
- [x] Post-publish production runtime passed server/client initialization, DataRecoveryProbe, 112-anchor/12-route reachability and 30-job/76-stage catalog probes at iPhone XR `801x392`; sampled client baseline ~58.1 FPS.
- [x] Published starter van spawned through the production remote with `ok=true` and visually retained upright wheels plus corrected body proportions.

## 2026-10-04 concept visual-polish pass

- [x] Native Roblox concept-quality presentation pass implemented for this game; no static concept screenshot is used in gameplay.
- [x] Lighting/VFX and native ScreenGui styling are test-guarded and pass local static verification plus Studio PlaySolo runtime QA.
- [x] Evidence: `docs/evidence/2026-10-04-concept-visual-polish.md`.
