# Repair HUD revision, 11 October 2026

Scope: RepairHud.cs, RepairHud.Dashboard.cs, the three RepairGame interaction constructor bindings, an isolated UI item glyph helper, and RepairHudRegression.cs. Job data, interactions, fixture models, city/van art, saved schema, rewards, commerce and native delivery are owned separately and are outside this UI change.

## Evidence and causes

The actual native screenshots show identical crossed-tool pictures for wrench, voltage tester, professional kit and fleet; all workshop and paint items show the same building. Row selects ServiceIllustrationGraphic.Scene from the page number. Item identity never reaches the illustration.

The repair panel selects generic strings by CategoryIndex and branches on phase==1. It always creates four replacement buttons and calls AdvanceRepair(1). RepairGame's three interaction construction sites omit the job presentation. This hides the 24 distinct fixture workflows and cannot render sequences in persisted phases zero or two.

All non-dispatch menu footers close the tablet and resume driving. There is no retained parent menu. The requested Back action needs a separate destination/history from the explicit route action, and must preserve driving pause through locale/orientation/profile rebuilding and native presentation.

## Intended presentation

Repair Empire retains its original orange/navy service identity: a compact navy header and navigation, cool service-white working surface, orange status/action accents, an actual workshop photograph, and readable call information. Tool, headquarters, workshop upgrade and paint rows receive matching item silhouettes. Eight colored van previews show paint differences without applying styles to the profile or the world.

The panel presents the exact localized stage title, instructions and action names from JobPresentation. Both Hold and Sequence advance the current persisted phase. Sequence grids use their actual action counts rather than a fixed four-button stage. Input interruption resets partial work; native presentation continues to own taps and navigation.

## Validation contract

RepairHudRegression.Validate builds actual uGUI hierarchies with an inactive game fixture (no initialization/save). It compares generated item meshes, exact localized stage/instruction/action text, Hold/Sequence/count, retained parent Back after locale/orientation refresh, native-presenter pause guards, and wallet/style preservation. It covers DE/EN, regular portrait, landscape and the narrow reserved pane; all 24 calls are covered in the regular pane.

Root ran the actual Unity baseline in Repair/baseline-ui-retry.log: exit 1 with expected repeated item geometry, missing menu Back, localized stage/instruction and mode/action-count failures. The first attempt had an ambiguous reflection overload; the fixture was repaired and the successful reproduction used the exact VertexHelper overload.

The production change binds all three RepairGame interaction construction sites to ActiveJob.Presentation and renders the current stage metadata for both input kinds. A focused compile against the actual Unity references passes (Repair/UI/Repair.Hud.SourceCheck.dll). The fixture also checks actual BeginRepair binding for a phase-two sequence, Hold geometry, fixed target bounds and all button states at contrast >=4.5. Source is frozen for root engine GREEN/render review. Engine/render jobs run only at root. Actual rendered comparison with the approved three-view concept remains required before any TestFlight delivery; source syntax or compilation alone does not satisfy the visual gate.
