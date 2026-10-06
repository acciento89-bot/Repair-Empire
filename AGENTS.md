# AGENTS.md

## Product
Repair Empire is a native iOS/Android Unity service-business simulator.

## Execution
- Read README -> MASTER-PLAN -> ART-DIRECTION -> V1 LEDGER before implementation.
- Ledger is canonical.
- Portrait mobile first, touch-first, safe-area aware, 60 FPS target.
- Driving must remain responsive and unobstructed on the authored road network.
- Tablet information must meet contrast/readability standards before features are marked complete.
- Do not add legacy platform/runtime files, Lua/Luau, Rojo or place files.
- Data-driven jobs, tools, vehicles and upgrades.
- Commit coherent verified slices to main.

## Quality
- No dark-on-dark unreadable job rows.
- Driving input stays available after spawn and job changes.
- Tablet pauses driving input while open.
- Touch targets are at least 48 logical points.
- DE/EN required before release.
