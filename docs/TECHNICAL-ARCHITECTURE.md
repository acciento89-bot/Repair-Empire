# Repair Empire - Technical Architecture

## Platform
Roblox Studio + Luau.

## Architecture style
Server-authoritative domain services with thin clients and shared typed configuration.

## Proposed source layout
```
src/
  client/
    controllers/
    ui/
    input/
    effects/
  server/
    services/
      PlayerDataService
      JobService
      EconomyService
      ProgressionService
      ToolService
      VehicleService
      EmployeeService
      PurchaseService
      AnalyticsService
      SecurityService
    systems/
    datastore/
  shared/
    config/
    types/
    constants/
    remotes/
    util/
assets/
docs/
tests/
```

## Source control workflow
Recommended: Rojo-compatible filesystem project so Luau source and config are reviewable in Git.
Studio-only assets may remain Roblox-managed, but IDs and ownership assumptions must be documented.

## Service boundaries
PlayerDataService: load/save/migrate player profile.
JobService: create, assign, validate and finish jobs.
EconomyService: all Cash/Company Point mutations.
ProgressionService: XP, levels, unlocks, prestige.
ToolService: ownership/equip/tier checks.
VehicleService: ownership/spawn/travel-related state.
EmployeeService: NPC staff and passive jobs.
PurchaseService: Game Pass/Product entitlement and receipt granting.
AnalyticsService: normalized gameplay/economy event emission.
SecurityService: remote rate limits, sanity checks, suspicious-event logging.

## Network boundary
Client may request intent:
- accept job
- start interaction
- complete interaction attempt
- purchase/equip selection
- open UI action

Client may never set:
- Cash amount
- XP amount
- completed job state
- item ownership
- employee ownership
- purchase success
- prestige eligibility

## Shared configuration
All content IDs and balance values stored in immutable-style data modules:
- Jobs
- Tools
- Vehicles
- Employees
- Progression
- Monetization
- Districts

## Persistence
Use DataStoreService for durable player profile.
Version every profile schema.
Migrations must be sequential and testable.
Save strategy:
- on meaningful checkpoints where appropriate
- periodic guarded autosave
- PlayerRemoving
- BindToClose best effort
- retry with backoff
- never block gameplay forever on save failure

## Cross-server
MemoryStore is optional only when needed for transient cross-server coordination. V1 core loop must not require it.

## Testing
Automated tests should cover pure modules and economic rules where practical.
Manual Studio test matrix covers:
- solo
- multi-client
- reconnect
- mobile emulation
- controller
- purchase sandbox
- datastore failure simulations

## Performance
Budgets must be measured, not assumed.
Avoid per-frame server loops for jobs.
Prefer event-driven state.
Pool/reuse high-frequency effects where useful.
Stream world content if map scale requires it.
