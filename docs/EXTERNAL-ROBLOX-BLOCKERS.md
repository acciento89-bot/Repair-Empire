# External Roblox Blockers

Everything in this document requires authenticated Roblox/Studio/runtime access or real production assets. These values must not be fabricated.

## P00-T02 - Platform ownership and IDs
Required:
- Roblox owner/group
- production Universe ID
- production Start Place ID
- development/test Place ID(s)

Already decided in source:
- display name: Repair Empire
- one production experience
- isolated development/test environment
- all platform IDs centralized in configuration

## P06/P08/P13 - Final visual/runtime assets
Source code already provides functional placeholders and systems. Final release quality still requires:
- polished vehicle models and driving validation
- polished city/workshop art
- final tool/repair props
- audio asset IDs and final effects
- device-specific visual QA in Roblox clients

## P08 - Performance verification
Requires Roblox Studio/client profiling:
- StreamingEnabled behavior
- client/server frame and memory measurements
- network behavior with multiple players

## P09 - Multi-client validation
Requires Roblox Studio multi-client/runtime tests:
- join/leave races
- co-op disconnect/reconnect
- simultaneous stage requests
- latency behavior

## P10 - Monetization IDs and sandbox
Requires Creator Dashboard:
- five Game Pass IDs if all hypotheses are retained
- six Developer Product IDs
- final prices
- sandbox purchase verification
- receipt retry/reconnect verification against Roblox MarketplaceService

No product/pass ID is invented in source.

## P13 - Device and accessibility validation
Requires real/emulated Roblox clients:
- small phone
- tablet
- desktop mouse/keyboard
- controller
- safe area/input overlap validation

## P14 - Runtime exploit validation
Requires Studio/runtime:
- remote replay
- race conditions
- position spoof attempts
- purchase receipt retry simulation
- live network timing cases

## P16 - Public release
Requires authenticated Roblox dashboard actions:
- content/age questionnaire
- icon and thumbnails
- final experience metadata review
- publish/release controls
- controlled public exposure

## P17 - Evidence-dependent tasks
Cannot exist before real users/data:
- first telemetry review
- first evidence-based balance patch
- post-launch backlog prioritization from actual behavior

## Rule
A blocked task stays blocked/partial in the ledger until its external acceptance criteria are genuinely verified.
