//
//  GameScene+SkinPicker.swift
//  BrickBraker
//
//  Created by Upendra Sharma on 2/16/26.
//

import SpriteKit

extension GameScene {

    func setupSkinPicker() {
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

    func removeSkinPicker() {
        for node in skinPickerNodes { node.removeFromParent() }
        skinPickerNodes.removeAll()
        showingSkinPicker = false
    }

    func updateStartPickerHighlights() {
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
}
