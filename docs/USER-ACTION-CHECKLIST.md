# Repair Empire - User Action Checklist

This file contains only actions that require the owner rather than repository/runtime implementation.

## Completed — no owner action required

The following release preparation is already complete:
- Roblox experience ownership, Universe and production/development place IDs
- isolated development DataStore configuration
- five live Game Pass IDs and launch prices
- six live Developer Product IDs and launch prices
- solo and multi-client Studio QA
- profile migration/session/recovery QA
- job/tool/vehicle/company progression QA
- reconnect/host-transfer and abuse/race/spatial checks
- StreamingEnabled/performance baselines
- compact phone, iPhone XR, iPad, desktop and controller/input QA
- experience icon, three landscape thumbnails, description review and 17-section content questionnaire
- P19 Production Art & World Quality gate and persisted visual evidence
- final private development-place build published successfully to Roblox as **v70**

See `docs/REPAIR-EMPIRE-V1-LEDGER.md`, `docs/EXTERNAL-ROBLOX-BLOCKERS.md` and `docs/evidence/p19/README.md` for evidence.

## Remaining owner action — REAL ROBUX PURCHASE

A single successful Developer Product receipt/rejoin path still needs live MarketplaceService evidence.

This requires an owner-approved transaction because Roblox's current test flow charges real Robux. Do not initiate it automatically.

Configured products:
- `instant_job_finish` — Product ID `3715318304` — **29 R$**
- `boost_15` — Product ID `3715318201` — 39 R$
- `small_cash` — Product ID `3715317811` — 49 R$
- `boost_60` — Product ID `3715318256` — 99 R$
- `medium_cash` — Product ID `3715317874` — 149 R$
- `large_cash` — Product ID `3715318066` — 399 R$

The lowest-cost live proof is `instant_job_finish` at 29 R$, but the owner must explicitly approve whichever real purchase is used.

After that approved purchase:
1. verify the receipt grant once;
2. force/reproduce receipt retry or rejoin processing;
3. verify no duplicate value/analytics grant;
4. confirm the paid state survives reconnect and remains consistent with Prestige rules;
5. mark P10-T06 and P16-T03 complete;
6. update/copy the final build to the production place and perform controlled public exposure.

## Post-launch

P17 telemetry review and the first evidence-based balance patch intentionally wait for real-player data. They are not unfinished pre-launch implementation.
