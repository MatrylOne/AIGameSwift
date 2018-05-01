//
//  main.swift
//  AIGame
//
//  Created by Jakub Nadolny on 21.04.2018.
//  Copyright © 2018 Jakub Nadolny. All rights reserved.
//

import Foundation

public func randomVsMinMax(size:Int){
    var board = Board(size: size)
    var graph = Graph(board: board)
    
    var emptyIndexes = board.getEmptyIndices()
    while(emptyIndexes.count != 0){
        let ai = graph.alphaBeta(level: 5)
        let secondMove = ai.board.checkPoints.last!.move
        board.assign(move: secondMove)
        
        print(board)
        print(board.scores)
        /////////////
        emptyIndexes = board.getEmptyIndices()
        let randomNumber = Int(arc4random_uniform(UInt32(emptyIndexes.count)))
        let place = emptyIndexes[randomNumber]
        let move = Move(row: place.row, col: place.col, player: .player2)
        board.assign(move: move)
        
        print(board)
        print(board.scores)
        
        graph = Graph(board: board)
        ////////////////
        emptyIndexes = board.getEmptyIndices()
    }
    
}

public func printBest(){
    let size = 50
    let board = Board(size:size)
    let graph = Graph(board:board)
    var node = graph.root
    let values = size * size
    for _ in 0..<values{
        let childCount = node.child.count
        let random = Int(arc4random_uniform(UInt32(childCount)))
        node = node.child[random]
    }
    print(node)
    
    print("Stworzono wszystkie")
}

public func play(size:Int) {
    var board = Board(size: size)
    var player = Value.player1
    while (board.scores[Value.player1]! < 100 && board.scores[Value.player2]! < 1000) {
        print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
        print(board)
        print()
        print("Player 1 : \(board.scores[Value.player1]!)")
        print("Player 2 : \(board.scores[Value.player2]!)")
        print()
        print()
        print("Player \(player) wiersz : ")
        let lastRow = Int(readLine()!)!
        print("Player \(player) kolumna : ")
        let lastCol = Int(readLine()!)!
        board.assign(move:Move(row: lastRow, col: lastCol, player: player))
        
        if (player == .player1) {
            player = .player2
        } else {
            player = .player1
        }
    }
}

public func minMax(size:Int){
    let board:Board = Board(size: size)
    let graph = Graph(board: board)
    let best = graph.minMax(level: 3)
    print(best.board)
    print(best.board.scores)
    print(best.getScore())
    print(best.board.checkPoints.last!.move)
    
}

public func aiVSai(size:Int){
    var board = Board(size: size)
    var emptyIndexes = board.getEmptyIndices()
    var currentPlayer = Value.player1
    while(emptyIndexes.count != 0){
        let ai = Graph(board: board, mode: .max, player: currentPlayer)
        let best = ai.alphaBeta(level: 5)
        board.assign(move: best.board.checkPoints.last!.move)
        currentPlayer = currentPlayer == .player1 ? .player2 : .player1
        ////////////////
        emptyIndexes = board.getEmptyIndices()
        print(board)
        print(board.scores)
    }
}

public func compareAI(size:Int, fill:Int, depth:Int){
    var board = Board(size: size)
    var currentPlayer = Value.player1
    
    // fill board
    for _ in 0..<fill{
        let emptyIndexes = board.getEmptyIndices()
        let randomNumber = Int(arc4random_uniform(UInt32(emptyIndexes.count)))
        let place = emptyIndexes[randomNumber]
        let move = Move(row: place.row, col: place.col, player: currentPlayer)
        board.assign(move: move)
        currentPlayer = currentPlayer == .player1 ? .player2 : .player1
    }
    print(board)
    let ab = Graph(board: board, mode: .max, player: .player1)
    
    let start = DispatchTime.now()
    
    let resAB = ab.alphaBeta(level: depth)
    let stop = DispatchTime.now()
    print(resAB)
    print("MinMax time = \((stop.uptimeNanoseconds - start.uptimeNanoseconds)/1000000)")
}

randomVsMinMax(size: 8)
