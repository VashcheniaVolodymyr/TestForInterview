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
            return collectionView.dequeueCell(with: EmptyCollectionViewCell.self, for: indexPath)
        }

        return build(collectionView, indexPath, items[indexPath.item])
    }
    
    // MARK: Footer (supplementary)
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let buildFooter = buildFooter else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, with: UICollectionReusableView.self, for: indexPath)
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
