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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class SpinViewController: UIViewController {
  private var links: [String] = [
    "https://www.raywenderlich.com/5429927-beginning-collection-views",
    "https://www.raywenderlich.com/6849561-layout-in-ios",
    "https://www.raywenderlich.com/5429279-programming-in-swift-functions-and-types",
    "https://www.raywenderlich.com/6484760-create-a-splash-screen-with-swiftui",
    "https://www.raywenderlich.com/6275408-create-a-drawing-app-with-pencilkit",
    "https://www.raywenderlich.com/6177504-continuous-integration",
    "https://www.raywenderlich.com/5429927-beginning-collection-views",
    "https://www.raywenderlich.com/6849561-layout-in-ios",
    "https://www.raywenderlich.com/5429279-programming-in-swift-functions-and-types",
    "https://www.raywenderlich.com/6484760-create-a-splash-screen-with-swiftui",
    "https://www.raywenderlich.com/6275408-create-a-drawing-app-with-pencilkit",
    "https://www.raywenderlich.com/6177504-continuous-integration",
    "https://www.raywenderlich.com/3161-web-design-drinking-from-a-firehose",
    "https://www.raywenderlich.com/3153-table-view-helper-class-for-ios",
    "https://www.raywenderlich.com/3152-auto-complete-tutorial-for-ios-how-to-auto-complete-with-custom-values",
  ]
  
  private let activityIndicator = UIActivityIndicatorView()
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var actionsStackView: UIStackView!
  @IBOutlet weak var spinButton: UIButton!
  @IBOutlet weak var errorLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    actionsStackView.isHidden = true
    errorLabel.isHidden = true
    stackView.insertArrangedSubview(activityIndicator, at: 0)
  }
  
  @IBAction func spin(_ sender: Any) {
  }
  
  private func cancel() {
  }
  
  private func resetViews() {
  }
  
  @IBAction func share(_ sender: Any) {
  }
  
  @IBAction func save(_ sender: Any) {
  }
}
