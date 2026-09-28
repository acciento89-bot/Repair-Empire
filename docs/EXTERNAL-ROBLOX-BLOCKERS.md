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
Source code provides functional self-contained systems. Final release quality still requires:
- polished vehicle models and driving validation
- polished city/workshop art
- final tool/repair props
- audio asset IDs and final effects
- device-specific visual QA in Roblox clients

## P08 - Performance verification
Still required:
- StreamingEnabled behavior under travel
- client/server frame and memory measurements
- network behavior with multiple players

## P09 - Multi-client validation
Still required:
- join/leave races
- co-op disconnect/reconnect
- simultaneous stage requests
- latency behavior

## P10 - Monetization sandbox
Resolved:
- five Game Pass IDs created and source-configured
- six Developer Product IDs created and source-configured
- launch Robux prices configured
- managed/regional pricing disabled
- updated monetization config published to Repair Empire Dev

Still required:
- actual sandbox purchase verification
- receipt retry/reconnect verification against MarketplaceService
- entitlement persistence checks after rejoin/Prestige

## P13 - Device and accessibility validation
Still required:
- small phone
- tablet
- desktop mouse/keyboard
- controller
- safe-area/input-overlap validation

## P14 - Runtime exploit validation
Still required:
- remote replay
- race conditions
- position spoof attempts
- purchase receipt retry simulation
- live network timing cases

## P16 - Data/runtime and public release
Still required:
- migration/recovery runtime cases beyond the successful boot smoke test
- full QA matrix
- content/age questionnaire
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
