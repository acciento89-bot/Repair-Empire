# Repair Environment Finish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans. User explicitly authorizes autonomous inline implementation until16October05:30Europe/Berlin; no additional design-approval pause or production delegation.

**Goal:** Replace the visible smooth tree cores and flat glazing in actual Repair gameplay with original textured foliage and bounded real street reflections.

**Architecture:** Extend UrbanArtKit's existing owned materials/meshes and use one district-owned custom ReflectionProbe/cubemap capture. Keep live gameplay, city authority and isolated fixture studio unchanged. One shared imported512px canopy texture supplements the existing original alpha sprig.

**Tech Stack:** Unity6000.6.4f1, Built-in Standard/Lambert, C#, native Metal/uGUI, existing ArtLifetime ownership.

**Spec:** docs/ART-DIRECTION.md; docs/CONCEPT-SPEC.md; approved external repair-empire-3-ansichten.png; latest actual native evidence docs/QA/repair-street-rebuild-20261015.json.

## Global Constraints

- Repair only; approved PerfectDrop/RisingSteps and OMF submission remain untouched.
- Existing54city collision fields and deterministic height RNG remain exact relative to compact-street04f7a0d, all24halting volumes clear.
- No new controller/save/job/commerce/version/scene/package/ProjectSettings mutation.
- Shared imported textures survive district destruction; generated meshes/materials/cubemap/camera must be disposed by their owner.
- No per-frame reflection capture, extra main camera, global environment mutation, UI/studio capture or renderer state leak.
- Native Metal screenshots are actual evidence. Whole graphical release remains failed/icon pending until actual Concept review supports otherwise;90percent is a target.

## Review Focus

- Imported texture misconfiguration or absent native shader variant must fail before acceptance.
- Crown detail must not become brighter balls, sparse cards or unreasonable overdraw/geometry; inspect actual native view and count/bound buffers.
- Cube rendering must restore target/renderer states and leave no enabled capture camera; prove native actual capture, not a flag-only claim.
- City probe must not override van's higher-priority owned reflection or studio layer30 probe.
- Repeated district build/destruction must preserve shared assets and restore global render/RNG state.

---

### Task1: Original foliage surface and denser authored canopy

**Files:** Create Assets/Resources/Art/StreetCanopy-v1.png(+meta), Assets/Editor/RepairEnvironmentFinishValidation.cs(+meta); modify Assets/Scripts/Visuals/DistrictArtGeometry.cs, optionally existing Foliage.shader if real renders require it.

**Interfaces:** Existing UrbanArtKit.Tree/Shrub and owned LeafMass/goldenCrown/Leaves remain. Shared Resources.Load<Texture2D>("Art/StreetCanopy-v1") supplies core detail;112folded original sprigs/limb across5limbs, smaller textured core and finer secondary branches replace smooth visible balls.

- [x] Add actual engine regression for shared512canopy binding,560sprigs/tree, finite normals and bounded retained tree vertices/lifecycle; run RED against old core.
- [x] Mechanically resize original built-in imagegen output512px; configure sRGB/default non-readable mipmapped/trilinear/repeat compressed import, no texture editing/repainting.
- [x] Texture and shrink crown cores, fit denser alpha sprigs and own secondary branches using mathematical variation only; retain existing collision/RNG.
- [x] Run engine foliage/ownership guards and native render; inspect shape/color/coverage before acceptance.

### Task2: Bounded actual district reflection

**Files:** Create Assets/Scripts/Visuals/CitySceneReflections.cs(+meta); modify CityBuilder.cs and RepairRuntimeQa.cs; extend RepairEnvironmentFinishValidation.

**Interfaces:** CitySceneReflections.Capture(Transform district) creates one owned64px custom cubemap/probe, exposes Captured and CaptureCount read-only. Called once after city/sky construction in play mode only; no Update. Probe importance10, layer bounds exclude studio; existing van importance20 wins.

- [x] Add lifecycle and native capture assertions before implementation, checking one disabled transient camera disposed, probe scope/ownership, unchanged renderer enabled states and nonuniform actual GPU pixels.
- [x] Implement one scene capture with target restore/finally and graceful unsupported fallback; use existing Standard material/reflection pipeline rather than a new package or global environment change.
- [x] Verify captured city reflections in actual window/car readbacks, van priority and studio exclusion; keep all camera/texture owners explicit.

### Task3: Integrated verification and commit

**Files:** docs/QA/repair-environment-finish-20261015.json; current exact-source visual/icon binders; README/ART/provenance/ledger/context.

- [x] Run strongest aggregate/native build, independently review sources, capture actual new street/tree/glazing views plus portrait/landscape DE/EN.
- [x] Run four real drives/ordered repair/exact-once payout and same-profile reload on the frozen built source; inspect Concept beside native evidence.
- [x] Verify native file hashes, unchanged settings and exact collider/RNG authority; record any remaining limitations without90percent/release claim.
- [x] Commit/push coherent verified slice to main preserving historical user-deleted Concept unstaged. Continue next largest actual graphic gap under deadline.


Ruling16October00:03Berlin: the aggregate caught the unchanged40000vertex residential-fixture ceiling after denser foliage. Preserve this ceiling by indexing four corners per flat facade face (24boxvertices instead of36), preserving geometry/rounded profiles and existing physical UV mapping; no global primitive/van/fixture change. The intended new canopy changes the finite texture contract from3to4total and2to3sharedimports, with all ownership assertions retained.


Outcome: exact source88e507b9; aggregate/Mac0; final native1492/1377/7,314bundle/settings/collision/RNG verified; independent review closed allimportantfindings. Evidence docs/QA/repair-environment-finish-20261016.json. WholeConcept failed/iconpending.
