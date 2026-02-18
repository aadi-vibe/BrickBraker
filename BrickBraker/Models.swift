//
//  Models.swift
//  BrickBraker
//
//  Created by Upendra Sharma on 2/16/26.
//

import SpriteKit

// MARK: - Skin & Texture Definitions

struct BallSkin {
    let name: String
    let color: SKColor
    let strokeColor: SKColor
    let face: String
    let glowColor: SKColor
}

struct PaddleSkin {
    let name: String
    let fillColor: SKColor
    let strokeColor: SKColor
    let glowWidth: CGFloat
}

struct BrickTexture {
    let name: String
    let colors: [SKColor]
    let pattern: String   // "solid", "striped", "gradient", "neon", "candy"
}

let ballSkins: [BallSkin] = [
    BallSkin(name: "Classic",
             color: SKColor(red: 1, green: 0.95, blue: 0.4, alpha: 1),
             strokeColor: SKColor(red: 1, green: 0.8, blue: 0.2, alpha: 1),
             face: "😊",
             glowColor: SKColor(red: 1, green: 0.9, blue: 0.3, alpha: 0.5)),
    BallSkin(name: "Ice",
             color: SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1),
             strokeColor: SKColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1),
             face: "😎",
             glowColor: SKColor(red: 0.3, green: 0.7, blue: 1, alpha: 0.5)),
    BallSkin(name: "Fire",
             color: SKColor(red: 1, green: 0.35, blue: 0.2, alpha: 1),
             strokeColor: SKColor(red: 0.9, green: 0.15, blue: 0.05, alpha: 1),
             face: "😠",
             glowColor: SKColor(red: 1, green: 0.3, blue: 0.1, alpha: 0.5)),
    BallSkin(name: "Alien",
             color: SKColor(red: 0.3, green: 0.95, blue: 0.4, alpha: 1),
             strokeColor: SKColor(red: 0.15, green: 0.75, blue: 0.2, alpha: 1),
             face: "👽",
             glowColor: SKColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 0.5)),
    BallSkin(name: "Magic",
             color: SKColor(red: 0.7, green: 0.3, blue: 1, alpha: 1),
             strokeColor: SKColor(red: 0.55, green: 0.15, blue: 0.85, alpha: 1),
             face: "🤩",
             glowColor: SKColor(red: 0.6, green: 0.2, blue: 0.9, alpha: 0.5)),
]

let paddleSkins: [PaddleSkin] = [
    PaddleSkin(name: "Classic", fillColor: .white,
               strokeColor: SKColor(red: 0.6, green: 0.85, blue: 1.0, alpha: 1), glowWidth: 0),
    PaddleSkin(name: "Neon Blue",
               fillColor: SKColor(red: 0.15, green: 0.5, blue: 1.0, alpha: 1),
               strokeColor: SKColor(red: 0.4, green: 0.75, blue: 1, alpha: 1), glowWidth: 4),
    PaddleSkin(name: "Hot Red",
               fillColor: SKColor(red: 0.9, green: 0.15, blue: 0.15, alpha: 1),
               strokeColor: SKColor(red: 1, green: 0.4, blue: 0.3, alpha: 1), glowWidth: 4),
    PaddleSkin(name: "Lime",
               fillColor: SKColor(red: 0.1, green: 0.85, blue: 0.3, alpha: 1),
               strokeColor: SKColor(red: 0.4, green: 1, blue: 0.5, alpha: 1), glowWidth: 4),
    PaddleSkin(name: "Purple",
               fillColor: SKColor(red: 0.6, green: 0.2, blue: 0.9, alpha: 1),
               strokeColor: SKColor(red: 0.75, green: 0.45, blue: 1, alpha: 1), glowWidth: 4),
]

// Stage difficulty is computed from the stage number (1-30).
// Parameters scale progressively so each stage feels harder.
struct StageParams {
    let ballSpeed: CGFloat
    let brickRows: Int
    let brickMoveInterval: TimeInterval
    let brickMoveDistance: CGFloat
    let paddleWidthMultiplier: CGFloat

