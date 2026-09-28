# Repair Empire - V1 QA Matrix

## Core boot
- Fresh server boots without service dependency errors.
- Remotes are created exactly once.
- New player receives default profile.
- Returning player loads existing profile.
- Profile schema migration fixture reaches current version.
- Save failure never silently overwrites a newer locked session.

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
- Small phone: no critical control overlaps Roblox movement controls. iPhone XR landscape and portrait are runtime-verified; smaller compact preset remains.
- Tablet: panels remain readable and centered.
- Desktop: mouse navigation/menu rendering is runtime-verified; full keyboard-only core-loop traversal remains.
- Controller: selectable controls and ButtonX repair action work.
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
Items involving real DataStore, MarketplaceService sandbox, multi-client network timing, device emulation and Roblox publish state require Roblox Studio/client access before public release.
