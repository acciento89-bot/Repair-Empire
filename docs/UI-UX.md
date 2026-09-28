# Repair Empire - UI/UX Specification

## Principle
Mobile-first without making desktop feel like a mobile port.

## HUD
Top:
- Cash
- Player level/XP
- concise company status if needed

Left:
- active job objective
- next stage
- distance/navigation cue

Right/bottom-right:
- context interaction
- equipped tool / quick action

Bottom-left:
- native movement area remains unobstructed

## Input targets
Touch targets must be comfortably tappable.
Do not place critical UI under mobile thumbstick/jump regions.
Every action must have keyboard/mouse and controller equivalents.

## Screen hierarchy
Primary:
- HUD
- Job Board
- Workshop
- Tools
- Vehicles
- Employees
- Skill Tree
- Daily Jobs
- Achievements
- Prestige
- Shop

## Modal rules
One modal at a time.
Critical gameplay remains visible where possible.
Purchase confirmation must clearly state what is bought.
No surprise prompt immediately after spawn.

## Feedback
Every successful repair stage gets:
- visual change
- concise sound/haptic-compatible feedback where supported
- stage progress response

Reward feedback shows source and amount without covering gameplay for long.

## Navigation
Job destination uses simple world marker + distance.
Avoid minimap in V1 unless playtesting proves it necessary.

## Accessibility
- Do not rely on color alone.
- Maintain readable contrast.
- Provide icon + text for critical states.
- Avoid rapid flashing.
- Support reduced-motion option for nonessential effects if practical.
- Text scale/layout tested on small phones and tablets.

## First-session UX
The player should see only the systems needed now. Unlock UI progressively to reduce cognitive load.

## Visual direction
Readable stylized 3D, bright but not neon-heavy.
Clear silhouettes for interactable components.
Repair targets should remain legible against world geometry.
