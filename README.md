# BrickBraker

A classic brick breaker arcade game for iOS, built with SpriteKit. Smash through rows of colorful bricks with a bouncing ball, customize your look, and chase a high score — all with retro chiptune music playing in the background.

## Gameplay

Slide your finger to control the paddle and keep the ball in play. The ball bounces off walls, the paddle, and bricks. Each brick you break earns 10 points. Clear all the bricks to win. You get 3 lives per game — if the ball falls past your paddle, you lose a life.

Bricks slowly descend over time. If they reach your paddle, it's game over.

## Features

### Customizable Skins
Pick your style before each game or mid-game through the settings panel:

- **Ball skins** — 5 options, each with a unique color and emoji face: Classic 😊, Ice 😎, Fire 😠, Alien 👽, and Magic 🤩
- **Paddle skins** — 5 color themes: Classic (white), Neon Blue, Hot Red, Lime, and Purple, each with a glow effect
- **Brick textures** — 5 visual styles for the brick grid: Classic (solid fill), Neon (glowing outlines), Candy (highlight stripes), Dark (horizontal line pattern), and Mono (gradient overlay)

### Settings Panel
Tap the gear icon (⚙️) in the top-right corner at any time to open settings. The game pauses automatically while settings are open. From here you can:

- Toggle background music on/off
- Toggle bounce sound effects on/off
- Switch ball, paddle, and brick skins on the fly

### Sound & Music
All audio is generated programmatically — no external sound files needed for gameplay audio. The game features:

- A chiptune-style background music loop that starts when you launch the ball
- Bounce sound effects when the ball hits walls or the paddle
- A distinct break sound when bricks shatter

Audio is built using `AVAudioEngine` with procedurally generated PCM buffers for a retro arcade feel.

### Particle Effects
Bricks burst into colored particles when destroyed, giving satisfying visual feedback on every hit.

### Responsive Layout
The game adapts to any iPhone screen size and respects the safe area (notch / Dynamic Island) so the HUD is always visible.

## Tech Stack

- **Language:** Swift
- **Framework:** SpriteKit (rendering, physics, collision detection)
- **Audio:** AVFoundation (`AVAudioEngine` + `AVAudioPlayerNode` with programmatic tone generation)
- **Target:** iOS (portrait orientation)

## How to Run

1. Open `BrickBraker.xcodeproj` in Xcode
2. Select an iPhone simulator or a connected device
3. Build and run (⌘R)

## Project Structure

```
BrickBraker/
├── BrickBraker.xcodeproj
└── BrickBraker/
    ├── GameScene.swift          # All game logic, UI, physics, sound, and settings
    ├── GameViewController.swift # Scene setup and safe area handling
    ├── AppDelegate.swift
    └── Assets.xcassets/
```

## License

This project is for personal/educational use.
