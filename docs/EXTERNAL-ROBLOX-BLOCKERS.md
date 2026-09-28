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
- self-contained feedback sound and tween VFX pass is implemented; Studio audio preload verified

V1 acceptance is complete. Physical-client driving feel and additional repair-prop art polish are optional post-launch polish, not release blockers.

## P08 - Performance verification
Resolved for V1 release acceptance:
- StreamingEnabled verified in Studio
- server world baseline recorded: 572 BaseParts, 614 descendants, 22.14 ms average Heartbeat in Studio
- two simultaneous Studio clients produce 120-frame avg/p95 frame-time, approximate FPS and memory baselines
- latest two-client sample: Player1 75.82 ms avg / 117.03 ms p95 / 13.2 FPS / 2428.5 MB; Player2 27.75 ms avg / 58.57 ms p95 / 36.0 FPS / 2568.1 MB
- compact-phone, tablet and desktop runtime views are verified
- baseline hooks are Studio-only and documented in `docs/PERFORMANCE-BASELINE.md`

Production-device telemetry and real-user network behavior move to post-launch P17 monitoring and are not remaining P08 acceptance blockers.

## P09 - Multi-client validation
Resolved/verified:
- Studio server boot with 2 simultaneous clients (Player1/Player2) verified; both clients initialized successfully
- hard termination of one test client verified that the Studio server and remaining client continue running without Repair Empire runtime errors
- deterministic owner-transfer, party-capacity and zero-contribution reward invariants are pure-test guarded

Resolved in code/tests:
- active-contract join capacity and owner transfer are deterministic
- disconnected contribution is retained for same-contract rejoin
- simultaneous stage requests are rejected while a contract mutation is active
- stage timing is calculated from server clock and cannot be client timestamp-spoofed

## P10 - Monetization sandbox
Resolved:
- five Game Pass IDs created and source-configured
- six Developer Product IDs created and source-configured
- launch Robux prices configured
- managed/regional pricing disabled
- updated monetization config published to Repair Empire Dev

Resolved in runtime:
- live Game Pass prompt reached Roblox Marketplace in Studio
- Roblox recognized an already-owned Extra Vehicle Slot pass and explicitly confirmed the account was not charged
- live entitlement effects are visible after rejoin (VIP/Premium Workshop UI state)

Resolved in code/tests:
- ProductId lookup/allowlisting
- atomic/idempotent receipt grants
- duplicate receipt retries do not duplicate value or analytics
- Cash, Developer Product consumables, active paid boosts, receipt history and lifetime stats survive Prestige
- Game Pass ownership remains external to profile reset

Still required:
- one owner-approved real-Robux Developer Product transaction; Roblox's current test flow charges actual Robux
- receipt retry/reconnect verification against live MarketplaceService using that transaction

Game Pass ownership/rejoin is already runtime-evidenced by existing owned entitlements.

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


## P14 - Runtime exploit validation
Resolved/verified for V1:
- per-player value-mutation guard serializes Tool, Vehicle, Workshop, Employee and Skill purchases/upgrades
- Developer Product receipt grants use the same mutation guard
- lock cleanup on disconnect and release-on-error behavior are pure-test verified
- stale/replayed job completion, simultaneous mutation, out-of-order actions, spatial spoofing and server-timing guards are adversarial pure-tested and consumed by runtime services
- duplicate receipt and retry behavior is deterministic/idempotent in code tests

External executor fuzzing and real-user network abuse remain post-launch monitoring inputs, not known unresolved client-controlled mint paths.

## P16 - Data/runtime and public release
Current platform incident:
- on 2026-09-29 Studio repeatedly returned `PublishService AssetUpload failed: UploadStatusPolling max polling retry reached` while publishing the development place
- current reports from other Roblox creators show the same Studio save/publish failure; the latest green Rojo build is preserved locally at `.local-backups/RepairEmpire-latest-green.rbxlx` and in GitHub
- retry cloud publishing when Roblox's upload service recovers

Resolved in runtime:
- isolated development DataStore recovery probe passed v1→v2 migration, expired-lock acquisition, active foreign-lock rejection, foreign-write rejection and temporary-key cleanup

Resolved in code/tests:
- expired session locks are acquirable
- active foreign session locks block acquisition
- active foreign session locks cannot be overwritten during save
- future schema versions fail closed

Resolved in Creator Hub:
- content questionnaire is complete and content maturity is now assigned as `Minimal`

Still required:
- controlled public exposure only after the paid Developer Product release gate clears and the current Roblox Studio publishing incident recovers

## P12/P15 - Prelaunch pacing
Resolved:
- level-by-level active progression model uses actual job/tool/district unlock data
- modeled time to level 100 at 45s travel is 31.6 hours
- CI guardrail requires first-prestige leveling estimate to remain between 20 and 80 hours
- maximum passive/active modeled rate ratio is 39.1%
- company-level target does not model as a later gate than level 100

## P17 - Evidence-dependent tasks
Cannot exist before real users/data:
- first telemetry review
- first evidence-based balance patch

The backlog classification/prioritization framework itself is complete; actual post-launch ordering will consume telemetry when available.

## Rule
A blocked or partial task stays blocked/partial until its acceptance criteria are genuinely verified.
