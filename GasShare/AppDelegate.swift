//
//  AppDelegate.swift
//  GasShare
//
//  Created by Eric Kim on 7/8/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
import Venmo_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyBazJ2z6FlEblgXnM5x4Z0lnYf8rof9-GM")
        
        Venmo.startWithAppId("2842", secret: "FqF947VRnYGzxUfnHyfgVULZQBRFUZxE", name: "Gas Share")
        
        if NSUserDefaults.standardUserDefaults().boolForKey("usedAppBefore") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
            
            self.window?.rootViewController = mainViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if Venmo.sharedInstance().handleOpenURL(url) {
            return true
        }
        
        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

