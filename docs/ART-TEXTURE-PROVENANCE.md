# City material atlas provenance
Built-in imagegen, execution45efbe92-b18a-4fff-8446-a32dd32ef60c, 2026-10-08. Original retained; selected PNG copied without editing to Assets/Resources/Art/WorldMaterialsAtlas.png.
Prompt: one flat orthographic 2x2 base-color atlas; top-left charcoal asphalt, top-right light grey sidewalk slabs, bottom-left pale limestone cladding, bottom-right blue architectural glass. Tileable edges, no labels, logos, perspective, baked shadows, scene or watermark. Used as textures on actual 3D geometry, never as a fake gameplay screenshot.
Generated image inspected: correct quadrants, readable fine materials, no text. Actual Unity shader/import/binding validation and Mac QA9 rendered inspection pass; latest native performance verification remains pending.

Foliage: built-in imagegen execution4e17b7de-5ba0-4829-a8e2-d5c3f843ff42. Prompt: isolated detailed rounded deciduous canopy without trunk, ground, labels or backdrop, soft even summer light, true transparent gaps and outline. Original PNG remains unchanged; copied to Assets/Resources/Art/TreeCanopy.png. Inspected RGBA1254² alpha0..255. Used on three crossed 3D planes over the authored trunk.
Unity imports atlas quadrants as four independent Texture2DArray layers for correct repeating mip filtering; original PNG untouched. Source PNG and generated native Unity array both remain in the full project.

## Original street masonry and maple sprigs — 2026-10-15

`Assets/Resources/Art/StreetBrick-v1.png` is an original warm red-brown running-bond brick material, generated with built-in image_gen (`exec-b5fd5674-0bf3-42e2-ba44-bdd03689f1ab.png`). The selected source has nine irregular courses; the generator did not preserve the prompt's requested eight. The shader therefore derives mortar relief from the actual image rather than imposing a second grid. The original remains under Codex generated_images; only mechanical native sips downscaling to RGB512² was used. SHA256: `d21e280d18b42ab80d997d2935d791406d20ab47ed2fa379dfe0c9ae1597fb91`.

`Assets/Resources/Art/StreetLeafSprigs-v1.png` is one original airy maple sprig cluster with transparent gaps and outline, generated with built-in image_gen (`exec-0e6ef2de-4d89-45a8-ad19-e69cf2267ebb.png`). Mechanical sips downscaling preserves RGBA512² and actual alpha0..255. SHA256: `d9784b3b0e5939f67306825a155534a16bcc5ef689e1a7712a6c0993a53ece5a`. This is used on folded leaf cards in the actual 3D tree mesh, not as an illustrated tree or gameplay backdrop.

Exact prompts, original PNG paths/hashes, Unity imports and bounded native evidence are recorded in `docs/QA/repair-street-concept-20261015.json` and `/Volumes/SSK SSD/Kamilunavo/Builds/RepairStreet-20261015`. Both imported resources are shared and non-readable at runtime; generated material/mesh/plaster ownership remains with the district. Three actual native Mac processes pass1422/1311/7 checks. Root compared the new real driving frame with the unchanged approved board; whole-game graphics remain below the Concept and no new Repair upload is authorized by this evidence alone.

## Original service stone and woven cloth — 2026-10-15

`Assets/Resources/Art/ServiceStone-v1.png` is original pale ivory mineral stone, generated through built-in image_gen (`exec-092e3724-df6c-4ff3-a3ca-5b9b3f9d2ff5.png`). `ServiceCloth-v1.png` is original desaturated blue-grey woven service fabric (`exec-5fab2f92-88eb-4028-977f-eaec2a54f88f.png`). Both original RGB1254² outputs remain intact under Codex generated_images. Only mechanical native sips downscaling produced the RGB256² project resources. Project SHA256 values: stone `1778c3419c0497619d527590bcd90cf336d787b4b7204a4062101a053f584512`; cloth `4de9c23cef273917409e00599c081b2b092cd324b314f9719e6270b758dc29ed`.

