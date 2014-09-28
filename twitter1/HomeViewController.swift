//
//  HomeViewController.swift
//  twitter1
//
//  Created by Andrew Folta on 9/27/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController, UITableViewDataSource {
    var tweets: [TwitterTweet]?
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        MMProgressHUD.showWithStatus("Loading...")
        twitterModel.homeStatuses(sinceID: nil, maxID: nil) {
            (tweets: [TwitterTweet]?, error: NSError?) -> Void in
            MMProgressHUD.dismiss()
            if error != nil {
                // TODO -- handle error
            }
            self.tweets = tweets
            self.tableView.reloadData()
        }
    }

    @IBAction func onLogout(sender: AnyObject) {
        twitterModel.clearSession()
    }

    @IBAction func onCompose(sender: AnyObject) {
        // TODO -- push to compose view
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

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

