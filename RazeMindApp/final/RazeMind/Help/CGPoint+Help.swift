/// Copyright (c) 2020 Razeware LLC
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

import CoreGraphics

extension CGPoint {
  func translatedBy(x: CGFloat, y: CGFloat) -> CGPoint {
    return CGPoint(x: self.x + x, y: self.y + y)
  }
}

extension CGPoint {
  func alignCenterInParent(_ parent: CGSize) -> CGPoint {
    let x = parent.width/2 + self.x
    let y = parent.height/2 + self.y
    return CGPoint(x: x, y: y)
  }
  
  func scaledFrom(_ factor: CGFloat) -> CGPoint {
    return CGPoint(
      x: self.x * factor,
      y: self.y * factor)
  }
}

extension CGSize {
  func scaledDownTo(_ factor: CGFloat) -> CGSize {
    return CGSize(width: width/factor, height: height/factor)
  }
  
  var length: CGFloat {
    return sqrt(pow(width, 2) + pow(height, 2))
  }
  
  var inverted: CGSize {
    return CGSize(width: -width, height: -height)
  }
}
