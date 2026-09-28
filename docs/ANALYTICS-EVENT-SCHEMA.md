# Analytics Event Schema

Balance version: sourced at runtime from `BalanceConfig.Version`.

## Funnel/custom events
- session_start
- tutorial_start
- first_job_accepted
- first_job_completed
- first_upgrade_bought
- district_2_unlocked
- company_system_opened
- first_employee_hired
- first_coop_job_completed
- prestige_available
- prestige_completed
- job_accepted
- job_completed
- job_abandoned
- purchase_granted

## Economy
Every Cash/Company Points source or sink flows through EconomyService and is emitted through Roblox AnalyticsService `LogEconomyEvent`.

Transaction type is the normalized server reason, never a client-provided string.

## Privacy/cardinality
- No external PII.
- No raw free-form client data.
- No receipt IDs in analytics.
- No high-cardinality GUIDs as event names/custom fields.
- Player association is handled by Roblox AnalyticsService.

## Balance attribution
Every deployed balance change increments `BalanceConfig.Version` so telemetry windows can be mapped to a known configuration.
