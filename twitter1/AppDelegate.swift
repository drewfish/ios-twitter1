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
            var ham = storyboard.instantiateViewControllerWithIdentifier("hamburgerPage") as HamburgerViewController
            var nav = storyboard.instantiateViewControllerWithIdentifier("tweetListNav") as UINavigationController
            ham.viewController = nav
            window?.rootViewController = ham
        }

        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        twitterModel.oauthURL(url)
        return true
    }
}

