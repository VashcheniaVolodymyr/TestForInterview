//
//  NavigationBarModifier.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 25.09.2025.
//

import SwiftUI

struct NavigationBarModifier: ViewModifier {
    let title: String?
    let customAction: VoidCallBack?
    let style: NavigationBar.Style
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                NavigationBar(
                    title: title,
                    style: style,
                    customAction: customAction
                )
                .padding(.horizontal, 24)
                content
            }
            .navigationBarHidden(true)
        }
    }
    
    init(
        title: String? = nil,
        action: VoidCallBack? = nil,
        style: NavigationBar.Style = .defaultStyle
    ) {
        self.title = title
        self.customAction = action
        self.style = style
    }
}
