//
//  Board.swift
//  Bejeweled
//
//  Created by Francesc Miquel Obrador Artigues on 21/5/22.
//

import Foundation

let numColumns = 10
let numRows = 10

class Board {
    
    private var gems = [[Gem]] (repeating: [Gem](repeating: Gem(), count: numColumns), count: numRows)
    
    func createGemsSet() -> Set<Gem> {
        var set: Set<Gem> = []
        
        for row in 0..<numRows {
            for column in 0..<numColumns {
                let gemType = GemType.GetRandom()
                let gem = Gem(column: column, row: row, gemType: gemType)
                gems[column][row] = gem
                set.insert(gem)
            }
        }
        
        return set
    }
    
    func GetGemAt(column: Int, row: Int) -> Gem? {
        guard (column >= 0 && column < numColumns) && (row >= 0 && row < numRows)
        else{
            print("this position does not exist!")
            return nil
        }
        
        return gems[column][row]
    }
    
    func performSwap(_ swap: Swap) {
      let columnA = swap.gemA.column
      let rowA = swap.gemB.row
      let columnB = swap.gemB.column
      let rowB = swap.gemB.row

      gems[columnA][rowA] = swap.gemB
      swap.gemB.column = columnA
      swap.gemB.row = rowA

      gems[columnB][rowB] = swap.gemA
      swap.gemA.column = columnB
      swap.gemA.row = rowB
    }
}
