//
//  CombineCollectionViewDataSource.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 28.09.2025.
//

import UIKit

final class CombineCollectionViewDataSource<Element: Hashable>:
    NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: Types
    typealias CellBuilder = (UICollectionView, IndexPath, Element) -> UICollectionViewCell
    typealias FooterBuilder = (UICollectionView, IndexPath) -> UICollectionReusableView
    typealias ActionBuilder = Callback<Element>

    // MARK: Input
    private let build: CellBuilder
    private let action: ActionBuilder
    private var buildFooter: FooterBuilder?
    private var items: [Element] = []

    // MARK: Init
    init(builder: @escaping CellBuilder, action: @escaping ActionBuilder) {
        self.build = builder
        self.action = action
        super.init()
    }

    // MARK: Public API
    func setFooterBuilder(_ builder: @escaping FooterBuilder) {
        self.buildFooter = builder
    }
    
    func pushItems(_ items: [Element], to collectionView: UICollectionView) {
        collectionView.dataSource = self
        collectionView.delegate = self
        self.items = items
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return items.isEmpty ? 1 : items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if items.isEmpty {
            let cell: EmptyCollectionViewCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptyCollectionViewCell.identifier,
                for: indexPath
            ) as! EmptyCollectionViewCell
            return cell
        }

        return build(collectionView, indexPath, items[indexPath.item])
    }
    
    // MARK: Footer (supplementary)
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let buildFooter = buildFooter else {
            return collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: UICollectionReusableView.identifier,
                for: indexPath
            )
        }
        return buildFooter(collectionView, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let element: Element = self.items.safelyAccessElement(at: indexPath.row) else {
            return
        }
        action(element)
    }
}

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

    func dequeueCell<T: UICollectionViewCell>(with _: UICollectionViewCell.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
}