These are albedo surfaces on actual fixture-wall/counter and closed folded-towel meshes, not illustrated repair scenes. Unity imports use sRGB, mipmaps, anisotropy2, trilinear repeat, compressed HQ, no alpha and no runtime readability. Imported resources remain shared and survive studio disposal. Original cloth, stoneware plant/tray, clock cupola and arch bridge are authored Unity geometry with native resource owners.

The isolated service camera now renders on demand through an owned HDR temporary and filmic finish material into cached targets. It restores the caller's render targets and leaves global rendering untouched. Current exact prompts, original/project image metadata and hashes, native ownership/budget tests, actual24-fixture gallery and comparisons are in `docs/QA/repair-art-complete-20261015.json` and `/Volumes/SSK SSD/Kamilunavo/Builds/RepairArtComplete-20261015`. Final native Mac1422/1371/7 checks pass; this is not full Concept or physical-device approval.

## Original workshop dashboard illustrations — 2026-10-15

`Assets/Resources/Art/Workshop/ServiceWorkshopHero-v1.png` and `ServiceWorkshopHero-wide-v1.png` are original decorative workshop-menu illustrations generated with built-in image_gen. The approved three-view Repair board supplies style/content reference for the first; the panoramic edit references that original output. They depict an own branded rounded service van and warm workshop, with no manufacturer logo or drawn game controls.

Original outputs remain intact under Codex generated_images (`exec-1cea88b1-fdd8-4f1e-b019-b1c68cc3b5a9.png`, RGB1586×992; `exec-b1e38010-67ce-4a02-96b2-e3062f3ebf4e.png`, RGB2172×724). Mechanical native sips reduction produced RGB1024×640 and1536×512 project assets. SHA256: portrait `df2e5ff825746ee10adc5feaab757024692514f696b682e2fc78985792120424`; wide `ff107803079b77b0b7dd87de4f5fec1e753ed464f64a6aa62a995389436da142`. A requested4:1 panorama generated as3:1; integration preserves its actual proportions instead of stretching it.

These are explicitly illustrations in the menu, not gameplay captures or proof of the3D workshop. The new driving van, city and repair fixtures remain actual Unity meshes; the optional native workshop inspection photo remains separately captured. Native imports are shared, non-readable, sRGB, NPOT-preserving Texture2D, no mipmaps, bilinear clamp, compressedHQ/max2048. Prompt summaries, full original/reference hashes and output metadata are recorded in `docs/QA/repair-van-workshop-20261015.json` and `Builds/RepairVan-20261015/workshop-art-provenance.json`; summaries are labeled as such, not represented as exact prompts. Actual menu/photo/model comparisons and native validation are bound to that report's exact source.

## Original vehicle optical materials — 2026-10-15

Built-in `image_gen.imagegen` created the original two optical materials. No CLI/API fallback and no external model was shipped. The complete prompts, original PNG paths/SHA256/sizes, project PNG paths/SHA256/sizes and final native evidence are preserved in `docs/QA/repair-road-van-20261015.json`.

`/Volumes/SSK SSD/Kamilunavo/Projects/Repair-Empire/Assets/Resources/Art/VanHeadlampOptics-v1.png`: 512×244, SHA256 `6351e90bbf25859a33776761a4d15b109c69d991aecead3f5f32c8ce1f9c0640`. Original preserved at `/Volumes/SSK SSD/Kamilunavo/Builds/RepairRoadVan-20261015/VanHeadlampOptics-v1-original.png`. Only RGB conversion and aspect-preserving Lanczos downsampling were applied.

`/Volumes/SSK SSD/Kamilunavo/Projects/Repair-Empire/Assets/Resources/Art/VanRedLens-v1.png`: 192×512, SHA256 `68ff021d18139c47f1295ca69dfdbcb0bdd8c271caf71bb02d4d4f07ba2573a1`. Original preserved at `/Volumes/SSK SSD/Kamilunavo/Builds/RepairRoadVan-20261015/VanRedLens-v1-original.png`. Only RGB conversion and aspect-preserving Lanczos downsampling were applied.

