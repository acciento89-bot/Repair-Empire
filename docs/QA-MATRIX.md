# Repair Empire - V1 QA Matrix

## Core boot
- Fresh server boots without service dependency errors.
- Remotes are created exactly once.
- New player receives default profile.
- Returning player loads existing profile.
- Profile schema migration fixture reaches current version; live development-DataStore probe verifies v1→v2 migration and preserved values.
- Save failure never silently overwrites a newer locked session; live probe verifies active foreign-lock writes are blocked.

## Solo gameplay
- Player requests offers.
- Ineligible district jobs are not offered.
- Job cannot be accepted twice.
- Required tool tier is enforced.
- Job receives a valid world anchor.
- Player cannot complete a stage out of order.
- Player cannot complete a stage faster than the configured minimum.
- Player cannot complete a stage outside spatial range.
- Completion grants Cash/XP/Company Points exactly once.
- Abandon removes active job without reward.
- Instant finish requires owned consumable and spatial presence.

## Progression
- XP can cross multiple level thresholds.
- District unlocks occur at configured levels.
- Tool purchase/equip persists.
- Vehicle purchase/select persists.
- Workshop upgrades obey max tier and cost.
- Employee hiring obeys slot/workshop/company gates.
- Passive income is capped at configured offline duration.
- Prestige requires all eligibility gates and explicit confirmation.

## Multiplayer/co-op
- 1-6 players may participate as designed.
- Full party rejects additional join.
- Non-member cannot contribute.
- Owner disconnect transfers ownership.
- Zero-contribution player receives no co-op reward.
- Final completion cannot be replayed.

## Monetization
- Unknown/unconfigured pass/product key rejects safely.
- Client purchase-finished event never grants value.
- Developer Product receipt grants exactly once.
- Duplicate receipt returns granted without duplicate value.
- Receipt save failure returns NotProcessedYet.
- Paid entitlements survive prestige. Pure rules verify Cash, Developer Product consumables and active boosts; live Game Pass rejoin still requires Marketplace sandbox evidence.
- Duplicate receipt retries do not duplicate value or purchase analytics.
- Free path remains complete.

## UI/input
- Small phone: no critical control overlaps Roblox movement controls. iPhone XR and compact iPhone 7 landscape/portrait are runtime-verified; compact Premium Workshop marker overflow was fixed.
- Tablet: iPad 6th Generation landscape and portrait runtime views remain readable and within the device display.
- Desktop: mouse navigation/menu rendering is runtime-verified; full keyboard-only core-loop traversal remains.
- Controller: Generic Gamepad runtime verifies Repair Empire menu access/focus via ButtonY and close/back via ButtonB; D-pad traversal is deterministic and pure-tested; repair action remains bound to ButtonX through ContextActionService.
- Critical states use text plus context, not color alone.
- No mandatory animation is required to understand state.

## Failure/reconnect
- Disconnect during active solo job does not duplicate rewards.
- Disconnect during co-op does not orphan contract ownership.
- Rejoin after save succeeds with exact previous persistent state.
- Shutdown attempts to release all session locks.

## Security
See `SECURITY-TEST-MATRIX.md`.

## External-runtime requirement
The executable QA matrix has been run across Studio/device emulation and deterministic server-side abuse/recovery tests. The remaining release-only external evidence is the real-Robux Marketplace receipt test and Roblox assigning the submitted content maturity label.
