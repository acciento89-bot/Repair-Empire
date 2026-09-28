# Repair Empire V1 Ledger

Status legend: [ ] open, [~] implemented/partially verified, [x] verified complete, [!] blocked by external Roblox/runtime dependency.

Implementation is active. Core systems are implemented and the repository is CI-green.

Verification baseline:
- GitHub Actions run #385: success
- Head verified through formatting, Selene lint, Rojo build and 35 pure-Luau tests; release-readiness reports Sandbox-ready: yes; phone HUD and contrast guardrails are included
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
- [x] P08-T05 Navigation markers
- [~] P08-T06 Performance/streaming pass — StreamingEnabled verified; server world baseline recorded at 572 parts / 614 descendants / 22.14 ms average Heartbeat and a reproducible 120-frame Studio client probe now records avg/p95 frame time, FPS and memory for two simultaneous clients; production-device, travel/streaming and network profiling remain

## P09 Multiplayer & Co-op
- [x] P09-T01 Co-op contract state model
- [x] P09-T02 Contribution tracking
- [x] P09-T03 Reward split/validation
- [x] P09-T04 Four launch large contracts
- [~] P09-T05 Multi-client abuse/reconnect tests — real Studio server boot with 2 simultaneous clients verified; hard disconnect of one test client leaves server and second client stable; deterministic owner-transfer, capacity and zero-contribution reward invariants are pure-test guarded; contract-active reconnect, simultaneous-stage and latency abuse scenarios remain

## P10 Monetization
- [x] P10-T01 Monetization config and catalog IDs — 5 Game Passes and 6 Developer Products created with live Roblox IDs and configured prices
- [x] P10-T02 Game Pass entitlement service
- [x] P10-T03 Developer Product receipt handler
- [x] P10-T04 Idempotency/duplicate receipt protection
- [x] P10-T05 Shop UI and explicit purchase flow — real Roblox prices are read from MarketplaceService and live Studio Shop rendering with configured prices is runtime-verified
- [~] P10-T06 Sandbox verification — live IDs/prices are configured; receipt idempotency, duplicate-analytics suppression and paid-state survival across Prestige are pure-test verified; real Marketplace purchase/reconnect sandbox verification remains

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
- [!] P12-T05 Endgame pacing verification — requires real playtest/telemetry across late-game progression

## P13 UI/UX Polish
- [x] P13-T01 Small-phone layouts — iPhone XR plus compact iPhone 7 (667x375) landscape/portrait runtime QA verified; Sensor orientation is enabled at StarterGui and active PlayerGui; compact Premium Workshop marker overflow found and fixed
- [~] P13-T02 Tablet/desktop layouts — iPad 6th Generation landscape/portrait visual runtime QA verified; desktop UI and mouse navigation are verified including live Shop rendering; full keyboard-only traversal remains
- [~] P13-T03 Controller navigation — focusable UI, ButtonStart open/toggle and ButtonB back/close paths implemented; controller runtime QA remains
- [~] P13-T04 Accessibility pass — text/context and non-color-only critical states implemented; explicit accessible palette plus 4.5:1 contrast CI guardrail verified; final device/visual audit remains
- [~] P13-T05 Feedback/audio/effects polish — HUD/reward/error feedback exists and the self-contained world/workshop art pass is Studio-verified; final sound/VFX asset pass remains
- [~] P13-T06 Progression and management screens — complete approved navigation hierarchy is implemented and pure-test guarded; desktop mouse traversal is partially runtime-verified (Jobs/Shop); full touch/controller traversal remains

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
- [~] P15-T06 Full launch economy pass — executable Early/Mid/Late/Prestige model and CI guardrails are verified; real travel, retention and player-behavior pacing still require Roblox playtests/telemetry

## P16 Release
- [~] P16-T01 Full QA matrix — phone and tablet device passes, desktop mouse UI, 2-client boot/disconnect, performance baselines and DataStore smoke tests are executed; controller, keyboard-only, Marketplace sandbox and remaining network/recovery abuse cases remain
- [~] P16-T02 Data migration/recovery test — Studio API access enabled; isolated development store verified with fresh-load 404, stop/save and successful second load; schema migration, expired-lock acquisition and foreign-lock write rejection are pure-test guarded; corresponding live DataStore recovery cases remain
- [~] P16-T03 Purchase release checklist — live IDs/prices configured and Dev published; actual purchase/receipt sandbox verification remains
- [~] P16-T04 Store metadata/assets checklist — final metadata is configured and the 17-section Roblox content questionnaire was submitted successfully; final icon/thumbnails remain
- [~] P16-T05 Controlled public launch — authenticated dashboard/Studio publishing is working and both production/dev places exist privately; public exposure remains intentionally blocked by QA, assets and monetization gates
- [x] P16-T06 Launch monitoring/rollback readiness — analytics, rollback and incident runbooks prepared

## P17 Post-launch
- [x] P17-T01 Incident process
- [!] P17-T02 First telemetry review — requires live user data
- [!] P17-T03 First balance patch — requires telemetry/player evidence
- [x] P17-T04 Content cadence
- [~] P17-T05 Backlog prioritization from evidence — prioritization framework exists; real ordering waits for launch evidence
