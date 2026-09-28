# P10 - Monetization

## Goal
Implement explicit, safe Roblox-native monetization around an already complete free loop.

### P10-T01 Monetization config/catalog IDs
Product/pass definitions live in config with environment-safe IDs.

### P10-T02 Game Pass entitlement service
Server resolves entitlements before applying economic/gameplay benefits.

### P10-T03 Developer Product receipt handler
One server-side receipt grant path maps product ID -> deterministic grant handler.

### P10-T04 Idempotency protection
Duplicate/retried receipts cannot duplicate grants; uncertain grants are handled safely.

### P10-T05 Shop UI
Clear product description, price surfaced through Roblox APIs where applicable, explicit user action.

### P10-T06 Sandbox verification
Test each pass/product, reconnect around purchase, duplicate receipt scenario and failed/aborted prompts.

## Launch hypotheses
Use ECONOMY-MONETIZATION.md. Prices remain configurable hypotheses until tested.

## Guardrails
No lootboxes, no tutorial paywall, no required energy purchase, no fake scarcity.

## Definition of Done
Every configured purchase either grants exactly once or safely remains unresolved for retry.
