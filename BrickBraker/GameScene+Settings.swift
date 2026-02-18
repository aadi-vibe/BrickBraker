//
//  GameScene+Settings.swift
//  BrickBraker
//
//  Created by Upendra Sharma on 2/16/26.
//

import SpriteKit

extension GameScene {

    func openSettings() {
        guard !settingsOpen else { return }
        settingsOpen = true

        if ballLaunched {
            gamePausedForSettings = true
            self.isPaused = true
        }

        let area = gameArea
        let panelW: CGFloat = frame.width - 40
        let panelH: CGFloat = 430
        let panelCenter = CGPoint(x: frame.midX, y: area.midY)

        let dim = SKSpriteNode(color: SKColor(white: 0, alpha: 0.7),
                               size: CGSize(width: frame.width, height: frame.height))
        dim.position = CGPoint(x: frame.midX, y: frame.midY)
        dim.zPosition = 90; dim.name = "settingsDim"
        addChild(dim); settingsNodes.append(dim)

        let panel = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 16)
        panel.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.95)
        panel.strokeColor = SKColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 1)
        panel.lineWidth = 2; panel.position = panelCenter; panel.zPosition = 95
        addChild(panel); settingsNodes.append(panel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "SETTINGS"; title.fontSize = 24; title.fontColor = .white
        title.position = CGPoint(x: panelCenter.x, y: panelCenter.y + panelH / 2 - 35)
        title.zPosition = 100
        addChild(title); settingsNodes.append(title)

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

        addSettingsLabel("Music", at: CGPoint(x: leftX, y: yPos), align: .left)
        addToggle(name: "toggleMusic", on: soundManager.musicEnabled,
                  at: CGPoint(x: rightX - 30, y: yPos))
        yPos -= rowHeight

        addSettingsLabel("Bounce Sound", at: CGPoint(x: leftX, y: yPos), align: .left)
        addToggle(name: "toggleBounce", on: soundManager.bounceEnabled,
                  at: CGPoint(x: rightX - 30, y: yPos))
        yPos -= rowHeight

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

            let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            nameLabel.text = tex.name; nameLabel.fontSize = 8
            nameLabel.fontColor = SKColor(white: 0.5, alpha: 1)
            nameLabel.position = CGPoint(x: 0, y: -14)
            nameLabel.horizontalAlignmentMode = .center
            nameLabel.verticalAlignmentMode = .center
            node.addChild(nameLabel)
        }
        yPos -= rowHeight

        addSettingsLabel("Stage", at: CGPoint(x: leftX, y: yPos), align: .left)
        let stageBtn = SKShapeNode(rectOf: CGSize(width: 130, height: 30), cornerRadius: 15)
        stageBtn.fillColor = SKColor(red: 0.2, green: 0.35, blue: 0.65, alpha: 1)
        stageBtn.strokeColor = SKColor(red: 0.4, green: 0.6, blue: 1, alpha: 1)
        stageBtn.lineWidth = 1.5; stageBtn.glowWidth = 1
        stageBtn.position = CGPoint(x: rightX - 70, y: yPos)
        stageBtn.zPosition = 100; stageBtn.name = "openStagesMenu"
        addChild(stageBtn); settingsNodes.append(stageBtn)
        let stageBtnTxt = SKLabelNode(fontNamed: "AvenirNext-Bold")
        stageBtnTxt.text = "Stage \(selectedStage)  ▸"
        stageBtnTxt.fontSize = 14; stageBtnTxt.fontColor = .white
        stageBtnTxt.verticalAlignmentMode = .center; stageBtnTxt.horizontalAlignmentMode = .center
        stageBtnTxt.zPosition = 1; stageBtnTxt.name = "stageBtnLabel"
        stageBtn.addChild(stageBtnTxt)
        yPos -= rowHeight

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

    func addSettingsLabel(_ text: String, at pos: CGPoint,
                          align: SKLabelHorizontalAlignmentMode) {
        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text; label.fontSize = 15; label.fontColor = SKColor(white: 0.8, alpha: 1)
        label.position = pos; label.horizontalAlignmentMode = align
        label.verticalAlignmentMode = .center; label.zPosition = 100
        addChild(label); settingsNodes.append(label)
    }

    func addToggle(name: String, on: Bool, at pos: CGPoint) {
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

    func openStagesMenu() {
        guard !stagesMenuOpen else { return }
        stagesMenuOpen = true

        let panelW: CGFloat = frame.width - 30
        let panelH: CGFloat = 440
        let panelCenter = CGPoint(x: frame.midX, y: gameArea.midY)

        let dim = SKSpriteNode(color: SKColor(white: 0, alpha: 0.8),
                               size: CGSize(width: frame.width, height: frame.height))
        dim.position = CGPoint(x: frame.midX, y: frame.midY)
        dim.zPosition = 110; dim.name = "stagesDim"
        addChild(dim); stagesMenuNodes.append(dim)

        let panel = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 16)
        panel.fillColor = SKColor(red: 0.07, green: 0.07, blue: 0.16, alpha: 0.97)
        panel.strokeColor = SKColor(red: 0.35, green: 0.45, blue: 0.85, alpha: 1)
        panel.lineWidth = 2; panel.position = panelCenter; panel.zPosition = 115
        addChild(panel); stagesMenuNodes.append(panel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "SELECT STAGE"; title.fontSize = 22; title.fontColor = .white
        title.position = CGPoint(x: panelCenter.x, y: panelCenter.y + panelH / 2 - 32)
        title.zPosition = 120
        addChild(title); stagesMenuNodes.append(title)

        let cols = 6
        let rows = 5
        let cellSize: CGFloat = 44
        let cellGap: CGFloat = 6
        let gridW = CGFloat(cols) * cellSize + CGFloat(cols - 1) * cellGap
        let gridH = CGFloat(rows) * cellSize + CGFloat(rows - 1) * cellGap
        let gridOriginX = panelCenter.x - gridW / 2 + cellSize / 2
        let gridOriginY = panelCenter.y + panelH / 2 - 70

        for stage in 1...30 {
            let idx = stage - 1
            let col = idx % cols
            let row = idx / cols
            let x = gridOriginX + CGFloat(col) * (cellSize + cellGap)
            let y = gridOriginY - CGFloat(row) * (cellSize + cellGap)

            let isSelected = (stage == selectedStage)
            let isLocked = (stage > highestUnlockedStage)
            let t = CGFloat(stage - 1) / 29.0

            let r = min(1.0, t * 2)
            let g = min(1.0, max(0, 1.0 - (t - 0.3) * 2))
            let b: CGFloat = 0.15
            let stageColor = SKColor(red: r, green: g, blue: b, alpha: 1)

            let cell = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize), cornerRadius: 8)

            if isLocked {
                cell.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.14, alpha: 1)
                cell.strokeColor = SKColor(white: 0.2, alpha: 1)
                cell.lineWidth = 1
                cell.glowWidth = 0
            } else if isSelected {
                cell.fillColor = stageColor
                cell.strokeColor = .white
                cell.lineWidth = 2.5
                cell.glowWidth = 2
            } else {
                cell.fillColor = SKColor(red: 0.12, green: 0.12, blue: 0.22, alpha: 1)
                cell.strokeColor = stageColor
                cell.lineWidth = 1.5
                cell.glowWidth = 0
            }

            cell.position = CGPoint(x: x, y: y)
            cell.zPosition = 120
            cell.name = isLocked ? "stageLocked_\(stage)" : "stage_\(stage)"
            addChild(cell); stagesMenuNodes.append(cell)

            if isLocked {
                let lockLabel = SKLabelNode(text: "🔒")
                lockLabel.fontSize = 18
                lockLabel.verticalAlignmentMode = .center
                lockLabel.horizontalAlignmentMode = .center
                lockLabel.zPosition = 1; lockLabel.alpha = 0.6
                cell.addChild(lockLabel)
            } else {
                let numLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
                numLabel.text = "\(stage)"; numLabel.fontSize = 16
                numLabel.fontColor = isSelected ? .white : stageColor
                numLabel.verticalAlignmentMode = .center
                numLabel.horizontalAlignmentMode = .center
                numLabel.zPosition = 1
                cell.addChild(numLabel)
            }
        }

        let backBtn = SKShapeNode(rectOf: CGSize(width: 120, height: 36), cornerRadius: 18)
        backBtn.fillColor = SKColor(red: 0.25, green: 0.25, blue: 0.4, alpha: 1)
        backBtn.strokeColor = SKColor(red: 0.5, green: 0.55, blue: 0.8, alpha: 1)
        backBtn.lineWidth = 1.5; backBtn.glowWidth = 1
        backBtn.position = CGPoint(x: panelCenter.x, y: gridOriginY - CGFloat(rows) * (cellSize + cellGap) + 4)
        backBtn.zPosition = 120; backBtn.name = "closeStagesMenu"
        addChild(backBtn); stagesMenuNodes.append(backBtn)

        let backTxt = SKLabelNode(fontNamed: "AvenirNext-Bold")
        backTxt.text = "◂  BACK"; backTxt.fontSize = 15; backTxt.fontColor = .white
        backTxt.verticalAlignmentMode = .center; backTxt.horizontalAlignmentMode = .center
        backTxt.zPosition = 1
        backBtn.addChild(backTxt)
    }

    func closeStagesMenu() {
        for node in stagesMenuNodes { node.removeFromParent() }
        stagesMenuNodes.removeAll()
        stagesMenuOpen = false
    }

    func handleStagesMenuTap(_ location: CGPoint) {
        let tapped = nodes(at: location)
        for node in tapped {
            guard let name = node.name else { continue }

            if name == "closeStagesMenu" || name == "stagesDim" {
                closeStagesMenu()
                return
            }

            if name.hasPrefix("stageLocked_") {
                let shakeLeft = SKAction.moveBy(x: -4, y: 0, duration: 0.05)
                let shakeRight = SKAction.moveBy(x: 8, y: 0, duration: 0.05)
                let shakeBack = SKAction.moveBy(x: -4, y: 0, duration: 0.05)
                let target = (node as? SKShapeNode) ?? (node.parent as? SKShapeNode)
                target?.run(SKAction.sequence([shakeLeft, shakeRight, shakeBack, shakeRight, shakeBack]))
                return
            }

            if name.hasPrefix("stage_") {
                if let stage = Int(name.replacingOccurrences(of: "stage_", with: "")) {
                    selectedStage = stage
                    closeStagesMenu()
                    closeSettings()
                    soundManager.stopMusic()
                    removeAction(forKey: "brickMovement")
                    removeAction(forKey: "enableBallPhysics")
                    for brick in bricks { brick.removeFromParent() }
                    bricks.removeAll()
                    livesRemaining = 3; score = 0; isGameOver = false; ballLaunched = false
                    updateLivesDisplay()
                    scoreLabel.text = "Score: 0"
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
                    showMessage("STAGE \(stage)", sub: "Tap to start!")
                    return
                }
            }
        }
    }

    func updateStageBtnLabel() {
        for node in settingsNodes {
            if let shape = node as? SKShapeNode, node.name == "openStagesMenu" {
                if let label = shape.childNode(withName: "stageBtnLabel") as? SKLabelNode {
                    label.text = "Stage \(selectedStage)  ▸"
                }
            }
        }
    }

    func closeSettings() {
        if stagesMenuOpen { closeStagesMenu() }
        for node in settingsNodes { node.removeFromParent() }
        settingsNodes.removeAll()
        settingsOpen = false

        if gamePausedForSettings {
            gamePausedForSettings = false
            self.isPaused = false
        }
    }

    func handleSettingsTap(_ location: CGPoint) {
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
                    if waitingToLaunch || isGameOver {
                        for brick in bricks { brick.removeFromParent() }
                        bricks.removeAll()
                        setupBricks()
                    }
                    refreshSettingsHighlights()
                    return
                }
            }

            if name == "openStagesMenu" {
                openStagesMenu()
                return
            }
        }
    }

    func refreshSettingsHighlights() {
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
}
