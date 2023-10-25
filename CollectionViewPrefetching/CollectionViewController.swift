/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The main view controller.
*/

import UIKit

final class CollectionViewController: UICollectionViewController {
    // MARK: Properties

    private let animationDuration: Double = 1.0
    private let delayBase: Double = 1.0

    private let dataSource = CustomDataSource()

    // MARK: UIViewController overrides

    /// - Tag: SetDataSources
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the collection view's data source.
        collectionView.dataSource = dataSource

        // Set the collection view's prefetching data source.
        collectionView.prefetchDataSource = dataSource
        collectionView.isPrefetchingEnabled = true

        // Add a border to the collection view's layer so its edges are visible.
        collectionView.layer.borderColor = UIColor.systemYellow.cgColor

        collectionView.collectionViewLayout = createPerSectionLayout()

//        HeroCell.registerReusableCell(in: collectionView)
    }
}

extension CollectionViewController {

    func layoutCinemaRatio(contentWidth: CGFloat) -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.top = 8
        item.contentInsets.bottom = 8
        item.contentInsets.leading = 8
        item.contentInsets.trailing = 8
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(contentWidth), heightDimension: .absolute((contentWidth * 9.0) / 16.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .groupPagingCentered

        section.visibleItemsInvalidationHandler = self.handleVisibleItemsInvalidation

        return section

    }

    func createLayoutForHeroSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let contentWidth = layoutEnvironment.container.contentSize.width - (layoutEnvironment.container.contentInsets.leading + layoutEnvironment.container.contentInsets.trailing)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.top = 8
        item.contentInsets.bottom = 8
        item.contentInsets.leading = 8
        item.contentInsets.trailing = 8
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(contentWidth), heightDimension: .absolute(contentWidth / 2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .groupPagingCentered

        section.visibleItemsInvalidationHandler = self.handleVisibleItemsInvalidation

        return section
    }

    func createLayoutForNormalSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let contentWidth = layoutEnvironment.container.contentSize.width - (layoutEnvironment.container.contentInsets.leading + layoutEnvironment.container.contentInsets.trailing)
        let section = layoutCinemaRatio(contentWidth: contentWidth / 3)

        section.orthogonalScrollingBehavior = .groupPaging

        return section
    }

    func createLayoutForLargeSection(_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let contentWidth = layoutEnvironment.container.contentSize.width - (layoutEnvironment.container.contentInsets.leading + layoutEnvironment.container.contentInsets.trailing)
        let section = layoutCinemaRatio(contentWidth: contentWidth / 5)

        section.orthogonalScrollingBehavior = .groupPaging

        return section
    }

    func createPerSectionLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
                                                            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            if 0 == sectionIndex {
                return self.createLayoutForHeroSection(layoutEnvironment)
            } else if 1 == sectionIndex % 2 {
                return self.createLayoutForLargeSection(layoutEnvironment)
            } else {
                return self.createLayoutForNormalSection(layoutEnvironment)
            }
        }

        return layout
    }

    // perform animations on the visible items
    func handleVisibleItemsInvalidation (
        visibleItems: [NSCollectionLayoutVisibleItem],
        scrollOffset: CGPoint,
        layoutEnvironment: NSCollectionLayoutEnvironment) -> Void {

            print("visible:\(visibleItems.count) offset:\(scrollOffset)")
    }
}
