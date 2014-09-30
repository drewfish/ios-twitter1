//
//  LoginViewController.swift
//  twitter1
//
//  Created by Andrew Folta on 9/27/14.
//  Copyright (c) 2014 Andrew Folta. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {
    @IBAction func onLogin() {
        twitterModel.createSession() {
            (error: NSError?) in
            if error == nil {
                self.performSegueWithIdentifier("loginSegue", sender: self)
            }
            else {
                // TODO -- handle error
                println(error)
            }
        }
    }
}

