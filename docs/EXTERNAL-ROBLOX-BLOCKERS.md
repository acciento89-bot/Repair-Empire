# External Roblox Blockers

Everything in this document still requires Roblox runtime/dashboard evidence, real product IDs or final release assets. Platform ownership and place IDs are no longer blockers.

## Resolved platform setup
- experience: **Repair Empire**
- Universe ID: `10768475286`
- production start place: `79925227687072`
- development/test place: `138882349802835`
- both places are private
- Studio API Services access is enabled for testing
- development and production DataStores are isolated in code; Studio always resolves to the development store
- the dev place has completed a server/client boot smoke test without the previous API-services block

## P06/P08/P13 - Final visual/runtime assets
Resolved:
- self-contained procedural city/workshop art pass is implemented and Studio-verified
- streets, sidewalks, markings, lighting, district dressing and street-facing facades are present
- vehicles remain self-contained procedural models rather than external Marketplace assets

Still required:
- driving validation on actual client input
- final tool/repair prop polish where desired
- audio asset IDs and final effects
- device-specific visual QA in Roblox clients

## P08 - Performance verification
Resolved:
- StreamingEnabled verified in Studio
- server-only world baseline recorded: 572 BaseParts, 614 descendants, 22.14 ms average Heartbeat in Studio
- two simultaneous Studio clients now produce 120-frame avg/p95 frame-time, approximate FPS and memory baselines
- latest two-client sample: Player1 75.82 ms avg / 117.03 ms p95 / 13.2 FPS / 2428.5 MB; Player2 27.75 ms avg / 58.57 ms p95 / 36.0 FPS / 2568.1 MB
- baseline hooks are Studio-only and documented in `docs/PERFORMANCE-BASELINE.md`

Still required:
- production-device FPS/frame time and memory
- streaming behavior under player travel
- server/network behavior with multiple players

## P09 - Multi-client validation
Resolved/verified:
- Studio server boot with 2 simultaneous clients (Player1/Player2) verified; both clients initialized successfully
- hard termination of one test client verified that the Studio server and remaining client continue running without Repair Empire runtime errors
- deterministic owner-transfer, party-capacity and zero-contribution reward invariants are pure-test guarded

Still required:
- join/leave races during an active contract
- co-op reconnect and owner-transfer during an active contract
- simultaneous stage requests
- latency behavior

## P10 - Monetization sandbox
Resolved:
- five Game Pass IDs created and source-configured
- six Developer Product IDs created and source-configured
- launch Robux prices configured
- managed/regional pricing disabled
- updated monetization config published to Repair Empire Dev

Resolved in code/tests:
- ProductId lookup/allowlisting
- atomic/idempotent receipt grants
- duplicate receipt retries do not duplicate value or analytics
- Cash, Developer Product consumables, active paid boosts, receipt history and lifetime stats survive Prestige
- Game Pass ownership remains external to profile reset

Still required:
- actual Marketplace sandbox purchase verification
- receipt retry/reconnect verification against live MarketplaceService
- Game Pass entitlement persistence after real purchase/rejoin

## P13 - Device and accessibility validation
Resolved/verified:
- iPhone XR landscape emulator view is visually usable
- iPhone XR portrait runtime is enabled and visually usable; menu remains within the display and tabs scroll horizontally
- compact iPhone 7 (667x375) landscape and portrait runtime are visually usable; Premium Workshop marker overflow was found and fixed
- StarterGui defaults to Sensor orientation and active PlayerGui receives the same runtime preference
- iPad 6th Generation landscape and portrait runtime views are visually usable
- desktop mouse runtime navigation is verified for opening the menu and switching to the Shop
- live Shop rendering displays configured Roblox prices
- explicit UI palette has automated 4.5:1 minimum contrast checks in CI

Still required:
- full desktop keyboard-only traversal
- controller
- remaining safe-area/input-overlap validation

## P14 - Runtime exploit validation
Resolved/verified:
- per-player value-mutation guard serializes Tool, Vehicle, Workshop, Employee and Skill purchases/upgrades
- Developer Product receipt grants use the same mutation guard
- lock cleanup on disconnect and release-on-error behavior are pure-test verified

Still required:
- remote replay
- race conditions
- position spoof attempts
- purchase receipt retry simulation
- live network timing cases

## P16 - Data/runtime and public release
Resolved in runtime:
- isolated development DataStore recovery probe passed v1→v2 migration, expired-lock acquisition, active foreign-lock rejection, foreign-write rejection and temporary-key cleanup

Resolved in code/tests:
- expired session locks are acquirable
- active foreign session locks block acquisition
- active foreign session locks cannot be overwritten during save
- future schema versions fail closed

Still required:
- full QA matrix
- Roblox content questionnaire is submitted; resulting label is still pending/unknown in Creator Hub
- icon and thumbnails
- final experience metadata review
- controlled public exposure only after release gates pass

## P17 - Evidence-dependent tasks
Cannot exist before real users/data:
- first telemetry review
- first evidence-based balance patch
- post-launch backlog prioritization from actual behavior

## Rule
A blocked or partial task stays blocked/partial until its acceptance criteria are genuinely verified.
