# P00 - Product Definition

## Goal
Turn the approved planning baseline into an implementation-ready Roblox project without reopening product design.

## Tasks

### P00-T01 Initialize standalone implementation repository and project metadata
Deliverables:
- dedicated Repair Empire repository
- README links canonical specs and ledger
- default branch and source-control conventions
- Roblox/Rojo project metadata placeholders only where actual IDs are not yet known

Acceptance:
- clone is self-describing
- next task can be determined from ledger
- no product scope is lost during migration from the planning folder

### P00-T02 Confirm Roblox experience ownership/naming/place structure
Decide and record:
- owner/group
- final experience display name
- universe/place structure
- development vs production place strategy

Acceptance:
- IDs/ownership facts are documented once known
- code does not scatter literal place/product IDs

### P00-T03 Freeze V1 identifiers and terminology
Define stable internal IDs for four categories, three districts, currencies and core systems.

Acceptance:
- IDs are machine-friendly and not tied to localized display text
- terminology matches PRODUCT-SPEC and GAME-DESIGN

## Tests
Documentation consistency review.

## Definition of Done
All three tasks verified, ledger updated, no unresolved naming ambiguity blocks P01.
