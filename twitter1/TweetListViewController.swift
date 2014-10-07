//
//  TweetListViewController.swift
//  twitter1
//
//  Created by Andrew Folta on 9/27/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


class TweetListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetCellDelegate {

    enum ContentType: String {
        case Home       = "Home"
        case Mentions   = "Mentions"
    }

    var contentType = ContentType.Home
    var tweets: [TwitterTweet]?
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl?

    func setContentType(type: ContentType) {
        if type != contentType {
            // FUTURE -- figure out why this causes a crash
            //tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
            contentType = type
            navigationItem.title = contentType.toRaw()
            tweets = nil
        }
        reload()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension

        navigationItem.title = contentType.toRaw()

        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "pull to refresh")
        refreshControl!.addTarget(self, action: "reload", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTweetPosted:", name: TWITTER_NOTIFY_TWEET_POSTED, object: nil)

        reload()
    }

    @IBAction func onLogout(sender: AnyObject) {
        twitterModel.clearSession()
    }

    @IBAction func onCompose(sender: AnyObject) {
        performSegueWithIdentifier("composeSegue", sender: self)
    }

    func onTweetPosted(notification: NSNotification) {
        var newTweet = notification.userInfo!["tweet"] as TwitterTweet
        tweets?.insert(newTweet, atIndex: 0)
        tableView.reloadData()
        var path = NSIndexPath(forRow: 0, inSection: 0)
        tableView.selectRowAtIndexPath(path, animated: true, scrollPosition: .Top)
    }

    func onTap(tweetCell cell: TweetCell) {
        var path = tableView.indexPathForCell(cell)
        tableView.selectRowAtIndexPath(path!, animated: false, scrollPosition: .None)
        performSegueWithIdentifier("profileSegue", sender: self)
    }

    func reload() {
        var sinceID: Int?
        if let old = tweets {
            sinceID = old.reduce(-1, combine: {
                (running: Int, tweet: TwitterTweet) -> Int in
                return max(running, tweet.id)
            })
        }
        self.refreshControl?.endRefreshing()
        MMProgressHUD.showWithStatus("Loading...")
        var done = {
            (tweets: [TwitterTweet]?, error: NSError?) -> Void in
            MMProgressHUD.dismiss()
            if error != nil {
                // TODO -- handle error
                println(error)
                return
            }
            if sinceID == nil {
                self.tweets = tweets
            } else {
                // the returned tweets are newer than the ones we have
                var more = tweets!      // can't use `tweets!` as an lvalue apparently
                if self.tweets != nil {
                    more += self.tweets!
                }
                self.tweets = more
            }
            self.tableView.reloadData()
        }
        switch contentType {
        case .Home:
            twitterModel.homeStatuses(sinceID: sinceID, maxID: nil, done: done)
        case .Mentions:
            twitterModel.mentionsStatuses(sinceID: sinceID, maxID: nil, done: done)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("TweetCell") as TweetCell
        cell.setTweet(tweets![indexPath.row])
        cell.delegate = self
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var dest = segue.destinationViewController as UIViewController
        if let vc = dest as? TweetViewController {
            var indexPath = tableView.indexPathForSelectedRow()
            var tweet = tweets?[indexPath!.row]
            vc.tweet = tweet
        }
        if let vc = dest as? ProfileViewController {
            var indexPath = tableView.indexPathForSelectedRow()
            var tweet = tweets?[indexPath!.row]
            vc.user = tweet!.user
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: TWITTER_NOTIFY_TWEET_POSTED, object: nil)
    }
}

