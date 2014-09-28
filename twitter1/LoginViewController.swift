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
                // TODO -- display error
                println(error)
            }
        }
    }

//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
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

