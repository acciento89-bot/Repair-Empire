# Project Metadata

## Repository
- Repository: `acciento89-bot/Repair-Empire`
- Default branch: `main`
- Visibility: public
- Product/brand owner: Kamilunavo
- Final working display name: **Repair Empire**
- Platform: Roblox
- Language/runtime: Luau / Roblox Studio
- Source workflow: Rojo-compatible filesystem project

## Roblox ownership and place architecture
Decisions that are fixed without requiring Roblox account access:
- One production Roblox experience/universe.
- One production start place for the public game.
- One separate development/test place inside the same experience when Roblox permissions/workflow allow it; if Roblox account constraints make that impractical, a separate private development experience is acceptable, but production IDs remain isolated in config.
- Development/test places are never referenced by gameplay feature modules directly.
- All environment-specific Roblox IDs are centralized in `src/shared/config/PlatformConfig.luau` once known.

Resolved Roblox platform values:
- ownership type: authenticated personal Roblox creator account used to create the experience; no group ownership configured
- production universe ID: `10768475286`
- production start place ID: `79925227687072`
- development/test place ID: `138882349802835`
- development place name: **Repair Empire Dev**

The experience and both places remain private while QA is incomplete.

## Environment names
Stable internal environment keys:
- `development`
- `production`

## Rojo/source metadata
Expected source roots:
- `src/client`
- `src/server`
- `src/shared`

The initial Rojo project maps:
- `ReplicatedStorage/RepairEmpire/Shared` <- `src/shared`
- `StarterPlayer/StarterPlayerScripts/RepairEmpireClient` <- `src/client`
- `ServerScriptService/RepairEmpireServer` <- `src/server`

## Configuration policy
Roblox IDs, product/pass IDs, place IDs and balance values are centralized in configuration. Feature modules must not scatter literal platform IDs.

## Planning baseline
The complete V1 planning baseline is present under `docs/` and `docs/plans/`.
