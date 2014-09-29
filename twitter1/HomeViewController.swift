//
//  HomeViewController.swift
//  twitter1
//
//  Created by Andrew Folta on 9/27/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tweets: [TwitterTweet]?
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension

        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "pull to refresh")
        refreshControl!.addTarget(self, action: "reload", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)

        reload()
    }

    @IBAction func onLogout(sender: AnyObject) {
        twitterModel.clearSession()
    }

    @IBAction func onCompose(sender: AnyObject) {
        // TODO -- push to compose view
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
        twitterModel.homeStatuses(sinceID: sinceID, maxID: nil) {
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
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var dest = segue.destinationViewController as TweetViewController
        var indexPath = tableView.indexPathForSelectedRow()
        var tweet = tweets?[indexPath!.row]
        dest.tweet = tweet
    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
}

