//
//  PagerListView.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 29.09.2025.
//

import SwiftUI

struct PagerListView: View {
    var totalPages: Int
    @State var current: Int

    var itemSelected: (Int) -> Void
    private let windowSize = 3

    var body: some View {
        HStack(spacing: 8) {
            if totalPages == 0 {
                EmptyView()
            } else if totalPages <= 5 {
                ForEach(1...totalPages, id: \.self) { pageChip($0) }
            } else {
                // первая
                pageChip(1)

                let mid = middleWindow()

                if mid.start > 2 {
                    dots
                }

                ForEach(mid.start...mid.end, id: \.self) { pageChip($0) }

                if mid.end < totalPages - 1 {
                    dots
                }

                // последняя
                pageChip(totalPages)
            }
        }
    }

    private func middleWindow() -> (start: Int, end: Int) {
        let n = totalPages
        let leftBound = 2
        let rightBound = max(2, n - 1)

        let curIdx = current
        if rightBound < leftBound { return (leftBound, leftBound) }

        let half = windowSize / 2
        var start = max(leftBound, curIdx - half)
        let maxStart = max(leftBound, rightBound - (windowSize - 1))
        start = min(start, maxStart)
        let end = min(start + windowSize - 1, rightBound)

        return (start, end)
    }

    private var dots: some View {
        Text("…")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(Color(.secondaryLabel))
            .padding(.horizontal, 4)
            .frame(height: 48, alignment: .bottom)
    }

    @ViewBuilder
    private func pageChip(_ page: Int) -> some View {
        Button {
            current = page
            itemSelected(page)
        } label: {
            Text("\(page)")
                .font(.system(size: 16, weight: .semibold))
                .padding(.all, 8)
                .frame(minWidth: 48)
                .background(
                   Circle()
                        .fill(page == current ? Color(.btnBg1) : Color(.clear))
                )
                .overlay(
                    Circle()
                        .stroke(page == current ? Color.clear : Color(.btnBg2), lineWidth: 1)
                )
                .foregroundColor(Color(.btnTxt1))
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}

final class PagerFooterView: UICollectionViewCell {
    static let reuseIdentifier = "PagerFooterView"

    private var host: UIHostingController<AnyView>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func set<Content: View>(rootView: Content, parent: UIViewController) {
        if let host = host {
            host.rootView = AnyView(rootView)
            host.view.invalidateIntrinsicContentSize()
            return
        }
        let hosting = UIHostingController(rootView: AnyView(rootView))
        hosting.view.backgroundColor = .clear

        parent.addChild(hosting)
        addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        hosting.didMove(toParent: parent)
        self.host = hosting
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
