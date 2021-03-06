/*
* Copyright (c) 2015 Razeware LLC
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
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import UIKit


class BullsEyeGame {
  var round = 0
  let startValue = RGB()
  var targetValue = RGB()
  var scoreRound = 0
  var scoreTotal = 0
  
  init() {
    startNewGame()
  }
  
  func startNewGame() {
    round = 0
    scoreTotal = 0
    startNewRound()
  }
  
  func startNewRound() {
    round = round + 1
    scoreRound = 0
    targetValue.r = Int.random(in:0..<256)
    targetValue.g = Int.random(in:0..<256)
    targetValue.b = Int.random(in:0..<256)
  }
  
  func checkGuess(guess: RGB, target: RGB) -> Int {
    let difference = guess.difference(target: targetValue)
    scoreRound = Int((1.0 - difference) * 100.0 + 0.5)
    scoreTotal = scoreTotal + scoreRound
    
    return 100 - scoreRound
  }
}
