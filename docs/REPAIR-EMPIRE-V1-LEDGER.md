# Repair Empire V1 Ledger

Status legend: [ ] open, [~] in progress, [x] verified complete, [!] blocked.

Planning baseline is complete. Implementation is intentionally not started.

## P00 Product Definition
- [ ] P00-T01 Initialize standalone implementation repository and project metadata
- [ ] P00-T02 Confirm Roblox experience ownership/naming/place structure
- [ ] P00-T03 Freeze V1 config identifiers and terminology

## P01 Technical Foundation
- [ ] P01-T01 Initialize Rojo/Luau source layout
- [ ] P01-T02 Add shared config/type/constants foundation
- [ ] P01-T03 Add remotes registry and validation conventions
- [ ] P01-T04 Add server service bootstrap/lifecycle
- [ ] P01-T05 Add test/lint/static-check workflow

## P02 Player Foundation
- [ ] P02-T01 Define versioned player profile schema
- [ ] P02-T02 Implement load/save/session lifecycle
- [ ] P02-T03 Implement schema migration harness
- [ ] P02-T04 Implement base HUD and responsive input shell
- [ ] P02-T05 Implement onboarding state foundation

## P03 Job Engine
- [ ] P03-T01 Define job data schema and registry
- [ ] P03-T02 Implement server job offer generation
- [ ] P03-T03 Implement accept/abandon lifecycle
- [ ] P03-T04 Implement staged interaction state machine
- [ ] P03-T05 Implement completion/reward transaction
- [ ] P03-T06 Implement reconnect/duplicate-completion protection
- [ ] P03-T07 Add first 5 vertical-slice jobs
- [ ] P03-T08 Job engine verification pass

## P04 Economy & Progression
- [ ] P04-T01 Central EconomyService
- [ ] P04-T02 XP and player levels
- [ ] P04-T03 district/job unlock rules
- [ ] P04-T04 Company Points and company levels
- [ ] P04-T05 source/sink telemetry hooks

## P05 Tools
- [ ] P05-T01 Tool definitions and ownership
- [ ] P05-T02 Equip flow
- [ ] P05-T03 Tier requirements and modifiers
- [ ] P05-T04 Tool shop UI
- [ ] P05-T05 Launch tool catalog

## P06 Vehicles
- [ ] P06-T01 Vehicle definitions/ownership
- [ ] P06-T02 Spawn/despawn rules
- [ ] P06-T03 Vehicle shop/garage
- [ ] P06-T04 Travel integration
- [ ] P06-T05 Launch vehicle catalog

## P07 Company Tycoon
- [ ] P07-T01 Workshop/company progression
- [ ] P07-T02 Employee definitions/hiring
- [ ] P07-T03 Passive job simulation
- [ ] P07-T04 Employee slots/upgrades
- [ ] P07-T05 Passive economy balancing guardrails

## P08 World
- [ ] P08-T01 Residential district
- [ ] P08-T02 Downtown district
- [ ] P08-T03 Industrial district
- [ ] P08-T04 Job anchor/building system
- [ ] P08-T05 Navigation markers
- [ ] P08-T06 Performance/streaming pass

## P09 Multiplayer & Co-op
- [ ] P09-T01 Co-op contract state model
- [ ] P09-T02 Contribution tracking
- [ ] P09-T03 Reward split/validation
- [ ] P09-T04 Four launch large contracts
- [ ] P09-T05 Multi-client abuse/reconnect tests

## P10 Monetization
- [ ] P10-T01 Monetization config and catalog IDs
- [ ] P10-T02 Game Pass entitlement service
- [ ] P10-T03 Developer Product receipt handler
- [ ] P10-T04 Idempotency/duplicate receipt protection
- [ ] P10-T05 Shop UI and explicit purchase flow
- [ ] P10-T06 Sandbox verification

## P11 Retention
- [ ] P11-T01 Daily jobs
- [ ] P11-T02 Daily login reward
- [ ] P11-T03 Achievement framework
- [ ] P11-T04 Launch achievements
- [ ] P11-T05 Rotating contract hooks

## P12 Prestige & Endgame
- [ ] P12-T01 Prestige eligibility
- [ ] P12-T02 Reset transaction
- [ ] P12-T03 Permanent meta bonuses
- [ ] P12-T04 Prestige UI
- [ ] P12-T05 Endgame pacing verification

## P13 UI/UX Polish
- [ ] P13-T01 Small-phone layouts
- [ ] P13-T02 Tablet/desktop layouts
- [ ] P13-T03 Controller navigation
- [ ] P13-T04 Accessibility pass
- [ ] P13-T05 Feedback/audio/effects polish

## P14 Security Hardening
- [ ] P14-T01 Remote inventory/audit
- [ ] P14-T02 Rate limits
- [ ] P14-T03 Spatial/state validation audit
- [ ] P14-T04 Economy exploit tests
- [ ] P14-T05 Purchase exploit tests
- [ ] P14-T06 Security logging

## P15 Analytics & Balancing
- [ ] P15-T01 Analytics event schema
- [ ] P15-T02 Funnel events
- [ ] P15-T03 Economy events
- [ ] P15-T04 Monetization events
- [ ] P15-T05 Balance versioning
- [ ] P15-T06 Full launch economy pass

## P16 Release
- [ ] P16-T01 Full QA matrix
- [ ] P16-T02 Data migration/recovery test
- [ ] P16-T03 Purchase release checklist
- [ ] P16-T04 Store metadata/assets checklist
- [ ] P16-T05 Controlled public launch
- [ ] P16-T06 Launch monitoring/rollback readiness

## P17 Post-launch
- [ ] P17-T01 Incident process
- [ ] P17-T02 First telemetry review
- [ ] P17-T03 First balance patch
- [ ] P17-T04 Content cadence
- [ ] P17-T05 Backlog prioritization from evidence
