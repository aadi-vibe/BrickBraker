//
//  GameViewController.swift
//  BrickBraker
//
//  Created by Upendra Sharma on 2/16/26.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = self.view as? SKView else { return }

        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)

        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
    }

    // Pass the safe area top inset to the scene once layout is known
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let skView = self.view as? SKView,
              let scene = skView.scene as? GameScene else { return }

        let topInset = view.safeAreaInsets.top
        scene.updateSafeAreaTop(topInset)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
