# Repair Empire - Rollback Runbook

## P0 triggers
- Persistent data loss or profile overwrite.
- Repeatable currency/XP duplication.
- Developer Product duplicate grants or widespread missing grants.
- Progression-blocking migration failure affecting broad population.

## Immediate actions
1. Stop expanding release exposure.
2. Disable or revert the offending config/code path.
3. Preserve logs and affected balance/schema version.
4. Do not deploy a destructive migration as an emergency guess.
5. If purchases are affected, prefer safe retry/defer over duplicate compensation logic.

## Configuration rollback
Balance and content changes should be reverted by restoring the previous config commit/version.

## Code rollback
Revert to the last known-good Git commit and rebuild/publish only after CI plus targeted regression checks.

## Data migration rollback
- Every schema migration must be sequential.
- Never decrement `SchemaVersion` without an explicit reverse migration.
- If recovery requires reconciliation, preserve original records rather than replacing them with defaults.

## Verification after rollback
- New profile load.
- Existing profile load.
- One full solo job.
- Economy source/sink.
- Save/rejoin.
- Purchase path if relevant.
