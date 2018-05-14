/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

let numColumns = 9
let numRows = 9

class Level {
  private var cookies = Array2D<Cookie>(columns: numColumns, rows: numRows)
  private var tiles = Array2D<Tile>(columns: numColumns, rows: numRows)
  private var possibleSwaps: Set<Swap> = []
  //private var swap: Swap?
  private var comboMultiplier = 1
  var score = 0
  var moves = 0
  
  init(filename: String) {
    guard let levelData = LevelData.loadFrom(file: filename) else { return }
    let tilesArray = levelData.tiles
    for (row, rowArray) in tilesArray.enumerated() {
      let tileRow = numRows - row - 1
      for (column, value) in rowArray.enumerated() {
        if value == 1 {
          tiles[column, tileRow] = Tile()
        }
      }
    }
  }
  
  // Create initial cookies
  // Return a set of cookies for animation
  func createInitialCookies() -> Set<Cookie> {
    var set: Set<Cookie> = []
    for row in 0..<numRows {
      for column in 0..<numColumns {
        if tiles[column, row] != nil {
          // Generate random cookie type without making a chain of three.
          var cookieType: CookieType
          repeat {
            cookieType = CookieType.random()
          } while (column >= 2 &&
            cookies[column - 1, row]?.cookieType == cookieType &&
            cookies[column - 2, row]?.cookieType == cookieType)
            || (row >= 2 &&
              cookies[column, row - 1]?.cookieType == cookieType &&
              cookies[column, row - 2]?.cookieType == cookieType)
          let cookie = Cookie(column: column, row: row, cookieType: cookieType)
          cookies[column, row] = cookie
          set.insert(cookie)
        }
      }
    }
    return set
  }
  
  // Shuffle all the cookies if there is no possible swap
  func shuffle() -> Set<Cookie> {
    var renew: Set<Cookie> = []
    for row in 0..<numRows {
      for col in 0..<numColumns {
        if let cookie = cookies[col, row] {
          if cookie.cookieMask == CookieMask.none && cookie.blastType == BlastType.none {
            renew.insert(cookie)
          }
        }
      }
    }
    // Random relocate cookies
    while (!renew.isEmpty) {
      
    }
  }
  
  // Detect if the swap is valid
  // Find all possible swaps in the cookies board
  // Check if the provided swap is in the swap pool
  func isPossibleSwap(_ swap: Swap) -> Bool {
    detectPossibleSwaps()
    return possibleSwaps.contains(swap)
  }
  
  
  // Swap is valid between two cookies if any:
  // 1). Both cookies are blast types
  // 2). At least one of the cookies is a samekind type of blast, while the other one is a cookie without mask
  // 3). After the swap, at least one of them can form a chain of 3 or more
  func detectPossibleSwaps() {
    var set: Set<Swap> = []
    for row in 0..<numRows {
      for column in 0..<numColumns {
        if let cookie = cookies[column, row] { // Have a cookie in this spot? If there is no tile, there is no cookie.
          if column < numColumns - 1,
            let other = cookies[column + 1, row] {
            if (cookie.cookieMask != CookieMask.none || other.cookieMask != CookieMask.none) {
              continue
            }
            // Swap them
            cookies[column, row] = other
            cookies[column + 1, row] = cookie
            
            // Is either cookie now part of a chain?
            if hasChain(atColumn: column + 1, row: row) ||
              hasChain(atColumn: column, row: row) ||
              isBlastPair(cookieFrom: cookie, cookieTo: other) {
              set.insert(Swap(cookieA: cookie, cookieB: other))
            }
            
            // Swap them back
            cookies[column, row] = cookie
            cookies[column + 1, row] = other
            
          if row < numRows - 1,
            let other = cookies[column, row + 1] {
            cookies[column, row] = other
            cookies[column, row + 1] = cookie
            
            // Is either cookie now part of a chain?
            if hasChain(atColumn: column, row: row + 1) ||
              hasChain(atColumn: column, row: row) ||
              isBlastPair(cookieFrom: cookie, cookieTo: other) {
              set.insert(Swap(cookieA: cookie, cookieB: other))
            }
            
            // Swap them back
            cookies[column, row] = cookie
            cookies[column, row + 1] = other
            }
          }
        }
      }
    }
    possibleSwaps = set
  }
  
