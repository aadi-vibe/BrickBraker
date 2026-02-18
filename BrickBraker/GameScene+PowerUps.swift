//
//  GameScene+PowerUps.swift
//  BrickBraker
//
//  Created by Upendra Sharma on 2/16/26.
//

import SpriteKit

extension GameScene {

    func dropPowerUp(from position: CGPoint, type: PowerUpType) {
        let capsule = SKSpriteNode(color: type.color, size: CGSize(width: 20, height: 20))
        capsule.position = position
        capsule.name = "powerUp"
        capsule.zPosition = 5

        let shape = SKShapeNode(circleOfRadius: 10)
        shape.fillColor = type.color
        shape.strokeColor = SKColor(white: 1, alpha: 0.8)
        shape.lineWidth = 1
        capsule.addChild(shape)

        let emoji = SKLabelNode(text: type.emoji)
        emoji.fontSize = 12
        emoji.verticalAlignmentMode = .center
        emoji.horizontalAlignmentMode = .center
        shape.addChild(emoji)

        capsule.userData = NSMutableDictionary(dictionary: ["powerUp": type.rawValue])

        addChild(capsule)
        powerUpNodes.append(capsule)

        // Fall animation - check for paddle intersection manually in update()
        let fallDuration: TimeInterval = 4.0
        let moveDown = SKAction.moveBy(x: 0, y: -800, duration: fallDuration)
        let remove = SKAction.removeFromParent()
        capsule.run(SKAction.sequence([moveDown, remove])) {
            if let idx = self.powerUpNodes.firstIndex(of: capsule) {
                self.powerUpNodes.remove(at: idx)
            }
        }
    }

    func activatePowerUp(_ type: PowerUpType) {
        soundManager.playBreak()
        activePowerUps.insert(type)
        powerUpTimers[type] = type.isPositive ? 10.0 : 5.0

        switch type {
        case .multiBall:
            activateMultiBall()
        case .bigBat:
            activateBigBat()
        case .bigBall:
            activateBigBall()
        case .ghostBrick:
            ghostBrickActive = true
            // Ball passes through bricks but still detects contact
            ball.physicsBody?.collisionBitMask = paddleCategory | wallCategory
            for extraBall in extraBalls {
                extraBall.physicsBody?.collisionBitMask = paddleCategory | wallCategory
            }
        case .ghostBall:
            ghostBallActive = true
        case .speedyBall:
            speedyBallActive = true
            speedyBallHitCount = 0
        case .punyBall:
            activatePunyBall()
        }

        updatePowerUpIndicator()
    }

    func activateMultiBall() {
        let angleOffset1: CGFloat = CGFloat.pi / 6
        let angleOffset2: CGFloat = -CGFloat.pi / 6

        for angleOffset in [angleOffset1, angleOffset2] {
            let extraBall = SKSpriteNode(color: .clear, size: CGSize(width: ballRadius * 2, height: ballRadius * 2))
            extraBall.position = ball.position
            extraBall.zPosition = 4
            applyBallSkinToBall(extraBall)

            let body = SKPhysicsBody(circleOfRadius: ballRadius)
            body.friction = 0; body.restitution = 1.0
            body.linearDamping = 0; body.angularDamping = 0; body.allowsRotation = false
            body.categoryBitMask = ballCategory
            body.contactTestBitMask = paddleCategory | brickCategory | bottomCategory | wallCategory
            body.collisionBitMask = paddleCategory | brickCategory | wallCategory
            extraBall.physicsBody = body

            if let mainVel = ball.physicsBody?.velocity {
                let angle = atan2(mainVel.dy, mainVel.dx) + angleOffset
                let speed = sqrt(mainVel.dx * mainVel.dx + mainVel.dy * mainVel.dy)
                body.velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
            }

            addChild(extraBall)
            extraBalls.append(extraBall)
        }
    }

    func applyBallSkinToBall(_ ballNode: SKSpriteNode) {
        ballNode.removeAllChildren()
        let skin = ballSkins[selectedBallSkin]
        let glow = SKShapeNode(circleOfRadius: ballRadius)
        glow.fillColor = skin.color
        glow.strokeColor = skin.strokeColor
        glow.lineWidth = 1.5; glow.glowWidth = 3
        ballNode.addChild(glow)
        let faceLabel = SKLabelNode(text: skin.face)
        faceLabel.fontSize = ballRadius * 1.5
        faceLabel.verticalAlignmentMode = .center
        faceLabel.horizontalAlignmentMode = .center
        faceLabel.zPosition = 1
        ballNode.addChild(faceLabel)
    }

    func activateBigBat() {
        bigBatActive = true
        paddle.size = CGSize(width: paddleWidth * 2, height: paddleHeight)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.friction = 0
        paddle.physicsBody?.restitution = 1.0
        paddle.physicsBody?.categoryBitMask = paddleCategory
        paddle.physicsBody?.contactTestBitMask = ballCategory | powerUpCategory
        paddle.physicsBody?.collisionBitMask = ballCategory
        applyPaddleSkin()
    }

