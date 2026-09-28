# P02 - Player Foundation

## Goal
Reliable player lifecycle, durable profile schema and responsive base UI.

### P02-T01 Versioned player profile schema
Fields include schema version, level/XP, Cash, Company Points, unlocks, owned tools/vehicles/employees, skill state, tutorial state, achievements, prestige and stats.
Acceptance: defaults are centralized and serializable.

### P02-T02 Load/save/session lifecycle
Implement guarded loading, autosave strategy, PlayerRemoving and shutdown handling.
Acceptance: rejoin preserves state; load failure cannot silently overwrite good data.

### P02-T03 Schema migration harness
Sequential migrations from N -> N+1.
Acceptance: old fixture profiles migrate to current schema deterministically.

### P02-T04 Base HUD and responsive input shell
Cash, level/XP, active-objective region, interaction region.
Acceptance: usable on small phone, tablet, desktop; controller focus path exists.

### P02-T05 Onboarding state foundation
Track tutorial steps server-authoritatively where progression value is involved.
Acceptance: tutorial resumes safely after reconnect.

## Tests
- new player
- returning player
- migration fixture
- simulated save failure
- mobile emulator
- controller navigation smoke test

## Definition of Done
P03 can rely on a stable loaded player profile and HUD shell.
