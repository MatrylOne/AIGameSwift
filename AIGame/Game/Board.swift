//
//  Board.swift
//  AIGame
//
//  Created by Jakub Nadolny on 21.04.2018.
//  Copyright © 2018 Jakub Nadolny. All rights reserved.
//

import Foundation

enum Value: UInt8 {
    case empty = 0
    case player1 = 1
    case player2 = 2
}

class Board: CustomStringConvertible {
    public let size: Int
    public var board: [[Value]]
    public var scores: [Value:Int] = [Value.player1:0, Value.player2:0]
    public var checkPoints:[(move:Move, scoreDiff:[Value:Int])]

    var description: String {
        var result: String = "";
        for i in 0..<size {
            for j in 0..<size {
                result += "\(getSign(row: i, col: j)) "
            }
            result += "\n"
        }
        return result
    }

    init(size: Int) {
        self.size = size
        board = Array(repeating: Array(repeating: Value.empty, count: size), count: size)
        checkPoints = []
    }

    init(board: Board) {
        self.size = board.size
        self.board = board.board
        self.scores = board.scores
        self.checkPoints = board.checkPoints
    }

    func getSign(row: Int, col: Int) -> String {
        let value = board[row][col]
        switch value {
        case .empty:
            return "🔲"
        case .player1:
            return "🔶"
        case .player2:
            return "🔷"
        }
    }

    ///////////////////
    func assign(move:Move){
        if (board[move.row][move.col] == .empty) {
            board[move.row][move.col] = move.player
            let scoresBackup = scores
            givePoint(move:move)
            let scoreDiff = [Value.player1: scores[Value.player1]! - scoresBackup[Value.player1]!,
                             Value.player2: scores[Value.player2]! - scoresBackup[Value.player2]!]
            checkPoints.append((move, scoreDiff))
        }
    }
    
    func revert(){
        let last = checkPoints.removeLast()
        board[last.move.row][last.move.col] = .empty
        scores[Value.player1]! -= last.scoreDiff[Value.player1]!
        scores[Value.player2]! -= last.scoreDiff[Value.player2]!
    }

    /////// Checking

    func givePoint(move:Move) {
        if (move.player != .empty) {

            if (isFullRow(row: move.row, col: move.col)) {
                if scores[move.player] != nil{
                    scores[move.player]! += countMaxRowScore(row: move.row, col: move.col)
                }else{
                    scores[move.player] = countMaxRowScore(row: move.row, col: move.col)
                }
            }

            if (isFullCol(row: move.row, col: move.col)) {
                if scores[move.player] != nil{
                    scores[move.player]! += countMaxColScore(row: move.row, col: move.col)
                }else{
                    scores[move.player] = countMaxRowScore(row: move.row, col: move.col)
                }
            }

            if (isFullRising(row: move.row, col: move.col)) {
                if scores[move.player] != nil{
                    scores[move.player]! += countMaxRisingDiagonalScore(row: move.row, col: move.col)
                }else{
                    scores[move.player] = countMaxRowScore(row: move.row, col: move.col)
                }
            }

            if (isFullFalling(row: move.row, col: move.col)) {
                if scores[move.player] != nil{
                    scores[move.player]! += countMaxFallingDiagonalScore(row: move.row, col: move.col)
                }else{
                    scores[move.player] = countMaxRowScore(row: move.row, col: move.col)
                }
            }
        }
    }

    func isFullRow(row: Int, col: Int) -> Bool {
        // row
        let rowC = countInRow(row: row, col: col)
        let rowCMax = countMaxRowScore(row: row, col: col)
        if (rowC == rowCMax && rowCMax > 1) {
            return true
        }
        return false
    }

    func isFullCol(row: Int, col: Int) -> Bool {
        // col
        let colC = countInCol(row: row, col: col)
        let colCMax = countMaxColScore(row: row, col: col)
        if (colC == colCMax && colCMax > 1) {
            return true
        }
        return false
    }

