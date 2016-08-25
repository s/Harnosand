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
        
        guard let credentialsPath = NSBundle.mainBundle().pathForResource("Credentials", ofType: "plist") else {
            print("Credentials.plist not found")
            return false
        }
        if let credentials = NSDictionary(contentsOfFile: credentialsPath) as? Dictionary<String, AnyObject>{
            if let apiKey = credentials["apiKey"] as? String{
                FlickrService.apiKey = apiKey
            }else{
                print("Can't find key: 'apiKey' in Credentials.plist")
            }
        }else{
            print("Can't read Credentials.plist as dictionary.")
            return false
        }
        
        window.backgroundColor = UIColor.whiteColor()
        window.makeKeyAndVisible()
        
        router = MainRouter(with: window)
        router?.loadMainView()
        
        return true
    }
}
