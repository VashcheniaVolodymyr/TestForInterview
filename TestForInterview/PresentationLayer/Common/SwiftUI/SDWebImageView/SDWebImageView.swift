//
//  SDWebImageView.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 01.10.2025.
//

import SwiftUI
import SDWebImage

public struct SDWebImageView: UIViewRepresentable {
    public enum ContentMode { case fill, fit, center }

    let url: URL?
    let placeholder: UIImage?
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    let options: SDWebImageOptions
    let context: [SDWebImageContextOption : Any]?
    let showsActivity: Bool
    let transition: SDWebImageTransition?

    public init(
        url: URL?,
        placeholder: UIImage? = nil,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = 0,
        options: SDWebImageOptions = [.scaleDownLargeImages, .continueInBackground, .retryFailed],
        context: [SDWebImageContextOption : Any]? = nil,
        showsActivity: Bool = true,
        transition: SDWebImageTransition? = .fade
    ) {
        self.url = url
        self.placeholder = placeholder
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.options = options
        self.context = context
        self.showsActivity = showsActivity
        self.transition = transition
    }

    public func makeUIView(context ctx: Context) -> SDAnimatedImageView {
        let iv = SDAnimatedImageView()
        iv.clipsToBounds = true
        iv.sd_imageIndicator = showsActivity ? SDWebImageActivityIndicator.medium : nil
        iv.sd_imageTransition = transition
        applyContentMode(iv)
        if cornerRadius > 0 {
            iv.layer.cornerRadius = cornerRadius
            iv.layer.masksToBounds = true
        }
        return iv
    }

    public func updateUIView(_ uiView: SDAnimatedImageView, context ctx: Context) {
        applyContentMode(uiView)
        
        uiView.sd_cancelCurrentImageLoad()
        uiView.layer.cornerRadius = cornerRadius
        uiView.layer.masksToBounds = cornerRadius > 0
        
        if let url = url {
            uiView.sd_setImage(
                with: url,
                placeholderImage: placeholder,
                options: options,
                context: context,
                progress: nil
            ) { _, _, _, _ in }
        } else {
            uiView.image = placeholder
        }
    }

    public static func dismantleUIView(_ uiView: SDAnimatedImageView, coordinator: ()) {
        uiView.sd_cancelCurrentImageLoad()
    }

    private func applyContentMode(_ iv: SDAnimatedImageView) {
        switch contentMode {
        case .fill:   iv.contentMode = .scaleAspectFill
        case .fit:    iv.contentMode = .scaleAspectFit
        case .center: iv.contentMode = .center
        }
    }
}