  func hasPossibleSwap() -> Bool {
    return !possibleSwaps.isEmpty
  }
  
  // Detect if two neibour cookies are blast pairs
  // Return true if there are pair of blast
  private func isBlastPair(cookieFrom: Cookie, cookieTo: Cookie) -> Bool {
    if cookieFrom.isBlast && cookieTo.isBlast {
      return true
    }
    
    if cookieFrom.isBlast && cookieFrom.blastType == BlastType.samekind && cookieTo.cookieMask == CookieMask.none
      || cookieTo.isBlast && cookieTo.blastType == BlastType.samekind && cookieFrom.cookieMask == CookieMask.none {
      return true
    }
  }
  
  // Detect if there is a chain at specific position (column, row)
  private func hasChain(atColumn column: Int, row: Int) -> Bool {
    let cookieType = cookies[column, row]!.cookieType
    
    // Horizontal chain check
    var horizontalLength = 1
    
    // Left
    var i = column - 1
    while i >= 0 && cookies[i, row]?.cookieType == cookieType {
      i -= 1
      horizontalLength += 1
    }
    
    // Right
    i = column + 1
    while i < numColumns && cookies[i, row]?.cookieType == cookieType {
      i += 1
      horizontalLength += 1
    }
    if horizontalLength >= 3 { return true }
    
    // Vertical chain check
    var verticalLength = 1
    
    // Down
    i = row - 1
    while i >= 0 && cookies[column, i]?.cookieType == cookieType {
      i -= 1
      verticalLength += 1
    }
    
    // Up
    i = row + 1
    while i < numRows && cookies[column, i]?.cookieType == cookieType {
      i += 1
      verticalLength += 1
    }
    return verticalLength >= 3
  }
  
  // Perform swap with provided swap instance
  func performSwap(_ swap: Swap) {
    //self.swap = swap
    let columnA = swap.cookieA.column
    let rowA = swap.cookieA.row
    let columnB = swap.cookieB.column
    let rowB = swap.cookieB.row
    
    cookies[columnA, rowA] = swap.cookieB
    swap.cookieB.column = columnA
    swap.cookieB.row = rowA
    
    cookies[columnB, rowB] = swap.cookieA
    swap.cookieA.column = columnB
    swap.cookieA.row = rowB
  }
  
  func dealMatches() -> Set<Chain> {
    let horizontalChains = detectHorizontalMatches()
    let verticalChains = detectVerticalMatches()
    
    let blaster: Set<Cookie> = findPowerCookies(hChains: horizontalChains, vChains: verticalChains)
    return removeMatches(hChains: horizontalChains, vChains: verticalChains)
  }
  
  // Detect if there is chain lenght > 3
  // Replace the lastSwapIn cookie with a corresponding blast version
  //
  func findPowerCookies(hChains: Set<Chain>, vChains: Set<Chain>) -> Set<Cookie> {
    var blaster: Set<Cookie> = []
    for chain in hChains {
      if chain.length == 4 {
        let cookie = Cookie(column: chain.lastSwapIn.column, row: chain.lastSwapIn.row, cookieType: chain.lastSwapIn.cookieType)
        cookie.blastType = BlastType.horizontal
        blaster.insert(cookie)
      } else if chain.length >= 5 {
        let cookie = Cookie(column: chain.lastSwapIn.column, row: chain.lastSwapIn.row, cookieType: chain.lastSwapIn.cookieType)
        cookie.blastType = BlastType.samekind
        blaster.insert(cookie)
      }
    }
    
    for chain in vChains {
      if chain.length == 4 {
        let cookie = Cookie(column: chain.lastSwapIn.column, row: chain.lastSwapIn.row, cookieType: chain.lastSwapIn.cookieType)
        cookie.blastType = BlastType.vertical
        blaster.insert(cookie)
      } else if chain.length >= 5 {
        let cookie = Cookie(column: chain.lastSwapIn.column, row: chain.lastSwapIn.row, cookieType: chain.lastSwapIn.cookieType)
        cookie.blastType = BlastType.samekind
        blaster.insert(cookie)
      }
    }
    
    return blaster
  }
  
