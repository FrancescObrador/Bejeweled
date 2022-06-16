//
//  GameScene.swift
//  Bejeweled
//
//  Created by Francesc Miquel Obrador Artigues on 20/5/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var board = Board()
    var selector: Selector!
    var scoreLabel: SKLabelNode!
    
    let tileWidth: CGFloat = 64.0
    let tileHeight: CGFloat = 64.0
    
    let gameLayer = SKNode()
    let gemsLayer = SKNode()
    let tilesLayer = SKNode()
    
    // I use this Start as an Init to load everything from the GameViewController
    func Start(){
        
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -10
        addChild(background)
        
        // Layers
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -tileWidth * CGFloat(numColumns) / 2,
            y: -tileHeight * CGFloat(numRows) / 2)
        
        gemsLayer.position = layerPosition
        gemsLayer.zPosition = 0
        tilesLayer.position = layerPosition
        tilesLayer.zPosition = -1;
        
        gameLayer.addChild(gemsLayer)
        gameLayer.addChild(tilesLayer)
        
        // Setup
        let newGems = board.createGemsSet()
        AddSprites(for: newGems)
        
        AddTiles()
        
        selector = Selector(width: tileWidth, height: tileHeight)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: frame.midX-200, y: frame.maxY-200)
           
        addChild(scoreLabel)
    }
    
    func SetScoreLabel(newValue: Int){
        scoreLabel.text = "Score: " + String(newValue)
    }
    
    func AddSprites(for gems: Set<Gem>) {
        for gem in gems {
            let sprite = SKSpriteNode(imageNamed: (gem.gemType.spriteName + "_00"))
            sprite.size = CGSize(width: tileWidth, height: tileHeight)
            sprite.position = PointFor(column: gem.column, row: gem.row)
            gemsLayer.addChild(sprite)
            gem.sprite = sprite
        }
    }
    
    func AddTiles() {
        var tileCount = 0
        for row in 0...numRows-1 {
            for column in 0...numColumns-1 {
                let tileNode = (tileCount % 2 == 0) ? SKSpriteNode(imageNamed: "Tile01") : SKSpriteNode(imageNamed: "Tile02")
                tileCount += 1
                tileNode.size = CGSize(width: tileWidth, height: tileHeight)
                tileNode.position = PointFor(column: column, row: row)
                tilesLayer.addChild(tileNode)
            }
            tileCount += 1
        }
    }
    
    // Tile to screen position
    private func PointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * tileWidth + tileWidth / 2,
            y: CGFloat(row) * tileHeight + tileHeight / 2)
    }
    
    // Screen position to tile
    private func ConvertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(numColumns) * tileWidth &&
            point.y >= 0 && point.y < CGFloat(numRows) * tileHeight {
            return (true, Int(point.x / tileWidth), Int(point.y / tileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    // ANIMATIONS
    func AnimateSwap(_ swap: Swap, completion: @escaping () -> Void) {
        let spriteA = swap.gemA.sprite!
        let spriteB = swap.gemB.sprite!
        
        spriteA.zPosition = 2
        spriteB.zPosition = 1
        
        let duration: TimeInterval = 0.3
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        spriteA.run(moveA, completion: completion)
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        spriteB.run(moveB)
        
        run(swapSound)
    }
    
    func AnimateInvalidSwap(_ swap: Swap, completion: @escaping () -> Void) {
        let spriteA = swap.gemA.sprite!
        let spriteB = swap.gemB.sprite!
        
        spriteA.zPosition = 2
        spriteB.zPosition = 1
        
        let duration: TimeInterval = 0.2
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        
        spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.run(SKAction.sequence([moveB, moveA]))
        
        run(invalidSwapSound)
    }
    
    func AnimateMatchedGems(for matches: Set<Match>, completion: @escaping () -> Void) {
        for matches in matches {
            for gem in matches.gems {
                if let sprite = gem.sprite {
                    if sprite.action(forKey: "removing") == nil {
                        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                        scaleAction.timingMode = .easeOut
                        sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                                   withKey: "removing")
                    }
                }
            }
        }
        run(matchSound)
        run(SKAction.wait(forDuration: 0.3), completion: completion)
    }
    
    func AnimateFallingGems(in columns: [[Gem]], completion: @escaping () -> Void) {
        var longestDuration: TimeInterval = 0
        for array in columns {
            for (index, gem) in array.enumerated() {
                let newPosition = PointFor(column: gem.column, row: gem.row)
                let delay = 0.05 + 0.15 * TimeInterval(index)
                
                let sprite = gem.sprite!
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / tileHeight) * 0.1)
                longestDuration = max(longestDuration, duration + delay)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([moveAction, fallingGemSound])]))
            }
        }
        
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func AnimateNewGems(in columns: [[Gem]], completion: @escaping () -> Void) {
        var longestDuration: TimeInterval = 0
        
        for array in columns {
            let startRow = array[0].row + 1
            
            for (index, gem) in array.enumerated() {
                
                let sprite = SKSpriteNode(imageNamed: gem.gemType.spriteName + "_00")
                sprite.size = CGSize(width: tileWidth, height: tileHeight)
                sprite.position = PointFor(column: gem.column, row: startRow)
                gemsLayer.addChild(sprite)
                gem.sprite = sprite
                
                let delay = 0.1 + 0.2 * TimeInterval(array.count - index - 1)
                
                let duration = TimeInterval(startRow - gem.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                
                let newPosition = PointFor(column: gem.column, row: gem.row)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.alpha = 0
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([
                            SKAction.fadeIn(withDuration: 0.05),
                            moveAction,
                            addGemSound])
                    ]))
            }
        }
        
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: gemsLayer)
        
        let (success, column, row) = ConvertPoint(location)
        
        if success {
            if board.TrySelectGem(column: column, row: row) {
                let gem = board.GetGemAt(column, row)!
                selector.Show(on: gem)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: gemsLayer)
        
        guard board.swipeFromColumn != nil else { return }
        
        let (success, column, row) = ConvertPoint(location)
        
        if success {
            var horizontalDelta = 0, verticalDelta = 0
            
            if column < board.swipeFromColumn! {          // swipe left
                horizontalDelta = -1
            } else if column > board.swipeFromColumn! {   // swipe right
                horizontalDelta = 1
            } else if row < board.swipeFromRow! {         // swipe down
                verticalDelta = -1
            } else if row > board.swipeFromRow! {         // swipe up
                verticalDelta = 1
            }
            
            if horizontalDelta != 0 || verticalDelta != 0 {
                board.TrySwap(horizontalDelta: horizontalDelta, verticalDelta: verticalDelta)
                selector.Hide()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        board.swipeFromColumn = nil
        board.swipeFromRow = nil
        if selector.sprite.parent != nil && board.swipeFromColumn != nil{
            selector.Hide()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
