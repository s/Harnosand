//
//  AppDelegate.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var router: MainRouter?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        guard let window = window else { return false }
        
        window.backgroundColor = UIColor.whiteColor()
        window.makeKeyAndVisible()
        
        router = MainRouter(with: window)
        router?.loadMainView()
        return true
    }
}
