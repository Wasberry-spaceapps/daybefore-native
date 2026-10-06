# Take a Minute — Game Specification

## What it is
An endless runner mini-game where the player controls a simple car silhouette that must jump over approaching obstacles (rocks and branches). The game gets progressively faster the longer the player survives. It serves as a brief distraction or "minute" to relax.

## Controls
- Spacebar (keyboard)
- Mouse click (mouse)
- Touch (mobile screens)
All inputs trigger a jump action.

## Visual elements
- **Car**: A simple silhouette composed of two rectangles (the body and the cabin). Drawn in `palette.text` or `colors.textSecondary`.
- **Ground**: A simple 1px horizontal line drawn at `canvas.height - 40`. Drawn in `palette.hairline` or `colors.divider`.
- **Obstacles**: 
  - Rocks: simple triangles/polygons.
  - Branches: simple short rectangles.
  - Both drawn in `palette.hairline` or `colors.divider`.
- **Score**: "Distance: [score]" text drawn in the top left, in `palette.muted` or `colors.textSecondary`.
- **Game Over Text**: "Finished." displayed in the center when an obstacle is hit, in `palette.muted` or `colors.textSecondary`.

## Timing
- Physics updates happen every frame (`requestAnimationFrame` equivalent).
- Gravity is applied continuously at 0.6.
- Jump force is -10.
- Starting speed is 4, increasing by 0.5 every 600 frames up to a maximum of 8.
- Obstacles spawn randomly every `Math.max(80, 150 - Math.floor(score / 50))` frames.

## Sound
None.

## End condition
The game ends ("runs until the user closes it") or enters a "Finished" state when the car collides with an obstacle. It does not automatically restart.

## Colors used
Web colors mapped to Day Before tokens:
- `#111111` (Background) -> `palette.ground`
- `#888888` (Car, Text) -> `palette.muted` (or `palette.faint`)
- `#2A2A2A` (Obstacles, Ground) -> `palette.hairline`
