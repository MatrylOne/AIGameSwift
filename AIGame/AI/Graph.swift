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

    init(board: Board) {
        root = Node(parent: nil, board: board, mode: Minmax.max, player: .player1, tour: .player1)
    }

    init(board: Board, mode: Minmax, player: Value) {
        root = Node(parent: nil, board: board, mode: mode, player: player, tour: player)
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
    lazy var child = self.createChild()
    
    // properties
    let board: Board
    let mode: Minmax
    let player: Value
    let tour: Value
    
    // values
    var indexFromRoot: Int = -1
    
    // indices
    lazy var emptyIndices = board.getEmptyIndices()

    init(parent: Node?, board: Board, mode: Minmax, player: Value, tour:Value) {
        self.parent = parent
        self.board = board
        self.mode = mode
        self.player = player
        self.tour = tour
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
                let calculated = child[i].minMax(level: level - 1)
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
                let calculated = child[i].alphaBeta(level: level - 1, alpha: alpha, beta: beta)
                let score = calculated.getScore()
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
            node.board.lastMove == move
        }.first!
    }

    private func createChild() -> ContiguousArray<Node> {
        let emptySize = emptyIndices.count
        let nextMode: Minmax = mode == .max ? .min : .max
        let nextPlayer: Value = self.tour == .player1 ? .player2 : .player1

        var child: ContiguousArray<Node> = ContiguousArray()
        child.reserveCapacity(emptySize)

        if (emptySize > 0) {
            for i in 0..<emptySize {
                var newBoard = Board(board: board)
                newBoard.assign(row: emptyIndices[i].0, col: emptyIndices[i].1, player: tour)
                let newNode = Node(parent: self, board: newBoard, mode: nextMode, player: player, tour:nextPlayer)
                if (self.parent == nil) {
                    newNode.indexFromRoot = i
                } else {
                    newNode.indexFromRoot = self.indexFromRoot
                }
                child.append(newNode)
            }
        }
        return child
    }
    
    var description: String {
        return "\(board.description)\n" +
        "mode : \(mode), now moving : \(player), score = \(board.scores[Value.player1]!) : \(board.scores[Value.player2]!)"
    }

}