    func isFullRising(row: Int, col: Int) -> Bool {
        //rising
        let risingC = countRisingDiagonal(row: row, col: col)
        let risingCMax = countMaxRisingDiagonalScore(row: row, col: col)
        if (risingC == risingCMax && risingCMax > 1) {
            return true
        }
        return false
    }

    func isFullFalling(row: Int, col: Int) -> Bool {
        //falling
        let fallingC = countFallingDiagonal(row: row, col: col)
        let fallingCMax = countMaxFallingDiagonalScore(row: row, col: col)
        if (fallingC == fallingCMax && fallingCMax > 1) {
            return true
        }
        return false
    }

    public func getEmptyIndices() -> [(row: Int, col: Int)] {
        var indices: [(row: Int, col: Int)] = []
        for i in 0..<size {
            for j in 0..<size {
                if (board[i][j] == .empty) {
                    indices.append((row: i, col: j))
                }
            }
        }
        return indices.shuffled()
    }

    func countEmptyIndices() -> Int{
        return getEmptyIndices().count
    }

//////// Calculations

// RISING
    func calculateRisingStartIndices(row: Int, col: Int) -> (row: Int, col: Int) {
        var startRowIndex = row
        var startColIndex = col

        while (startRowIndex < size - 1 && startColIndex > 0) {
            startRowIndex += 1
            startColIndex -= 1
        }

        return (row: startRowIndex, col: startColIndex)
    }

    func countRisingDiagonal(row: Int, col: Int) -> Int {
        var counter = 0

        var (rowIndex, colIndex) = calculateRisingStartIndices(row: row, col: col)

        while (rowIndex >= 0 && colIndex < size) {
            if (board[rowIndex][colIndex] != .empty) {
                counter += 1
            }
            rowIndex -= 1
            colIndex += 1
        }

        return counter
    }

    func countMaxRisingDiagonalScore(row: Int, col: Int) -> Int {
        var counter = 0
        var (rowIndex, colIndex) = calculateRisingStartIndices(row: row, col: col)

        while (rowIndex >= 0 && colIndex < size) {
            counter += 1
            rowIndex -= 1
            colIndex += 1
        }

        return counter

    }


// FALLING

    func countFallingDiagonal(row: Int, col: Int) -> Int {
        var counter = 0
        var (rowIndex, colIndex) = calculateFallingStartIndices(row: row, col: col)

        while (rowIndex < size && colIndex < size) {
            if (board[rowIndex][colIndex] != .empty) {
                counter += 1
            }
            rowIndex += 1
            colIndex += 1
        }
        return counter
    }

    func calculateFallingStartIndices(row: Int, col: Int) -> (row: Int, col: Int) {
        var startRowIndex = row
        var startColIndex = col

        while (startRowIndex > 0 && startColIndex > 0) {
            startRowIndex -= 1
            startColIndex -= 1
        }

        return (row: startRowIndex, col: startColIndex)
    }

    func countMaxFallingDiagonalScore(row: Int, col: Int) -> Int {
        var counter = 0
        var (rowIndex, colIndex) = calculateFallingStartIndices(row: row, col: col)

        while (rowIndex < size && colIndex < size) {
            counter += 1
            rowIndex += 1
            colIndex += 1
        }
        return counter

    }

// ROWS AND COLS

    func countMaxRowScore(row: Int, col: Int) -> Int {
        return size
    }

    func countMaxColScore(row: Int, col: Int) -> Int {
        return size
    }

    func countInRow(row: Int, col: Int) -> Int {
        var counter = 0
        for i in 0..<size {
            if (board[row][i] != .empty) {
                counter += 1
            }
        }
        return counter
    }

    func countInCol(row: Int, col: Int) -> Int {
        var counter = 0
        for i in 0..<size {
            if (board[i][col] != .empty) {
                counter += 1
            }
        }
        return counter
    }

}
