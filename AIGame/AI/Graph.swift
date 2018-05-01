//
//  Graph.swift
//  AIGame
//
//  Created by Jakub Nadolny on 21.04.2018.
//  Copyright © 2018 Jakub Nadolny. All rights reserved.
//

import Foundation

enum Minmax {
    case min
    case max
}

struct Move: Equatable {
    let row: Int
    let col: Int
    let player: Value

    static func ==(lhs: Move, rhs: Move) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col && rhs.player == lhs.player
    }

}

class Graph {
    var root: Node
    var board:Board

    init(board: Board) {
        self.board = Board(board: board)
        root = Node(parent: nil, board: &self.board, mode: Minmax.max, player: .player1, tour: .player1, move:Move(row: 0, col: 0, player: .empty))
    }

    init(board: Board, mode: Minmax, player: Value) {
        self.board = Board(board: board)
        root = Node(parent: nil, board: &self.board, mode: mode, player: player, tour: player, move:Move(row: 0, col: 0, player: .empty))
    }

    func minMax(level: Int) -> Node {
        let best = root.minMax(level: level)
        let node = root.child[best.indexFromRoot]
        return node
    }
    
    func alphaBeta(level:Int) -> Node{
        let best = root.alphaBeta(level: level, alpha: Int.min, beta: Int.max)
        let node = root.child[best.indexFromRoot]
        return node
    }
}

class Node: CustomStringConvertible {
    // nodes links
    weak var parent: Node?
    var child: ContiguousArray<Node> = ContiguousArray()
    
    // properties
    var board: Board
    let mode: Minmax
    let move:Move
    let player: Value
    let tour: Value
    
    // values
    var indexFromRoot: Int = -1
    
    // indices
    lazy var emptyIndices = board.getEmptyIndices()

    init(parent: Node?, board: inout Board, mode: Minmax, player: Value, tour:Value, move:Move) {
        self.parent = parent
        self.board = board
        self.mode = mode
        self.player = player
        self.tour = tour
        self.move = move
        
        let emptySize = emptyIndices.count
        child.reserveCapacity(emptySize)
        
        board.assign(move: move)
    }

    func minMax(level: Int) -> Node {
        var value:Node? = nil
        if (level == 0 || emptyIndices.count == 0) {
            // nie schodź niżej. zwróć wynik wyżej
            return self
        } else {
            var i = 0
            let empties = emptyIndices.count
            while i < empties{
                createNextChild()
                let calculated = child[i].minMax(level: level - 1)
                board.revert()
                if let _ = value {
                    if (mode == .min) {
                        if calculated.getScore() < value!.getScore() {
                            value = calculated
                        }
                    } else {
                        if calculated.getScore() > value!.getScore() {
                            value = calculated
                        }
                    }
                } else {
                    value = calculated
                }
                i += 1
            }
        }
        return value == nil ? self : value!
    }
    
    func alphaBeta(level: Int, alpha:Int, beta:Int) -> Node {
        var value:Node? = nil
        var alpha = alpha
        var beta = beta
        
        if (level == 0 || emptyIndices.count == 0) {
            // nie schodź niżej. zwróć wynik wyżej
            return self
        } else {
            var i = 0
            let empties = emptyIndices.count
            while i < empties && alpha < beta{
                createNextChild()
                let calculated = child[i].alphaBeta(level: level - 1, alpha: alpha, beta: beta)
                let score = calculated.getScore()
                print("Score = \(score)")
                if let _ = value {
                    if mode == .min {
                        if score < value!.getScore() {
                            value = calculated
                            if score < beta{
                                beta = score
                            }
                        }
                    } else {
                        if score > value!.getScore() {
                            value = calculated
                            if score > alpha{
                                alpha = score
                            }
                        }
                    }
                } else {
                    value = calculated
                    if mode == .min{
                        beta = calculated.getScore()
                    }else{
                        alpha = calculated.getScore()
                    }
                }
                i += 1
                board.revert()
            }
        }
        return value == nil ? self : value!
    }

    func getScore() -> Int {
        let oponent: Value = player == .player1 ? .player2 : .player1
        return board.scores[player]! - board.scores[oponent]!
    }

    func findMove(move: Move) -> Node {
        return child.filter { (node: Node) -> Bool in
            node.board.checkPoints.last!.move == move
        }.first!
    }
    
    private func createNextChild(){
        let nextMode: Minmax = mode == .max ? .min : .max
        let nextPlayer: Value = self.tour == .player1 ? .player2 : .player1
        
        let nextIndice = emptyIndices.removeFirst()
        
        let move = Move(row: nextIndice.0, col: nextIndice.1, player: tour)
        let newNode = Node(parent: self, board: &board, mode: nextMode, player: player, tour:nextPlayer, move:move)
        if (self.parent == nil) {
            newNode.indexFromRoot = child.count
        } else {
            newNode.indexFromRoot = self.indexFromRoot
        }
        child.append(newNode)
        
    }
    
    var description: String {
        return "\(board.description)\n" +
        "mode : \(mode), now moving : \(player), score = \(board.scores[Value.player1]!) : \(board.scores[Value.player2]!)"
    }

}
