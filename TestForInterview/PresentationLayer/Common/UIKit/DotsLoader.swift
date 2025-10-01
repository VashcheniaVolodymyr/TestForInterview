//
//  DotsLoader.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 28.09.2025.
//
import UIKit

final class DotsLoaderView: UIView {
    // MARK: Public
    var dotColor: UIColor = .label { didSet { dotLayer.backgroundColor = dotColor.cgColor } }
    var dotCount: Int = 12 { didSet { reconfigure(keepPhase: true) } }
    var dotSize: CGFloat = 8 { didSet { layoutDot() } }
    var radius: CGFloat = 18 { didSet { layoutDot() } }
    var duration: CFTimeInterval = 0.9 { didSet { reconfigure(keepPhase: true) } }
    var minScale: CGFloat = 0.35 { didSet { updateScaleAnimation(keepPhase: true) } }
    var maxScale: CGFloat = 1.0 { didSet { updateScaleAnimation(keepPhase: true) } }

    // MARK: Private
    private let replicator = CAReplicatorLayer()
    private let dotLayer = CALayer()
    private let scaleKey = "scalePulse"

    private var animationsInstalled = false
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: Private methods
    private func commonInit() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        let noImplicit: [String: CAAction] = [
            "position": NSNull(), "bounds": NSNull(), "transform": NSNull(),
            "opacity": NSNull(), "sublayers": NSNull(), "onOrderIn": NSNull(), "onOrderOut": NSNull()
        ]
        layer.actions = noImplicit
        replicator.actions = noImplicit
        dotLayer.actions = noImplicit

        layer.addSublayer(replicator)
        replicator.addSublayer(dotLayer)

        if #available(iOS 13.0, *) { dotColor = .label }
        dotLayer.backgroundColor = dotColor.cgColor
        dotLayer.masksToBounds = true
        dotLayer.contentsScale = UIScreen.main.scale
        dotLayer.transform = CATransform3DMakeScale(minScale, minScale, 1)
    }

    // MARK: Layout lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        replicator.frame = bounds
        layoutDot()
        CATransaction.commit()

        if window != nil, !animationsInstalled {
            configureReplicator()
            addScaleAnimation(from: minScale)
            animationsInstalled = true
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            if !animationsInstalled {
                configureReplicator()
                addScaleAnimation(from: minScale)
                animationsInstalled = true
            }
            resumeInternally()
        } else {
            pauseInternally()
        }
    }

    // MARK: Geometry
    private func layoutDot() {
        let s = dotSize
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let startPoint = CGPoint(x: center.x, y: center.y - radius)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        dotLayer.bounds = CGRect(x: 0, y: 0, width: s, height: s)
        dotLayer.position = startPoint
        dotLayer.cornerRadius = s / 2
        CATransaction.commit()
    }

    private func configureReplicator() {
        let count = max(1, dotCount)
        replicator.instanceCount = count

        let angle = (2 * CGFloat.pi) / CGFloat(count)
        replicator.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
        replicator.instanceDelay = duration / CFTimeInterval(count)
    }

    private func reconfigure(keepPhase: Bool) {
        guard animationsInstalled else { return }
        configureReplicator()
        if keepPhase {
            updateScaleAnimation(keepPhase: true)
        } else {
            addScaleAnimation(from: minScale)
        }
    }

    // MARK: Анимация масштаба
    private func addScaleAnimation(from startScale: CGFloat) {
        dotLayer.removeAnimation(forKey: scaleKey)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        dotLayer.transform = CATransform3DMakeScale(startScale, startScale, 1)
        CATransaction.commit()

        let a = CABasicAnimation(keyPath: "transform.scale")
        a.fromValue = startScale
        a.toValue = maxScale
        a.duration = duration
        a.autoreverses = true
        a.repeatCount = .infinity
        a.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        a.isRemovedOnCompletion = true

        dotLayer.add(a, forKey: scaleKey)
    }

    private func updateScaleAnimation(keepPhase: Bool) {
        guard animationsInstalled else { return }
        let currentScale = keepPhase
            ? (dotLayer.presentation()?.value(forKeyPath: "transform.scale") as? CGFloat) ?? minScale
            : minScale
        addScaleAnimation(from: currentScale)
    }

    private func pauseInternally() {
        let t = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0
        layer.timeOffset = t
    }
    
    private func resumeInternally() {
        let paused = layer.timeOffset
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        let delta = layer.convertTime(CACurrentMediaTime(), from: nil) - paused
        layer.beginTime = delta
    }
}


private var loaderKey: UInt8 = 0

extension UIViewController {
    private var dotsLoader: DotsLoaderView? {
        get { objc_getAssociatedObject(self, &loaderKey) as? DotsLoaderView }
        set { objc_setAssociatedObject(self, &loaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func showLoader(
        dotColor: UIColor = UIColor(resource: .txt),
        dotCount: Int = 8,
        radius: CGFloat = 18,
        dotSize: CGFloat = 10,
        duration: CFTimeInterval = 0.75
    ) {
        if let loader = dotsLoader {
            view.bringSubviewToFront(loader)
            return
        }

        let loader = DotsLoaderView()
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.dotColor = dotColor
        loader.dotCount = dotCount
        loader.radius = radius
        loader.dotSize = dotSize
        loader.duration = duration

        view.addSubview(loader)
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loader.widthAnchor.constraint(equalToConstant: (radius + dotSize) * 2),
            loader.heightAnchor.constraint(equalToConstant: (radius + dotSize) * 2)
        ])

        dotsLoader = loader
    }

    func hideLoader() {
        guard let loader = dotsLoader else { return }
        if Thread.current.isMainThread {
            loader.removeFromSuperview()
        } else {
            DispatchQueue.main.async {
                loader.removeFromSuperview()
            }
        }
        dotsLoader = nil
    }
}
