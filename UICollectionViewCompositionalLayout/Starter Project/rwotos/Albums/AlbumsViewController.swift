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

class AlbumsViewController: UIViewController {
  static let sectionHeaderElementKind = "section-header-element-kind"

  enum Section: String, CaseIterable {
    case featuredAlbums = "Featured Albums"
    case sharedAlbums = "Shared Albums"
    case myAlbums = "My Albums"
  }

  var dataSource: UICollectionViewDiffableDataSource<Section, AlbumItem>! = nil
  var albumsCollectionView: UICollectionView! = nil

  var baseURL: URL?

  convenience init(withAlbumsFromDirectory directory: URL) {
    self.init()
    baseURL = directory
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Your Albums"
    configureCollectionView()
    configureDataSource()
  }
}

extension AlbumsViewController {
  func configureCollectionView() {
    let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
    view.addSubview(collectionView)
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = .systemBackground
    collectionView.delegate = self
    collectionView.register(AlbumItemCell.self, forCellWithReuseIdentifier: AlbumItemCell.reuseIdentifer)
    albumsCollectionView = collectionView
  }

  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource
      <Section, AlbumItem>(collectionView: albumsCollectionView) {
        (collectionView: UICollectionView, indexPath: IndexPath, albumItem: AlbumItem) -> UICollectionViewCell? in

        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: AlbumItemCell.reuseIdentifer,
          for: indexPath) as? AlbumItemCell else { fatalError("Could not create new cell") }
        cell.featuredPhotoURL = albumItem.imageItems[0].thumbnailURL
        cell.title = albumItem.albumTitle
        return cell
    }

    let snapshot = snapshotForCurrentState()
    dataSource.apply(snapshot, animatingDifferences: false)
  }

  func generateLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
      layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      let isWideView = layoutEnvironment.container.effectiveContentSize.width > 500
      return self.generateMyAlbumsLayout(isWide: isWideView)
    }
    return layout
  }

  func generateMyAlbumsLayout(isWide: Bool) -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

    let groupHeight = NSCollectionLayoutDimension.fractionalWidth(isWide ? 0.25 : 0.5)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: groupHeight)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: isWide ? 4 : 2)

    let section = NSCollectionLayoutSection(group: group)

    return section
  }

  func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, AlbumItem> {
    let allAlbums = albumsInBaseDirectory()
    let sharingSuggestions = Array(albumsInBaseDirectory().prefix(3))
    let sharedAlbums = Array(albumsInBaseDirectory().suffix(3))

    var snapshot = NSDiffableDataSourceSnapshot<Section, AlbumItem>()
    snapshot.appendSections([Section.featuredAlbums])
    snapshot.appendItems(sharingSuggestions)

    snapshot.appendSections([Section.sharedAlbums])
    snapshot.appendItems(sharedAlbums)

    snapshot.appendSections([Section.myAlbums])
    snapshot.appendItems(allAlbums)
    return snapshot
  }

  func albumsInBaseDirectory() -> [AlbumItem] {
    guard let baseURL = baseURL else { return [] }

    let fileManager = FileManager.default
    do {
      return try fileManager.albumsAtURL(baseURL)
    } catch {
      print(error)
      return []
    }
  }
}

extension AlbumsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
    let albumDetailVC = AlbumDetailViewController(withPhotosFromDirectory: item.albumURL)
    navigationController?.pushViewController(albumDetailVC, animated: true)
  }
}
