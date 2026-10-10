# Repair Empire Art Direction

## Target
Clean modern city-service aesthetic. Dark navy interface surfaces with orange used as action/accent rather than washing every control.

## Palette
- Deep navy: #071727
- Panel: #0D263C
- Orange action: #FF6D23
- Orange highlight: #FF9A36
- Cyan navigation: #2DBBFF
- Success green: #39D47A
- Primary text: #F7FAFF
- Secondary text: #B5C4D3

## City
- Wide central road with sidewalks and clear customer pull-off zones.
- Repair Empire workshop is a hero landmark.
- Background buildings use low-cost modular silhouettes.
- Navigation arrows stay cyan and never compete with orange action UI.

## Vehicle
White service van with orange/navy brand treatment. Camera keeps road and route marker visible.

## UI
Top: Cash | Level/XP | Tool | Settings.
Upper-left: one service-call card.
Right: Tablet action.
Bottom: steering left/right + Brake + Accelerate.
Tablet: high-contrast dark navy shell, orange active tab/action, white text, light blue-gray metadata.

## Primary visual reference

![Primary Repair Empire concept](concepts/PRIMARY-CONCEPT.png)

This image is the binding visual target for the branded service van, contemporary city, workshop/HQ, navigation language, service-call presentation and tablet UI. The concept contains multiple UI states: the Tablet and detailed job interfaces are contextual overlays and must not cover normal driving.

### Non-negotiable visual gates
- Driving view prioritizes road, route guidance and vehicle readability; HUD stays compact.
- The city must read as a designed service district, not a corridor of primitive boxes.
- The van is a hero asset with recognizable Kamilunavo/Repair Empire branding and clear driving feedback.
- Navy is the structural UI color; orange is an action/accent color, not a full-screen wash.
- Tablet content must maintain high contrast and readable row/action hierarchy on small phones.
- Default road network and vehicle physics must not allow routine soft-locks or trapping.


## 2026-10-09 service dashboard revision

The user's approved menu reference supersedes the original full dark tablet treatment. Repair keeps its own workshop identity: a warm ivory menu, dark navy lettering, muted green-blue scenic panels, white illustrated cards and a fixed orange primary action. The supplied Rising Steps screenshot is a hierarchy reference only; no fantasy artwork, game branding or third-party assets are copied. Driving retains compact navy overlays, orange service actions and cyan route guidance.

Normal entry opens the company dashboard. Its hero shows the live route or company progress; all eight specialist sections are exposed as illustrated cards. Four small permanent destinations (Home, Calls, Workshop, Shop), an options shortcut and the persistent drive action reduce navigation overhead. Jobs retain accurate individual service diagrams, paid status, requirements and payouts. Narrow usable panes stack commerce/settings actions rather than reducing touch targets.

Original code-drawn city, customer, van, workshop, tools, earnings, daily, options and design illustrations are owned by ServiceIllustrationGraphic. The city uses the existing owned textures plus native authored roofs, awnings, café details, planted verges and kiosks. The van gains physical visual trim, step treads, wheel arches, wipers and company lettering. Road geometry/colliders and the vehicle physics body are unchanged; decorative additions remain outside the road corridors. Actual rendering and performance acceptance are required before release.


## Approved 2026-10-10 workshop / street / repair board

The approved three-view board at `/Volumes/SSK SSD/Kamilunavo/Artifacts/KamilunavoDelivery-20261009/concepts-20261010/repair-empire-3-ansichten.png` supersedes the October 9 gallery menu. Repair uses its own orange/navy workshop identity: a modeled branded workshop hero, compact service cards with matching fixture imagery, and permanent bottom Aufträge / Ausrüstung / Werkstatt / Firma destinations. Company/team/daily/shop/options are contextual destinations; they do not become eight global tabs.

Menu images are photographs rendered from owned runtime 3D fixtures and the actual modeled van/workshop. Faucet, toilet, switch, basin, heating and climate have separate physical silhouettes. Repair presents the same fixture through Prüfen / Wechseln / Testen; the faucet exposes its cartridge/washer and shows removing/inserting the washer during the existing four-contact sequence. The modeled tool, fixture and counter are genuine meshes; generated concept pixels do not replace gameplay. Phase actions remain touch-accessible on a fixed shelf, with the scene/details scrolling above them. DE/EN and landscape use the same action authority.

The service van adds rounded hood/bumper/mirror/case surfaces, raised cargo doors, curved rack rails, ladder clamps and modeled wheel centers/tread. The district adds beveled masonry envelopes, recessed windows/jambs/sills, corner stone modules, dormers, segmented visual curbs/drains, solid modeled tree crowns and warm soft daylight. Street collision dimensions/topology and Rigidbody/input remain unchanged. Restrained surface variation supports a baked appearance; this is not an assertion of offline baked GI or concept-photo equivalence.

The studio is isolated on layer30 and excluded from the driving camera. One disabled camera renders cached thumbnails/workshop images and a phase/contact repair image on demand; render context is restored and owned meshes/targets are destroyed with their scene. Actual Unity compilation, rendered-frame review, orientation/touch acceptance and frame/memory measurement remain root-coordinated gates.
