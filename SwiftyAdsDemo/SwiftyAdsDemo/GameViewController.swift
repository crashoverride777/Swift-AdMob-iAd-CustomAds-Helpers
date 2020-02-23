//
//  GameViewController.swift
//  Example
//
//  Created by Dominik Ringler on 23/05/2019.
//  Copyright © 2019 Dominik. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    private let swiftyAds: SwiftyAdsType = SwiftyAds.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup swifty ad
        #if DEBUG
        let swiftyAdsMode: SwiftyAdsMode = .test(devices: [])
        #else
        let swiftyAdsMode: SwiftyAdsMode = .production
        #endif
        swiftyAds.setup(
            with: self,
            delegate: self,
            bannerAnimationDuration: 1.5,
            mode: swiftyAdsMode,
            handler: ({ status in
                guard status.hasConsent else { return }
                DispatchQueue.main.async {
                    self.swiftyAds.showBanner(from: self, atTop: false)
                }
            })
        )
        
        // Load game scene
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.swiftyAds = swiftyAds
            
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - SwiftyAdsDelegate

extension GameViewController: SwiftyAdsDelegate {
    
    func swiftyAdsDidOpen(_ swiftyAds: SwiftyAds) {
        print("SwiftyAds did open")
    }
    
    func swiftyAdsDidClose(_ swiftyAds: SwiftyAds) {
        print("SwiftyAds did close")
    }
    
    func swiftyAds(_ swiftyAds: SwiftyAds, didChange consentStatus: SwiftyAdsConsentStatus) {
        print("SwiftyAds did change consent status to \(consentStatus)")
        // e.g update mediation networks
    }
    
    func swiftyAds(_ swiftyAds: SwiftyAds, didRewardUserWithAmount rewardAmount: Int) {
        print("SwiftyAds did reward user with \(rewardAmount)")
        
        if let scene = (view as? SKView)?.scene as? GameScene {
            scene.coins += rewardAmount
        }
    }
}
