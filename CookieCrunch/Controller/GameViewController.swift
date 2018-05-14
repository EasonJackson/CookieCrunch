/**
 * GameViewController.swift
 * CookieCrunch
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
  
  // MARK: Properties
  // The scene draws the tiles and cookie sprites, and handles swipes actions from screen touch.
  var scene: GameScene!
  //The level store all data model, provide mechanism to swap, handle match.
  var level: Level!
  var movesUsed = 0
  var score = 0
  
  // Create a variable of background music player
  // Initialization is in a closure
  // lazy marks the closure won't 
  lazy var backgroundMusic: AVAudioPlayer? = {
    guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3") else {
      return nil
    }
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.numberOfLoops = 1
      return player
    } catch {
      return nil
    }
  }()
  
  // MARK: IBOutlets
  @IBOutlet weak var gameOverPanel: UIImageView!
  @IBOutlet weak var targetLabel: UILabel!
  @IBOutlet weak var movesLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var shuffleButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Configure the view
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false
    
    // Create and configure the scene.
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    
    // Create level
    level = Level(filename: "Level_0")
    scene.level = level
    scene.swipeHandler = handleSwipe

    // Present the scene.
    skView.presentScene(scene)
    scene.addTiles()
    
    // Start background music
    backgroundMusic?.play()
    
    // Start a new game
    beginGame()
  }
  
  // Start a new game and reset all properties
  func beginGame() {
    level.resetComboMultiplier()
    updateLabels()
    scene.removeAllCookieSprites()
    let newCookies = level.createInitialCookies()
    scene.addSprites(for: newCookies)
  }
  
  // Swap handler func used in scene
  func handleSwipe(_ swap: Swap) {
    view.isUserInteractionEnabled = false
    
    if level.isPossibleSwap(swap) {
      level.performSwap(swap)
      scene.animate(swap, completion: handleMatches)
    } else {
      scene.animateInvalidSwap(swap) {
        self.view.isUserInteractionEnabled = true
      }
    }
  }
  
  func handleMatches() {
    let chains = level.dealMatches()
    let blastCookie = level.findPowerCookie()
    if chains.count == 0 {
      beginNextTurn()
      return
    }
    scene.animateMatchedCookies(for: chains) {
      for chain in chains {
        self.score += chain.score
      }
      self.updateLabels()
      scene.animatePowerCookies(for: chains) {
      
        let columns = self.level.fillHoles()
        self.scene.animateFallingCookies(in: columns) {
          let columns = self.level.topUpCookies()
          self.scene.animateNewCookies(in: columns) {
            self.handleMatches()
          }
        }
      }
    }
  }
  
  func beginNextTurn() {
    repeat {
      level.shuffle()
      level.detectPossibleSwaps()
    } while (level.hasPossibleSwap())
    level.resetComboMultiplier()
    level.detectPossibleSwaps()
    view.isUserInteractionEnabled = true
  }
  
  func updateLabels() {
    //targetLabel.text = String(format: "%ld", )
    movesLabel.text = String(format: "%ld", movesUsed)
    scoreLabel.text = String(format: "%ld", score)
  }
  
  // MARK: IBActions
  @IBAction func shuffleButtonPressed(_: AnyObject) {
    shuffle()
  }
  
  // MARK: View Controller Functions
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }
  
  func shuffle() {
    scene.animateShuffle()
    level.shuffle()
  }
}
