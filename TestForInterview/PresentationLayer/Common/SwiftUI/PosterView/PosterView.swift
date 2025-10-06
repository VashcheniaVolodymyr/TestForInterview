//
//  PosterView.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 01.10.2025.
//
import SwiftUI
import SDWebImage

struct PosterViewSwiftUI: View {
    let movie: MovieItem
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                SDWebImageView(
                    url: movie.item.posterURL(),
                    placeholder: nil,
                    contentMode: .center,
                    cornerRadius: 14,
                    context: imageContext,
                    showsActivity: true,
                    transition: .fade
                )
                .frame(width: 163, height: 233)
                
                Image(.star)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(movie.isFavorite ? Color(.favorite) : Color(.star))
                    .frame(width: 20, height: 19.7)
                    .padding(.top, 10)
                    .padding(.trailing, 10)
            }
            
            VStack(spacing: 0) {
                Text(movie.item.title)
                    .foregroundColor(Color(.txt))
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(movie.item.ratingLocalized())
                    .foregroundColor(Color(.txt))
                    .font(.system(size: 10, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var imageContext: [SDWebImageContextOption : Any] {
        let imageResizingTransformer = SDImageResizingTransformer(
            size: CGSize(width: 163, height: 233),
            scaleMode: .aspectFill
        )
        let round = SDImageRoundCornerTransformer(radius: 12,
                                                   corners: .allCorners,
                                                   borderWidth: 0,
                                                   borderColor: nil)
        
        let tint = SDImageTintTransformer(color: .clear)

        let pipeline = SDImagePipelineTransformer(transformers: [imageResizingTransformer, round, tint])
      
        return [.imageTransformer : pipeline]
    }
}

final class PosterHostingCell: UICollectionViewCell {
    private var host: UIHostingController<PosterViewSwiftUI>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        host?.view.removeFromSuperview()
        host?.removeFromParent()
        host = nil
    }
    
    func configure(in parent: UIViewController, movie: MovieItem) {
        if let host = host {
            host.rootView = PosterViewSwiftUI(movie: movie)
        } else {
            let h = UIHostingController(rootView: PosterViewSwiftUI(movie: movie))
            h.view.backgroundColor = .clear
            parent.addChild(h)
            contentView.addSubview(h.view)
            h.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                h.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                h.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                h.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                h.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            h.didMove(toParent: parent)
            host = h
        }
    }
}
