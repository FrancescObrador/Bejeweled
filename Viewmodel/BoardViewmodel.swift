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
    
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    
    var swipeHandler: ((Swap) -> Void)?
    
    
    private var gems = [[Gem?]] (repeating: [Gem?](repeating: Gem(), count: numColumns), count: numRows)
    private var possibleSwaps: Set<Swap> = []
    
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
        
        DetectPossibleSwaps()
        
        return set
    }
    
    func GetGemAt(_ column: Int, _ row: Int) -> Gem? {
        guard (column >= 0 && column < numColumns) && (row >= 0 && row < numRows)
        else{
            print("this position does not exist!")
            return nil
        }
        
        return gems[column][row]
    }
    
    func TrySelectGem(column: Int, row: Int) -> Bool {
        
        if let gem = GetGemAt(column, row) {
            swipeFromColumn = gem.column
            swipeFromRow = gem.row
            
            return true
        }
        return false
    }
    
    func TrySwap(horizontalDelta: Int, verticalDelta: Int) {
        let toColumn = swipeFromColumn! + horizontalDelta
        let toRow = swipeFromRow! + verticalDelta
        
        guard toColumn >= 0 && toColumn < numColumns else { return }
        guard toRow >= 0 && toRow < numRows else { return }
        
        if let toGem = GetGemAt(toColumn, toRow),
           let fromGem = GetGemAt(swipeFromColumn!, swipeFromRow!) {
            if let handler = swipeHandler {
                let swap = Swap(gemA: fromGem, gemB: toGem)
                handler(swap)
            }
        }
        
        swipeFromColumn = nil
    }
    
    
    func performSwap(_ swap: Swap) {
        let columnA = swap.gemA.column
        let rowA = swap.gemA.row
        
        let columnB = swap.gemB.column
        let rowB = swap.gemB.row
        
        gems[columnA][rowA] = swap.gemB
        swap.gemB.column = columnA
        swap.gemB.row = rowA
        
        gems[columnB][rowB] = swap.gemA
        swap.gemA.column = columnB
        swap.gemA.row = rowB
    }
    
    private func DetectHorizontalMatches() -> Set<Match> {
        var set: Set<Match> = []
        
        for row in 0..<numRows {
            var column = 0
            while column < numColumns-2 {
                if let gem = GetGemAt(column, row) {
                    let matchType = gem.gemType
                    if gems[column + 1][row]?.gemType == matchType &&
                        gems[column + 2][row]?.gemType == matchType {
                        
                        let match = Match(matchType: .horizontal)
                        
                        repeat {
                            match.add(gem: GetGemAt(column, row)!)
                            column += 1
                        } while column < numColumns && GetGemAt(column, row)?.gemType == matchType
                        
                        set.insert(match)
                        continue
                    }
                }
                column += 1
            }
        }
        return set
    }
    
    private func DetectVerticalMatches() -> Set<Match> {
        var set: Set<Match> = []
        
        for column in 0..<numColumns {
            var row = 0
            while row < numRows-2 {
                if let gem = GetGemAt(column, row) {
                    let matchType = gem.gemType
                    
                    if gems[column][row + 1]?.gemType == matchType &&
                        gems[column][row + 2]?.gemType == matchType {
                        let match = Match(matchType: .vertical)
                        
                        repeat {
                            match.add(gem: GetGemAt(column, row)!)
                            row += 1
                        } while row < numRows && GetGemAt(column, row)?.gemType == matchType
                        
                        set.insert(match)
                        continue
                    }
                }
                row += 1
            }
        }
        return set
    }
    
    private func RemoveGems(in matches: Set<Match>) {
        for match in matches {
            for gem in match.gems {
                gems[gem.column][gem.row] = nil
            }
        }
    }
    
    func RemoveMatches() -> Set<Match> {
        let horizontalMatches = DetectHorizontalMatches()
        let verticalMatches = DetectVerticalMatches()
        
        RemoveGems(in: horizontalMatches)
        RemoveGems(in: verticalMatches)
        
        return horizontalMatches.union(verticalMatches)
    }
    
    private func HasMatch(column: Int, row: Int) -> Bool {
        let gemType = gems[column][row]!.gemType
        
        // Horizontal chain check
        var horizontalLength = 1
        
        // Left
        var i = column - 1
        while i >= 0 && gems[i][row]?.gemType == gemType {
            i -= 1
            horizontalLength += 1
        }
        
        // Right
        i = column + 1
        while i < numColumns && gems[i][row]?.gemType == gemType {
            i += 1
            horizontalLength += 1
        }
        if horizontalLength >= 3 { return true }
        
        // Vertical chain check
        var verticalLength = 1
        
        // Down
        i = row - 1
        while i >= 0 && gems[column][i]?.gemType == gemType {
            i -= 1
            verticalLength += 1
        }
        
        // Up
        i = row + 1
        while i < numRows && gems[column][i]?.gemType == gemType {
            i += 1
            verticalLength += 1
        }
        return verticalLength >= 3
    }
    
    func DetectPossibleSwaps() {
        var set: Set<Swap> = []
        
        for row in 0..<numRows {
            for column in 0..<numColumns {
                if let gem = gems[column][row] {
                    
                    if column < numColumns - 1,
                       let other = gems[column + 1][row] {
                        // Swap them
                        gems[column][row] = other
                        gems[column + 1][row] = gem
                        
                        if HasMatch(column: column + 1, row: row) ||
                            HasMatch(column: column, row: row) {
                            set.insert(Swap(gemA: gem, gemB: other))
                        }
                        
                        gems[column][row] = gem
                        gems[column + 1][row] = other
                    }
                    
                    if row < numRows - 1,
                       let other = gems[column][row + 1] {
                        gems[column][row] = other
                        gems[column][row + 1] = gem
                        
                        if HasMatch(column: column, row: row + 1) ||
                            HasMatch(column: column, row: row) {
                            set.insert(Swap(gemA: gem, gemB: other))
                        }
                        
                        // Swap them back
                        gems[column][row] = gem
                        gems[column][row + 1] = other
                    }
                }
                else if column == numColumns - 1, let gem = gems[column][row] {
                    if row < numRows - 1,
                       let other = gems[column][row + 1] {
                        gems[column][row] = other
                        gems[column][row + 1] = gem
                        
                        if HasMatch(column: column, row: row + 1) ||
                            HasMatch(column: column, row: row) {
                            set.insert(Swap(gemA: gem, gemB: other))
                        }
                        
                        // Swap them back
                        gems[column][row] = gem
                        gems[column][row + 1] = other
                    }
                    
                }
            }
        }
        
        possibleSwaps = set
    }
    
    func
    
    CanSwap(_ swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
    func FillEmptyTiles() -> [[Gem]] {
        var columns: [[Gem]] = []
        
        for column in 0..<numColumns {
            var array: [Gem] = []
            for row in 0..<numRows {
                if gems[column][row] == nil {
                    for lookup in (row + 1)..<numRows {
                        if let gem = gems[column][lookup] {
                            gems[column][lookup] = nil
                            gems[column][row] = gem
                            gem.row = row
                            array.append(gem)
                            break
                        }
                    }
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func SpawnGems() -> [[Gem]] {
        
        var columns: [[Gem]] = []
        var gemType = GemType.GetRandom()
        
        for column in 0..<numColumns {
            var array: [Gem] = []
            var row = numRows - 1
            while row >= 0 && gems[column][row] == nil {
                gemType = GemType.GetRandom()
                let gem = Gem(column: column, row: row, gemType: gemType)
                gems[column][row] = gem
                array.append(gem)
                
                row -= 1
            }
            
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
}
