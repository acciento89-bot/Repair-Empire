# City material atlas provenance
Built-in imagegen, execution45efbe92-b18a-4fff-8446-a32dd32ef60c, 2026-10-08. Original retained; selected PNG copied without editing to Assets/Resources/Art/WorldMaterialsAtlas.png.
Prompt: one flat orthographic 2x2 base-color atlas; top-left charcoal asphalt, top-right light grey sidewalk slabs, bottom-left pale limestone cladding, bottom-right blue architectural glass. Tileable edges, no labels, logos, perspective, baked shadows, scene or watermark. Used as textures on actual 3D geometry, never as a fake gameplay screenshot.
Generated image inspected: correct quadrants, readable fine materials, no text. Actual Unity shader/import/binding validation and Mac QA9 rendered inspection pass; latest native performance verification remains pending.

Foliage: built-in imagegen execution4e17b7de-5ba0-4829-a8e2-d5c3f843ff42. Prompt: isolated detailed rounded deciduous canopy without trunk, ground, labels or backdrop, soft even summer light, true transparent gaps and outline. Original PNG remains unchanged; copied to Assets/Resources/Art/TreeCanopy.png. Inspected RGBA1254² alpha0..255. Used on three crossed 3D planes over the authored trunk.
Unity imports atlas quadrants as four independent Texture2DArray layers for correct repeating mip filtering; original PNG untouched. Source PNG and generated native Unity array both remain in the full project.
