//
//  Configurable.swift
//  CollectionViewPrefetching
//
//  Created by Robert Wakefield on 10/16/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit

protocol Configurable {

    var totalTiles: UILabel? { get set }

    var representedIdentifier: CarouselTileId? { get set }

    func configure(for indexPath: IndexPath, with data: DisplayData?)
}
