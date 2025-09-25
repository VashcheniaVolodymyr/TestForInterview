//
//  ImageButton.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 25.09.2025.
//

import SwiftUI

struct ImageButtonConfigurable: Hashable, Identifiable {
    let id: String = UUID().uuidString
    let config: ImageButton.Config
    let style: ImageButton.Style
}

struct ImageButton: View {
    struct Config: Hashable, Identifiable {
        let id: String = UUID().uuidString
        
        static func == (lhs: ImageButton.Config, rhs: ImageButton.Config) -> Bool {
           return lhs.image == rhs.image
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(image)
            hasher.combine(text)
        }
        
        let image: String
        let text: String?
        let action: VoidCallBack?
        let isMultiline: Bool
        
        static let empty: Config = .init(
            image: UIImage(resource: .left).description,
            text: "Button",
            action: nil
        )
        
        init(image: String, text: String? = nil, action: VoidCallBack? = nil, isMultiline: Bool = true) {
            self.image = image
            self.text = text
            self.action = action
            self.isMultiline = isMultiline
        }
    }
    
    enum Style: Hashable {
        case `default`
        case custom(color: Color, size: CGFloat? = nil)
    }
    
    private var config: Config = .empty
    private var style: ImageButton.Style = .default
    
    var body: some View {
        if config.action.isNil {
            HStack {
                if config.image.isEmpty.NOT {
                    Image(config.image)
                        .resizable()
                        .frame(width: getSize(), height: getSize())
                        .foregroundColor(getColor())
                }
                
                if !config.text.isNil {
                    Text(config.text ?? "")
                        .foregroundColor(getColor())
                }
            }
            
        } else {
            Button {
                config.action?()
            } label: {
                HStack {
                    if config.image.isEmpty.NOT {
                        Image(config.image)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: getSize(), height: getSize())
                            .foregroundColor(getColor())
                    }
                    
                    if !config.text.isNil {
                        Text(config.text ?? "")
                            .foregroundColor(getColor())
                    }
                }
            }
        }
    }
    
    init(config: Config, style: Style = .default) {
        self.config = config
        self.style = style
    }
    
    func getColor() -> Color {
        switch style {
        case .default:
            return Color(.txt)
        case .custom(color: let color, _):
            return color
        }
    }
    
    func getSize() -> CGFloat {
        switch style {
        case .default:
            return 24
        case .custom(_, size: let size):
            return size ?? 24
        }
    }
}
