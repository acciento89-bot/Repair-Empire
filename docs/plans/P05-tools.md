# P05 - Tools

## Goal
Make tools a readable capability/progression layer.

### P05-T01 Definitions and ownership
Data-driven tool families, tiers, costs and requirements.
Acceptance: ownership persists and invalid IDs are rejected.

### P05-T02 Equip flow
Server validates owned/equippable state; client presents selection.
Acceptance: respawn/rejoin restores valid equipped state.

### P05-T03 Tier requirements/modifiers
Jobs declare required capability/tier. Modifiers affect server-calculated timings/rewards only where designed.

### P05-T04 Tool shop UI
Show owned, locked, affordable and effect differences clearly.

### P05-T05 Launch catalog
Populate launch target of ~20 meaningful upgrades/items without filler duplication.

## Tests
Purchase race, insufficient funds, locked tier, invalid equip, reconnect.

## Definition of Done
Job engine can gate and modify interactions through ToolService without hardcoded tool logic.
