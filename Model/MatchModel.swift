//
//  MatchModel.swift
//  Bejeweled
//
//  Created by Francesc Miquel Obrador Artigues on 27/5/22.
//

import Foundation

enum MatchType {
    case horizontal
    case vertical
}

class Match: Hashable {
    var gems: [Gem] = []
    var score = 0
    
    var matchType: MatchType
    
    init(matchType: MatchType) {
        self.matchType = matchType
    }
    
    func add(gem: Gem) {
        gems.append(gem)
        score += (10 * gems.count)
    }
    
    func firstGem() -> Gem {
        return gems[0]
    }
    
    func lastGem() -> Gem {
        return gems[gems.count - 1]
    }
    
    var length: Int {
        return gems.count
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(firstGem().hashValue ^ lastGem().hashValue)
    }
    
    static func ==(lhs: Match, rhs: Match) -> Bool {
        return lhs.gems == rhs.gems
    }
}
