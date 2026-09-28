# Roblox Dashboard Setup Checklist

These are the only platform values/actions intentionally not invented by source code.

## Experience
- Create/confirm owner or Roblox group.
- Create production experience named **Repair Empire**.
- Record Universe ID.
- Record production Start Place ID.
- Create/confirm development/test place or private development experience.
- Record development/test Place ID(s).

Write the confirmed values into `src/shared/config/PlatformConfig.luau`.

## Game Passes
Create and record IDs for:
- double_cash
- vip
- extra_employee_slot
- extra_vehicle_slot
- premium_workshop

Keep prices initially aligned with `MonetizationConfig.PriceHypothesis` unless deliberately changed.

## Developer Products
Create and record IDs for:
- small_cash
- medium_cash
- large_cash
- boost_15
- boost_60
- instant_job_finish

After IDs exist, update `MonetizationConfig.luau` and run sandbox purchase verification.

## Access/testing
- Enable Studio API access only where required for test DataStores.
- Keep production and development IDs distinct.
- Never test destructive data migrations against the production DataStore without a recovery plan.

## Release settings
- Confirm age/content questionnaire against actual shipped content.
- Configure icon and thumbnails.
- Confirm description matches actual features.
- Verify supported devices/input modes.
- Keep experience private until P16 release gates pass.
