//
//  LaunchScene.swift
//  TestForInterview
//
//  Created by Vashchenia Volodymyr on 01.10.2025.
//

import UIKit

final class LaunchScene: UIViewController {
    // MARK: Lificycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .bg)
        
        self.showLoader()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.hideLoader()
    }
    
    // MARK: Private
    private var finished: VoidCallBack?
    
    // MARK: Init
    init(duration: Double, finished: VoidCallBack? = nil) {
        self.finished = finished
        super.init(nibName: nil, bundle: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.finished?()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
