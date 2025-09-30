//
//  DotsLoaderSU.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 28.09.2025.
//

import SwiftUI

struct DotsLoader: UIViewRepresentable, Equatable {
    struct Config: Equatable {
        var dotColor: UIColor
        var dotCount: Int
        var radius: CGFloat
        var dotSize: CGFloat
        var duration: CFTimeInterval
        var minScale: CGFloat
        var maxScale: CGFloat
    }

    var config: Config

    init(dotColor: UIColor =  UIColor(resource: .txt),
         dotCount: Int = 8,
         radius: CGFloat = 18,
         dotSize: CGFloat = 10,
         duration: CFTimeInterval = 0.75,
         minScale: CGFloat = 0.35,
         maxScale: CGFloat = 1) {
        self.config = .init(dotColor: dotColor,
                            dotCount: dotCount,
                            radius: radius,
                            dotSize: dotSize,
                            duration: duration,
                            minScale: minScale,
                            maxScale: maxScale)
    }

    static func ==(lhs: DotsLoader, rhs: DotsLoader) -> Bool {
        lhs.config == rhs.config
    }

    func makeUIView(context: Context) -> DotsLoaderView {
        let v = DotsLoaderView()
        apply(config: config, to: v, onlyIfChanged: false)
        return v
    }

    func updateUIView(_ uiView: DotsLoaderView, context: Context) {
        apply(config: config, to: uiView, onlyIfChanged: true)
    }

    private func apply(config: Config, to v: DotsLoaderView, onlyIfChanged: Bool) {
        func set<T: Equatable>(_ keyPath: ReferenceWritableKeyPath<DotsLoaderView, T>, _ value: T) {
            if !onlyIfChanged || v[keyPath: keyPath] != value {
                v[keyPath: keyPath] = value
            }
        }
        set(\.dotColor, config.dotColor)
        set(\.dotCount, config.dotCount)
        set(\.radius, config.radius)
        set(\.dotSize, config.dotSize)
        set(\.duration, config.duration)
        set(\.minScale, config.minScale)
        set(\.maxScale, config.maxScale)
    }
}

struct LoaderView: View {
    var body: some View {
        DotsLoader()
            .equatable()
    }
}
