//
//  GameScene+HUD.swift
//  BrickBraker
//
//  Created by Upendra Sharma on 2/16/26.
//

import SpriteKit

extension GameScene {

    func setupHUD() {
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
        scoreLabel.horizontalAlignmentMode = .center; scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: frame.midX, y: hudCenterY)
        scoreLabel.zPosition = 10; scoreLabel.text = "Score: 0"
        addChild(scoreLabel)

        highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        highScoreLabel.fontSize = 12
        highScoreLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.3, alpha: 0.8)
        highScoreLabel.horizontalAlignmentMode = .center; highScoreLabel.verticalAlignmentMode = .center
        highScoreLabel.position = CGPoint(x: frame.midX, y: hudCenterY - 16)
        highScoreLabel.zPosition = 10
        updateHighScoreDisplay()
        addChild(highScoreLabel)

        powerUpIndicatorLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        powerUpIndicatorLabel.fontSize = 12
        powerUpIndicatorLabel.fontColor = SKColor(red: 0.8, green: 0.8, blue: 0.2, alpha: 1)
        powerUpIndicatorLabel.horizontalAlignmentMode = .center; powerUpIndicatorLabel.verticalAlignmentMode = .center
        powerUpIndicatorLabel.position = CGPoint(x: frame.midX, y: area.maxY - 10)
        powerUpIndicatorLabel.zPosition = 10
        powerUpIndicatorLabel.isHidden = true
        addChild(powerUpIndicatorLabel)

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

    func updateLivesDisplay() {
        var text = "Lives: "
        for i in 0..<3 { text += i < livesRemaining ? "● " : "○ " }
        livesLabel.text = text.trimmingCharacters(in: .whitespaces)
    }

    func updateHighScoreDisplay() {
        highScoreLabel.text = "Best: \(highScore)"
    }

    func updateHighScore() {
        if score > highScore {
            highScore = score
            updateHighScoreDisplay()
            saveProgress()
        }
    }

    func updatePowerUpIndicator() {
        if activePowerUps.isEmpty {
            powerUpIndicatorLabel.isHidden = true
            return
        }
        var text = "Active: "
        for powerUp in activePowerUps.sorted(by: { $0.rawValue < $1.rawValue }) {
            let remaining = Int(powerUpTimers[powerUp] ?? 0)
            text += "\(powerUp.emoji)(\(remaining)s) "
        }
        powerUpIndicatorLabel.text = text.trimmingCharacters(in: .whitespaces)
        powerUpIndicatorLabel.isHidden = false
    }

    func showMessage(_ text: String, sub: String = "") {
        messageLabel.text = text; messageLabel.isHidden = false
        subMessageLabel.text = sub; subMessageLabel.isHidden = sub.isEmpty
    }

    func hideMessage() {
        messageLabel.isHidden = true; subMessageLabel.isHidden = true
    }
}
