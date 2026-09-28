# Repair Empire - Analytics and Balancing

## Purpose
Analytics exists to answer product/balance questions, not to collect data without a decision use-case.

## Core funnel
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

## Job events
job_offered
job_accepted
job_stage_completed
job_abandoned
job_completed

Properties:
job_id, category, district, player_level_band, duration_bucket, party_size.

## Economy events
currency_earned
currency_spent
upgrade_purchased
tool_purchased
vehicle_purchased
employee_hired
prestige_spend

Properties must identify source/sink category and configured balance version.

## Monetization events
shop_opened
product_prompted
gamepass_prompted
purchase_granted

Never treat a client event as proof of payment.

## Metrics
Acquisition/activation:
- first job completion
- first upgrade completion

Engagement:
- session length
- jobs/session
- sessions/player
- co-op participation

Retention:
- D1/D7/D30 when platform analytics supports measurement

Economy:
- cash earned/spent per level band
- median balances
- upgrade pacing
- passive/active income split

Monetization:
- conversion
- ARPPU
- ARPDAU
- product/pass mix

## Balance version
Every server session exposes a balance/config version so metric changes can be attributed to a release.

## Privacy/data minimization
Use Roblox/platform identifiers only as technically necessary. No external PII collection is required for V1.
