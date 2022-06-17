//
//  GameViewController.swift
//  Bejeweled
//
//  Created by Francesc Miquel Obrador Artigues on 20/5/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var board : Board!
    var gameScene: GameScene!
    var currentScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                gameScene = (scene as! GameScene)
                board = gameScene.board
                board.swipeHandler = HandleSwipe
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        gameScene.Start()
        HandleMatches()
        
    }
    
    func HandleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false
        
        board.DetectPossibleSwaps()
        
        // if there is no more gems to swap shuffle it
        if board.NeedsToShuffle() {
            gameScene.Shuffle()
            board.DetectPossibleSwaps()
        }
        
        if board.CanSwap(swap) {
            board.performSwap(swap)
            HandleMatches()
            gameScene.AnimateSwap(swap) {
                self.view.isUserInteractionEnabled = true
            }
        } else {
            gameScene.AnimateInvalidSwap(swap){
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func HandleMatches() {
        var matches = board.RemoveMatches()
        
        while !matches.isEmpty
        {
            for match in matches {
                currentScore += match.score
            }
            gameScene.SetScoreLabel(newValue: currentScore)
            
            gameScene.AnimateMatchedGems(for: matches) {
                let columns = self.board.FillEmptyTiles()
                
                self.gameScene.AnimateFallingGems(in: columns) {
                    let columns = self.board.SpawnGems()
                    
                    self.gameScene.AnimateNewGems(in: columns){
                        self.view.isUserInteractionEnabled = true
                    }
                }
            }
            matches = board.RemoveMatches()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
