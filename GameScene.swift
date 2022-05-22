//
//  GameScene.swift
//  Bejeweled
//
//  Created by Francesc Miquel Obrador Artigues on 20/5/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var board: Board!
    
    let tileWidth: CGFloat = 64.0
    let tileHeight: CGFloat = 64.0
    
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    
    let gameLayer = SKNode()
    let gemsLayer = SKNode()
    let tilesLayer = SKNode()
    
    func beginGame(){
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -tileWidth * CGFloat(numColumns) / 2,
            y: -tileHeight * CGFloat(numRows) / 2)
        
        gemsLayer.position = layerPosition
        tilesLayer.position = layerPosition
        tilesLayer.zPosition = -1;
        gameLayer.addChild(gemsLayer)
        gameLayer.addChild(tilesLayer)
        
        board = Board()
        let newGems = board.createGemsSet()
        addSprites(for: newGems)
        addTiles()
    }
    
    func addSprites(for gems: Set<Gem>) {
        for gem in gems {
            let sprite = SKSpriteNode(imageNamed: (gem.gemType.spriteName + "_00"))
            print(gem.gemType.spriteName + "_00")
            sprite.size = CGSize(width: tileWidth, height: tileHeight)
            sprite.position = pointFor(column: gem.column, row: gem.row)
            gemsLayer.addChild(sprite)
            gem.sprite = sprite
        }
    }
    
    func addTiles() {
        var tileCount = 0
        
        for row in 0...numRows-1 {
            for column in 0...numColumns-1 {
                let tileNode = (tileCount % 2 == 0) ? SKSpriteNode(imageNamed: "Tile") : SKSpriteNode(imageNamed: "Tilex")
                tileCount += 1
                tileNode.size = CGSize(width: tileWidth, height: tileHeight)
                tileNode.position = pointFor(column: column, row: row)
                tilesLayer.addChild(tileNode)
            }
            tileCount += 1
        }
    }
    
    // Tile to screen position
    private func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * tileWidth + tileWidth / 2,
            y: CGFloat(row) * tileHeight + tileHeight / 2)
    }
    
    // Screen position to tile
    private func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(numColumns) * tileWidth &&
            point.y >= 0 && point.y < CGFloat(numRows) * tileHeight {
            return (true, Int(point.x / tileWidth), Int(point.y / tileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    private func trySwap(horizontalDelta: Int, verticalDelta: Int) {
        let toColumn = swipeFromColumn! + horizontalDelta
        let toRow = swipeFromRow! + verticalDelta
        
        guard toColumn >= 0 && toColumn < numColumns else { return }
        guard toRow >= 0 && toRow < numRows else { return }
        
        if let toGem = board.GetGemAt(column: toColumn, row: toRow),
           let fromGem = board.GetGemAt(column: swipeFromColumn!, row: swipeFromRow!) {
            // Swap
        }
    }
    
    override func didMove(to view: SKView) {
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: gemsLayer)
        let (success, column, row) = convertPoint(location)
        if success {
            if board.GetGemAt(column: column, row: row) != nil {
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard swipeFromColumn != nil else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: gemsLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            var horizontalDelta = 0, verticalDelta = 0
            if column < swipeFromColumn! {          // swipe left
                horizontalDelta = -1
            } else if column > swipeFromColumn! {   // swipe right
                horizontalDelta = 1
            } else if row < swipeFromRow! {         // swipe down
                verticalDelta = -1
            } else if row > swipeFromRow! {         // swipe up
                verticalDelta = 1
            }
            
            if horizontalDelta != 0 || verticalDelta != 0 {
                trySwap(horizontalDelta: horizontalDelta, verticalDelta: verticalDelta)
                
                swipeFromColumn = nil
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
