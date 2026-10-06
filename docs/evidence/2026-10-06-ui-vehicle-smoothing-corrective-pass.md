# UI palette + vehicle smoothing corrective pass — 2026-10-06

## Scope

This pass addresses the player-reported Repair Empire regressions:

- menu/button presentation had been flattened into an overly orange global style;
- driving looked continuously choppy despite acceptable client FPS.

## Canonical source

- Functional corrective commit: `60c569f` — `fix: preserve UI palette and smooth vehicle driving`.
- Build-revision commit: `04cbe60` — `chore: record UI vehicle smoothing build revision`.
- Canonical branch: `main`.
- Build marker: `Workspace.RepairEmpireBuildRevision = "2026-10-06-ui-vehicle-smoothing"`.

## UI correction

`VisualPolishController` no longer repaints every generic `TextButton` with one accent color. Authored semantic button colors are preserved and only receive restrained polish treatment.

Runtime palette probe:

- visible buttons sampled: 20;
- unique button-color families: 5;
- largest single-color share: 0.650;
- result: `UI pass=true`.

## Vehicle correction

The old live driving path moved a multi-part anchored model server-side with `Model:PivotTo()` on Heartbeat and performed an overlap-box sweep while moving. That produces discrete transform replication and visible stutter.

The corrected vehicle:

- is one welded physical assembly;
- uses an explicit invisible `DriveCollision` hull;
- has unanchored physical parts with massless visual children;
- remains server authoritative via `SetNetworkOwner(nil)`;
- uses `AlignOrientation` for steering;
- uses `AssemblyLinearVelocity` for travel instead of live `PivotTo` teleporting.

Runtime smoothing probe:

- `physical=true`;
- distance during measured drive: 12.21 studs;
- measured frames: 177;
- measured client rate: 58.5 FPS;
- zero-motion frame ratio: 0.192;
- average per-frame travel: 0.0693 studs;
- maximum per-frame travel: 0.3058 studs;
- result: `DRIVE pass=true`.

Combined targeted runtime result:

`[RepairRuntimeProbe] RESULT pass=true uiPass=true drivePass=true`.

The existing broad Studio journey probe separately stopped at its pre-existing avatar-visible-body-count assertion before its normal vehicle phase. The targeted corrective probe intentionally does not reinterpret that unrelated assertion as evidence for or against UI/vehicle smoothing; it uses the existing server E2E seat fixture and validates the repaired paths directly.

## Static verification

Fresh canonical-source verification passed:

- StyLua check: pass;
- Selene: 0 errors / 0 warnings / 0 parse errors;
- pure Luau tests: 53 passed;
- Rojo build: pass;
- release-readiness: sandbox-ready, no configuration blockers.

Regression tests include:

- `tests/ui-button-color-preservation.spec.luau`;
- `tests/vehicle-physics-smoothing.spec.luau`.

## Production sync and publish

- Existing Universe: `10768475286`.
- Existing production Place: `79925227687072`.
- No new Place/Experience was created.
- Rojo sync confirmation for project `RepairEmpire` was explicitly accepted in the existing production Place.
- Direct cloud DataModel parity probe before publish:
  - `preserve=true`;
  - `orangeOverride=false`;
  - `physical=true`;
  - `velocity=true`;
  - revision `2026-10-06-ui-vehicle-smoothing`.
- Studio publish state reached `PublishSuccessful`.
- Studio reported `Place published. Eligible players can now play this place in Roblox.`.
- Studio publish notes target: `v39`.
- Studio reported `Published new changes in "Reparatur-Imperium " to Roblox.`.

## Independent no-Rojo reopen

After stopping the Rojo server, the production Place was opened again from Roblox. The Rojo plugin logged connection failures to `localhost:34872`, confirming the verification was not being supplied by local source.

The fresh cloud DataModel still reported:

- `preserve=true`;
- `orangeOverride=false`;
- `physical=true`;
- `velocity=true`;
- revision `2026-10-06-ui-vehicle-smoothing`.

The Team Create edit context reports `game.PlaceVersion=38` because that collaborative edit session retains its base-place version metadata. This is not used as the publish-version authority; the publish state machine and Creator Output explicitly identify the successful new publish as `v39`.
