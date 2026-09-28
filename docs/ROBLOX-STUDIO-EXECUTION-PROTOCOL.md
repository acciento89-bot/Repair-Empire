# Repair Empire - Roblox Studio Execution Protocol

Use this after the real Roblox experience/place IDs are configured. It is ordered so destructive or purchase-related checks happen only after basic data safety is proven.

## A. Development place setup
1. Open the development/test place in Roblox Studio.
2. Sync/build the repository through Rojo.
3. Confirm `Workspace.StreamingEnabled = true`.
4. Confirm server boot prints the Repair Empire initialization message without service dependency errors.
5. Keep the production experience private while this protocol is incomplete.

Expected result: world, workshop, three districts, remotes, client HUD/menu and server services initialize without errors.

## B. Fresh-profile smoke test
Use a test account with no Repair Empire data.

Verify:
1. Spawn at the Residential workshop.
2. HUD shows Cash, Level/XP, Company Level, Skill Points, equipped tool and next district.
3. Tutorial starts at the first plumbing job.
4. Jobs screen offers the first playable jobs.
5. Complete Leaking Faucet.
6. Player reaches Level 2 and has enough Cash for Basic Screwdriver.
7. Buy Basic Screwdriver.
8. Tutorial directs to Running Toilet.
9. Complete Running Toilet.
10. Open Workshop and finish the onboarding sequence.

Expected result: no Robux purchase is required, no progression dead-end occurs, and the first objective is understandable without external instructions.

## C. Save/rejoin and session-lock test
1. Change persistent state: earn Cash/XP, buy a tool and vehicle, hire an employee.
2. Leave normally and rejoin.
3. Confirm exact state returns.
4. Start a second Studio/client session against the same account/profile while the first session is active.

Expected result:
- normal rejoin restores persistent state;
- a second active writer cannot acquire the same live session lock;
- the existing profile is never replaced by defaults.

## D. Migration/recovery test
Use copied/test data only.

1. Load a schema-v1 fixture/profile.
2. Confirm migration reaches current schema and preserves existing balances/progression.
3. Simulate an expired lock and confirm it is recoverable.
4. Simulate a foreign non-expired lock and confirm overwrite is refused.
5. Simulate DataStore failure/retry behavior.

Expected result: migration is additive and recovery never silently discards player value.

## E. Solo gameplay matrix
For representative jobs in each category/district:
- Plumbing
- Heating
- Climate
- Energy
- Residential
- Downtown
- Industrial

Verify:
1. eligibility gates;
2. tool-tier gates;
3. weighted offers;
4. repeat cooldown;
5. navigation marker;
6. spatial validation;
7. stage order;
8. minimum stage timing;
9. final Cash/XP/Company Points;
10. no duplicate completion reward.

Expected result: client cannot invent value or complete remotely.

## F. Tool, skill, vehicle and company progression
Verify:
- 20 tools / 9 tool families;
- category Skill Tree ranks and skill-point spending;
- speed/Cash/XP bonuses affect only server-calculated outcomes;
- 8 owned/selectable vehicle variants;
- vehicle driving/owner restriction;
- 12 employees / five worker tiers;
- workshop tier gates and employee slots;
- passive income and 4-hour offline cap;
- Prestige reset/retained state.

## G. Multi-client co-op
Start 2 clients first, then repeat with up to 6.

Verify:
- create/discover/join/leave;
- party capacity;
- stage synchronization;
- tool/eligibility validation for joiners;
- contribution tracking;
- zero-contribution no-reward case;
- reward split;
- host disconnect and owner transfer;
- participant disconnect;
- simultaneous action requests;
- final completion cannot be replayed.

Expected result: no client can award another player or force-spend resources.

## H. Device/input QA
Use Roblox device emulation and, where available, real devices.

### Small phone
Verify:
- menu fits safe viewport;
- default thumbstick/jump areas remain unobstructed;
- repair/instant-finish controls remain reachable;
- text is readable.

### Tablet
Verify panel sizing and scrolling.

### Desktop
Verify mouse/keyboard, M menu toggle and E interaction.

### Controller
Verify:
- ButtonStart menu;
- selectable UI navigation;
- ButtonX repair action;
- close/back behavior.

## I. Performance/streaming
Profile at least:
- empty server;
- one player driving across all districts;
- six-player server;
- active co-op contract.

Record:
- client FPS/frame time;
- server frame time;
- memory;
- network receive/send;
- streaming behavior while traveling between districts.

Any severe regression blocks public exposure.

## J. Security abuse pass
Execute `docs/SECURITY-TEST-MATRIX.md`.

Focus on:
- rapid remote spam;
- invalid IDs/payloads;
- too-fast actions;
- out-of-range actions;
- stale job instance replay;
- simultaneous purchases;
- economy mutation attempts;
- co-op membership spoofing.

Expected result: reject/log without duplicated persistent value.

## K. Marketplace sandbox
Only after real Game Pass/Product IDs are configured.

For every launch pass:
- buy/own entitlement;
- rejoin;
- confirm exact effect;
- confirm free path remains complete.

For every Developer Product:
- purchase once;
- verify grant;
- replay/retry receipt;
- reconnect during processing;
- verify no duplicate grant.

Specific checks:
- Double Cash/boost never stack above 2x;
- Extra Employee Slot adds exactly one slot;
- Extra Vehicle Slot permits exactly two concurrent spawns;
- VIP is cosmetic;
- Premium Workshop is cosmetic;
- paid state survives Prestige as designed.

## L. Release candidate gate
Before public exposure all of these must be true:
- CI green;
- save/rejoin/migration/lock checks pass;
- solo matrix passes;
- co-op matrix passes;
- device/input QA passes;
- Marketplace sandbox passes;
- security runtime tests pass;
- performance acceptable;
- icon/thumbnails/content questionnaire complete;
- production IDs match configuration.

Then follow the controlled-launch and monitoring runbooks.
