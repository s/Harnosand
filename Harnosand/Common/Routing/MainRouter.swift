//
//  MainRouter.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import UIKit

protocol MainRouterProtocol{
    func loadMainView()
}

class MainRouter: NSObject {
    private var window: UIWindow
    
    init(with window:UIWindow) {
        self.window = window
        super.init()
    }
}

extension MainRouter: MainRouterProtocol{
    func loadMainView() {
        let feedView = FeedViewController()
        self.window.rootViewController = feedView
    }
}