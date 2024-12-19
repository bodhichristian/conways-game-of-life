//
//  ContentView.swift
//  ConwayLife
//
//  Created by christian on 12/19/24.
//

import SwiftUI

@Observable
class Cell {
    var id: UUID = UUID()
    var alive: Bool = false
}

struct ContentView: View {
    
    let rows = 10
    let columns = 10
    let spacing: CGFloat = 2
    
    private var gridItems: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: rows)
    }
    
    private var totalCells: Int {
        rows * columns
    }
    
    @State private var gameBoard: [[Cell]] = []
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack {
            LazyVGrid(columns: gridItems) {
                ForEach(gameBoard.flatMap { $0 }, id: \.id) { cell in
                    Rectangle()
                        .foregroundStyle(cell.alive ? .black : .secondary.opacity(0.5))
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            if timer == nil {
                                cell.alive.toggle()
                            }
                        }
                }
            }
            
            HStack {
                Button("Clear") {
                    setBoard()
                }
                .disabled(timer != nil)
                
                Button("Randomize") {
                    for row in gameBoard {
                        for cell in row {
                            cell.alive = Bool.random()
                        }
                    }
                }
                
                Button("Step") {
                    newGeneration()
                }
                
                Button {
                    if timer == nil {
                        automateGameplay()
                    } else {
                        stopAutomation()
                    }
                } label: {
                    if timer == nil {
                        Text("Start")
                    } else {
                        Text("Stop")
                            .fontWeight(.bold)
                    }
                }
            }
            .padding()
        }
        .padding()
        .onAppear {
            setBoard()
        }
    }
    
    private func setBoard() {
        gameBoard = []
        
        for _ in 0..<rows {
            var row: [Cell] = []
            for _ in 0..<columns {
                let cell = Cell()
                row.append(cell)
            }
            gameBoard.append(row)
        }
    }
    
    private func newGeneration() {
        for rowIndex in gameBoard.indices {
            for columnIndex in gameBoard[rowIndex].indices {
                let cell = gameBoard[rowIndex][columnIndex]
                let aliveNeighbors = aliveNeighbors(for: (row: rowIndex, column: columnIndex))
                
                // Birth
                if cell.alive == false && aliveNeighbors == 3 {
                    cell.alive = true
                }
                
                // Death from under- or overpopulation
                if cell.alive && (aliveNeighbors < 2 || aliveNeighbors > 3) {
                    cell.alive = false
                }
            }
        }
    }
    
    private func aliveNeighbors(for position: (row: Int, column: Int)) -> Int {
        var neighbors = 0
        
        let directions = [
            (row: -1, col: 0), // up
            (row: -1, col: -1), // up, left
            (row: -1, col: 1), // up, right
            
            (row: 1, col: 0), // down
            (row: 1, col: -1), // down, left
            (row: 1, col: 1), // down, right
            
            (row: 0, col: -1), // left
            (row: 0, col: 1) // right
        ]
        
        for direction in directions {
            let newRow = position.row + direction.row
            let newCol = position.column + direction.col
            
            if gameBoard.indices.contains(newRow),
               gameBoard[newRow].indices.contains(newCol),
               gameBoard[newRow][newCol].alive {
                neighbors += 1
            }
        }
        return neighbors
    }
    
    func automateGameplay() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
            newGeneration()
        })
    }
    
    func stopAutomation() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ContentView()
}
