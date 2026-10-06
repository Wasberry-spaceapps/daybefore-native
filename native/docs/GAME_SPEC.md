# Take a Minute Game Spec

## Canvas & Environment
- **Canvas Size**: 600 width x 200 height (fixed logic scale, visually scaled).
- **Ground Height**: 40px from bottom (Y=160).
- **Physics**: 
  - Gravity: 0.6
  - Jump Force: -10
  - Base Speed: 4
  - Speed Increase: +0.5 every 600 frames
  - Max Speed: 8

## Visuals
- **Text / Car**: web used `#888888` (textSecondary).
- **Obstacles / Ground**: web used `#2A2A2A` (divider).
- **Car Shape**: Rectangle 40x20, plus another rectangle 20x12 at x+8, y-12 from the car's top-left. Starts at x=50, y=140.
- **Ground**: 1px high solid line at Y=160.
- **Score Text**: `Distance: [score]` at (20, 30) using 14px system font.
- **Game Over Text**: `Finished. Tap or press Space to restart.` horizontally centered, vertically at canvas.height / 2 (y=100) using 20px system font.
- **Close Button**: Text button reading "close" at the top left.

## Entities
### Car
- X: 50, Width: 40, Height: 20
- Starts grounded (Y = 140).
- Bounding Box for collision: (X:50, Y:car.y, W:40, H:20). The top smaller rectangle is NOT part of collision checking.

### Obstacles
- Spawns every `Math.max(80, 150 - Math.floor(score / 50))` frames.
- Randomly `rock` (50%) or `branch` (50%).
- Start X: 600 (canvas right edge), move left by `speed` each frame.
- **Rock**: width 20, height 15. Polygon drawn from (x, y+height) -> (x+width/2, y) -> (x+width, y+height). Y = 145.
- **Branch**: width 30, height 5. Rectangle. Y = 155.
- Removed when `x + width < 0`.

## Game Loop & Logic
- **Score**: Increases by 0.1 each frame.
- **Input**: Spacebar, Tap/Touch, Mouse click.
- **Jump**: Sets `dy = jumpForce` if `grounded` and game is not over.
- **Game Over**: True when collision occurs. Collision is AABB between car(40x20) and obstacle bounding box.
- **Restart**: Any input while game over resets state (frames=0, score=0, speed=4, obstacles clear, car original Y, game over false).
