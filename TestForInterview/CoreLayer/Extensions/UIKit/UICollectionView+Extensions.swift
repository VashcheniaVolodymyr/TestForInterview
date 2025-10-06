//
//  UICollectionView+Extensions.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 06.10.2025.
//

import UIKit

extension UICollectionReusableView {
    static var identifier: String { String(describing: self) }
}

extension UICollectionView {
    func dequeueCell<T: UICollectionViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: type.identifier, for: indexPath) as! T
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String,
                                                                       with type: T.Type,
                                                                       for indexPath: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type.identifier, for: indexPath) as! T
    }
}
