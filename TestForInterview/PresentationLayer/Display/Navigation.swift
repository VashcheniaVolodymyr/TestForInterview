//
//  Navigation.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 24.09.2025.
//

import UIKit
import Combine

final class Navigation: Injectable {
    // MARK: Private
    private var cancellables: Set<AnyCancellable> = []
    private lazy var window: UIWindow = UIWindow()
    private lazy var currentNavigationController: UINavigationController = .init()
    
    // MARK: Public properties
    lazy var topViewController: UIViewController? = {
        currentNavigationController.topViewController
    }()
    
    lazy var visibleController: UIViewController? = {
        currentNavigationController.visibleViewController
    }()
    
    lazy var currentController: UIViewController? = {
        currentNavigationController.viewControllers.last
    }()
    
    // MARK: Init
    init() {
        ThemeManager.shared.interfaceStylePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] theme in
                guard let self = self else { return }
                self.applyTheme(theme: theme)
            }
            .store(in: &cancellables)
    }
    
    convenience init(
        window: UIWindow = UIWindow(),
        currentNavigationController: BaseNavigationController = .init()
    ) {
        self.init()
        self.window = window
        self.currentNavigationController = currentNavigationController
    }
    
    // MARK: Public methods
    func start(window: UIWindow) {
        self.window = window
        self.navigate(builder: Scenes.launchScene(duration: 2, finished: { [weak self] in
            self?.navigate(builder: Scenes.dashboard())
        }))
    }
    
    func navigate<SceneBuilder>(builder: SceneBuilder, completion: VoidCallBack? = nil)
    where SceneBuilder: SceneBuilderProtocol, SceneBuilder.Scene: UIViewController {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch builder.transition {
            case .push(animated: let isAnimated):
                self.currentNavigationController.pushViewController(builder.buildScene(), animated: isAnimated)
            case .root(animated: let isAnimated, option: let option):
                if self.currentNavigationController.viewControllers.count > 1 {
                    self.currentNavigationController.viewControllers = []
                }
                
                self.root(
                    navigation: BaseNavigationController(rootViewController: builder.buildScene()),
                    animated: isAnimated,
                    animateOption: option,
                    completion: completion
                )
            }
        }
    }
    
    func popViewController(animated: Bool = true, finishedAction: VoidCallBack? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let poped = self.currentNavigationController.popViewController(animated: animated)
            
            if poped.notNil {
                finishedAction?()
            }
        }
    }
    
    // MARK: Private methods
    private func root(
        navigation: BaseNavigationController,
        animated: Bool = false,
        animateOption: UIView.AnimationOptions? = nil,
        completion: VoidCallBack? = nil
    ) {
        if let option = animateOption, animated {
            window.rootViewController = navigation
            currentNavigationController = navigation
            window.makeKeyAndVisible()
            completion?()
            UIView.transition(
                with: window,
                duration: 0.5,
                options: option,
                animations: nil,
                completion: nil
            )
        } else {
            UIView.performWithoutAnimation {
                window.rootViewController = navigation
                currentNavigationController = navigation
                window.makeKeyAndVisible()
                completion?()
            }
        }
    }
    
    private func applyTheme(theme: UIUserInterfaceStyle) {
        UIView.transition(
            with: self.window,
            duration: 0.3,
            options: .transitionCrossDissolve
        ) { [weak self] in
            guard let self = self else { return }
            self.window.overrideUserInterfaceStyle = theme
        }
    }
}
