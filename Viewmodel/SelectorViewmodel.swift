//
//  SelectorViewmodel.swift
//  Bejeweled
//
//  Created by Francesc Miquel Obrador Artigues on 27/5/22.
//

import SpriteKit

class Selector {
    var sprite: SKSpriteNode!
    var gem: Gem?
    
    init(width: CGFloat, height: CGFloat){
        self.sprite = SKSpriteNode(imageNamed: "selector")
        self.sprite.size = CGSize(width: width, height: height)
    }
    
    func Hide() {
        sprite.removeFromParent()
    }
    
    func Show(on gem: Gem) {
        if sprite.parent != nil {
            self.gem?.StopGemAnim()
            sprite.removeFromParent()
        }
        
        if let gemSprite = gem.sprite {
            self.gem = gem;
            gemSprite.addChild(sprite)
            gem.StartGemAnim()
        }
    }
    
}
