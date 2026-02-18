//
//  GameScene.swift
//  BrickBraker
//
//  Created by Upendra Sharma on 2/16/26.
//

import SpriteKit

// MARK: - Game Scene

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Game Objects
    var paddle: SKSpriteNode!
    var ball: SKSpriteNode!
    var bricks: [SKSpriteNode] = []
    var extraBalls: [SKSpriteNode] = []
    var powerUpNodes: [SKNode] = []

    // MARK: - Game State
    var livesRemaining = 3
    var score = 0
    var highScore = 0
    var isGameOver = false
    var ballLaunched = false
    var waitingToLaunch = true

    // MARK: - Settings State
    var selectedBallSkin = 0
    var selectedPaddleSkin = 0
    var selectedBrickTexture = 0
    var selectedStage = 1   // 1–30
    var highestUnlockedStage = 1  // stages 1…this are playable (persisted)
    var settingsOpen = false
    var stagesMenuOpen = false
    var settingsNodes: [SKNode] = []
    var stagesMenuNodes: [SKNode] = []
    var gamePausedForSettings = false

    // Start-screen skin picker (shown only on TAP TO START)
    var skinPickerNodes: [SKNode] = []
    var showingSkinPicker = true

    // MARK: - UI Nodes
    var livesLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var messageLabel: SKLabelNode!
    var subMessageLabel: SKLabelNode!
    var settingsButton: SKLabelNode!
    var powerUpIndicatorLabel: SKLabelNode!

    // MARK: - Sound
    var soundManager: SoundManager!

    // MARK: - Physics Categories
    let ballCategory:    UInt32 = 0x1 << 0
    let paddleCategory:  UInt32 = 0x1 << 1
    let brickCategory:   UInt32 = 0x1 << 2
    let bottomCategory:  UInt32 = 0x1 << 3
    let wallCategory:    UInt32 = 0x1 << 4
    let powerUpCategory: UInt32 = 0x1 << 5

    // MARK: - Power-Up State
    var activePowerUps: Set<PowerUpType> = []
    var ghostBrickActive = false
    var ghostBallActive = false
    var speedyBallActive = false
    var speedyBallHitCount = 0
    var punyBallActive = false
    var bigBatActive = false
    var bigBallActive = false
    var originalBallRadius: CGFloat = 8
    var originalPaddleWidth: CGFloat = 100
    var powerUpTimers: [PowerUpType: TimeInterval] = [:]

    // MARK: - Layout
    var safeAreaTop: CGFloat = 50
    var hudHeight: CGFloat = 44
    let paddleYOffset: CGFloat = 50
    let brickSpacing: CGFloat = 4

    // These are computed from the selected stage
    var stageParams: StageParams { StageParams.forStage(selectedStage) }
    var currentBrickRows: Int { stageParams.brickRows }
    var currentBrickMoveInterval: TimeInterval { stageParams.brickMoveInterval }
    var currentBrickMoveDistance: CGFloat { stageParams.brickMoveDistance }
    var currentBallSpeed: CGFloat { stageParams.ballSpeed }
    var currentPaddleWidthMultiplier: CGFloat { stageParams.paddleWidthMultiplier }
    var hudDidLayout = false

    var paddleWidth: CGFloat = 100
    var paddleHeight: CGFloat = 14
    var ballRadius: CGFloat = 8
    var brickWidth: CGFloat = 60
    var brickHeight: CGFloat = 22
    var brickColumns = 5

    var gameArea: CGRect {
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
        loadProgress()
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1)
        rebuildLayout()
    }

    // MARK: - Progress Persistence

    func loadProgress() {
        let defaults = UserDefaults.standard
        let saved = defaults.integer(forKey: "highestUnlockedStage")
        if saved > 0 {
            highestUnlockedStage = min(saved, 30)
            selectedStage = highestUnlockedStage  // resume where they left off
        }
        let savedHigh = defaults.integer(forKey: "highScore")
        if savedHigh > 0 { highScore = savedHigh }
    }

    func saveProgress() {
        let defaults = UserDefaults.standard
        defaults.set(highestUnlockedStage, forKey: "highestUnlockedStage")
        defaults.set(highScore, forKey: "highScore")
    }

    func rebuildLayout() {
        removeAllChildren()
        bricks.removeAll()
        extraBalls.removeAll()
        powerUpNodes.removeAll()
        skinPickerNodes.removeAll()
        settingsNodes.removeAll()
        stagesMenuNodes.removeAll()
        settingsOpen = false
        stagesMenuOpen = false

        // Reset power-up flags (can't call clearAllPowerUps here because ball/paddle aren't created yet)
        ghostBrickActive = false
        ghostBallActive = false
        speedyBallActive = false
        speedyBallHitCount = 0
        punyBallActive = false
        bigBatActive = false
        bigBallActive = false
        mainBallLost = false
        activePowerUps.removeAll()
        powerUpTimers.removeAll()

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

    // MARK: - Brick Movement

    func startBrickMovement() {
        removeAction(forKey: "brickMovement")
        let wait = SKAction.wait(forDuration: currentBrickMoveInterval)
        let move = SKAction.run { [weak self] in self?.moveBricksDown() }
        run(SKAction.repeatForever(SKAction.sequence([wait, move])), withKey: "brickMovement")
    }

    func moveBricksDown() {
        guard !isGameOver else { return }
        for brick in bricks {
            let moveDown = SKAction.moveBy(x: 0, y: -currentBrickMoveDistance, duration: 0.4)
            moveDown.timingMode = .easeInEaseOut
            brick.run(moveDown)
            if brick.position.y - brickHeight / 2 < paddle.position.y + paddleHeight {
                triggerGameOver(); return
            }
        }
    }

    // MARK: - Ball Launch

    func launchBall() {
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
        body.velocity = CGVector(dx: cos(angle) * currentBallSpeed, dy: sin(angle) * currentBallSpeed)

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

    func normalizeBallVelocity() {
        guard let velocity = ball.physicsBody?.velocity else { return }
        let dx = velocity.dx; let dy = velocity.dy
        let speed = sqrt(dx * dx + dy * dy)
        guard speed > 0 else { return }
        var newDy = dy
        if abs(dy) < speed * 0.25 { newDy = (dy >= 0 ? 1 : -1) * speed * 0.25 }
        let newSpeed = sqrt(dx * dx + newDy * newDy)

        var targetSpeed = currentBallSpeed
        if speedyBallActive {
            targetSpeed *= 1.15
        }

        ball.physicsBody?.velocity = CGVector(dx: (dx / newSpeed) * targetSpeed,
                                              dy: (newDy / newSpeed) * targetSpeed)
    }

    // MARK: - Lose Life

    var mainBallLost = false

    func loseLife() {
        guard ballLaunched else { return }

        // If extra balls are still in play, hide the main ball and wait
        if !extraBalls.isEmpty {
            mainBallLost = true
            ball.physicsBody?.categoryBitMask = 0
            ball.physicsBody?.contactTestBitMask = 0
            ball.physicsBody?.collisionBitMask = 0
            ball.physicsBody?.velocity = .zero
            ball.isHidden = true
            ball.position = CGPoint(x: -100, y: -100) // move off screen
            return
        }

        // No extra balls - actually lose a life
        mainBallLost = false
        ballLaunched = false
        removeAction(forKey: "enableBallPhysics")

        // Remove any remaining extra balls
        for eb in extraBalls { eb.removeFromParent() }
        extraBalls.removeAll()

        // Clear power-ups on life loss
        clearAllPowerUps()

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
            ball.isHidden = false
            placeBallOnPaddle()
            showMessage("TAP TO CONTINUE",
                        sub: "\(livesRemaining) ball\(livesRemaining == 1 ? "" : "s") remaining")
        }
    }

    // MARK: - Game Over

    func triggerGameOver() {
        guard !isGameOver else { return }
        isGameOver = true; ballLaunched = false
        ball.physicsBody = nil
        removeAction(forKey: "brickMovement")
        removeAction(forKey: "enableBallPhysics")
        soundManager.stopMusic()
        clearAllPowerUps()
        updateHighScore()
        let highNote = score >= highScore ? "  ★ New Best!" : ""
        showMessage("GAME OVER", sub: "Score: \(score)\(highNote)  •  Tap to restart")
        messageLabel.fontColor = SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
    }

    // MARK: - Win

    func checkWinCondition() {
        if bricks.isEmpty {
            isGameOver = true; ballLaunched = false
            ball.physicsBody = nil
            removeAction(forKey: "brickMovement")
            removeAction(forKey: "enableBallPhysics")
            soundManager.stopMusic()
            clearAllPowerUps()
            updateHighScore()

            if selectedStage >= highestUnlockedStage && selectedStage < 30 {
                highestUnlockedStage = selectedStage + 1
                saveProgress()
            }

            if selectedStage < 30 {
                let nextStage = selectedStage + 1
                showMessage("STAGE \(selectedStage) CLEAR!",
                            sub: "Score: \(score)  •  Tap for Stage \(nextStage)")
                selectedStage = nextStage
            } else {
                showMessage("ALL STAGES COMPLETE!",
                            sub: "Score: \(score)  •  You're a legend!")
            }
            messageLabel.fontColor = SKColor(red: 0.2, green: 1, blue: 0.4, alpha: 1)
        }
    }

    // MARK: - Restart

    func restartGame() {
        let wasGameOver = (livesRemaining <= 0)
        for brick in bricks { brick.removeFromParent() }
        bricks.removeAll()

        if wasGameOver {
            score = 0
            scoreLabel.text = "Score: 0"
        }

        livesRemaining = 3; isGameOver = false; ballLaunched = false
        updateLivesDisplay()
        messageLabel.fontColor = .white
        calculateSizes()
        paddle.size = CGSize(width: paddleWidth, height: paddleHeight)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.friction = 0
        paddle.physicsBody?.restitution = 1.0
        paddle.physicsBody?.categoryBitMask = paddleCategory
        paddle.physicsBody?.contactTestBitMask = ballCategory | powerUpCategory
        paddle.physicsBody?.collisionBitMask = ballCategory
        applyPaddleSkin()
        paddle.position.x = gameArea.midX
        placeBallOnPaddle()
        setupBricks()

        if wasGameOver {
            showingSkinPicker = true
            setupSkinPicker()
            showMessage("TAP TO START", sub: "Choose your style below!")
        } else {
            showMessage("STAGE \(selectedStage)", sub: "Score: \(score)  •  Tap to start!")
        }
    }

    // MARK: - Brick Hit (Two-Hit System)

    func hitBrick(_ brick: SKSpriteNode) {
        guard let userData = brick.userData else {
            breakBrick(brick)
            return
        }

        var hitsRemaining = (userData["hitsRemaining"] as? Int) ?? 1
        hitsRemaining -= 1

        if hitsRemaining > 0 {
            // Show crack
            userData["hitsRemaining"] = hitsRemaining
            applyBrickCrack(to: brick)
            soundManager.playBounce()
            return
        }

        // Brick breaks - check for power-up drop
        if let powerUpStr = userData["powerUp"] as? String,
           let powerType = PowerUpType(rawValue: powerUpStr) {
            dropPowerUp(from: brick.position, type: powerType)
        }

        breakBrick(brick)
    }

    func applyBrickCrack(to brick: SKSpriteNode) {
        // Darken the brick
        brick.color = brick.color.withAlphaComponent(0.6)

        // Add crack lines
        for _ in 0..<3 {
            let line = SKShapeNode()
            let startX = CGFloat.random(in: -brickWidth/2 ... brickWidth/2)
            let startY = CGFloat.random(in: -brickHeight/2 ... brickHeight/2)
            let endX = CGFloat.random(in: -brickWidth/2 ... brickWidth/2)
            let endY = CGFloat.random(in: -brickHeight/2 ... brickHeight/2)

            let path = CGMutablePath()
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: endX, y: endY))
            line.path = path
            line.strokeColor = SKColor(white: 0, alpha: 0.5)
            line.lineWidth = 1
            brick.addChild(line)
        }
    }

    // MARK: - Brick Break Effect

    func breakBrick(_ brick: SKSpriteNode) {
        soundManager.playBreak()
        score += 10; scoreLabel.text = "Score: \(score)"
        if score > highScore { highScore = score; updateHighScoreDisplay() }
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
            if let brick = brickNode as? SKSpriteNode {
                if speedyBallActive {
                    speedyBallHitCount += 1
                }
                if ghostBrickActive {
                    // Break without bouncing
                    hitBrick(brick)
                } else {
                    hitBrick(brick)
                }
            }
            return
        }

        if combined == (ballCategory | paddleCategory) {
            let paddleNode = (maskA == paddleCategory) ? contact.bodyA.node : contact.bodyB.node
            let ballNode = (maskA == ballCategory) ? contact.bodyA.node : contact.bodyB.node

            if ghostBallActive && ballNode == ball {
                ghostBallActive = false
                // Ball passes through, remove paddle from collision temporarily
                paddle.physicsBody?.collisionBitMask = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.paddle.physicsBody?.collisionBitMask = self.ballCategory
                }
                loseLife()
                return
            }

            soundManager.playBounce()
            guard let vel = (ballNode as? SKSpriteNode)?.physicsBody?.velocity else { return }
            let ballPos = (ballNode as? SKSpriteNode)?.position ?? ball.position
            let hit = ballPos.x - paddle.position.x
            let norm = hit / (paddle.size.width / 2)
            let angle = norm * (CGFloat.pi / 3)
            let speed = sqrt(vel.dx * vel.dx + vel.dy * vel.dy)
            (ballNode as? SKSpriteNode)?.physicsBody?.velocity = CGVector(dx: sin(angle) * speed,
                                                                           dy: abs(cos(angle) * speed))
            return
        }

        if combined == (powerUpCategory | paddleCategory) {
            let powerUpNode = (maskA == powerUpCategory) ? contact.bodyA.node : contact.bodyB.node
            if let powerUp = powerUpNode as? SKSpriteNode, let userData = powerUp.userData as? [String: Any] {
                if let powerUpStr = userData["powerUp"] as? String,
                   let powerType = PowerUpType(rawValue: powerUpStr) {
                    activatePowerUp(powerType)
                }
                powerUp.removeFromParent()
                if let idx = powerUpNodes.firstIndex(of: powerUp) {
                    powerUpNodes.remove(at: idx)
                }
            }
            return
        }

        if combined == (ballCategory | wallCategory) {
            if ghostBrickActive {
                ghostBrickActive = false
                // Restore brick collision
                ball.physicsBody?.collisionBitMask = paddleCategory | brickCategory | wallCategory
                for extraBall in extraBalls {
                    extraBall.physicsBody?.collisionBitMask = paddleCategory | brickCategory | wallCategory
                }
                activePowerUps.remove(.ghostBrick)
                powerUpTimers.removeValue(forKey: .ghostBrick)
                updatePowerUpIndicator()
            }
            soundManager.playBounce(); return
        }

        if combined == (ballCategory | bottomCategory) {
            let ballNode = (maskA == ballCategory) ? contact.bodyA.node : contact.bodyB.node
            // If it's an extra ball, just remove it
            if let extraBall = ballNode as? SKSpriteNode, extraBalls.contains(extraBall) {
                extraBall.removeFromParent()
                if let idx = extraBalls.firstIndex(of: extraBall) {
                    extraBalls.remove(at: idx)
                }
                // If main ball was already lost and this was the last extra ball, lose a life
                if mainBallLost && extraBalls.isEmpty {
                    mainBallLost = false
                    ball.isHidden = false
                    loseLife()
                }
                return
            }
            // Main ball - lose a life
            loseLife(); return
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if stagesMenuOpen {
            handleStagesMenuTap(location)
            return
        }

        if settingsOpen {
            handleSettingsTap(location)
            return
        }

        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if node.name == "settingsButton" {
                openSettings()
                return
            }
        }

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

    func movePaddleTo(x: CGFloat) {
        let half = paddle.size.width / 2
        let area = gameArea
        let newX = min(area.maxX - half, max(area.minX + half, x))
        paddle.position.x = newX
        if waitingToLaunch { ball.position.x = newX }
    }

    // MARK: - Frame Update

    override func update(_ currentTime: TimeInterval) {
        if ballLaunched { normalizeBallVelocity() }

        // Update extra balls velocity normalization
        for extraBall in extraBalls {
            if let vel = extraBall.physicsBody?.velocity {
                let speed = sqrt(vel.dx * vel.dx + vel.dy * vel.dy)
                guard speed > 0 else { continue }
                var targetSpeed = currentBallSpeed
                if speedyBallActive {
                    targetSpeed *= (1.0 + 0.15 * CGFloat(speedyBallHitCount))
                }
                extraBall.physicsBody?.velocity = CGVector(dx: (vel.dx / speed) * targetSpeed,
                                                            dy: (vel.dy / speed) * targetSpeed)
            }
        }

        // Check for extra balls that fell off screen
        extraBalls.removeAll { extraBall in
            if extraBall.position.y < gameArea.minY - 50 {
                extraBall.removeFromParent()
                return true
            }
            return false
        }

        // Check power-up capsule collection (manual intersection since no physics body)
        var collectedCapsules: [SKNode] = []
        for capsule in powerUpNodes {
            let paddleFrame = paddle.frame
            let capsuleFrame = capsule.frame
            if paddleFrame.intersects(capsuleFrame) {
                if let userData = capsule.userData,
                   let powerUpStr = userData["powerUp"] as? String,
                   let powerType = PowerUpType(rawValue: powerUpStr) {
                    activatePowerUp(powerType)
                }
                collectedCapsules.append(capsule)
            }
        }
        for capsule in collectedCapsules {
            capsule.removeAllActions()
            capsule.removeFromParent()
            if let idx = powerUpNodes.firstIndex(of: capsule) {
                powerUpNodes.remove(at: idx)
            }
        }

        // Update power-up timers
        var expiredPowerUps: [PowerUpType] = []
        for (type, time) in powerUpTimers {
            powerUpTimers[type] = time - (1.0 / 60.0)
            if powerUpTimers[type] ?? 0 <= 0 {
                expiredPowerUps.append(type)
            }
        }

        for powerUp in expiredPowerUps {
            deactivatePowerUp(powerUp)
        }

        // Speedy ball velocity modification for main ball
        if speedyBallActive && ballLaunched {
            if let vel = ball.physicsBody?.velocity {
                let speed = sqrt(vel.dx * vel.dx + vel.dy * vel.dy)
                guard speed > 0 else { return }
                let targetSpeed = currentBallSpeed * (1.0 + 0.15 * CGFloat(speedyBallHitCount))
                ball.physicsBody?.velocity = CGVector(dx: (vel.dx / speed) * targetSpeed,
                                                      dy: (vel.dy / speed) * targetSpeed)
            }
        }

        updatePowerUpIndicator()
    }
}
