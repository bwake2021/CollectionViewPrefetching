/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that implements both `UICollectionViewDataSource` and `UICollectionViewDataSourcePrefetching`.
*/

import UIKit

/// - Tag: CustomDataSource
class CustomDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    // MARK: Properties

    struct Model {
        var identifier = UUID()
        
        // Add additional properties for your own model here.
    }

    /// Example data identifiers.
    private let models = (1...1000).map { _ in
        return Model()
    }

    /// An `AsyncFetcher` that is used to asynchronously fetch `DisplayData` objects.
    private let asyncFetcher = AsyncFetcher()

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 32
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        models.count
    }

    /// - Tag: CellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var cell: UICollectionViewCell & Configurable
        if indexPath.section == 0 {

            cell = HeroCell.dequeueReusableCell(from: collectionView, for: indexPath)

        } else {
            
            cell = Cell.dequeueReusableCell(from: collectionView, for: indexPath)
        }

        cell.alpha = 1.0
        cell.totalTiles?.text = "\(collectionView.numberOfItems(inSection: indexPath.section))"
        let model = models[indexPath.section]
        let identifier = model.identifier.uuidString
        let carouselTileId = CarouselTileId(tileIndex: indexPath.item, carouselId: identifier)
        cell.representedIdentifier = carouselTileId

        asyncFetcher.fetch(carouselTileId) { fetchedData in
            DispatchQueue.main.async {
                /*
                 The `asyncFetcher` has fetched data for the identifier. Before
                 updating the cell, check whether the collection view has recycled it to represent other data.
                 */
                guard cell.representedIdentifier == carouselTileId else { return }

                // Configure the cell with the fetched image.
                cell.configure(for: indexPath, with: fetchedData)
            }
        }

        return cell
    }

    // MARK: UICollectionViewDataSourcePrefetching

    /// - Tag: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        for indexPath in indexPaths {
            let model = models[indexPath.item]
            asyncFetcher.fetch(CarouselTileId(indexPath: indexPath, carouselId: model.identifier.uuidString))
        }
    }

    /// - Tag: CancelPrefetching
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // Cancel any in-flight requests for data for the specified index paths.
        for indexPath in indexPaths {
            let model = models[indexPath.item]
            asyncFetcher.cancelFetch(model.identifier.uuidString, indexPath.item)
        }
    }
}
