//
//  TweetCell.swift
//  twitter1
//
//  Created by Andrew Folta on 9/28/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


private let prettyRelativeDateFormatter = NSDateFormatter()


func prettyRelativeDate(date: NSDate) -> String {
    var hours = date.timeIntervalSinceNow / (60 * 60)
    if -24 < hours {
        return "\(-Int(hours))h"
    }
    // FUTURE -- figure out how to create/configure these dateformatters only once
    prettyRelativeDateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
    prettyRelativeDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    return prettyRelativeDateFormatter.stringFromDate(date)
}


class TweetCell: UITableViewCell {
    var tweet: TwitterTweet?
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!

    func setTweet(tweet: TwitterTweet) {
        self.tweet = tweet
        nameLabel.text = tweet.user.name
        screennameLabel.text = "@\(tweet.user.screenname)"
        tweetLabel.text = tweet.text
        authorImage.setImageWithURL(tweet.user.profileImageURL)
        authorImage.layer.cornerRadius = 8.0
        authorImage.layer.masksToBounds = true
        createdLabel.text = prettyRelativeDate(tweet.createdAt)
    }
}

