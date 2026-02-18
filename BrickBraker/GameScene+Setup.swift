//
//  GameScene+Setup.swift
//  BrickBraker
//
//  Created by Upendra Sharma on 2/16/26.
//

import SpriteKit

extension GameScene {

    func setupGameAreaBorder() {
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

    func setupWalls() {
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

    func configureWall(_ node: SKNode) {
        node.physicsBody?.friction = 0
        node.physicsBody?.restitution = 1.0
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = wallCategory
        node.physicsBody?.contactTestBitMask = ballCategory
        node.physicsBody?.collisionBitMask = ballCategory
    }

    func setupPaddle() {
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
        paddle.physicsBody?.contactTestBitMask = ballCategory | powerUpCategory
        paddle.physicsBody?.collisionBitMask = ballCategory
        addChild(paddle)
    }

    func applyPaddleSkin() {
        paddle.removeAllChildren()
        let skin = paddleSkins[selectedPaddleSkin]
        let shape = SKShapeNode(rectOf: paddle.size, cornerRadius: paddleHeight / 2)
        shape.fillColor = skin.fillColor
        shape.strokeColor = skin.strokeColor
        shape.lineWidth = 1.5
        shape.glowWidth = skin.glowWidth
        paddle.addChild(shape)
    }

    func setupBall() {
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

    func applyBallSkin() {
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

    func placeBallOnPaddle() {
        ball.physicsBody = nil
        ball.position = CGPoint(x: paddle.position.x,
                                y: paddle.position.y + paddleHeight / 2 + ballRadius + 4)
        ballLaunched = false
        waitingToLaunch = true
    }

    func setupBricks() {
        let area = gameArea
        let texture = brickTextures[selectedBrickTexture]
        let topGap: CGFloat = 70
        let startY = area.maxY - topGap

        let rows = currentBrickRows
        let cols = brickColumns
        let formation = BrickFormation.generate(stage: selectedStage, rows: rows, cols: cols)
        var rng = SeededRNG(seed: UInt64(selectedStage * 31337 + 271828))

        for row in 0..<rows {
            for col in 0..<cols {
                guard row < formation.count && col < formation[row].count && formation[row][col] else {
                    continue
                }

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

                // Determine if this brick is 2-hit
                let twoHitFraction = 0.10 + (Double(selectedStage - 1) / 29.0) * 0.50
                let isTwoHit = rng.nextDouble() < twoHitFraction

                // Determine if brick has power-up
                let hasPowerUp = rng.nextDouble() < 0.15
                var powerUpType: PowerUpType? = nil
                if hasPowerUp {
                    let isPositive = rng.nextDouble() < 0.60
                    let types: [PowerUpType] = isPositive
                        ? [.multiBall, .bigBat, .bigBall, .ghostBrick]
                        : [.ghostBall, .speedyBall, .punyBall]
                    powerUpType = types[rng.nextInt(bound: types.count)]
                }

                // Store in userData
                var userData = NSMutableDictionary()
                userData["hitsRemaining"] = isTwoHit ? 2 : 1
                if let powerUp = powerUpType {
                    userData["powerUp"] = powerUp.rawValue
                }
                brick.userData = userData

                // Visual indicator for power-up bricks
                if let powerUp = powerUpType {
                    let indicator = SKLabelNode(text: powerUp.emoji)
                    indicator.fontSize = 10
                    indicator.verticalAlignmentMode = .center
                    indicator.horizontalAlignmentMode = .center
                    indicator.zPosition = 2
                    brick.addChild(indicator)
                }

                // Visual indicator for 2-hit bricks (subtle border)
                if isTwoHit {
                    let border = SKShapeNode(rectOf: CGSize(width: brickWidth - 4, height: brickHeight - 2), cornerRadius: 2)
                    border.fillColor = .clear
                    border.strokeColor = SKColor(white: 1, alpha: 0.4)
                    border.lineWidth = 1.5
                    border.zPosition = 1
                    brick.addChild(border)
                }

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

    func applyBrickPattern(to brick: SKSpriteNode, texture: BrickTexture, row: Int, col: Int) {
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
            let stripe = SKShapeNode(rectOf: CGSize(width: bw * 0.6, height: 2))
            stripe.fillColor = SKColor(white: 1, alpha: 0.4)
            stripe.strokeColor = .clear
            stripe.position = CGPoint(x: 0, y: bh * 0.25)
            brick.addChild(stripe)
            let border = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: 4)
            border.fillColor = .clear
            border.strokeColor = SKColor(white: 1, alpha: 0.25)
            border.lineWidth = 1
            brick.addChild(border)

        case "striped":
            for s in stride(from: -bh / 2 + 4, to: bh / 2, by: 5) {
                let line = SKShapeNode(rectOf: CGSize(width: bw, height: 1))
                line.fillColor = SKColor(white: 0, alpha: 0.3)
                line.strokeColor = .clear
                line.position = CGPoint(x: 0, y: s)
                brick.addChild(line)
            }

        case "gradient":
            let top = SKSpriteNode(
                color: SKColor(white: 1, alpha: 0.15),
                size: CGSize(width: bw, height: bh / 2)
            )
            top.position = CGPoint(x: 0, y: bh / 4)
            brick.addChild(top)

        default:
            break
        }
    }

    func calculateSizes() {
        let w = frame.width
        paddleWidth = w * 0.26 * currentPaddleWidthMultiplier
        paddleHeight = 14
        ballRadius = 8
        originalBallRadius = ballRadius
        originalPaddleWidth = paddleWidth
        brickColumns = max(4, Int(w / 72))
        brickWidth = (w - CGFloat(brickColumns + 1) * brickSpacing) / CGFloat(brickColumns)
        brickHeight = 22
    }
}
