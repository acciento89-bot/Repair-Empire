# P01 - Technical Foundation

## Goal
Create a maintainable Luau project skeleton with explicit server/client/shared boundaries.

### P01-T01 Initialize Rojo/Luau source layout
Create src/client, src/server, src/shared and Roblox project mapping.
Acceptance: sync/build succeeds and minimal place boots.

### P01-T02 Shared config/type/constants foundation
Add typed IDs/config structures for jobs, districts, currencies and tunables.
Acceptance: no core subsystem needs raw magic strings for domain IDs.

### P01-T03 Remotes registry and validation conventions
Centralize RemoteEvent/RemoteFunction creation/lookup.
Document payload-validation and naming rules.
Acceptance: no ad-hoc remote creation in feature modules.

### P01-T04 Server service bootstrap/lifecycle
Create deterministic service initialization with dependency ordering and failure logging.
Acceptance: service boot is repeatable in Studio server tests.

### P01-T05 Test/lint/static-check workflow
Add formatter/linter/type/static checks and a unit-test path appropriate to chosen toolchain.
Acceptance: one command/workflow runs all configured checks.

## Architecture constraints
- client never owns economy truth
- shared modules contain no server secrets/value-grant authority
- configuration is data, not UI logic

## Verification
Fresh checkout -> install/tool bootstrap -> build/sync -> start test server -> run checks.

## Definition of Done
Foundation boots cleanly and P02 can add player state without restructuring.