    func activateBigBall() {
        bigBallActive = true
        ball.size = CGSize(width: ballRadius * 1.5 * 2, height: ballRadius * 1.5 * 2)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius * 1.5)
        ball.physicsBody?.friction = 0; ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.linearDamping = 0; ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = paddleCategory | brickCategory | bottomCategory | wallCategory
        ball.physicsBody?.collisionBitMask = paddleCategory | brickCategory | wallCategory
        applyBallSkin()
    }

    func activatePunyBall() {
        punyBallActive = true
        ball.size = CGSize(width: ballRadius * 0.5 * 2, height: ballRadius * 0.5 * 2)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius * 0.5)
        ball.physicsBody?.friction = 0; ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.linearDamping = 0; ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = paddleCategory | brickCategory | bottomCategory | wallCategory
        ball.physicsBody?.collisionBitMask = paddleCategory | brickCategory | wallCategory
        applyBallSkin()

        // Add 2 hits to all remaining bricks
        for brick in bricks {
            if let userData = brick.userData {
                let current = (userData["hitsRemaining"] as? Int) ?? 1
                userData["hitsRemaining"] = current + 2
            }
        }
    }

    func deactivatePowerUp(_ type: PowerUpType) {
        activePowerUps.remove(type)
        powerUpTimers.removeValue(forKey: type)

        switch type {
        case .bigBat:
            if bigBatActive {
                bigBatActive = false
                paddle.size = CGSize(width: paddleWidth, height: paddleHeight)
                paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
                paddle.physicsBody?.isDynamic = false
                paddle.physicsBody?.friction = 0
                paddle.physicsBody?.restitution = 1.0
                paddle.physicsBody?.categoryBitMask = paddleCategory
                paddle.physicsBody?.contactTestBitMask = ballCategory | powerUpCategory
                paddle.physicsBody?.collisionBitMask = ballCategory
                applyPaddleSkin()
            }
        case .bigBall:
            if bigBallActive {
                bigBallActive = false
                ball.size = CGSize(width: originalBallRadius * 2, height: originalBallRadius * 2)
                ball.physicsBody = SKPhysicsBody(circleOfRadius: originalBallRadius)
                ball.physicsBody?.friction = 0; ball.physicsBody?.restitution = 1.0
                ball.physicsBody?.linearDamping = 0; ball.physicsBody?.angularDamping = 0
                ball.physicsBody?.allowsRotation = false
                ball.physicsBody?.categoryBitMask = ballCategory
                ball.physicsBody?.contactTestBitMask = paddleCategory | brickCategory | bottomCategory | wallCategory
                ball.physicsBody?.collisionBitMask = paddleCategory | brickCategory | wallCategory
                applyBallSkin()
            }
        case .ghostBrick:
            ghostBrickActive = false
            // Restore brick collision
            ball.physicsBody?.collisionBitMask = paddleCategory | brickCategory | wallCategory
            for extraBall in extraBalls {
                extraBall.physicsBody?.collisionBitMask = paddleCategory | brickCategory | wallCategory
            }
        case .ghostBall:
            ghostBallActive = false
        case .speedyBall:
            speedyBallActive = false
            speedyBallHitCount = 0
        case .punyBall:
            if punyBallActive {
                punyBallActive = false
                ball.size = CGSize(width: originalBallRadius * 2, height: originalBallRadius * 2)
                ball.physicsBody = SKPhysicsBody(circleOfRadius: originalBallRadius)
                ball.physicsBody?.friction = 0; ball.physicsBody?.restitution = 1.0
                ball.physicsBody?.linearDamping = 0; ball.physicsBody?.angularDamping = 0
                ball.physicsBody?.allowsRotation = false
                ball.physicsBody?.categoryBitMask = ballCategory
                ball.physicsBody?.contactTestBitMask = paddleCategory | brickCategory | bottomCategory | wallCategory
                ball.physicsBody?.collisionBitMask = paddleCategory | brickCategory | wallCategory
                applyBallSkin()
            }
        case .multiBall:
            break
        }

        updatePowerUpIndicator()
    }

    func clearAllPowerUps() {
        // Reset all flags first (avoid deactivation side effects)
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

        // Remove extra balls
        for eb in extraBalls { eb.removeFromParent() }
        extraBalls.removeAll()

        // Remove falling power-up capsules
        for node in powerUpNodes {
            node.removeAllActions()
            node.removeFromParent()
        }
        powerUpNodes.removeAll()

        // Restore ball size (guard against nil during initial setup)
        if ball != nil {
            ball.size = CGSize(width: originalBallRadius * 2, height: originalBallRadius * 2)
            ball.isHidden = false
            if ball.physicsBody != nil {
                ball.physicsBody = SKPhysicsBody(circleOfRadius: originalBallRadius)
                ball.physicsBody?.friction = 0; ball.physicsBody?.restitution = 1.0
                ball.physicsBody?.linearDamping = 0; ball.physicsBody?.angularDamping = 0
                ball.physicsBody?.allowsRotation = false
                ball.physicsBody?.categoryBitMask = ballCategory
                ball.physicsBody?.contactTestBitMask = paddleCategory | brickCategory | bottomCategory | wallCategory
                ball.physicsBody?.collisionBitMask = paddleCategory | brickCategory | wallCategory
            }
            applyBallSkin()
        }

        // Restore paddle size (guard against nil during initial setup)
        if paddle != nil {
            paddle.size = CGSize(width: paddleWidth, height: paddleHeight)
            paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
            paddle.physicsBody?.isDynamic = false
            paddle.physicsBody?.friction = 0
            paddle.physicsBody?.restitution = 1.0
            paddle.physicsBody?.categoryBitMask = paddleCategory
            paddle.physicsBody?.contactTestBitMask = ballCategory
            paddle.physicsBody?.collisionBitMask = ballCategory
            applyPaddleSkin()
        }

        if powerUpIndicatorLabel != nil {
            updatePowerUpIndicator()
        }
    }
}
