# Repair Empire - Game Design

## Core session loop
1. Spawn at workshop or last valid company state.
2. Inspect available jobs.
3. Accept one active job.
4. Navigate to target building.
5. Diagnose issue through short readable interactions.
6. Perform repair interaction sequence.
7. Server validates completion.
8. Receive Cash, XP and progress.
9. Upgrade or accept next job.

## Design target
Jobs should feel active, not like holding one button. Most use 2-5 short stages. Each stage should communicate what changed.

## Job structure
Each job definition contains:
- id
- category
- minimum player level
- minimum company level if relevant
- district
- weighted rarity
- base reward
- XP
- expected duration
- required tool tier
- stage definitions
- optional co-op modifier
- cooldown/repetition controls

## Categories
### Plumbing
Leaks, fittings, valves, drains, sanitary objects.
### Heating
Radiators, boilers, circulation, balancing-themed simplified jobs.
### Climate
AC units, airflow, cooling/service-themed jobs.
### Energy
Heat pumps, solar/energy-system themed high-level jobs.

## Progression layers
Player Level: unlocks jobs and districts.
Company Level: unlocks workshop/company systems.
Tools: reduce interaction time or enable higher tiers.
Vehicles: capacity, travel convenience, presentation.
Employees: passive throughput and company fantasy.
Skill Tree: four category branches.
Achievements: milestone rewards.
Prestige: endgame reset with permanent meta bonuses.

## World
Three districts:
1. Residential - tutorial and early game.
2. Downtown - midgame, mixed residential/commercial.
3. Industrial - endgame, large/co-op jobs.

Workshop is the persistent hub for upgrades, employees and vehicles.

## Cooperative play
Server size target: 1-6.
Co-op large jobs are optional. Solo player must always have viable content.
Co-op rewards scale by contribution and job definition, not by client claims.
No player can force-spend another player's resources.

## Difficulty
Difficulty comes from:
- more stages
- tool requirements
- timing/sequence variation
- travel scale
- concurrent objectives on large jobs

Avoid twitch precision that harms mobile users.

## Onboarding
First 10 minutes:
- guided first plumbing job
- first upgrade
- second job with one new mechanic
- workshop/company introduction
- visible next district requirement

Tutorial text must be short and contextual.

## Retention systems
- Daily jobs
- Daily login reward with modest value
- Achievement milestones
- visible next unlock
- prestige milestones
- rotating high-value contract set

No energy system.

## Failure states
Failure should cost time/opportunity, not wipe paid currency.
Disconnect/rejoin must not duplicate job rewards.
