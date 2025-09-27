//
//  NavigationBar.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 25.09.2025.
//

import SwiftUI

struct NavigationBar: View {
    enum Style {
        case defaultStyle
    }
    
    @Injected private var navigation: Navigation
    
    private let style: Style
    private let title: String?
    private let customAction: VoidCallBack?
    
    var body: some View {
        Group {
            switch style {
            case .defaultStyle:
                defaultStyleView()
            }
        }
    }
    
    private func defaultStyleView() -> some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 20) {
                    Button(action: action) {
                        Image(.left)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(.txt))
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 24, alignment: .topLeading)
                    
                    Text(title ?? "")
                        .font(getFont())
                        .foregroundColor(Color(.txt))
                        .frame(alignment: .center)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
    }

    init(
        title: String? = nil,
        style: Style = .defaultStyle,
        customAction: VoidCallBack? = nil
    ) {
        self.title = title
        self.style = style
        self.customAction = customAction
    }
    
    private func getFont() -> Font {
        return Font.system(size: 30, weight: .bold)
    }
    
    private func action() {
        if let action = customAction {
            action()
        } else {
            navigation.popViewController()
        }
    }
}
