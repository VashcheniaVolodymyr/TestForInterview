//
//  SearchBarView.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 26.09.2025.
//

import SwiftUI

struct SearchBarView: View {
    // MARK: Private
    @State private var isEditing = false
    
    // MARK: Public
    @Binding var text: String
    public var placeholder: String = NSLocalizedString("search", comment: "")
    public var onSubmit: VoidCallBack?
    
    // MARK: Init
    public init(
        text: Binding<String>,
        placeholder: String = "Search",
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                Image(.search)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(.txt))
                
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.secondary)
                            .opacity(0.8)
                    }
                    TextField("", text: $text)
                        .font(.system(size: 18, weight: .medium))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .padding(.all, 16)
        }
        .background(Color(.search))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    SearchBarView(text: .constant(""))
}
