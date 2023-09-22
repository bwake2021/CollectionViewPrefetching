/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The main view controller.
*/

import UIKit

final class ViewController: UIViewController {
    // MARK: Properties

    @IBOutlet var collectionView: UICollectionView!
    
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
        collectionView.layer.borderColor = UIColor.black.cgColor

        collectionView.collectionViewLayout = createPerSectionLayout()
    }
}

extension ViewController {

    func createLayoutForHeroSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets.bottom = 8
        item.contentInsets.leading = 8
        item.contentInsets.trailing = 8
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(520))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .groupPagingCentered

        return section
    }

    func createLayoutForNormalSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1.0)))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.42), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets.trailing = 8

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.bottom = 8
        section.contentInsets.leading = 8

        section.orthogonalScrollingBehavior = .groupPaging

        return section
    }

    func createLayoutForPosterSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1.0)))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .absolute(180))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets.trailing = 8

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.bottom = 8
        section.contentInsets.leading = 8

        section.orthogonalScrollingBehavior = .groupPaging

        return section
    }

    func createPerSectionLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
                                                            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            if 0 == sectionIndex {
                return self.createLayoutForHeroSection()
            } else if 1 == sectionIndex % 2 {
                return self.createLayoutForPosterSection()
            } else {
                return self.createLayoutForNormalSection()
            }
        }

        return layout
    }
}
