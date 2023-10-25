//
//  UICollectionViewCell+reuseIdentifier.swift
//  CollectionViewPrefetching
//
//  Created by Robert Wakefield on 10/16/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit

extension UICollectionViewCell {

    static var reuseIdentifier: String { "\(Self.self)" }

    static func dequeueReusableCell(from collectionView: UICollectionView, for indexPath: IndexPath) -> Self {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.reuseIdentifier, for: indexPath) as? Self
        else {
            fatalError("Expected `\(Self.self)` type for reuseIdentifier \(Self.reuseIdentifier). Check the configuration in Main.storyboard.")
        }

        return cell
    }

    static func registerReusableCell(in collectionView: UICollectionView) {
        collectionView.register(Self.self, forCellWithReuseIdentifier: Self.reuseIdentifier)
    }
}
