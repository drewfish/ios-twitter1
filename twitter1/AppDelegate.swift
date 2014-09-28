//
//  AppDelegate.swift
//  twitter1
//
//  Created by Andrew Folta on 9/27/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


extension UIViewController {
    // expose model to all view controllers
    var twitterModel: Twitter {
        return (UIApplication.sharedApplication().delegate as AppDelegate).twitterModel
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    var twitterModel = Twitter()

    func onSessionCleared() {
        var page = storyboard.instantiateViewControllerWithIdentifier("loginPage") as UIViewController
        window?.rootViewController = page
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        var hud = MMProgressHUD.sharedHUD()
        hud.presentationStyle = MMProgressHUDPresentationStyle.Fade

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onSessionCleared", name: TWITTER_NOTIFY_SESSION_CLEARED, object: nil)

        if twitterModel.sessionUser != nil {
            var page = storyboard.instantiateViewControllerWithIdentifier("homePage") as UIViewController
            window?.rootViewController = page
        }

        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        twitterModel.oauthURL(url)
        return true
    }

/*
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
*/

}

