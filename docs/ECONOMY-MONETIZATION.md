# Repair Empire - Economy and Monetization

## Economy goals
- Player receives a meaningful upgrade opportunity early.
- Higher tiers expand choices rather than only inflate numbers.
- Free progression remains complete.
- Values are fully configuration-driven.
- Economy can be rebalanced without engine rewrites.

## Currencies
### Cash
Primary soft currency. Earned from jobs and passive company systems.
Uses: tools, vehicles, employee upgrades, workshop progression.

### Company Points
Long-term progression currency.
Earned from company milestones, larger contracts and selected achievements.
Uses: company-tier unlocks and selected meta upgrades.

No premium custom currency in V1. Robux purchases map to explicit products/passes.

## Launch Game Pass hypotheses
- 2x Cash - 299 R$
- VIP - 399 R$
- Extra Employee Slot - 149 R$
- Extra Vehicle Slot - 149 R$
- Premium Workshop cosmetics/convenience - 249 R$

Prices are test hypotheses, not immutable promises.

## Developer Product hypotheses
- Small Cash Pack - 49 R$
- Medium Cash Pack - 149 R$
- Large Cash Pack - 399 R$
- 15 min 2x boost - 39 R$
- 60 min 2x boost - 99 R$
- Instant job finish - 29 R$ where allowed by design

## Monetization rules
- Never gate the main city behind payment.
- Never require payment to finish tutorial.
- No randomized paid rewards in V1.
- No fake discounts or fake timers.
- Purchase prompts occur only from explicit player action except a very limited contextual upsell design approved later.
- Paid boosts cannot break server validation.
- Receipts must be processed idempotently.

## Balance framework
Track:
- source/sink ratio
- median cash balance by level band
- time-to-first-upgrade
- time-to-district-unlock
- tool upgrade adoption
- employee ROI
- prestige time
- conversion rate
- ARPPU
- ARPDAU
- payer vs non-payer progression gaps

## Example reward model
BaseReward * districtMultiplier * jobDifficultyMultiplier * serverValidatedBoosts.
Client never supplies multiplier values.

## Anti-inflation controls
- escalating upgrade costs
- meaningful sinks at each progression band
- passive income caps/efficiency curves
- no uncapped offline income in V1
- reward tables versioned for analysis

## Purchase safety
Developer Product receipt grant uses a durable/idempotent receipt record or equivalent safe grant pattern. If a receipt result is uncertain, do not duplicate grant.
