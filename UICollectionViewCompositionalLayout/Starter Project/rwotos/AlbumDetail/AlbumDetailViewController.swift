/// Copyright (c) 2019 Razeware LLC
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

import UIKit

class AlbumDetailViewController: UIViewController {
  static let syncingBadgeKind = "syncing-badge-kind"

  enum Section {
    case albumBody
  }

  var dataSource: UICollectionViewDiffableDataSource<Section, AlbumDetailItem>! = nil
  var albumDetailCollectionView: UICollectionView! = nil

  var albumURL: URL?

  convenience init(withPhotosFromDirectory directory: URL) {
    self.init()
    albumURL = directory
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = albumURL?.lastPathComponent.displayNicely
    configureCollectionView()
    configureDataSource()
  }
}

extension AlbumDetailViewController {
  func configureCollectionView() {
    let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
    view.addSubview(collectionView)
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = .systemBackground
    collectionView.delegate = self
    collectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: PhotoItemCell.reuseIdentifer)
    albumDetailCollectionView = collectionView
  }

  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource
      <Section, AlbumDetailItem>(collectionView: albumDetailCollectionView) {
        (collectionView: UICollectionView, indexPath: IndexPath, detailItem: AlbumDetailItem) -> UICollectionViewCell? in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: PhotoItemCell.reuseIdentifer,
          for: indexPath) as? PhotoItemCell else { fatalError("Could not create new cell") }
        cell.photoURL = detailItem.thumbnailURL
        return cell
    }

    let snapshot = snapshotForCurrentState()
    dataSource.apply(snapshot, animatingDifferences: false)
  }

  func generateLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0))
    let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalWidth(2/3))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: fullPhotoItem, count: 1)

    let section = NSCollectionLayoutSection(group: group)

    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
  }

  func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, AlbumDetailItem> {
    var snapshot = NSDiffableDataSourceSnapshot<Section, AlbumDetailItem>()
    snapshot.appendSections([Section.albumBody])
    let items = itemsForAlbum()
    snapshot.appendItems(items)
    return snapshot
  }

  func itemsForAlbum() -> [AlbumDetailItem] {
    guard let albumURL = albumURL else { return [] }
    let fileManager = FileManager.default
    do {
      return try fileManager.albumDetailItemsAtURL(albumURL)
    } catch {
      print(error)
      return []
    }
  }
}

extension AlbumDetailViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
    let photoDetailVC = PhotoDetailViewController(photoURL: item.photoURL)
    navigationController?.pushViewController(photoDetailVC, animated: true)
  }
}
