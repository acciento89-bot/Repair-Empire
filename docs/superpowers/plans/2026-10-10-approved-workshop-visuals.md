# Approved Workshop Visuals Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans inline; root exclusively operates Unity, native builds and delivery. User already approved implementation of the three-view board; no additional design approval or worker commits.

**Goal:** Carry the approved orange/navy workshop, credible service van/city and hands-on repair board into actual runtime source.

**Architecture:** Extend the current RepairHud and MeshArt owners. A scene-owned service showroom supplies cached images from the same modeled fixtures used in repair phases; it is isolated from city physics and its camera renders only when requested. Core contract, persistence, commerce and driving code remain authoritative and unchanged.

**Tech Stack:** Existing Unity 6 built-in rendering, C#, uGUI; no packages/providers/assets bought.

**Spec:** Approved `repair-empire-3-ansichten.png`, viewed at `/Volumes/SSK SSD/Kamilunavo/Artifacts/KamilunavoDelivery-20261009/concepts-20261010/`.

## Global Constraints

- Preserve road topology/colliders, Rigidbody driving, hold/tap/hold ordering, exactly-once payment and departure boundary.
- Preserve profile/schema/IAP; DE/EN, portrait/landscape/usable pane, >=48 logical-point targets.
- Permanent Calls / Equipment / Workshop / Company navigation; no eight-tab or gallery menu.
- Matching actual faucet/toilet/switch images; actual 3D geometry, no generated gameplay screenshots.
- Preserve user deletion of docs/concepts/PRIMARY-CONCEPT.png.

## Review Focus

- Cached render textures and camera owned/cleaned; no per-frame offscreen camera.
- Compact landscape/reserved pane exposes fixed action and nav without overlap.
- Fresh profile, locked/paid calls and unsupported saves stay honest.
- Four-category routes/repair phase callbacks and paid-job spam remain guarded.
- Shadow/tree/model complexity measured by root, visual acceptance based on actual frames.

### Task 1: Fixtures and source images
- [x] Add bevelled solids and swept tubes to MeshArt; create ServiceSceneArt fixture geometry and a scene-owned cache.
- [x] Keep thumbnails and phase render separate, only render on requests, exclude layer30 from main camera.
- [x] Editor fixture validates faucet/toilet/switch silhouettes, phase-specific replacement and no collider; runtime validates actual rendered distinct thumbnails.

### Task 2: Workshop tablet and repair procedure
- [x] Replace gallery Home with modeled workshop hero, selected call and compact customer cards.
- [x] Fix four bottom destinations; retain specialist IDs under relevant destinations and options/shop shortcuts.
- [x] Bind correct 3D images and phase view to Prüfen/Wechseln/Testen with existing RepairHold/RepairTap names/actions.
- [x] Runtime validates nav, scene imagery, DE/EN orientation and fixed targets, then existing reward/replay suite.

### Task 3: City and van
- [x] Bevel doors/hood/bumper, add credible wheels/ladders, enhance varied masonry/window returns/storefront/curbs/trees and workshop props without changing collision.
- [x] Refine daylight and restrained cheap material shading for richer surfaces.
- [x] Lightweight source compilation/pure rule checks; root performs BuildAutomation.ValidateAll, actual presentation/full QA and screenshot/performance review.

Source tasks implemented and lightweight compile/pure checks passed. Actual engine/render/runtime/performance acceptance remains with root; checkboxes describe source deliverables, not those unexecuted gates.
