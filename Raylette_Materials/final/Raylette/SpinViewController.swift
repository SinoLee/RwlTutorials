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
import LinkPresentation

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
  private var provider = LPMetadataProvider()
  private var linkView = LPLinkView()
  private var currentMetadata: LPLinkMetadata?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    actionsStackView.isHidden = true
    errorLabel.isHidden = true
    stackView.insertArrangedSubview(activityIndicator, at: 0)
  }
  
  @IBAction func spin(_ sender: Any) {
    errorLabel.isHidden = true
    guard !activityIndicator.isAnimating else {
      cancel()
      return
    }

    spinButton.setTitle("Cancel", for: .normal)
    activityIndicator.startAnimating()
    actionsStackView.isHidden = true
    let random = Int.random(in: 0..<links.count)
    let randomTutorialLink = links[random]

    provider = LPMetadataProvider()
    provider.timeout = 5
    // 1
    linkView.removeFromSuperview()

    guard let url = URL(string: randomTutorialLink) else { return }
    // 2
    linkView = LPLinkView(url: url)
    

    fetchMetadata(for: url)
    // 5
    stackView.insertArrangedSubview(linkView, at: 0)
  }
  
  private func cancel() {
    provider.cancel()
    provider = LPMetadataProvider()
    resetViews()
  }
  
  private func resetViews() {
    activityIndicator.stopAnimating()
    spinButton.setTitle("Spin the Wheel", for: .normal)
    actionsStackView.isHidden = false
  }
  
  private func fetchMetadata(for url: URL) {
    // 1. Check if the metadata exists
    if let existingMetadata = MetadataCache.retrieve(urlString: url.absoluteString) {
      linkView = LPLinkView(metadata: existingMetadata)
      resetViews()
      currentMetadata = existingMetadata
    } else {
      // 2. If it doesn't start the fetch
      provider.startFetchingMetadata(for: url) { [weak self] metadata, error in
        guard let self = self else { return }
        
        guard
          let metadata = metadata,
          error == nil
          else {
            if let error = error as? LPError {
              DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.errorLabel.text = error.prettyString
                self.errorLabel.isHidden = false
                self.resetViews()
              }
            }
            return
        }
        
        // 3. And cache the new metadata once you have it
        self.currentMetadata = metadata
        if let imageProvider = metadata.imageProvider {
          metadata.iconProvider = imageProvider
        }
        MetadataCache.cache(metadata: metadata)
        
        // 4. Use the metadata
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          
          self.linkView.metadata = metadata
          self.resetViews()
        }
      }
    }
  }
  
  @IBAction func share(_ sender: Any) {
    guard currentMetadata != nil else { return }
    
    let activityController = UIActivityViewController(activityItems: [self], applicationActivities: nil)
    present(activityController, animated: true, completion: nil)
  }
  
  @IBAction func save(_ sender: Any) {
    guard let metadata = currentMetadata else { return }
    MetadataCache.addToSaved(metadata: metadata)
    errorLabel.text = "Successfully saved!"
    errorLabel.isHidden = false
  }
}

extension SpinViewController: UIActivityItemSource {
  // 1. Required function returning a placeholder
  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    return "website.com"
  }
  
  // 2. Required function that returns the actual activity item
  func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
    return currentMetadata?.originalURL
  }
  
  // 3. The metadata that the share sheet automatically picks up
  func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
    return currentMetadata
  }
}
