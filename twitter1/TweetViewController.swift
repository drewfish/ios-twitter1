//
//  TweetViewController.swift
//  twitter1
//
//  Created by Andrew Folta on 9/27/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


private let prettyLongDateFormatter = NSDateFormatter()


class TweetViewController: UIViewController {
    var tweet: TwitterTweet?
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var retweetsLabel: UILabel!
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!

    @IBAction func onReply(sender: AnyObject) {
        performSegueWithIdentifier("replySegue", sender: self)
    }

    @IBAction func onRetweet() {
        if retweetButton.selected {
            // FUTURE -- un-retweet
        }
        else {
            MMProgressHUD.showWithStatus("Retweeting...")
            twitterModel.retweet(tweet!) {
                (error: NSError?) -> Void in
                MMProgressHUD.dismiss()
                if error == nil {
                    self.retweetButton.selected = true
                    self.retweetsLabel.text = "\(self.tweet!.retweetCount)"
                }
                else {
                    self.retweetButton.selected = false
                    // TODO -- handle error
                    println(error)
                }
            }
        }
    }

    @IBAction func onFavorite() {
        if favoriteButton.selected {
            // FUTURE -- un-favorite
        }
        else {
            MMProgressHUD.showWithStatus("Favoriting...")
            twitterModel.favorite(tweet!) {
                (error: NSError?) -> Void in
                MMProgressHUD.dismiss()
                if error == nil {
                    self.favoriteButton.selected = true
                    self.favoritesLabel.text = "\(self.tweet!.favoriteCount)"
                }
                else {
                    self.favoriteButton.selected = false
                    // TODO -- handle error
                    println(error)
                }
            }
        }
    }

    // this is called when a reply to this tweet is posted
    func onTweetPosted(notification: NSNotification) {
        // go back to where we came from
        navigationController?.popToRootViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // FUTURE -- figure out how to create/configure these dateformatters only once
        prettyLongDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        prettyLongDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle

        authorImage.setImageWithURL(tweet!.user.profileImageURL)
        authorImage.layer.cornerRadius = 8.0
        authorImage.layer.masksToBounds = true
        nameLabel.text = tweet!.user.name
        screennameLabel.text = "@\(tweet!.user.screenname)"
        tweetLabel.text = tweet!.text
        createdLabel.text = prettyLongDateFormatter.stringFromDate(tweet!.createdAt)
        retweetsLabel.text = "\(tweet!.retweetCount)"
        favoritesLabel.text = "\(tweet!.favoriteCount)"
        retweetButton.selected = tweet!.didRetweet
        favoriteButton.selected = tweet!.didFavorite

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTweetPosted:", name: TWITTER_NOTIFY_TWEET_POSTED, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TWITTER_NOTIFY_TWEET_POSTED, object: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let compose = segue.destinationViewController as? ComposeViewController {
            compose.replyingTo = tweet
        }
    }
}

