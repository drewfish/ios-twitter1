//
//  Twitter.swift
//  twitter1
//
//  Created by Andrew Folta on 9/27/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


typealias TweetID = UInt64
private let DEFAULTS_KEY_TWITTER_SESSION = "twitterSession"
private let CONSUMER_KEY = "KL2KHoLzh70IcEzT79xz2PSdf"
private let CONSUMER_SECRET = "a9JUy0xVhx9wcRjjTjEE1FlMAZDGm7LFvKiK5jmpXP7g2dD3zo"
let TWITTER_NOTIFY_SESSION_CREATED = "session-created"
let TWITTER_NOTIFY_SESSION_CLEARED = "session-cleared"


class Twitter: BDBOAuth1RequestOperationManager {

    var sessionUser: TwitterUser? {
        get {
            if _sessionUser == nil {
                var data: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(DEFAULTS_KEY_TWITTER_SESSION)
                if let gotData = data as? NSData {
                    var dictionary = NSJSONSerialization.JSONObjectWithData(gotData, options: nil, error: nil) as NSDictionary
                    _sessionUser = TwitterUser(dictionary: dictionary)
                }
            }
            return _sessionUser
        }
        set(user) {
            var data: NSData?
            if user != nil {
                data = NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: nil, error: nil)
            }
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: DEFAULTS_KEY_TWITTER_SESSION)
            NSUserDefaults.standardUserDefaults().synchronize()
            _sessionUser = user
        }
    }

    // still no idea why I need to make this
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init() {
        super.init(
            baseURL: NSURL(string: "https://api.twitter.com/"),
            consumerKey: CONSUMER_KEY,
            consumerSecret: CONSUMER_SECRET
        )
    }

    func createSession(done: (error: NSError?) -> Void) {
        // FUTURE -- remove this if we want to present the user a button to "re-login"
        if sessionUser != nil {
            done(error: nil)
            return
        }

        // clear BDBOAuth's cache
        requestSerializer.removeAccessToken()

        fetchRequestTokenWithPath(
            "oauth/request_token",
            method: "GET",
            callbackURL: NSURL(string: "netfoltatwitter1://oauth"),
            scope: nil,
            success: {
                (requestToken: BDBOAuthToken!) in
                var authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
                self.sessionCreateDone = done
                UIApplication.sharedApplication().openURL(authURL)
            },
            failure: {
                (error: NSError?) in
                done(error: error)
            }
        )
    }

    func oauthURL(url: NSURL) {
        fetchAccessTokenWithPath(
            "oauth/access_token",
            method: "POST",
            requestToken: BDBOAuthToken(queryString: url.query),
            success: {
                (accessToken: BDBOAuthToken!) -> Void in
                self.requestSerializer.saveAccessToken(accessToken)
                self.GET(
                    "1.1/account/verify_credentials.json",
                    parameters: nil,
                    success: {
                        (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                        self.sessionUser = TwitterUser(dictionary: response as NSDictionary)
                        NSNotificationCenter.defaultCenter().postNotificationName(TWITTER_NOTIFY_SESSION_CREATED, object: nil)
                        if let gotOp = self.sessionCreateDone {
                            self.sessionCreateDone = nil
                            gotOp(error: nil)
                        }
                    },
                    failure: {
                        (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        if let gotOp = self.sessionCreateDone {
                            self.sessionCreateDone = nil
                            gotOp(error: error)
                        }
                    }
                )
            },
            failure: {
                (error: NSError?) -> Void in
                if let gotOp = self.sessionCreateDone {
                    self.sessionCreateDone = nil
                    gotOp(error: error)
                }
            }
        )
    }

    func clearSession() {
        sessionUser = nil
        requestSerializer.removeAccessToken()
        NSNotificationCenter.defaultCenter().postNotificationName(TWITTER_NOTIFY_SESSION_CLEARED, object: nil)
    }

    func homeStatuses(options: (), done: (statuses: [TwitterTweet]?, error: NSError?) -> Void) {
        // TODO
    }

    func tweet(fields: (), done: (error: NSError?) -> Void) {
        // TODO
    }

    func retweet(tweetID: TweetID, done: (error: NSError?) -> Void) {
        // TODO
    }

    func favorite(tweetID: TweetID, done: (error: NSError?) -> Void) {
        // TODO
    }

    private var _sessionUser: TwitterUser?
    private var sessionCreateDone: ((error: NSError?) -> Void)?
}


class TwitterUser: NSObject {
    var name: String
    var screenname: String
    var profileImageURL: NSURL
    var dictionary: NSDictionary

    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as String
        screenname = dictionary["screen_name"] as String
        profileImageURL = NSURL(string: dictionary["profile_image_url"] as String)
    }
}


class TwitterTweet: NSObject {
    var user: TwitterUser
    var text: String

    init(dictionary: NSDictionary) {
        user = TwitterUser(dictionary: dictionary["user"] as NSDictionary)
        text = dictionary["text"] as String
    }
}

