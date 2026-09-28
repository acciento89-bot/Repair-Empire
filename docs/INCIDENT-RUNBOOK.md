# Repair Empire - Incident Runbook

## Severity
### P0
Data loss, broad economy exploit, duplicated paid grants, experience unusable for most players.

### P1
Blocked progression, widespread job failure, purchase grants delayed for many users, severe performance regression.

### P2
Localized gameplay defect, balance issue, device-specific UX problem.

### P3
Cosmetic/content polish defect.

## Incident record
Capture:
- detected timestamp
- severity
- affected version/commit
- balance version
- symptoms
- reproduction
- mitigation
- user impact
- permanent fix
- prevention/follow-up

## Response
P0/P1:
- freeze unrelated releases
- mitigate first
- preserve evidence
- rollback if safer than hotfix
- validate data and purchase safety before reopening exposure

P2/P3:
- schedule into normal patch/content cadence unless impact expands.

## Post-incident
Every P0/P1 gets a short root-cause note and at least one concrete prevention action.
