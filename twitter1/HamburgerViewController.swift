//
//  HamburgerViewController.swift
//  twitter1
//
//  Created by Andrew Folta on 10/5/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


let HAMBURGER_ANIMATION_DURATION: NSTimeInterval = 0.3


class HamburgerViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    var open = false
    var viewController: UIViewController?

    @IBAction func onProfile(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(HAMBURGER_ANIMATION_DURATION, animations: {
            () -> Void in
            self.open = false
            self.render()
            self.viewController?.performSegueWithIdentifier("profileSegue", sender: self)
        })
    }

    @IBAction func onHome(sender: AnyObject) {
        if let nav = viewController as? UINavigationController {
            UIView.animateWithDuration(
                HAMBURGER_ANIMATION_DURATION,
                animations: {
                    () -> Void in
                    self.open = false
                    self.render()
                    nav.popToRootViewControllerAnimated(true)
                },
                completion: {
                    (foo: Bool) -> Void in
                    if let list = nav.topViewController as? TweetListViewController {
                        list.setContentType(.Home)
                    }
                }
            )
        }
    }

    @IBAction func onMentions(sender: AnyObject) {
        if let nav = viewController as? UINavigationController {
            UIView.animateWithDuration(
                HAMBURGER_ANIMATION_DURATION,
                animations: {
                    () -> Void in
                    self.open = false
                    self.render()
                    nav.popToRootViewControllerAnimated(true)
                },
                completion: {
                    (foo: Bool) -> Void in
                    if let list = nav.topViewController as? TweetListViewController {
                        list.setContentType(.Mentions)
                    }
                }
            )
        }
    }

    @IBAction func onSwipeRight(sender: UISwipeGestureRecognizer) {
        if open {
            // we're already open
            return
        }

        // for some reason the render() in viewDidLoad() isn't setting up menuView correctly
        render()

        open = true
        UIView.animateWithDuration(HAMBURGER_ANIMATION_DURATION, animations: {
            () -> Void in
            self.render()
        })
    }

    @IBAction func onSwipeLeft(sender: UISwipeGestureRecognizer) {
        if !open {
            // we're already closed
            return
        }
        open = false
        UIView.animateWithDuration(HAMBURGER_ANIMATION_DURATION, animations: {
            () -> Void in
            self.render()
        })
    }

    func render() {
        menuView.frame.origin.x = open ? 0 : -200
        containerView.frame.origin.x = open ? 200 : 0
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
        render()
    }
}

