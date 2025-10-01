//
//  CollectionView.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 26.09.2025.
//

import SwiftUI
import UIKit

// Reusable SwiftUI wrapper for UICollectionView (iOS 13+)
public struct CollectionView<Item: Identifiable & Hashable, Cell: View>: UIViewRepresentable {
    public typealias SectionID = Int

    private let data: [Item]
    private let layout: UICollectionViewLayout
    private let allowsSelection: Bool
    private let isScrollEnabled: Bool
    private let prefetchThreshold: Int
    private let onReachedEnd: (() -> Void)?
    private let didSelect: ((Item) -> Void)?
    private let cell: (Item) -> Cell

    public init(
        _ data: [Item],
        layout: UICollectionViewLayout,
        allowsSelection: Bool = true,
        isScrollEnabled: Bool = true,
        prefetchThreshold: Int = 5,
        onReachedEnd: (() -> Void)? = nil,
        didSelect: ((Item) -> Void)? = nil,
        @ViewBuilder cell: @escaping (Item) -> Cell
    ) {
        self.data = data
        self.layout = layout
        self.allowsSelection = allowsSelection
        self.isScrollEnabled = isScrollEnabled
        self.prefetchThreshold = max(0, prefetchThreshold)
        self.onReachedEnd = onReachedEnd
        self.didSelect = didSelect
        self.cell = cell
    }

    public func makeCoordinator() -> Coordinator { Coordinator(self) }

    public func makeUIView(context: Context) -> UICollectionView {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.allowsSelection = allowsSelection
        collection.isScrollEnabled = isScrollEnabled
        collection.delegate = context.coordinator
        collection.register(HostingCollectionViewCell.self,
                            forCellWithReuseIdentifier: HostingCollectionViewCell.reuseID)
        collection.contentInset = .zero
        context.coordinator.configureDataSource(for: collection)
        
        return collection
    }

    public func updateUIView(_ uiView: UICollectionView, context: Context) {
        context.coordinator.parent = self
        uiView.setCollectionViewLayout(layout, animated: false)
        uiView.isScrollEnabled = isScrollEnabled
        context.coordinator.apply(items: data)
    }

    public final class Coordinator: NSObject, UICollectionViewDelegate {
        var parent: CollectionView
        var dataSource: UICollectionViewDiffableDataSource<SectionID, Item>!

        init(_ parent: CollectionView) { self.parent = parent }

        func configureDataSource(for collectionView: UICollectionView) {
            dataSource = .init(collectionView: collectionView) { [weak self] cv, indexPath, item in
                let cell = cv.dequeueReusableCell(withReuseIdentifier: HostingCollectionViewCell.reuseID,
                                                  for: indexPath) as! HostingCollectionViewCell
                guard let strong = self else { return cell }
                cell.set(strong.parent.cell(item))
                return cell
            }
        }

        func apply(items: [Item], animatingDifferences: Bool = true) {
            var snapshot = NSDiffableDataSourceSnapshot<SectionID, Item>()
            snapshot.appendSections([0])
            snapshot.appendItems(items, toSection: 0)
            dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        }

        public func collectionView(_ collectionView: UICollectionView,
                                   willDisplay cell: UICollectionViewCell,
                                   forItemAt indexPath: IndexPath) {
            guard let count = dataSource?.snapshot().numberOfItems, count > 0 else { return }
            let thresholdIndex = max(0, count - 1 - parent.prefetchThreshold)
            if indexPath.item >= thresholdIndex {
                parent.onReachedEnd?()
            }
        }

        public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            parent.didSelect?(item)
        }
        
        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

// MARK: - Internal hosting cell that embeds SwiftUI
final class HostingCollectionViewCell: UICollectionViewCell {
    static let reuseID = "HostingCollectionViewCell"
    private var host: UIHostingController<AnyView>?

    override func prepareForReuse() {
        super.prepareForReuse()
        host?.view.removeFromSuperview()
        host = nil
    }

    func set<Content: View>(_ view: Content) {
        let controller = UIHostingController(rootView: AnyView(view))
        controller.view.backgroundColor = .clear
        host = controller

        contentView.subviews.forEach { $0.removeFromSuperview() }
        let v = controller.view!
        v.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(v)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            v.topAnchor.constraint(equalTo: contentView.topAnchor),
            v.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

