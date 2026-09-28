# P14 - Security Hardening

## Goal
Audit the complete value-bearing surface after feature implementation.

### P14-T01 Remote inventory/audit
List every remote, caller, payload, server checks and rate limit requirement.

### P14-T02 Rate limits
Implement/configure per-action limits for high-risk remotes.

### P14-T03 Spatial/state validation
Audit all interactions for state order, target ownership and generous but meaningful distance checks.

### P14-T04 Economy exploit tests
Attempt arbitrary grants, negative spends, repeated purchase calls, stale job completion and race conditions.

### P14-T05 Purchase exploit tests
Attempt client spoof, duplicate receipt path and entitlement mismatch.

### P14-T06 Security logging
Normalized anomaly events with thresholds for reject/log/kick policy.

## Policy
Prefer reject + log over false-positive punishment.
Kick only high-confidence repeated abuse in V1.

## Definition of Done
No known client-controlled path can directly mint persistent value or mark paid entitlement.
