//
//  GameScene.swift
//  BrickBraker
//
//  Created by Upendra Sharma on 2/16/26.
//

import SpriteKit
import AVFoundation

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

// MARK: - Sound Manager

class SoundManager {
    private let engine = AVAudioEngine()
    private let bouncePlayer = AVAudioPlayerNode()
    private let breakPlayer = AVAudioPlayerNode()
    private let musicPlayer = AVAudioPlayerNode()
    private var bounceBuffer: AVAudioPCMBuffer?
    private var breakBuffer: AVAudioPCMBuffer?
    private var musicBuffer: AVAudioPCMBuffer?
    private var isMusicPlaying = false

    var musicEnabled = true
    var bounceEnabled = true

    init() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }

        engine.attach(bouncePlayer)
        engine.attach(breakPlayer)
        engine.attach(musicPlayer)

        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(bouncePlayer, to: engine.mainMixerNode, format: format)
        engine.connect(breakPlayer, to: engine.mainMixerNode, format: format)
        engine.connect(musicPlayer, to: engine.mainMixerNode, format: format)

        musicPlayer.volume = 0.18

        do { try engine.start() } catch { print("Audio engine start failed: \(error)") }

        let sr = format.sampleRate
        let ch = format.channelCount
        bounceBuffer = makeTone(frequency: 880, duration: 0.1, amplitude: 0.5,
                                decay: 25, sampleRate: sr, channels: ch)
        breakBuffer = makeBreak(duration: 0.15, amplitude: 0.6,
                                sampleRate: sr, channels: ch)
        musicBuffer = makeMusicLoop(sampleRate: sr, channels: ch)
    }

    func playBounce() {
        guard bounceEnabled, let buf = bounceBuffer else { return }
        bouncePlayer.scheduleBuffer(buf, at: nil, completionHandler: nil)
        if !bouncePlayer.isPlaying { bouncePlayer.play() }
    }

    func playBreak() {
        guard bounceEnabled, let buf = breakBuffer else { return }
        breakPlayer.scheduleBuffer(buf, at: nil, completionHandler: nil)
        if !breakPlayer.isPlaying { breakPlayer.play() }
    }

    func startMusic() {
        guard musicEnabled, let buf = musicBuffer, !isMusicPlaying else { return }
        isMusicPlaying = true
        musicPlayer.scheduleBuffer(buf, at: nil, options: .loops, completionHandler: nil)
        musicPlayer.play()
    }

    func stopMusic() {
        musicPlayer.stop()
        isMusicPlaying = false
    }

    // MARK: - Tone Generation

    private func makeTone(frequency: Double, duration: Double, amplitude: Float,
                          decay: Double, sampleRate: Double, channels: UInt32) -> AVAudioPCMBuffer? {
        let count = AVAudioFrameCount(sampleRate * duration)
        guard let fmt = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels),
              let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: count) else { return nil }
        buf.frameLength = count
        for ch in 0..<Int(channels) {
            let data = buf.floatChannelData![ch]
            for i in 0..<Int(count) {
                let t = Double(i) / sampleRate
                data[i] = amplitude * Float(exp(-t * decay)) * sin(Float(2.0 * .pi * frequency * t))
            }
        }
        return buf
    }

    private func makeBreak(duration: Double, amplitude: Float,
                           sampleRate: Double, channels: UInt32) -> AVAudioPCMBuffer? {
        let count = AVAudioFrameCount(sampleRate * duration)
        guard let fmt = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels),
              let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: count) else { return nil }
        buf.frameLength = count
        for ch in 0..<Int(channels) {
            let data = buf.floatChannelData![ch]
            for i in 0..<Int(count) {
                let t = Double(i) / sampleRate
                let env = Float(exp(-t * 20))
                let noise = Float.random(in: -1...1)
                let tone = sin(Float(2.0 * .pi * 300 * t)) + sin(Float(2.0 * .pi * 600 * t))
                data[i] = amplitude * env * (noise * 0.4 + tone * 0.3)
            }
        }
        return buf
    }

    private func makeMusicLoop(sampleRate: Double, channels: UInt32) -> AVAudioPCMBuffer? {
        let bpm: Double = 140
        let beatDuration = 60.0 / bpm
        let melody: [(freq: Double, beats: Double)] = [
            (523.25, 0.5), (587.33, 0.5), (659.25, 0.5), (783.99, 0.5),
            (659.25, 1.0), (523.25, 0.5), (587.33, 0.5),
            (783.99, 0.5), (659.25, 0.5), (523.25, 1.0),
            (0, 0.5),
            (392.00, 0.5), (440.00, 0.5), (523.25, 0.5), (659.25, 0.5),
            (523.25, 1.0), (440.00, 0.5), (392.00, 0.5),
            (523.25, 0.5), (440.00, 0.5), (392.00, 1.0),
            (0, 0.5),
            (783.99, 0.5), (659.25, 0.5), (783.99, 0.5), (880.00, 0.5),
            (783.99, 1.0), (659.25, 0.5), (523.25, 0.5),
            (587.33, 0.5), (523.25, 0.5), (440.00, 1.0),
            (0, 0.5),
            (523.25, 0.5), (587.33, 0.5), (659.25, 0.5), (523.25, 0.5),
            (440.00, 0.5), (392.00, 0.5), (440.00, 0.5), (523.25, 0.5),
            (523.25, 1.5), (0, 0.5),
        ]
        var totalBeats: Double = 0
        for note in melody { totalBeats += note.beats }
        let totalDuration = totalBeats * beatDuration
        let totalSamples = AVAudioFrameCount(sampleRate * totalDuration)
        guard let fmt = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels),
              let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: totalSamples) else { return nil }
        buf.frameLength = totalSamples
        var sampleOffset = 0
        let amplitude: Float = 0.35
        for note in melody {
            let noteSamples = Int(note.beats * beatDuration * sampleRate)
            let freq = note.freq
            for ch in 0..<Int(channels) {
                let data = buf.floatChannelData![ch]
                for i in 0..<noteSamples {
                    let idx = sampleOffset + i
                    guard idx < Int(totalSamples) else { break }
                    if freq == 0 {
                        data[idx] = 0
                    } else {
                        let t = Double(i) / sampleRate
                        let noteDur = note.beats * beatDuration
                        let attack = min(Float(t / 0.01), 1.0)
                        let release = Float(max(0, min(1, (noteDur - t) / 0.05)))
                        let env = attack * release
                        let fundamental = sin(Float(2.0 * .pi * freq * t))
                        let third = sin(Float(2.0 * .pi * freq * 3.0 * t)) * 0.33
                        let fifth = sin(Float(2.0 * .pi * freq * 5.0 * t)) * 0.2
                        data[idx] = amplitude * env * (fundamental + third + fifth)
                    }
                }
            }
            sampleOffset += noteSamples
        }
        return buf
    }
}

