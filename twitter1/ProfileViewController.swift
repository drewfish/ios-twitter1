//
//  ProfileViewController.swift
//  twitter1
//
//  Created by Andrew Folta on 10/4/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    var user: TwitterUser?
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        authorImage.setImageWithURL(user!.profileImageURL)
        authorImage.layer.cornerRadius = 8.0
        authorImage.layer.masksToBounds = true
        nameLabel.text = user!.name
        screennameLabel.text = "@\(user!.screenname)"
        tweetsLabel.text = "\(user!.tweetsCount)"
        followingLabel.text = "\(user!.followingCount)"
        followersLabel.text = "\(user!.followersCount)"
        descriptionLabel.text = user!.userDescription
    }

}
