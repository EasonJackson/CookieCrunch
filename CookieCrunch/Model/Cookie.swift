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

import SpriteKit

class Cookie: CustomStringConvertible, Hashable {
  let cookieType: CookieType
  var cookieMask: CookieMask = CookieMask.none
  var column: Int
  var row: Int
  var isBlast: Bool
  var blastType: BlastType
  var sprite: SKSpriteNode?
  
  var description: String {
    return "type:\(cookieType) square:(\(column),\(row))"
  }
  
  var hashValue: Int {
    return row * 10 + column
  }
  
  init(column: Int, row: Int, cookieType: CookieType) {
    self.column = column
    self.row = row
    self.cookieType = cookieType
    self.isBlast = false
    self.blastType = BlastType.none
  }
  
  static func ==(lhs: Cookie, rhs: Cookie) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
    
  }
}

// ENUM CookieType
enum CookieType: Int {
  case unknown = 0, croissant, cupcake, danish, donut, macaroon, sugarCookie,
  croissantLineH, cupcakeLineH, danishLineH, donutLineH, macaroonLineH, sugarCookieLineH,
  croissantLineV, cupcakeLineV, danishLineV, donutLineV, macaroonLineV, sugarCookieLineV,
  croissantSqr, cupcakeSqr, danishSqr, donutSqr, macaroonSqr, sugarCookieSqr,
  powerCookie
  
  var spriteName: String {
    let spriteNames = [
      "Croissant",
      "Cupcake",
      "Danish",
      "Donut",
      "Macaroon",
      "SugarCookie",
      "CroissantLineH",
      "CupcakeLineH",
      "DanishLineH",
      "DonutLineH",
      "MacaroonLineH",
      "SugarCookieLineH",
      "CroissantLineV",
      "CupcakeLineV",
      "DanishLineV",
      "DonutLineV",
      "MacaroonLineV",
      "SugarCookieLineV",
      "CroissantSqr",
      "CupcakeSqr",
      "DanishSqr",
      "DonutSqr",
      "MacaroonSqr",
      "SugarCookieSqr",
      "PowerCookie"]
    
    return spriteNames[rawValue - 1]
  }
  
  var highlightedSpriteName: String {
    return spriteName + "-Highlighted"
  }
  
  func toVerticleBlast() -> String {
    return spriteName + "LineV"
  }
  
  func toHorizontalBlast() -> String {
    return spriteName + "LineH"
  }
  
  func toSqrBlast() -> String {
    return spriteName + "Sqr"
  }
  
  static func random() -> CookieType {
    return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
  }
}

// ENUM CookieMask
enum CookieMask: Int {
  case none = 0, block, frozen
  var maskName: String {
    let maskNames = [
      "Blocked",
      "Frozen"
    ]
    return maskNames[rawValue - 1]
  }
  
  static func random() -> CookieMask {
    return CookieMask(rawValue: Int(arc4random_uniform(3)))!
  }
}

// ENUM Cookie BlastType
enum BlastType: Int {
  case none = 0, vertical, horizontal, samekind
  
}
