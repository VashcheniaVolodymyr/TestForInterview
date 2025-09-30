//
//  EmptyCollectionViewCell.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 30.09.2025.
//

import UIKit

final class EmptyCollectionViewCell: UICollectionViewCell {
    // MARK: Private
    private let imageView = UIImageView()

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.5),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.5)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public
    func configure(image: UIImage?) {
        imageView.image = image
    }
}
