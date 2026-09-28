# Repair Empire - Launch Metrics Checklist

## Purpose
This checklist defines the telemetry views that must be reviewed during private QA and controlled launch. It does not require an external analytics backend; V1 uses Roblox AnalyticsService.

## Activation funnel
Review:
1. session_start
2. tutorial_start
3. first_job_accepted
4. first_job_completed
5. first_upgrade_bought
6. company_system_opened
7. district_2_unlocked
8. first_employee_hired
9. first_coop_job_completed
10. prestige_available
11. first_prestige_completed

Primary questions:
- Where does the largest first-session drop occur?
- Is the first job completed within the 3-minute product target?
- Is the first meaningful upgrade reached in the first session?
- Does any progression gate create an unexpected stall?

## Job health
Review:
- job_accepted
- job_completed
- job_abandoned
- completion/abandon ratio by job definition
- category and district mix
- unusually high completion speed or repeated invalid-request security logs

## Economy
Review Roblox economy events by:
- balance_version
- player_level
- company_level
- source/sink reason
- ending balance

Watch:
- source/sink ratio
- median Cash by level band
- tool/vehicle/workshop/employee sink adoption
- passive-vs-active income share
- time-to-Downtown / time-to-Industrial / time-to-Prestige

## Monetization
Review:
- shop_opened
- gamepass_prompted
- product_prompted
- purchase_granted
- grant failures or repeated NotProcessedYet receipts

Validate:
- conversion only follows explicit user action
- payer/non-payer progression remains viable
- 2x effects never stack above the configured cap
- paid entitlements survive Prestige

## Data safety
Operational logs to watch:
- profile load failures
- session-lock acquisition failures
- save/retry failures
- shutdown save/release failures
- receipt candidate/save failures

Any sustained increase is P0/P1 investigation territory.

## Multiplayer
Review:
- co-op creation/join completion path
- zero-contribution completions
- disconnect/owner-transfer reports
- security anomaly counts around co-op remotes

## Release decision
Do not expand controlled exposure while any of these are unresolved:
- persistent data-loss symptom
- repeatable currency/XP duplication
- purchase duplicate/missing grants
- first-session progression blocker
- broad device/input blocker
- severe server/client performance regression

## Balance attribution
Every deployed economy/progression change must update `BalanceConfig.Version` so before/after telemetry windows can be compared reliably.
