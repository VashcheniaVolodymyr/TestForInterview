//
//  AppButton.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 25.09.2025.
//
import SwiftUI

struct AppButton: View {
    struct Config: Hashable, Identifiable {
        let id: String
        let title: String
        let action: VoidCallBack?
        let style: Style
        let size: Size
        
        init(
            id: String = UUID().uuidString,
            title: String,
            style: Style = .primary,
            size: Size = .SizeM,
            action: VoidCallBack? = nil
        ) {
            self.id = id
            self.title = title
            self.action = action
            self.style = style
            self.size = size
        }
      
        static let empty: Config = .init(title: "", action: nil)
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(action.notNil)
            hasher.combine(style)
            hasher.combine(id)
            hasher.combine(size)
        }
        
        static func == (lhs: Config, rhs: Config) -> Bool {
            return lhs.title == rhs.title
            && lhs.action.notNil == rhs.action.notNil
            && lhs.style == rhs.style
            && lhs.id == rhs.id
        }
    }
    
    enum Style: Hashable {
        case primary
        case secondary
    }
    
    enum Size: CGFloat {
        case SizeM = 47
        
        var font: Font {
            switch self {
            case .SizeM:
                return .system(size: 16, weight: .semibold)
            }
        }
    }
    
    let config: Config
    
    init(
        id: String = UUID().uuidString,
        title: String,
        style: Style = .primary,
        size: Size = .SizeM,
        action: VoidCallBack? = nil
    ) {
        self.config = .init(
            id: id,
            title: title,
            style: style,
            size: size,
            action: action
        )
    }
    
    init(config: Config) {
        self.config = config
    }
    
    var body: some View {
        VStack {
            switch config.style {
            case .primary: primaryButton
            case .secondary: secondaryButton
            }
        }
        .animation(.easeInOut(duration: 0.3), value: config.style)
    }
    
    private var primaryButton: some View {
        Button {
            action()
        } label: {
            HStack {
                HStack(alignment: .center) {
                    textComponent
                }
                .padding(.horizontal, 20)
            }
            .frame(
                minWidth: 52,
                maxWidth: .infinity,
                minHeight: config.size.rawValue,
                maxHeight: config.size.rawValue
            )
            .background(getBackgroundColor())
            .cornerRadius(getCornerRadius())
        }
    }
    
    private var secondaryButton: some View {
        Button {
            action()
        } label: {
            HStack {
                VStack {
                    HStack(alignment: .center) {
                        textComponent
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(
                minWidth: 52,
                maxWidth: .infinity,
                minHeight: config.size.rawValue,
                maxHeight: config.size.rawValue
            )
            .background(getBackgroundColor())
            .cornerRadius(getCornerRadius())
            .overlay(
                RoundedRectangle(cornerRadius: getCornerRadius())
                    .stroke(
                        config.action.isNil
                        ? Color(.btnBg2).opacity(0.5)
                        : Color(.btnBg2),
                        lineWidth: 1
                    )
            )
        }
    }
    
    private var textComponent: some View {
        Text(config.title)
            .foregroundColor(foregroundColor())
            .frame(height: 24)
            .font(config.size.font)
            .minimumScaleFactor(0.5)
    }
    
    private func action() {
        guard let action = config.action else { return }
        action()
    }
    
    private func foregroundColor() -> Color {
        switch config.style {
        case .primary:
            return config.action.isNil
            ? Color(.btnTxt1).opacity(0.5)
            : Color(.btnTxt1)
        case .secondary:
            return config.action.isNil
            ? Color(.btnTxt2).opacity(0.5)
            : Color(.btnTxt2)
        }
    }
    
    private func strokeColor() -> Color {
        switch config.style {
        case .primary:
            return .clear
        case .secondary:
            return config.action.isNil
            ? Color(.btnTxt2).opacity(0.5)
            : Color(.btnTxt2)
        }
    }
    
    private func getBackgroundColor() -> Color {
        switch config.style {
        case .primary:
            return config.action.isNil
            ? Color(.btnBg1).opacity(0.5)
            : Color(.btnBg1)
        default:
            return .clear
        }
    }
    
    private func getCornerRadius() -> CGFloat {
       return 99
    }
}
