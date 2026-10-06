# Repair Empire V1 Master Plan

## Objective
Ship a polished native mobile repair-company simulator whose first minute supports accept job -> drive -> arrive -> repair -> reward.

## P00 Product lock
Core loop, job categories, city scope, upgrade economy, monetization boundaries and visual identity.

## P01 Unity mobile foundation
Project structure, identifiers, portrait, safe area, 60 FPS target and build setup.

## P02 Vehicle
Responsive touch driving, road collision, chase camera, reset/recovery and vehicle catalog foundation.

## P03 City/navigation
Compact district, road network, repair shop, customer destinations, route guidance and map abstraction.

## P04 Job engine
Data-driven service calls, selection, navigation, arrival, repair interactions, rewards and difficulty.

## P05 Tablet
Jobs, Tools, Vehicles, Workshop, Employees and Daily Jobs with readable mobile hierarchy.

## P06 Economy/progression
Cash, XP/levels, tool tiers, vehicle upgrades, workshop growth, employees and versioned profile.

## P07 Repair interactions
Tap/hold/sequence minigames for plumbing, heating, climate and electrical/energy work.

## P08 Game feel
Vehicle audio, repair audio, VFX, haptics, camera polish and transition feedback.

## P09 Retention
Daily jobs, login rewards, achievements and company goals.

## P10 Monetization
Optional cosmetics/convenience, StoreKit/Google Play Billing and receipt restore/retry.

## P11 Production art
Final van, workshop, city kit, customer locations, tool/repair assets, lighting and UI assets.

## P12 QA/release
Device matrix, vehicle stability, save/billing tests, performance/thermal, store assets/privacy and rollout.

## Definition of Done
- Vehicle never becomes trapped by the default city route.
- Controls respond immediately.
- Job/tablet text remains readable on compact phones.
- Core loop can be completed repeatedly without state corruption.
- 60 FPS target on supported reference devices.
- iOS/Android store validation passes.
