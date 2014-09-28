//
//  TweetCell.swift
//  twitter1
//
//  Created by Andrew Folta on 9/28/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


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
        // TODO -- authorImage
        // TODO -- createdLabel
    }

//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
}

