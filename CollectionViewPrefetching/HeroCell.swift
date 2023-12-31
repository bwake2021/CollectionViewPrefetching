/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The `UICollectionViewCell` used to represent data in the collection view.
*/

import UIKit

final class HeroCell: UICollectionViewCell, Configurable {
    
    static let formatter = ISO8601DateFormatter()
    
    // MARK: Properties

    @IBOutlet weak var section: UILabel?
    @IBOutlet weak var item: UILabel?
    @IBOutlet weak var carouselId: UILabel?
    @IBOutlet weak var tileIndex: UILabel?
    @IBOutlet weak var totalTiles: UILabel?
    @IBOutlet weak var cellWidth: UILabel?
    @IBOutlet weak var cellHeight: UILabel?
    @IBOutlet weak var startTimeStamp: UILabel?
    @IBOutlet weak var endTimeStamp: UILabel?

    /// The `CarouselItemId` for the data this cell presents.
    var representedIdentifier: CarouselTileId?

    // MARK: UICollectionViewCell

    override func awakeFromNib() {
        super.awakeFromNib()

        #if os(tvOS)
        layer.borderWidth = 8.0
        layer.borderColor = UIColor.clear.cgColor
        #endif

        cellWidth?.text = "\(contentView.bounds.width)"
        cellHeight?.text = "\(contentView.bounds.height)"
    }
    
    override func prepareForReuse() {
        
        section?.text = nil
        item?.text = nil
        carouselId?.text = nil
        tileIndex?.text = nil
        startTimeStamp?.text = nil
        endTimeStamp?.text = nil
        representedIdentifier = nil
        backgroundColor = .clear
        layer.borderColor = UIColor.clear.cgColor
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)

        layer.borderColor = self.isFocused ? UIColor.systemYellow.cgColor : UIColor.white.cgColor
    }

    // MARK: Convenience

    /**
     Configures the cell for display based on the model.
     
     - Parameters:
     - data: An optional `DisplayData` object to display.
     
     - Tag: Cell_Config
     */
    func configure(for indexPath: IndexPath, with data: DisplayData?) {
        backgroundColor = data?.color ?? .systemRed
        layer.borderColor = self.isFocused ? UIColor.systemYellow.cgColor : UIColor.white.cgColor

        section?.text = "\(indexPath.section)"
        item?.text = "\(indexPath.item)"

        guard let data else {
            endTimeStamp?.text = "nil Data!"
            return
        }

        carouselId?.text = data.carouselPageID.carouselId
        tileIndex?.text = "\(data.tileIndex)"

        startTimeStamp?.text = Self.formatter.string(from: data.startTimeStamp)
        endTimeStamp?.text = Self.formatter.string(from: data.endTimeStamp)
    }
}

