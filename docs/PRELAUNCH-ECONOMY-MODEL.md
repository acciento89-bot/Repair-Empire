# Repair Empire - Prelaunch Economy Model

This is a deterministic configuration model, not live-player telemetry.

## Model inputs
- balance version: `v1-prelaunch-001`
- fastest launch tool timing multiplier: 0.76
- modeled travel allowance for throughput comparison: 45 seconds/job
- offline passive cap: 240 minutes
- maximum workshop employee slots: 6
- conservative passive maximum assumes all six slots use the highest-rate employee definition

## Current modeled outputs
- XP required from level 1 to 100: **344,296 XP**
- total launch tool purchase sink: **$74,000**
- total launch vehicle purchase sink: **$264,500**
- workshop tier upgrade sink: **$166,000**
- hard progression sink subtotal before employee hires: **$504,500**
- conservative maximum passive rate: **$660/min**
- 4-hour conservative offline passive ceiling: **$158,400**
- modeled highest unboosted solo throughput with 45s travel and fastest tool: roughly **$1.69k/min**
- maximum passive rate is therefore roughly **39%** of the modeled high-end active solo rate

## Interpretation
The passive system is bounded and remains below half of modeled high-end active throughput, but the four-hour offline ceiling is economically meaningful. It must be watched during real playtests for employee ROI and whether offline income invalidates vehicle/tool/workshop sinks.

No paid multiplier is included in this comparison. Paid Cash acceleration is separately capped by server entitlement logic.

## Reproducibility
Run:

```sh
lune run scripts/economy-report
```

The CI test `tests/economy-model.spec.luau` fails if key sink totals change without review or if modeled passive throughput crosses the prelaunch guardrails.

## Still requires evidence
Static modeling cannot answer:
- actual travel time
- job abandonment
- time-to-first-upgrade
- district unlock pacing
- real employee purchase mix
- payer/non-payer progression gap
- time-to-Prestige

Those remain P15/P12 playtest and telemetry gates.