// MARK: - Game Scene

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Game Objects
    private var paddle: SKSpriteNode!
    private var ball: SKSpriteNode!
    private var bricks: [SKSpriteNode] = []

    // MARK: - Game State
    private var livesRemaining = 3
    private var score = 0
    private var isGameOver = false
    private var ballLaunched = false
    private var waitingToLaunch = true

    // MARK: - Settings State
    private var selectedBallSkin = 0
    private var selectedPaddleSkin = 0
    private var selectedBrickTexture = 0
    private var settingsOpen = false
    private var settingsNodes: [SKNode] = []
    private var gamePausedForSettings = false

    // Start-screen skin picker (shown only on TAP TO START)
    private var skinPickerNodes: [SKNode] = []
    private var showingSkinPicker = true

    // MARK: - UI Nodes
    private var livesLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var messageLabel: SKLabelNode!
    private var subMessageLabel: SKLabelNode!
    private var settingsButton: SKLabelNode!

    // MARK: - Sound
    private var soundManager: SoundManager!

    // MARK: - Physics Categories
    private let ballCategory:    UInt32 = 0x1 << 0
    private let paddleCategory:  UInt32 = 0x1 << 1
    private let brickCategory:   UInt32 = 0x1 << 2
    private let bottomCategory:  UInt32 = 0x1 << 3
    private let wallCategory:    UInt32 = 0x1 << 4

    // MARK: - Layout
    private var safeAreaTop: CGFloat = 50
    private var hudHeight: CGFloat = 44
    private let paddleYOffset: CGFloat = 50
    private let brickRows = 4
    private let brickSpacing: CGFloat = 4
    private let brickMoveInterval: TimeInterval = 6.0
    private let brickMoveDistance: CGFloat = 15.0
    private let ballSpeed: CGFloat = 420
    private var hudDidLayout = false

    private var paddleWidth: CGFloat = 100
    private var paddleHeight: CGFloat = 14
    private var ballRadius: CGFloat = 8
    private var brickWidth: CGFloat = 60
    private var brickHeight: CGFloat = 22
    private var brickColumns = 5

    private var gameArea: CGRect {
        let topReserved = safeAreaTop + hudHeight
        return CGRect(x: frame.minX, y: frame.minY,
                      width: frame.width, height: frame.height - topReserved)
    }

    // MARK: - Safe Area Callback

    func updateSafeAreaTop(_ inset: CGFloat) {
        guard !hudDidLayout else { return }
        safeAreaTop = max(inset, 20)
        hudDidLayout = true
        rebuildLayout()
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        soundManager = SoundManager()
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1)
        rebuildLayout()
    }

    private func rebuildLayout() {
        removeAllChildren()
        bricks.removeAll()
        skinPickerNodes.removeAll()
        settingsNodes.removeAll()
        settingsOpen = false

        calculateSizes()
        setupGameAreaBorder()
        setupWalls()
        setupPaddle()
        setupBall()
        setupBricks()
        setupHUD()
        showingSkinPicker = true
        setupSkinPicker()
        showMessage("TAP TO START", sub: "Choose your style below!")
    }

    private func calculateSizes() {
        let w = frame.width
        paddleWidth = w * 0.26
        paddleHeight = 14
        ballRadius = 8
        brickColumns = max(4, Int(w / 72))
        brickWidth = (w - CGFloat(brickColumns + 1) * brickSpacing) / CGFloat(brickColumns)
        brickHeight = 22
    }

    // MARK: - Game Border

    private func setupGameAreaBorder() {
        let area = gameArea
        let path = CGMutablePath()
        path.move(to: CGPoint(x: area.minX + 1, y: area.minY))
        path.addLine(to: CGPoint(x: area.minX + 1, y: area.maxY))
        path.addLine(to: CGPoint(x: area.maxX - 1, y: area.maxY))
        path.addLine(to: CGPoint(x: area.maxX - 1, y: area.minY))
        let border = SKShapeNode(path: path)
        border.strokeColor = SKColor(red: 0.5, green: 0.6, blue: 0.9, alpha: 1.0)
        border.lineWidth = 3
        border.zPosition = 2
        addChild(border)
    }

    // MARK: - Physics Walls

    private func setupWalls() {
        let area = gameArea
        let topWall = SKNode()
        topWall.position = CGPoint(x: area.midX, y: area.maxY)
        topWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -area.width / 2, y: 0),
                                            to: CGPoint(x: area.width / 2, y: 0))
        configureWall(topWall); addChild(topWall)

        let leftWall = SKNode()
        leftWall.position = CGPoint(x: area.minX, y: area.midY)
        leftWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: -area.height / 2),
                                             to: CGPoint(x: 0, y: area.height / 2))
        configureWall(leftWall); addChild(leftWall)

        let rightWall = SKNode()
        rightWall.position = CGPoint(x: area.maxX, y: area.midY)
        rightWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: -area.height / 2),
                                              to: CGPoint(x: 0, y: area.height / 2))
        configureWall(rightWall); addChild(rightWall)

        let bottomNode = SKNode()
        bottomNode.position = CGPoint(x: area.midX, y: area.minY - 40)
        bottomNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -area.width / 2, y: 0),
                                               to: CGPoint(x: area.width / 2, y: 0))
        bottomNode.physicsBody?.categoryBitMask = bottomCategory
        bottomNode.physicsBody?.contactTestBitMask = ballCategory
        bottomNode.physicsBody?.collisionBitMask = 0
        addChild(bottomNode)
    }

    private func configureWall(_ node: SKNode) {
        node.physicsBody?.friction = 0
        node.physicsBody?.restitution = 1.0
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = wallCategory
        node.physicsBody?.contactTestBitMask = ballCategory
        node.physicsBody?.collisionBitMask = ballCategory
    }

    // MARK: - Paddle

    private func setupPaddle() {
        let area = gameArea
        paddle = SKSpriteNode(color: .clear, size: CGSize(width: paddleWidth, height: paddleHeight))
        paddle.position = CGPoint(x: area.midX, y: area.minY + paddleYOffset)
        paddle.name = "paddle"
        paddle.zPosition = 3
        applyPaddleSkin()
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.friction = 0
        paddle.physicsBody?.restitution = 1.0
        paddle.physicsBody?.categoryBitMask = paddleCategory
        paddle.physicsBody?.contactTestBitMask = ballCategory
        paddle.physicsBody?.collisionBitMask = ballCategory
        addChild(paddle)
    }

    private func applyPaddleSkin() {
        paddle.removeAllChildren()
        let skin = paddleSkins[selectedPaddleSkin]
        let shape = SKShapeNode(rectOf: paddle.size, cornerRadius: paddleHeight / 2)
        shape.fillColor = skin.fillColor
        shape.strokeColor = skin.strokeColor
        shape.lineWidth = 1.5
        shape.glowWidth = skin.glowWidth
        paddle.addChild(shape)
    }

    // MARK: - Ball

    private func setupBall() {
        ball = SKSpriteNode(color: .clear, size: CGSize(width: ballRadius * 2, height: ballRadius * 2))
        ball.name = "ball"
        ball.zPosition = 4
        applyBallSkin()
        let body = SKPhysicsBody(circleOfRadius: ballRadius)
        body.friction = 0; body.restitution = 1.0
        body.linearDamping = 0; body.angularDamping = 0; body.allowsRotation = false
        body.categoryBitMask = ballCategory
        body.contactTestBitMask = paddleCategory | brickCategory | bottomCategory | wallCategory
        body.collisionBitMask = paddleCategory | brickCategory | wallCategory
        ball.physicsBody = body
        addChild(ball)
        placeBallOnPaddle()
    }

    private func applyBallSkin() {
        ball.removeAllChildren()
        let skin = ballSkins[selectedBallSkin]
        let glow = SKShapeNode(circleOfRadius: ballRadius)
        glow.fillColor = skin.color
        glow.strokeColor = skin.strokeColor
        glow.lineWidth = 1.5; glow.glowWidth = 3
        ball.addChild(glow)
        let faceLabel = SKLabelNode(text: skin.face)
        faceLabel.fontSize = ballRadius * 1.5
        faceLabel.verticalAlignmentMode = .center
        faceLabel.horizontalAlignmentMode = .center
        faceLabel.zPosition = 1
        ball.addChild(faceLabel)
    }

    private func placeBallOnPaddle() {
        ball.physicsBody = nil
        ball.position = CGPoint(x: paddle.position.x,
                                y: paddle.position.y + paddleHeight / 2 + ballRadius + 4)
        ballLaunched = false
        waitingToLaunch = true
    }

    // MARK: - Bricks

    private func setupBricks() {
        let area = gameArea
        let texture = brickTextures[selectedBrickTexture]
        let topGap: CGFloat = 70
        let startY = area.maxY - topGap

        for row in 0..<brickRows {
            for col in 0..<brickColumns {
                let baseColor = texture.colors[row % texture.colors.count]
                let brick = SKSpriteNode(
                    color: baseColor,
                    size: CGSize(width: brickWidth - 2, height: brickHeight)
                )
                brick.name = "brick"
                brick.zPosition = 3

                let xPos = frame.minX + brickSpacing + brickWidth / 2
                              + CGFloat(col) * (brickWidth + brickSpacing)
                let yPos = startY - CGFloat(row) * (brickHeight + brickSpacing)
                brick.position = CGPoint(x: xPos, y: yPos)

                // Apply texture pattern
                applyBrickPattern(to: brick, texture: texture, row: row, col: col)

                brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
                brick.physicsBody?.isDynamic = false
                brick.physicsBody?.friction = 0
                brick.physicsBody?.restitution = 1.0
                brick.physicsBody?.categoryBitMask = brickCategory
                brick.physicsBody?.contactTestBitMask = ballCategory
                brick.physicsBody?.collisionBitMask = ballCategory

                addChild(brick)
                bricks.append(brick)
            }
        }
    }

    private func applyBrickPattern(to brick: SKSpriteNode, texture: BrickTexture, row: Int, col: Int) {
        let bw = brickWidth - 2
        let bh = brickHeight

        switch texture.pattern {
        case "neon":
            let outline = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: 3)
            outline.fillColor = .clear
            outline.strokeColor = texture.colors[row % texture.colors.count]
            outline.lineWidth = 2
            outline.glowWidth = 3
            brick.color = SKColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1)
            brick.addChild(outline)

        case "candy":
            // Add small white highlight stripe
            let stripe = SKShapeNode(rectOf: CGSize(width: bw * 0.6, height: 2))
            stripe.fillColor = SKColor(white: 1, alpha: 0.4)
            stripe.strokeColor = .clear
            stripe.position = CGPoint(x: 0, y: bh * 0.25)
            brick.addChild(stripe)
            // Rounded feel
            let border = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: 4)
            border.fillColor = .clear
            border.strokeColor = SKColor(white: 1, alpha: 0.25)
            border.lineWidth = 1
            brick.addChild(border)

        case "striped":
            // Horizontal lines across brick
            for s in stride(from: -bh / 2 + 4, to: bh / 2, by: 5) {
                let line = SKShapeNode(rectOf: CGSize(width: bw, height: 1))
                line.fillColor = SKColor(white: 0, alpha: 0.3)
                line.strokeColor = .clear
                line.position = CGPoint(x: 0, y: s)
                brick.addChild(line)
            }

        case "gradient":
            // Lighter top half overlay
            let top = SKSpriteNode(
                color: SKColor(white: 1, alpha: 0.15),
                size: CGSize(width: bw, height: bh / 2)
            )
            top.position = CGPoint(x: 0, y: bh / 4)
            brick.addChild(top)

        default: // "solid"
            break
        }
    }

    // MARK: - Skin Picker (Start Screen)

    private func setupSkinPicker() {
        let area = gameArea
        let centerX = frame.midX
        let pickerY = area.midY - 70
        let spacing: CGFloat = 40

        let ballLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        ballLabel.text = "Ball:"
        ballLabel.fontSize = 15
        ballLabel.fontColor = SKColor(white: 0.7, alpha: 1)
        ballLabel.position = CGPoint(x: centerX - 110, y: pickerY + 30)
        ballLabel.horizontalAlignmentMode = .right
        ballLabel.zPosition = 25
        addChild(ballLabel); skinPickerNodes.append(ballLabel)

        let ballStartX = centerX - 90
        for i in 0..<ballSkins.count {
            let skin = ballSkins[i]
            let node = SKShapeNode(circleOfRadius: 14)
            node.fillColor = skin.color
            node.strokeColor = (i == selectedBallSkin) ? .white : SKColor(white: 0.4, alpha: 1)
            node.lineWidth = (i == selectedBallSkin) ? 3 : 1.5
            node.position = CGPoint(x: ballStartX + CGFloat(i) * spacing, y: pickerY + 32)
            node.zPosition = 25
            node.name = "ballSkin_\(i)"
            node.glowWidth = (i == selectedBallSkin) ? 2 : 0
            addChild(node); skinPickerNodes.append(node)
            let face = SKLabelNode(text: skin.face)
            face.fontSize = 12
            face.verticalAlignmentMode = .center; face.horizontalAlignmentMode = .center
            face.zPosition = 1
            node.addChild(face)
        }

        let paddleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        paddleLabel.text = "Paddle:"
        paddleLabel.fontSize = 15
        paddleLabel.fontColor = SKColor(white: 0.7, alpha: 1)
        paddleLabel.position = CGPoint(x: centerX - 110, y: pickerY - 20)
        paddleLabel.horizontalAlignmentMode = .right
        paddleLabel.zPosition = 25
        addChild(paddleLabel); skinPickerNodes.append(paddleLabel)

        let paddleStartX = centerX - 90
        for i in 0..<paddleSkins.count {
            let skin = paddleSkins[i]
            let node = SKShapeNode(rectOf: CGSize(width: 36, height: 10), cornerRadius: 5)
            node.fillColor = skin.fillColor
            node.strokeColor = (i == selectedPaddleSkin) ? .white : SKColor(white: 0.4, alpha: 1)
            node.lineWidth = (i == selectedPaddleSkin) ? 3 : 1.5
            node.position = CGPoint(x: paddleStartX + CGFloat(i) * spacing, y: pickerY - 18)
            node.zPosition = 25
            node.name = "paddleSkin_\(i)"
            node.glowWidth = (i == selectedPaddleSkin) ? 2 : 0
            addChild(node); skinPickerNodes.append(node)
        }
    }

    private func removeSkinPicker() {
        for node in skinPickerNodes { node.removeFromParent() }
        skinPickerNodes.removeAll()
        showingSkinPicker = false
    }

    private func updateStartPickerHighlights() {
        for node in skinPickerNodes {
            guard let name = node.name else { continue }
            if name.hasPrefix("ballSkin_"), let shape = node as? SKShapeNode {
                let idx = Int(name.replacingOccurrences(of: "ballSkin_", with: "")) ?? -1
                shape.strokeColor = (idx == selectedBallSkin) ? .white : SKColor(white: 0.4, alpha: 1)
                shape.lineWidth = (idx == selectedBallSkin) ? 3 : 1.5
                shape.glowWidth = (idx == selectedBallSkin) ? 2 : 0
            }
            if name.hasPrefix("paddleSkin_"), let shape = node as? SKShapeNode {
                let idx = Int(name.replacingOccurrences(of: "paddleSkin_", with: "")) ?? -1
                shape.strokeColor = (idx == selectedPaddleSkin) ? .white : SKColor(white: 0.4, alpha: 1)
                shape.lineWidth = (idx == selectedPaddleSkin) ? 3 : 1.5
                shape.glowWidth = (idx == selectedPaddleSkin) ? 2 : 0
            }
        }
    }

    // MARK: - HUD

    private func setupHUD() {
        let area = gameArea
        let hudCenterY = area.maxY + hudHeight / 2

        let hudBG = SKSpriteNode(
            color: SKColor(red: 0.08, green: 0.08, blue: 0.15, alpha: 1),
            size: CGSize(width: frame.width, height: hudHeight + safeAreaTop)
        )
        hudBG.position = CGPoint(x: frame.midX, y: frame.maxY - (hudHeight + safeAreaTop) / 2)
        hudBG.zPosition = 8
        addChild(hudBG)

        livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        livesLabel.fontSize = 20; livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .left; livesLabel.verticalAlignmentMode = .center
        livesLabel.position = CGPoint(x: frame.minX + 16, y: hudCenterY)
        livesLabel.zPosition = 10
        updateLivesDisplay()
        addChild(livesLabel)

        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 20; scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .right; scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: frame.maxX - 50, y: hudCenterY)
        scoreLabel.zPosition = 10; scoreLabel.text = "Score: 0"
        addChild(scoreLabel)

        // Settings gear button (top-right)
        settingsButton = SKLabelNode(text: "\u{2699}\u{FE0F}")
        settingsButton.fontSize = 26
        settingsButton.verticalAlignmentMode = .center
        settingsButton.horizontalAlignmentMode = .center
        settingsButton.position = CGPoint(x: frame.maxX - 24, y: hudCenterY)
        settingsButton.zPosition = 12
        settingsButton.name = "settingsButton"
        addChild(settingsButton)

        let gameMidY = area.midY
        messageLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        messageLabel.fontSize = 34; messageLabel.fontColor = .white
        messageLabel.horizontalAlignmentMode = .center; messageLabel.verticalAlignmentMode = .center
        messageLabel.position = CGPoint(x: frame.midX, y: gameMidY + 20)
        messageLabel.zPosition = 20; messageLabel.isHidden = true
        addChild(messageLabel)

        subMessageLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subMessageLabel.fontSize = 17
        subMessageLabel.fontColor = SKColor(white: 0.75, alpha: 1)
        subMessageLabel.horizontalAlignmentMode = .center; subMessageLabel.verticalAlignmentMode = .center
        subMessageLabel.position = CGPoint(x: frame.midX, y: gameMidY - 20)
        subMessageLabel.zPosition = 20; subMessageLabel.isHidden = true
        addChild(subMessageLabel)
    }

    private func updateLivesDisplay() {
        var text = "Lives: "
        for i in 0..<3 { text += i < livesRemaining ? "● " : "○ " }
        livesLabel.text = text.trimmingCharacters(in: .whitespaces)
    }

    private func showMessage(_ text: String, sub: String = "") {
        messageLabel.text = text; messageLabel.isHidden = false
        subMessageLabel.text = sub; subMessageLabel.isHidden = sub.isEmpty
    }

    private func hideMessage() {
        messageLabel.isHidden = true; subMessageLabel.isHidden = true
    }

    // MARK: - Settings Overlay

    private func openSettings() {
        guard !settingsOpen else { return }
        settingsOpen = true

        // Pause the game if ball is in play
        if ballLaunched {
            gamePausedForSettings = true
            self.isPaused = true
        }

        let area = gameArea
        let panelW: CGFloat = frame.width - 40
        let panelH: CGFloat = 380
        let panelCenter = CGPoint(x: frame.midX, y: area.midY)

        // Dim background
        let dim = SKSpriteNode(color: SKColor(white: 0, alpha: 0.7),
                               size: CGSize(width: frame.width, height: frame.height))
        dim.position = CGPoint(x: frame.midX, y: frame.midY)
        dim.zPosition = 90; dim.name = "settingsDim"
        addChild(dim); settingsNodes.append(dim)

        // Panel background
        let panel = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 16)
        panel.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.95)
        panel.strokeColor = SKColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 1)
        panel.lineWidth = 2; panel.position = panelCenter; panel.zPosition = 95
        addChild(panel); settingsNodes.append(panel)

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "SETTINGS"; title.fontSize = 24; title.fontColor = .white
        title.position = CGPoint(x: panelCenter.x, y: panelCenter.y + panelH / 2 - 35)
        title.zPosition = 100
        addChild(title); settingsNodes.append(title)

        // Close button
        let closeBtn = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeBtn.text = "X"; closeBtn.fontSize = 22; closeBtn.fontColor = SKColor(white: 0.6, alpha: 1)
        closeBtn.position = CGPoint(x: panelCenter.x + panelW / 2 - 25,
                                     y: panelCenter.y + panelH / 2 - 35)
        closeBtn.zPosition = 101; closeBtn.name = "closeSettings"
        addChild(closeBtn); settingsNodes.append(closeBtn)

        var yPos = panelCenter.y + panelH / 2 - 75
        let rowHeight: CGFloat = 50
        let leftX = panelCenter.x - panelW / 2 + 20
        let rightX = panelCenter.x + panelW / 2 - 20

        // --- Music toggle ---
        addSettingsLabel("Music", at: CGPoint(x: leftX, y: yPos), align: .left)
        addToggle(name: "toggleMusic", on: soundManager.musicEnabled,
                  at: CGPoint(x: rightX - 30, y: yPos))
        yPos -= rowHeight

        // --- Bounce sound toggle ---
        addSettingsLabel("Bounce Sound", at: CGPoint(x: leftX, y: yPos), align: .left)
        addToggle(name: "toggleBounce", on: soundManager.bounceEnabled,
                  at: CGPoint(x: rightX - 30, y: yPos))
        yPos -= rowHeight

        // --- Ball skin ---
        addSettingsLabel("Ball Skin", at: CGPoint(x: leftX, y: yPos), align: .left)
        let ballRowX = panelCenter.x - CGFloat(ballSkins.count - 1) * 18
        for i in 0..<ballSkins.count {
            let skin = ballSkins[i]
            let node = SKShapeNode(circleOfRadius: 12)
            node.fillColor = skin.color
            node.strokeColor = (i == selectedBallSkin) ? .white : SKColor(white: 0.3, alpha: 1)
            node.lineWidth = (i == selectedBallSkin) ? 2.5 : 1
            node.position = CGPoint(x: ballRowX + CGFloat(i) * 36, y: yPos)
            node.zPosition = 100; node.name = "sBall_\(i)"
            node.glowWidth = (i == selectedBallSkin) ? 2 : 0
            addChild(node); settingsNodes.append(node)
            let face = SKLabelNode(text: skin.face)
            face.fontSize = 10; face.verticalAlignmentMode = .center
            face.horizontalAlignmentMode = .center; face.zPosition = 1
            node.addChild(face)
        }
        yPos -= rowHeight

        // --- Paddle skin ---
        addSettingsLabel("Paddle Skin", at: CGPoint(x: leftX, y: yPos), align: .left)
        let padRowX = panelCenter.x - CGFloat(paddleSkins.count - 1) * 18
        for i in 0..<paddleSkins.count {
            let skin = paddleSkins[i]
            let node = SKShapeNode(rectOf: CGSize(width: 30, height: 8), cornerRadius: 4)
            node.fillColor = skin.fillColor
            node.strokeColor = (i == selectedPaddleSkin) ? .white : SKColor(white: 0.3, alpha: 1)
            node.lineWidth = (i == selectedPaddleSkin) ? 2.5 : 1
            node.position = CGPoint(x: padRowX + CGFloat(i) * 36, y: yPos)
            node.zPosition = 100; node.name = "sPad_\(i)"
            node.glowWidth = (i == selectedPaddleSkin) ? 2 : 0
            addChild(node); settingsNodes.append(node)
        }
        yPos -= rowHeight

        // --- Brick texture ---
        addSettingsLabel("Brick Style", at: CGPoint(x: leftX, y: yPos), align: .left)
        let brickRowX = panelCenter.x - CGFloat(brickTextures.count - 1) * 18
        for i in 0..<brickTextures.count {
            let tex = brickTextures[i]
            let node = SKShapeNode(rectOf: CGSize(width: 30, height: 14), cornerRadius: 3)
            node.fillColor = tex.colors[0]
            node.strokeColor = (i == selectedBrickTexture) ? .white : SKColor(white: 0.3, alpha: 1)
            node.lineWidth = (i == selectedBrickTexture) ? 2.5 : 1
            node.position = CGPoint(x: brickRowX + CGFloat(i) * 36, y: yPos)
            node.zPosition = 100; node.name = "sBrick_\(i)"
            node.glowWidth = (i == selectedBrickTexture) ? 2 : 0
            addChild(node); settingsNodes.append(node)

            // Name label below
            let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            nameLabel.text = tex.name; nameLabel.fontSize = 8
            nameLabel.fontColor = SKColor(white: 0.5, alpha: 1)
            nameLabel.position = CGPoint(x: 0, y: -14)
            nameLabel.horizontalAlignmentMode = .center
            nameLabel.verticalAlignmentMode = .center
            node.addChild(nameLabel)
        }
        yPos -= rowHeight

        // --- Done button ---
        let doneBtn = SKShapeNode(rectOf: CGSize(width: 120, height: 36), cornerRadius: 18)
        doneBtn.fillColor = SKColor(red: 0.2, green: 0.5, blue: 1, alpha: 1)
        doneBtn.strokeColor = SKColor(red: 0.4, green: 0.7, blue: 1, alpha: 1)
        doneBtn.lineWidth = 1.5; doneBtn.glowWidth = 2
        doneBtn.position = CGPoint(x: panelCenter.x, y: yPos + 10)
        doneBtn.zPosition = 100; doneBtn.name = "closeSettings"
        addChild(doneBtn); settingsNodes.append(doneBtn)

        let doneTxt = SKLabelNode(fontNamed: "AvenirNext-Bold")
        doneTxt.text = "DONE"; doneTxt.fontSize = 16; doneTxt.fontColor = .white
        doneTxt.verticalAlignmentMode = .center; doneTxt.horizontalAlignmentMode = .center
        doneTxt.zPosition = 1
        doneBtn.addChild(doneTxt)
    }

    private func addSettingsLabel(_ text: String, at pos: CGPoint,
                                   align: SKLabelHorizontalAlignmentMode) {
        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text; label.fontSize = 15; label.fontColor = SKColor(white: 0.8, alpha: 1)
        label.position = pos; label.horizontalAlignmentMode = align
        label.verticalAlignmentMode = .center; label.zPosition = 100
        addChild(label); settingsNodes.append(label)
    }

    private func addToggle(name: String, on: Bool, at pos: CGPoint) {
        let bg = SKShapeNode(rectOf: CGSize(width: 50, height: 26), cornerRadius: 13)
        bg.fillColor = on ? SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1)
                          : SKColor(white: 0.3, alpha: 1)
        bg.strokeColor = .clear; bg.position = pos; bg.zPosition = 100; bg.name = name
        addChild(bg); settingsNodes.append(bg)

        let knob = SKShapeNode(circleOfRadius: 10)
        knob.fillColor = .white; knob.strokeColor = .clear
        knob.position = CGPoint(x: on ? 12 : -12, y: 0)
        knob.zPosition = 1; knob.name = "knob"
        bg.addChild(knob)

        let stateLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        stateLabel.text = on ? "ON" : "OFF"
        stateLabel.fontSize = 9; stateLabel.fontColor = .white
        stateLabel.position = CGPoint(x: on ? -8 : 8, y: 0)
        stateLabel.verticalAlignmentMode = .center; stateLabel.horizontalAlignmentMode = .center
        stateLabel.zPosition = 1; stateLabel.name = "stateLabel"
        bg.addChild(stateLabel)
    }

    private func closeSettings() {
        for node in settingsNodes { node.removeFromParent() }
        settingsNodes.removeAll()
        settingsOpen = false

        if gamePausedForSettings {
            gamePausedForSettings = false
            self.isPaused = false
        }
    }

    private func handleSettingsTap(_ location: CGPoint) {
        let tapped = nodes(at: location)
        for node in tapped {
            guard let name = node.name else { continue }

            if name == "closeSettings" {
                closeSettings()
                return
            }

            if name == "toggleMusic", let bg = node as? SKShapeNode {
                soundManager.musicEnabled = !soundManager.musicEnabled
                let on = soundManager.musicEnabled
                bg.fillColor = on ? SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1)
                                  : SKColor(white: 0.3, alpha: 1)
                if let knob = bg.childNode(withName: "knob") {
                    knob.position.x = on ? 12 : -12
                }
                if let stateLabel = bg.childNode(withName: "stateLabel") as? SKLabelNode {
                    stateLabel.text = on ? "ON" : "OFF"
                    stateLabel.position.x = on ? -8 : 8
                }
                if !on { soundManager.stopMusic() }
                else if ballLaunched || gamePausedForSettings { soundManager.startMusic() }
                return
            }

            if name == "toggleBounce", let bg = node as? SKShapeNode {
                soundManager.bounceEnabled = !soundManager.bounceEnabled
                let on = soundManager.bounceEnabled
                bg.fillColor = on ? SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1)
                                  : SKColor(white: 0.3, alpha: 1)
                if let knob = bg.childNode(withName: "knob") {
                    knob.position.x = on ? 12 : -12
                }
                if let stateLabel = bg.childNode(withName: "stateLabel") as? SKLabelNode {
                    stateLabel.text = on ? "ON" : "OFF"
                    stateLabel.position.x = on ? -8 : 8
                }
                return
            }

            if name.hasPrefix("sBall_") {
                if let idx = Int(name.replacingOccurrences(of: "sBall_", with: "")) {
                    selectedBallSkin = idx
                    applyBallSkin()
                    refreshSettingsHighlights()
                    return
                }
            }

            if name.hasPrefix("sPad_") {
                if let idx = Int(name.replacingOccurrences(of: "sPad_", with: "")) {
                    selectedPaddleSkin = idx
                    applyPaddleSkin()
                    refreshSettingsHighlights()
                    return
                }
            }

            if name.hasPrefix("sBrick_") {
                if let idx = Int(name.replacingOccurrences(of: "sBrick_", with: "")) {
                    selectedBrickTexture = idx
                    // Rebuild bricks with new texture (only if waiting to launch or game over)
                    if waitingToLaunch || isGameOver {
                        for brick in bricks { brick.removeFromParent() }
                        bricks.removeAll()
                        setupBricks()
                    }
                    refreshSettingsHighlights()
                    return
                }
            }
        }
    }

    private func refreshSettingsHighlights() {
        for node in settingsNodes {
            guard let name = node.name else { continue }
            if name.hasPrefix("sBall_"), let shape = node as? SKShapeNode {
                let idx = Int(name.replacingOccurrences(of: "sBall_", with: "")) ?? -1
                shape.strokeColor = (idx == selectedBallSkin) ? .white : SKColor(white: 0.3, alpha: 1)
                shape.lineWidth = (idx == selectedBallSkin) ? 2.5 : 1
                shape.glowWidth = (idx == selectedBallSkin) ? 2 : 0
            }
            if name.hasPrefix("sPad_"), let shape = node as? SKShapeNode {
                let idx = Int(name.replacingOccurrences(of: "sPad_", with: "")) ?? -1
                shape.strokeColor = (idx == selectedPaddleSkin) ? .white : SKColor(white: 0.3, alpha: 1)
                shape.lineWidth = (idx == selectedPaddleSkin) ? 2.5 : 1
                shape.glowWidth = (idx == selectedPaddleSkin) ? 2 : 0
            }
            if name.hasPrefix("sBrick_"), let shape = node as? SKShapeNode {
                let idx = Int(name.replacingOccurrences(of: "sBrick_", with: "")) ?? -1
                shape.strokeColor = (idx == selectedBrickTexture) ? .white : SKColor(white: 0.3, alpha: 1)
                shape.lineWidth = (idx == selectedBrickTexture) ? 2.5 : 1
                shape.glowWidth = (idx == selectedBrickTexture) ? 2 : 0
            }
        }
    }

    // MARK: - Brick Movement

    private func startBrickMovement() {
        removeAction(forKey: "brickMovement")
        let wait = SKAction.wait(forDuration: brickMoveInterval)
        let move = SKAction.run { [weak self] in self?.moveBricksDown() }
        run(SKAction.repeatForever(SKAction.sequence([wait, move])), withKey: "brickMovement")
    }

    private func moveBricksDown() {
        guard !isGameOver else { return }
        for brick in bricks {
            let moveDown = SKAction.moveBy(x: 0, y: -brickMoveDistance, duration: 0.4)
            moveDown.timingMode = .easeInEaseOut
            brick.run(moveDown)
            if brick.position.y - brickHeight / 2 < paddle.position.y + paddleHeight {
                triggerGameOver(); return
            }
        }
    }

    // MARK: - Ball Launch

    private func launchBall() {
        guard waitingToLaunch, !isGameOver else { return }
        hideMessage()
        if showingSkinPicker { removeSkinPicker() }

        waitingToLaunch = false
        ballLaunched = true
        soundManager.startMusic()

        let body = SKPhysicsBody(circleOfRadius: ballRadius)
        body.friction = 0; body.restitution = 1.0
        body.linearDamping = 0; body.angularDamping = 0; body.allowsRotation = false
        body.categoryBitMask = 0
        body.contactTestBitMask = brickCategory | wallCategory
        body.collisionBitMask = brickCategory | wallCategory
        ball.physicsBody = body

        startBrickMovement()

        let angle = CGFloat.random(in: CGFloat.pi / 4 ... 3 * CGFloat.pi / 4)
        body.velocity = CGVector(dx: cos(angle) * ballSpeed, dy: sin(angle) * ballSpeed)

        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.35),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                self.ball.physicsBody?.categoryBitMask = self.ballCategory
                self.ball.physicsBody?.contactTestBitMask =
                    self.paddleCategory | self.brickCategory | self.bottomCategory | self.wallCategory
                self.ball.physicsBody?.collisionBitMask =
                    self.paddleCategory | self.brickCategory | self.wallCategory
            }
        ]), withKey: "enableBallPhysics")
    }

    // MARK: - Ball Speed

    private func normalizeBallVelocity() {
        guard let velocity = ball.physicsBody?.velocity else { return }
        let dx = velocity.dx; let dy = velocity.dy
        let speed = sqrt(dx * dx + dy * dy)
        guard speed > 0 else { return }
        var newDy = dy
        if abs(dy) < speed * 0.25 { newDy = (dy >= 0 ? 1 : -1) * speed * 0.25 }
        let newSpeed = sqrt(dx * dx + newDy * newDy)
        ball.physicsBody?.velocity = CGVector(dx: (dx / newSpeed) * ballSpeed,
                                              dy: (newDy / newSpeed) * ballSpeed)
    }

    // MARK: - Lose Life

    private func loseLife() {
        guard ballLaunched else { return }
        ballLaunched = false
        removeAction(forKey: "enableBallPhysics")

        livesRemaining -= 1
        updateLivesDisplay()

        if livesRemaining <= 0 {
            triggerGameOver()
        } else {
            let flash = SKSpriteNode(color: .red, size: gameArea.size)
            flash.position = CGPoint(x: gameArea.midX, y: gameArea.midY)
            flash.zPosition = 50; flash.alpha = 0.35
            addChild(flash)
            flash.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3),
                                         SKAction.removeFromParent()]))
            removeAction(forKey: "brickMovement")
            placeBallOnPaddle()
            showMessage("TAP TO CONTINUE",
                        sub: "\(livesRemaining) ball\(livesRemaining == 1 ? "" : "s") remaining")
        }
    }

    // MARK: - Game Over

    private func triggerGameOver() {
        guard !isGameOver else { return }
        isGameOver = true; ballLaunched = false
        ball.physicsBody = nil
        removeAction(forKey: "brickMovement")
        removeAction(forKey: "enableBallPhysics")
        soundManager.stopMusic()
        showMessage("GAME OVER", sub: "Score: \(score)  •  Tap to restart")
        messageLabel.fontColor = SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
    }

    // MARK: - Win

    private func checkWinCondition() {
        if bricks.isEmpty {
            isGameOver = true; ballLaunched = false
            ball.physicsBody = nil
            removeAction(forKey: "brickMovement")
            removeAction(forKey: "enableBallPhysics")
            soundManager.stopMusic()
            showMessage("YOU WIN!", sub: "Score: \(score)  •  Tap to play again")
            messageLabel.fontColor = SKColor(red: 0.2, green: 1, blue: 0.4, alpha: 1)
        }
    }

    // MARK: - Restart

    private func restartGame() {
        for brick in bricks { brick.removeFromParent() }
        bricks.removeAll()
        livesRemaining = 3; score = 0; isGameOver = false; ballLaunched = false
        updateLivesDisplay()
        scoreLabel.text = "Score: 0"
        messageLabel.fontColor = .white
        paddle.position.x = gameArea.midX
        placeBallOnPaddle()
        setupBricks()
        showingSkinPicker = true
        setupSkinPicker()
        showMessage("TAP TO START", sub: "Choose your style below!")
    }

    // MARK: - Brick Break Effect

    private func breakBrick(_ brick: SKSpriteNode) {
        soundManager.playBreak()
        score += 10; scoreLabel.text = "Score: \(score)"
        for _ in 0..<6 {
            let particle = SKSpriteNode(color: brick.color, size: CGSize(width: 5, height: 5))
            particle.position = brick.position; particle.zPosition = 5
            addChild(particle)
            let a = CGFloat.random(in: 0 ..< .pi * 2)
            let d = CGFloat.random(in: 20...60)
            let move = SKAction.moveBy(x: cos(a) * d, y: sin(a) * d, duration: 0.3)
            let fade = SKAction.fadeOut(withDuration: 0.3)
            particle.run(SKAction.sequence([SKAction.group([move, fade]),
                                            SKAction.removeFromParent()]))
        }
        if let idx = bricks.firstIndex(of: brick) { bricks.remove(at: idx) }
        brick.removeFromParent()
        checkWinCondition()
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        guard ballLaunched else { return }
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask
        let combined = maskA | maskB

        if combined == (ballCategory | brickCategory) {
            let brickNode = (maskA == brickCategory) ? contact.bodyA.node : contact.bodyB.node
            if let brick = brickNode as? SKSpriteNode { breakBrick(brick) }
            return
        }
        if combined == (ballCategory | paddleCategory) {
            soundManager.playBounce()
            guard let vel = ball.physicsBody?.velocity else { return }
            let hit = ball.position.x - paddle.position.x
            let norm = hit / (paddleWidth / 2)
            let angle = norm * (CGFloat.pi / 3)
            let speed = sqrt(vel.dx * vel.dx + vel.dy * vel.dy)
            ball.physicsBody?.velocity = CGVector(dx: sin(angle) * speed,
                                                  dy: abs(cos(angle) * speed))
            return
        }
        if combined == (ballCategory | wallCategory) {
            soundManager.playBounce(); return
        }
        if combined == (ballCategory | bottomCategory) {
            loseLife(); return
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Settings overlay intercepts all touches
        if settingsOpen {
            handleSettingsTap(location)
            return
        }

        // Settings gear button
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if node.name == "settingsButton" {
                openSettings()
                return
            }
        }

        // Start-screen skin picker
        if showingSkinPicker {
            for node in tappedNodes {
                guard let name = node.name else { continue }
                if name.hasPrefix("ballSkin_") {
                    if let idx = Int(name.replacingOccurrences(of: "ballSkin_", with: "")) {
                        selectedBallSkin = idx
                        applyBallSkin()
                        updateStartPickerHighlights()
                        return
                    }
                }
                if name.hasPrefix("paddleSkin_") {
                    if let idx = Int(name.replacingOccurrences(of: "paddleSkin_", with: "")) {
                        selectedPaddleSkin = idx
                        applyPaddleSkin()
                        updateStartPickerHighlights()
                        return
                    }
                }
            }
        }

        if isGameOver { restartGame(); return }
        if waitingToLaunch { movePaddleTo(x: location.x); launchBall(); return }
        movePaddleTo(x: location.x)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !settingsOpen else { return }
        guard let touch = touches.first else { return }
        movePaddleTo(x: touch.location(in: self).x)
    }

    private func movePaddleTo(x: CGFloat) {
        let half = paddleWidth / 2
        let area = gameArea
        let newX = min(area.maxX - half, max(area.minX + half, x))
        paddle.position.x = newX
        if waitingToLaunch { ball.position.x = newX }
    }

    // MARK: - Frame Update

    override func update(_ currentTime: TimeInterval) {
        if ballLaunched { normalizeBallVelocity() }
    }
}