Headlamp optics bind to the existing owned headlamp material. Red prism detail binds to the existing tail material, preserving dynamic brake tint/emission. Reverse and fog lamps use appropriate separate existing material instances. Imports: max512, NPOTNone, sRGB, mipmaps, clamp/trilinear, aniso2, compressedHQ and no runtime readability. Shared imported textures survive individual vehicle disposal; native geometry, ground and ownership tests remain separate from appearance approval.


## Original cabin geometry and glass material — 2026-10-15

The new seats, dashboard/instruments, steering, inner doors, bulkhead and true metal-shell window openings are original authored3Dgeometry in VanArt/VanCoachworkGeometry. No interior picture, purchased/downloaded base model or new external dependency was used. Shared quadratic outlines keep pane, gasket and body cut consistent. The existing original optical textures remain unchanged.

`Assets/Resources/Materials/VanCabGlass.mat` is an original material configuration using Unity's existing built-in Standard shader, with serialized premultiplied transparency. It is a shared Resources prototype; each van owns and disposes its runtime clone. A native GPU background-transmission probe verifies the production variant rather than relying on Editor appearance or material flags. The owned32pxenvironment cube captures the actual street once for the motor van; its disabled temporary camera/state restoration and destruction are verified. Static/Editor models keep the own procedural environment fallback.

Exact source/material/meta hashes, superseded failures, final native1466/1377/7, actual model/street PNGs and mechanical comparison-board provenance: `docs/QA/repair-cabin-20261015.json`, `Builds/RepairCabin-20261015`. These actual renders remain simplified and below full Concept quality; no new release approval.


## Original commercial-vehicle detail meshes — 2026-10-15

VanProductionDetails.cs is a new original authored geometry generator integrated by VanArt/VanCoachworkGeometry. Its body pressing/bonnet/fenders, swept mapped lamps/grille, door/mirror/roof/scuttle/step hardware, sensors, steel wheel dishes/folded openings and fitted tire tread are actual runtime3Dparts. Ford's official Transit brochure supplied vehicle-form reference only: https://www.ford.co.uk/content/dam/guxeu/uk/documents/brochures/cars/BRO-transit_van_25.5MY.pdf . No manufacturer logo, downloaded model or claim of an exact licensed replica. No new bitmap was generated in this pass; existing own headlamp/red-lens textures and shared cabin glass remain.

Each mesh is owned; safe disabled source copies are explicitly released after material batching while active buffers/semantic inspection meshes/transforms remain. Exact source hashes, real native photos, candidate failure history, independent review, immutable Concept hash and comparison-board provenance: `docs/QA/repair-transit-details-20261015.json`. Final source `da5426fd53524800207d90f5711f09af8ffb0d54f1bff7dfee033fff74e89fde`, aggregate/Mac0 and native1472/1377/7 pass. The comparison images are labeled mechanical layouts/resizing of genuine native captures/reference crop only, without generative repainting. The full graphical release gate stays failed.


## Original molded automotive micrograin — 2026-10-15

Built-in image_gen created original grayscale height data, execution4198330a-33ab-410f-8cc5-dc596f1384a7. The original1254square output is retained under Codex generated_images and Builds/RepairVanFinish-20261015; native sips only resizes to512square in `Assets/Resources/Art/VanMoldedGrain-v1.png`. Unity imports it as a non-readable compressed NormalMap, convert-to-normal enabled, scale.035, sRGBfalse, mipmapped/trilinear/repeat/aniso2. `VanMoldedSurface.mat` is an original serialized Standard NORMALMAP prototype. Runtime material clones/owned geometry are disposed; shared imports/prototype survive.

