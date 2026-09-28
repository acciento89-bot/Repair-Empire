# Repair Empire - User Action Checklist

This document intentionally contains only work that cannot be completed from the repository alone.

## 1. Roblox ownership and experience IDs
In Creator Dashboard / Roblox Studio, provide or confirm:
- Roblox owner or group that will own Repair Empire
- production Universe ID
- production Start Place ID
- development/test Place ID

After these values exist, they go into `src/shared/config/PlatformConfig.luau`.

## 2. Game Passes
Create these Game Passes if the launch catalog is retained:
- double_cash
- vip
- extra_employee_slot
- extra_vehicle_slot
- premium_workshop

Record each numeric Roblox ID.

## 3. Developer Products
Create these Developer Products:
- small_cash
- medium_cash
- large_cash
- boost_15
- boost_60
- instant_job_finish

Record each numeric Roblox ID.

## 4. Runtime verification in Roblox Studio
Once the IDs/experience exist, run the prepared QA matrix:
- fresh profile load/save/rejoin
- locked-session/recovery behavior
- solo job lifecycle
- tool/vehicle/company progression
- 2-6 player co-op
- reconnect and host-transfer cases
- remote abuse/race checks
- StreamingEnabled/performance profiling
- small phone/tablet/desktop/controller input QA

Use `docs/QA-MATRIX.md` and `docs/SECURITY-TEST-MATRIX.md`.

## 5. Marketplace sandbox
With the real IDs configured:
- verify each Game Pass prompt/entitlement
- buy each Developer Product in sandbox
- verify duplicate/retried receipts never duplicate grants
- verify reconnect during receipt processing
- verify paid entitlements survive Prestige

## 6. Final public-facing assets/settings
Before release:
- experience icon
- at least the planned landscape thumbnails
- final content/age questionnaire
- final description review
- supported-device/input review

The text draft and asset brief already exist in `docs/STORE-METADATA-DRAFT.md`.

## 7. Controlled launch
Only after the above gates pass:
- publish/update the production place
- expose the experience in a controlled launch
- verify analytics, saves and purchases
- then expand exposure

## What you do NOT need to design
The repository already contains:
- game/system architecture
- 30 launch jobs
- tool, vehicle, company and Prestige systems
- procedural V1 world
- co-op
- retention
- monetization code
- analytics/security
- responsive UI rules
- QA/security/release runbooks
- economy model and CI guardrails

Run `lune run scripts/release-readiness` at any time to print the remaining configuration blockers.