  private func removeMatches(hChains: Set<Chain>, vChains: Set<Chain>) -> Set<Chain> {
    removeCookies(in: hChains)
    removeCookies(in: vChains)
    calculateScores(for: hChains)
    calculateScores(for: vChains)
    return hChains.union(vChains)
  }
  
  private func detectHorizontalMatches() -> Set<Chain> {
    var set: Set<Chain> = []
    for row in 0..<numRows {
      var column = 0
      while column < numColumns-2 {
        if let cookie = cookies[column, row] {
          let matchType = cookie.cookieType
          if cookies[column + 1, row]?.cookieType == matchType &&
            cookies[column + 2, row]?.cookieType == matchType {
            let chain = Chain(chainType: .horizontal, lastSwapIn: cookies[column, row]!)
            repeat {
              chain.add(cookie: cookies[column, row]!)
              column += 1
            } while column < numColumns && cookies[column, row]?.cookieType == matchType
            
            set.insert(chain)
            continue
          }
        }
        column += 1
      }
    }
    return set
  }
  
  private func detectVerticalMatches() -> Set<Chain> {
    var set: Set<Chain> = []
    for column in 0..<numColumns {
      var row = 0
      while row < numRows-2 {
        if let cookie = cookies[column, row] {
          let matchType = cookie.cookieType
          if cookies[column, row + 1]?.cookieType == matchType &&
            cookies[column, row + 2]?.cookieType == matchType {
            let chain = Chain(chainType: .vertical, lastSwapIn: cookies[column, row]!)
            repeat {
              chain.add(cookie: cookies[column, row]!)
              row += 1
            } while row < numRows && cookies[column, row]?.cookieType == matchType
            
            set.insert(chain)
            continue
          }
        }
        row += 1
      }
    }
    return set
  }
  
  private func removeCookies(in chains: Set<Chain>) {
    for chain in chains {
      for cookie in chain.cookies {
        
        cookies[cookie.column, cookie.row] = nil
      }
    }
  }
  
  func fillHoles() -> [[Cookie]] {
    var columns: [[Cookie]] = []
    for column in 0..<numColumns {
      var array: [Cookie] = []
      for row in 0..<numRows {
        if tiles[column, row] != nil && cookies[column, row] == nil {
          for lookup in (row + 1)..<numRows {
            if let cookie = cookies[column, lookup] {
              cookies[column, lookup] = nil
              cookies[column, row] = cookie
              cookie.row = row
              array.append(cookie)
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
  
  func topUpCookies() -> [[Cookie]] {
    var columns: [[Cookie]] = []
    var cookieType: CookieType = .unknown
    
    for column in 0..<numColumns {
      var array: [Cookie] = []
      var row = numRows - 1
      while row >= 0 && cookies[column, row] == nil {
        if tiles[column, row] != nil {
          var newCookieType: CookieType
          repeat {
            newCookieType = CookieType.random()
          } while newCookieType == cookieType
          cookieType = newCookieType
          let cookie = Cookie(column: column, row: row, cookieType: cookieType)
          cookies[column, row] = cookie
          array.append(cookie)
        }
        row -= 1
      }
      if !array.isEmpty {
        columns.append(array)
      }
    }
    return columns
  }
  
  private func calculateScores(for chains: Set<Chain>) {
    // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
    for chain in chains {
      chain.score = 60 * (chain.length - 2) * comboMultiplier
      comboMultiplier += 1
    }
  }
  
  func resetComboMultiplier() {
    comboMultiplier = 1
  }
  
  func tileAt(column: Int, row: Int) -> Tile? {
    precondition(column >= 0 && column < numColumns)
    precondition(row >= 0 && row < numRows)
    return tiles[column, row]
  }
  
  func cookie(atColumn column: Int, row: Int) -> Cookie? {
    precondition(column >= 0 && column < numColumns)
    precondition(row >= 0 && row < numRows)
    return cookies[column, row]
  }
}

