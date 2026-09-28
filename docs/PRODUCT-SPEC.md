# Repair Empire - Product Specification

## 1. Vision
A highly replayable Roblox repair-company simulator with tycoon progression. Sessions should be immediately understandable, rewarding in 3-10 minute chunks, and still provide multi-week progression.

## 2. Target audience
Primary: Roblox players 10+ who already understand simulator/tycoon conventions.
Secondary: players who enjoy collection, upgrades, light roleplay and cooperative progression.

V1 must not require trade knowledge. Real-world building services are thematic inspiration, not a qualification test.

## 3. Player fantasy
"I start with a toolbox and an old van, become better at repairs, hire staff, unlock larger jobs and build the biggest service company in the city."

## 4. V1 scope
Included:
- One cohesive city with three unlockable districts.
- 30 launch job definitions.
- Four categories: Plumbing, Heating, Climate, Energy.
- Level and XP progression.
- Company level/progression.
- Tool upgrades.
- Vehicle progression.
- NPC employees and passive company income/jobs.
- Daily jobs.
- Achievements.
- Prestige/rebirth layer.
- Solo play.
- 1-6 player servers.
- Selected cooperative large jobs.
- Game Passes and Developer Products.
- Persistent player profile.
- Analytics events needed for balancing.
- Mobile, desktop, tablet and controller support.

Excluded from V1:
- PvP.
- Player-to-player trading.
- Player-generated construction.
- Voice-dependent gameplay.
- Real-money item marketplace outside Roblox systems.
- External account system.
- External backend dependency.
- Complex realistic hydraulic/electrical simulation.
- Open-world traffic simulation.
- Player guilds/clans.

## 5. Success criteria
Product:
- New player understands first objective without external instructions.
- First completed job within 3 minutes median target.
- Player sees next meaningful upgrade within first session.
- No progression dead-end without spending Robux.

Technical:
- Economy mutations validated server-side.
- Persistent save migration strategy exists before public release.
- Client cannot directly award currency, XP, ownership or completion.
- Core gameplay remains usable on mobile touch controls.

Operational:
- All tunable economy values live in config/data modules.
- Jobs/content can be added without modifying job engine logic.
- Ledger provides one canonical next task.

## 6. Product guardrails
- No lootbox/gacha monetization in V1.
- No deceptive countdowns or fake scarcity.
- Paid acceleration must have a free gameplay path.
- Avoid excessive modal prompts.
- Purchases must be idempotently granted.
- Never trust the client for value-bearing state.

## 7. Naming
Working title: Repair Empire.
Brand may change before public release without changing systems architecture.
