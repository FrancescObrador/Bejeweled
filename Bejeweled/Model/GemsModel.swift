//
//  GemsModel.swift
//  Bejeweled
//
//  Created by Francesc Miquel Obrador Artigues on 20/5/22.
//

import SpriteKit

enum GemType : Int {
    case amber, amethyst, diamond, esmerald, ruby, sapphire, topaz
    
    var spriteName: String {
        let spriteNames = [
            "amber",
            "amethyst",
            "diamond",
            "esmerald",
            "ruby",
            "sapphire",
            "topaz"]
        
        return spriteNames[rawValue]
    }
    
    static func GetRandom() -> GemType {
        return GemType(rawValue: Int(arc4random_uniform(7)))!
    }
}

class Gem : Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(column * 10)
        hasher.combine(row)
    }
    
    static func ==(lhs: Gem, rhs: Gem) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
        
    }
    
    var description: String {
        return "type:\(gemType) square:(\(column),\(row))"
    }
    
    var column: Int
    var row: Int
    let gemType: GemType
    var sprite: SKSpriteNode?
    var rotationFrames: [SKTexture] = []
    
    init(){
        self.column = 0
        self.row = 0
        self.gemType = GemType.amber
    }
    
    init(column: Int, row: Int, gemType: GemType){
        self.column = column
        self.row = row
        self.gemType = gemType
    }
    
    func buildAnimation() {
        let gemAtlas = SKTextureAtlas(named: gemType.spriteName)
        
        let numImages = gemAtlas.textureNames.count
        for i in 0...numImages-1 {
            let gemTextureName = (gemType.spriteName + "_" + String(format: "%02d", i))
            rotationFrames.append(gemAtlas.textureNamed(gemTextureName))
            print(i)
        }
    }
    
    func StartGemAnim() {
        if rotationFrames.isEmpty {
            buildAnimation()
        }
        
        sprite!.run(SKAction.repeatForever(
        SKAction.animate(with: rotationFrames,
                         timePerFrame: 0.05,
                         resize: false,
                         restore: true)),
        withKey:"Rotation")
    }
    
    func StopGemAnim(){
        sprite!.removeAllActions()
    }
}

struct Swap : Hashable {
    let gemA: Gem
    let gemB: Gem
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(gemA.hashValue ^ gemB.hashValue)
    }
    
    static func ==(lhs: Swap, rhs: Swap) -> Bool {
        return (lhs.gemA == rhs.gemA && lhs.gemB == rhs.gemB) || (lhs.gemA == rhs.gemB && lhs.gemB == rhs.gemA)
        
    }
    
    init(gemA: Gem, gemB: Gem) {
        self.gemA = gemA
        self.gemB = gemB
    }
}
