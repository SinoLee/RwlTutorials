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

import Foundation
import LinkPresentation

struct MetadataCache {
  static func cache(metadata: LPLinkMetadata) {
    // 1. Check if the metadata already exists for this URL
    do {
      guard retrieve(urlString: metadata.url!.absoluteString) == nil else {
        return
      }
      
      // 2. Transform the metadata to a Data object and set requiringSecureCoding to true
      let data = try NSKeyedArchiver.archivedData(withRootObject: metadata, requiringSecureCoding: true)
      
      // 3. Save to user defaults
      UserDefaults.standard.setValue(data, forKey: metadata.url!.absoluteString)
    }
    catch let error {
      print("Error when caching: \(error.localizedDescription)")
    }
  }

  static func retrieve(urlString: String) -> LPLinkMetadata? {
    do {
      // 1. Check if data exists for a particular url string
      guard
        let data = UserDefaults.standard.object(forKey: urlString) as? Data,
        // 2. Ensure that if can be transformed to an LPLinkMetadata object
        let metadata = try NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: data)
        else { return nil }
      return metadata
    }
    catch let error {
      print("Error when caching: \(error.localizedDescription)")
      return nil
    }
  }
  
  // 1
  static var savedURLs: [String] {
    UserDefaults.standard.object(forKey: "SavedURLs") as? [String] ?? []
  }

  // 2
  static func addToSaved(metadata: LPLinkMetadata) {
    guard var links = UserDefaults.standard.object(forKey: "SavedURLs") as? [String] else {
      UserDefaults.standard.set([metadata.url!.absoluteString], forKey: "SavedURLs")
      return
    }
    
    guard !links.contains(metadata.url!.absoluteString) else { return }
    
    links.append(metadata.url!.absoluteString)
    UserDefaults.standard.set(links, forKey: "SavedURLs")
  }
}