Exact prompt, source/project/meta/material hashes, authoring method and native differential readbacks: `docs/QA/repair-van-finish-20261015.json`, Builds/RepairVanFinish-20261015/generated-asset-provenance.json. Original generated height pixels are not fake gameplay. Actual GPU normal/flat control differs in12,033pixels at the production material strength; genuine native model views show its use. Original optic textures and cabin prototype are unchanged. No new external mesh or manufacturer logo; complete Concept review remains failed.


15October overnight compact street: ParkedVehicleArt.cs is original authored curved body/glazing/roof/wheel/detail geometry,5228vertices per instance;13parked examples use shared finite district materials and owned meshes. No external base model/image replaces actual street rendering. Native new street/car/comparison evidence is in docs/QA/repair-street-rebuild-20261015.json. Existing imported original brick/sprig textures retained unchanged in this slice.


16October canopy: original built-in imagegen output exec-0a444cf4-dac2-4632-9af5-11e138ed143f.png, archived as Builds/RepairEnvironmentFinish-20261015/StreetCanopy-v1-original.png; macOS sips onlyresizes512to Assets/Resources/Art/StreetCanopy-v1.png. Exact fullprompt/tool/original/projectpaths and no-paint conversion are in that Builds folder generated-asset-provenance.json, hashed in docs/QA/repair-environment-finish-20261016.json. Shared non-readable sRGB/mips/repeat/HQ compression, own CanopySurface shader, original geometry. Actual street cubemap is captured from3Dscene once, not generated imagery.


16October2026: Original built-in imagegen ServiceRoomReflection-v1 panorama; exact prompt/original/mechanical1024×512 conversion/Unity imports and64RGBAHalf prototype hashes in docs/QA/repair-lighting-studio-20261016.json and Builds/RepairLightingStudio-20261016/generated-asset-provenance.json. Assets/ArtSources/ServiceRoomReflection-v1.png is reflection input only, not gameplay imagery; Assets/Resources/Art/ServiceRoomReflection-v1.asset is shared HDR data. Scene clone is non-readable and owned, original survives cleanup.


## Original daylight sky — 2026-10-16

Built-in imagegen output exec-2702cdb4-f799-4e83-8cf8-0ca7cf7ca1c1.png is sky-only original artwork. The archived 1774×887 image is mechanically resized to Assets/Resources/Art/ServiceDaySky-v1.png (1024×512); no painted city/vehicle replaces 3D objects. Unity imports shared non-readable sRGB/mipmapped/HQ compressed data, Repeat U and Clamp V. RepairSky uses true latitude/longitude coordinates. Exact prompt, original/project/import hashes and actual native comparisons are in docs/QA/repair-skyline-finish-20261016.json and Builds/RepairSkylineFinish-20261016/generated-sky-provenance.json.

DistrictCivicHall.cs, rounded clock-cupola extension and StreetLampArt.cs are original authored meshes. Existing district materials are borrowed; new meshes and scene sky material are owned and disposed, while imported sky data survives. No external model/license dependency was added.


## Original service-room assemblies and water — 2026-10-16

The extended actual room shell, metric UVs/single grout mesh, open cabinet carcasses and thin seated drain/water meshes are original authored geometry. Existing original shared stone/cloth/HDR reflection assets are unchanged. ServiceWater-v1.mat is an original serialized Standard premultiplied configuration derived from the existing native-supported prototype, not a new downloaded dependency. The scene owns its material clone; the shared prototype survives disposal. No generated picture stands in for the room or service action. Exact hashes/native controls/Concept comparisons are in docs/QA/repair-fixture-finish-20261016.json.

2026-10-16: Regular UI body uses licensed unmodified BarlowMedium1.408 from official GoogleFonts `ofl/barlow/Barlow-Medium.ttf`, matching existing1.408Regular/Bold. Existing StreamingAssets/Barlow-OFL.txt retained. Source/license URLs and exact hash: Builds/RepairTabletFinish-20261016/font-provenance.json.
