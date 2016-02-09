//
//  InstallViewController.swift
//  SnapBoard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Updated by Grant Magdanz on 9/24/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

import UIKit

class InstallViewController: UIViewController {
    let UPDATE_11 = "update1.1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide"), name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidChangeFrame:"), name: UIKeyboardDidChangeFrameNotification, object: nil)
        */
        if !NSUserDefaults.standardUserDefaults().boolForKey(UPDATE_11) && NSLocale.preferredLanguages()[0] == "en-US" {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UPDATE_11)
            let alert = UIAlertView()
            alert.title = "Update!"
            alert.message = "SnapBoard now has line wrapping! You can disable it by going into SnapBoard settings (the gear icon on the keyboard). Thanks for being awesome. :)"
            alert.addButtonWithTitle("I got it!")
            alert.show()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismiss() {
        for view in self.view.subviews {
            if let inputView = view as? UITextField {
                inputView.resignFirstResponder()
            }
        }
    }
    
    /* func keyboardWillShow() {
        // intentionally empty
    }
    
    func keyboardDidHide() {
        // intentionally empty
    }
    
    func keyboardDidChangeFrame(notification: NSNotification) {
        // intentionally empty
    }*/
}

