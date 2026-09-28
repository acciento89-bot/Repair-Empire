# Repair Empire - User Action Checklist

This document intentionally contains only work that cannot be completed from the repository alone.

## 1. Roblox ownership and experience IDs — DONE
Configured:
- production Universe ID: `10768475286`
- production Start Place ID: `79925227687072`
- development/test Place ID: `138882349802835`
- development place: **Repair Empire Dev**
- both places private
- values are present in `src/shared/config/PlatformConfig.luau`
- Studio/API tests use an isolated development DataStore

## 2. Game Passes — DONE
Configured:
- double_cash — `1997847285` — 299 R$
- vip — `1998201387` — 399 R$
- extra_employee_slot — `1998489332` — 149 R$
- extra_vehicle_slot — `1997979360` — 149 R$
- premium_workshop — `1999077322` — 249 R$

## 3. Developer Products — DONE
Configured:
- small_cash — `3715317811` — 49 R$
- medium_cash — `3715317874` — 149 R$
- large_cash — `3715318066` — 399 R$
- boost_15 — `3715318201` — 39 R$
- boost_60 — `3715318256` — 99 R$
- instant_job_finish — `3715318304` — 29 R$

All 11 IDs are source-configured and the updated build has been published to Repair Empire Dev.

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
