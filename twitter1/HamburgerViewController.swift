//
//  HamburgerViewController.swift
//  twitter1
//
//  Created by Andrew Folta on 10/5/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


let HAMBURGER_ANIMATION_DURATION = 0.3


class HamburgerViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    var open = false
    var viewController: UIViewController?

    @IBAction func onProfile(sender: UITapGestureRecognizer) {
        // TODO -- segue(push) profile page for sessionUser
        println("HAM onProfile")
    }

    @IBAction func onHome(sender: AnyObject) {
        // TODO -- show tweetlist, configured as home
        println("HAM onHome")
    }

    @IBAction func onMentions(sender: AnyObject) {
        // TODO -- show tweetlist, configured as mentions
        println("HAM onMentions")
    }

    @IBAction func onSwipeRight(sender: UISwipeGestureRecognizer) {
        if open {
            // we're already open
            return
        }
        UIView.animateWithDuration(HAMBURGER_ANIMATION_DURATION, animations: {
            () -> Void in
            self.containerView.frame.origin.x = 200
        })
        open = true
    }

    @IBAction func onSwipeLeft(sender: UISwipeGestureRecognizer) {
        if !open {
            // we're already closed
            return
        }
        UIView.animateWithDuration(HAMBURGER_ANIMATION_DURATION, animations: {
            () -> Void in
            self.containerView.frame.origin.x = 0
        })
        open = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        authorImage.setImageWithURL(twitterModel.sessionUser!.profileImageURL)
        nameLabel.text = twitterModel.sessionUser!.name
        screennameLabel.text = "@\(twitterModel.sessionUser!.screenname)"

        if let vc = viewController {
            vc.view.frame = containerView.frame
            containerView.addSubview(vc.view)
        }

        // in case we get here via some wierd transition
        self.containerView.frame.origin.x = open ? 200 : 0
    }

}