    static func forStage(_ stage: Int) -> StageParams {
        let s = max(1, min(stage, 30))
        let t = CGFloat(s - 1) / 29.0  // 0.0 … 1.0

        // Steeper speed curve using a power ramp
        let speed: CGFloat = 310 + pow(t, 0.7) * 440              // 310 → 750
        let rows = 3 + Int(t * 7)                                  // 3 → 10
        let moveInterval: TimeInterval = 10.0 - Double(t) * 7.5    // 10s → 2.5s
        let moveDist: CGFloat = 8 + t * 28                         // 8 → 36
        let paddleMul: CGFloat = 1.3 - t * 0.65                    // 1.3 → 0.65

        return StageParams(ballSpeed: speed, brickRows: rows,
                           brickMoveInterval: moveInterval,
                           brickMoveDistance: moveDist,
                           paddleWidthMultiplier: paddleMul)
    }
}

// Simple seedable RNG so stage formations are deterministic.
struct SeededRNG {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
    mutating func nextDouble() -> Double {
        Double(next() & 0x1FFFFFFFFFFFFF) / Double(0x1FFFFFFFFFFFFF)
    }
    mutating func nextInt(bound: Int) -> Int {
        guard bound > 0 else { return 0 }
        return Int(next() % UInt64(bound))
    }
}

let brickTextures: [BrickTexture] = [
    BrickTexture(name: "Classic", colors: [
        SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1),
        SKColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1),
        SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1),
        SKColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1),
    ], pattern: "solid"),
    BrickTexture(name: "Neon", colors: [
        SKColor(red: 1, green: 0, blue: 0.5, alpha: 1),
        SKColor(red: 0, green: 1, blue: 0.8, alpha: 1),
        SKColor(red: 0.5, green: 0, blue: 1, alpha: 1),
        SKColor(red: 1, green: 1, blue: 0, alpha: 1),
    ], pattern: "neon"),
    BrickTexture(name: "Candy", colors: [
        SKColor(red: 1, green: 0.6, blue: 0.8, alpha: 1),
        SKColor(red: 0.6, green: 0.9, blue: 1, alpha: 1),
        SKColor(red: 1, green: 0.9, blue: 0.5, alpha: 1),
        SKColor(red: 0.7, green: 1, blue: 0.7, alpha: 1),
    ], pattern: "candy"),
    BrickTexture(name: "Dark", colors: [
        SKColor(red: 0.6, green: 0.1, blue: 0.1, alpha: 1),
        SKColor(red: 0.5, green: 0.3, blue: 0.05, alpha: 1),
        SKColor(red: 0.1, green: 0.4, blue: 0.15, alpha: 1),
        SKColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1),
    ], pattern: "striped"),
    BrickTexture(name: "Mono", colors: [
        SKColor(white: 0.85, alpha: 1),
        SKColor(white: 0.65, alpha: 1),
        SKColor(white: 0.45, alpha: 1),
        SKColor(white: 0.3, alpha: 1),
    ], pattern: "gradient"),
]

// MARK: - Power-Up Definition

enum PowerUpType: String, CaseIterable {
    case multiBall, bigBat, bigBall, ghostBrick
    case ghostBall, speedyBall, punyBall

    var emoji: String {
        switch self {
        case .multiBall: return "🔮"
        case .bigBat: return "🏏"
        case .bigBall: return "⚽"
        case .ghostBrick: return "👻"
        case .ghostBall: return "💀"
        case .speedyBall: return "⚡"
        case .punyBall: return "🔬"
        }
    }

    var isPositive: Bool {
        switch self {
        case .multiBall, .bigBat, .bigBall, .ghostBrick:
            return true
        case .ghostBall, .speedyBall, .punyBall:
            return false
        }
    }

    var color: SKColor {
        return isPositive
            ? SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1)
            : SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1)
    }
}
