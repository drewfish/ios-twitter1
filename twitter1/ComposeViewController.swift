//
//  ComposeViewController.swift
//  twitter1
//
//  Created by Andrew Folta on 9/27/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


class ComposeViewController: UIViewController, UITextViewDelegate {
    var replyingTo: TwitterTweet?
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetView: UITextView!
    var charCountItem: UIBarButtonItem!

    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onTweet(sender: AnyObject) {
        twitterModel.tweet(tweetView.text, replyingTo: replyingTo) {
            (newTweet: TwitterTweet?, error: NSError?) -> Void in
            // success case handled by notification
            if error != nil {
                // TODO -- handle error
                println(error)
            }
        }
    }

    func onTweetPosted(notification: NSNotification) {
        // not much to do here except bail
        dismissViewControllerAnimated(true, completion: nil)
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // http://stackoverflow.com/a/1773257
        // I'm guessing that the actual POST to twitter will use UTF-8 encoding
        var viewLength = textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        var textLength = text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        var newLength = viewLength + textLength - range.length
        charCountItem.title = "\(140 - newLength)"
        return newLength <= 140
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        authorImage.setImageWithURL(twitterModel.sessionUser!.profileImageURL)
        nameLabel.text = twitterModel.sessionUser!.name
        screennameLabel.text = "@\(twitterModel.sessionUser!.screenname)"
        if let tweet = replyingTo {
            tweetView.text = "@\(tweet.user.screenname) "
        }
        tweetView.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTweetPosted:", name: TWITTER_NOTIFY_TWEET_POSTED, object: nil)
        tweetView.becomeFirstResponder()

        // we create this using interface builder
        charCountItem = UIBarButtonItem()
        charCountItem.title = "\(140 - tweetView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))"
        charCountItem.enabled = false
        navigationItem.rightBarButtonItems?.append(charCountItem)
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TWITTER_NOTIFY_TWEET_POSTED, object: nil)
    }
}

