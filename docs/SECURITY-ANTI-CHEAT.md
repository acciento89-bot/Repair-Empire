# Repair Empire - Security and Anti-Cheat

## Threat model
Assume the client is fully controlled by an attacker.
Primary targets:
- currency inflation
- XP/level spoofing
- instant job completion
- duplicated purchase rewards
- fake ownership
- teleport/interaction abuse
- remote spam
- passive-income manipulation

## Trust boundary
Only server code may authoritatively mutate value-bearing state.

## Remote validation
For every RemoteEvent/RemoteFunction:
- validate type
- validate allowed enum/id
- validate player state
- validate ownership
- validate spatial plausibility where relevant
- validate sequence/state machine
- rate limit
- reject impossible/replayed transitions

## Job security
Server creates job instance ID.
Server tracks stage state.
Client requests interaction.
Server validates target, stage and timing.
Reward is calculated only from server config and server state.
Completion token/instance cannot be reused.

## Economy security
All grants and spends go through EconomyService.
Never directly mutate balances from UI handlers.
Transactions validate sufficient funds and allowed purchase state.

## Purchase security
Use Roblox purchase APIs.
Developer Product receipts are idempotent.
Game Pass entitlement checked server-side when value depends on it.
Never grant based solely on client purchase-finished events.

## Movement
Do not build aggressive anti-cheat that punishes latency.
For interaction validation, check generous distance and state thresholds.
Log repeated impossible actions before punitive action.

## Rate limiting
Per-player/per-action token bucket or window limits for high-risk remotes.
Limits should be config-driven and observable.

## Logging
Record security-relevant anomalies:
- invalid remote payload
- impossible job transition
- repeated too-fast interactions
- negative/overflow attempts
- duplicate receipt attempt

Do not log sensitive information unnecessarily.

## Response policy
V1 prioritizes reject + log.
Automatic kicks only for high-confidence repeated abuse.
Permanent bans require an explicit later operational design.

## Security acceptance
Before public release run exploit-oriented multi-client tests and manually attempt direct remote abuse from a test client.
