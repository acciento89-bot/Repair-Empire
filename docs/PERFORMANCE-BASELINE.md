# Repair Empire - Studio World Performance Baseline

Measured in **Repair Empire Dev** after the self-contained procedural world art pass.

## Environment
- Universe ID: `10768475286`
- Development Place ID: `138882349802835`
- Studio mode: server-only `Run`
- `Workspace.StreamingEnabled = true`
- Measurement source: Studio-only `WorldService` baseline hook
- CI baseline at time of measurement: GitHub Actions run #330 green

## Measured world footprint
- BaseParts in `RepairEmpireWorld`: **572**
- Total descendants in `RepairEmpireWorld`: **614**

This includes:
- three districts
- roads and connector roads
- sidewalks and lane markings
- street lighting
- procedural buildings and facade detail
- workshop
- trees and district dressing
- job anchors
- industrial detail

## Studio runtime baseline
120 server Heartbeats:
- average Heartbeat: **22.14 ms**
- approximate server-loop frequency: **45.2 Hz**

Studio-reported total memory:
- **3734.3 MB**

Important: that memory value includes Roblox Studio/editor/plugin overhead and is **not** a production client or dedicated-server memory figure.

## Two-client Studio client baseline

A Studio-only client probe now samples 120 `RenderStepped` frame intervals and records average frame time, p95 frame time, approximate FPS and Studio-reported memory.

Measured while the editor, one local server and **two simulated clients** were running simultaneously on the development Mac:

| Client | Average frame | P95 frame | Approx. FPS | Studio memory |
| --- | ---: | ---: | ---: | ---: |
| Player1 | 75.82 ms | 117.03 ms | 13.2 | 2428.5 MB |
| Player2 | 27.75 ms | 58.57 ms | 36.0 | 2568.1 MB |

The large variance is expected for local multi-client Studio emulation on one development machine. These figures are useful as a **regression baseline**, not as production device performance targets.

The same run kept `StreamingEnabled = true`; the server baseline was 572 parts / 614 descendants and remained running while both clients initialized successfully.

## Interpretation
The generated world is small enough to remain practical for continued V1 testing and StreamingEnabled is active. The server-only Studio run completed without Repair Empire runtime errors.

This does **not** complete P08-T06. Before public release, still measure:
- production-device client FPS/frame time
- production-device client memory
- server frame time under players
- network send/receive
- streaming behavior while traveling
- at least small-phone and desktop runtime behavior
- multi-player load

## Regression use
The Studio-only baseline hook intentionally runs only when `RunService:IsStudio()` is true. Future world-art changes can be compared against these counts and heartbeat values without adding production telemetry noise.
