//
//  Twitter.swift
//  twitter1
//
//  Created by Andrew Folta on 9/27/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


private let DEFAULTS_KEY_TWITTER_SESSION = "twitterSession"
private let CONSUMER_KEY = "KL2KHoLzh70IcEzT79xz2PSdf"
private let CONSUMER_SECRET = "a9JUy0xVhx9wcRjjTjEE1FlMAZDGm7LFvKiK5jmpXP7g2dD3zo"
let TWITTER_NOTIFY_SESSION_CREATED = "session-created"
let TWITTER_NOTIFY_SESSION_CLEARED = "session-cleared"
let TWITTER_NOTIFY_TWEET_POSTED = "tweet-posted"
let twitterDateFormatter = NSDateFormatter()


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
        twitterDateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
    }

    override init() {
        super.init(
            baseURL: NSURL(string: "https://api.twitter.com/"),
            consumerKey: CONSUMER_KEY,
            consumerSecret: CONSUMER_SECRET
        )
        twitterDateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
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
                        if let done = self.sessionCreateDone {
                            self.sessionCreateDone = nil
                            done(error: nil)
                        }
                    },
                    failure: {
                        (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        if let done = self.sessionCreateDone {
                            self.sessionCreateDone = nil
                            done(error: error)
                        }
                    }
                )
            },
            failure: {
                (error: NSError?) -> Void in
                if let done = self.sessionCreateDone {
                    self.sessionCreateDone = nil
                    done(error: error)
                }
            }
        )
    }

    func clearSession() {
        sessionUser = nil
        requestSerializer.removeAccessToken()
        NSNotificationCenter.defaultCenter().postNotificationName(TWITTER_NOTIFY_SESSION_CLEARED, object: nil)
    }

    func homeStatuses(
        #sinceID: Int?,
        maxID: Int?,
        done: (tweets: [TwitterTweet]?, error: NSError?) -> Void
    )
    {
        var params = NSMutableDictionary()
        if let id = sinceID {
            params.setValue(NSNumber(integer: id), forKey: "since_id")
        }
        if let id = maxID {
            params.setValue(NSNumber(integer: id), forKey: "max_id")
        }
        GET(
            "1.1/statuses/home_timeline.json",
            parameters: params,
            success: {
                (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                var tweets: [TwitterTweet] = []
                for dictionary in response as NSArray {
                    tweets.append(TwitterTweet(dictionary: dictionary as NSDictionary))
                }
                done(tweets: tweets, error: nil)
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                done(tweets: nil, error: error)
            }
        )
    }

    func tweet(
        text: String,
        replyingTo: TwitterTweet?,
        done: (newTweet: TwitterTweet?, error: NSError?) -> Void
    )
    {
        var params = NSMutableDictionary()
        params.setValue(NSString(string: text), forKey: "status")
        if let tweet = replyingTo {
            params.setValue(NSNumber(integer: tweet.id), forKey: "in_reply_to_status_id")
        }
        POST(
            "1.1/statuses/update.json",
            parameters: params,
            success: {
                (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                var newTweet = TwitterTweet(dictionary: response as NSDictionary)
                NSNotificationCenter.defaultCenter().postNotificationName(TWITTER_NOTIFY_TWEET_POSTED, object: nil, userInfo: ["tweet": newTweet])
                done(newTweet: newTweet, error: nil)
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                done(newTweet: nil, error: error)
            }
        )
    }

    func retweet(
        tweet: TwitterTweet,
        done: (error: NSError?) -> Void
    )
    {
        POST(
            "1.1/statuses/retweet/\(tweet.id).json",
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                tweet.retweetCount += 1
                tweet.didRetweet = true
                done(error: nil)
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                done(error: error)
            }
        )
    }

    func favorite(
        tweet: TwitterTweet,
        done: (error: NSError?) -> Void
    )
    {
        var params = NSMutableDictionary()
        params.setValue(NSNumber(integer: tweet.id), forKey: "id")
        POST(
            "1.1/favorites/create.json",
            parameters: params,
            success: {
                (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                tweet.favoriteCount += 1
                tweet.didFavorite = true
                done(error: nil)
            },
            failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                done(error: error)
            }
        )
    }

    private var _sessionUser: TwitterUser?
    private var sessionCreateDone: ((error: NSError?) -> Void)?
}


class TwitterUser: NSObject {
    var name: String
    var screenname: String
    var profileImageURL: NSURL
    var tweetsCount: Int
    var followersCount: Int
    var followingCount: Int
    var dictionary: NSDictionary    // mainly for easy serialization

    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as String
        screenname = dictionary["screen_name"] as String
        profileImageURL = NSURL(string: dictionary["profile_image_url"] as String)
        tweetsCount = dictionary["statuses_count"] as Int
        followersCount = dictionary["followers_count"] as Int
        followingCount = dictionary["friends_count"] as Int
    }
}


class TwitterTweet: NSObject {
    var id: Int
    var user: TwitterUser
    var text: String
    var favoriteCount: Int
    var didFavorite: Bool
    var retweetCount: Int
    var didRetweet: Bool
    var createdAt: NSDate

    init(dictionary: NSDictionary) {
        id = (dictionary["id"] as NSNumber).integerValue
        user = TwitterUser(dictionary: dictionary["user"] as NSDictionary)
        text = dictionary["text"] as String
        favoriteCount = dictionary["favorite_count"] as Int
        didFavorite = 0 != dictionary["favorited"] as Int
        retweetCount = dictionary["retweet_count"] as Int
        didRetweet = 0 != dictionary["retweeted"] as Int
        createdAt = twitterDateFormatter.dateFromString(dictionary["created_at"] as String)!
    }
}

