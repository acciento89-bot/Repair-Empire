# Stable V1 Identifiers and Terminology

This document freezes machine-facing identifiers for V1. Display text may be localized later; these IDs must remain stable once player data exists.

## Categories
- `plumbing` - Plumbing
- `heating` - Heating
- `climate` - Climate
- `energy` - Energy

## Districts
- `residential` - Residential
- `downtown` - Downtown
- `industrial` - Industrial

## Currencies
- `cash` - Cash
- `company_points` - Company Points

No custom premium currency exists in V1.

## Progression domains
- `player_level`
- `company_level`
- `tool_tier`
- `vehicle_tier`
- `employee_tier`
- `prestige_level`

## Core systems
- `jobs`
- `economy`
- `progression`
- `tools`
- `vehicles`
- `employees`
- `company`
- `coop`
- `monetization`
- `retention`
- `prestige`
- `analytics`
- `security`

## Environment keys
- `development`
- `production`

## Naming rules
- Machine IDs use lowercase snake_case.
- Luau module/type names use PascalCase.
- Remote names use PascalCase intent names and are registered centrally.
- Analytics event names use lowercase snake_case.
- Display strings are never used as persistence keys.
- Roblox numeric asset/product/place IDs never appear outside centralized platform/monetization config unless technically required by Roblox API boundaries.

## Compatibility rule
Changing any persisted identifier after public data exists requires an explicit migration.
