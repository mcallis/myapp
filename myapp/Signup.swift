//
//  Signup.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 13/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit



class Signup: UIViewControllerOwn, UITextFieldDelegate {
    
    @IBOutlet weak var fieldUsername: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldEmail: UITextField!
    
    let mAppManager: AppManager = AppManager.sharedInstance
    var fromLogOut: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Constants.TitlesViews.signup
    }
    
    @IBAction func closeView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        self.startIndicator()
        if canDoSignUp(){
            let newUser = User()
            newUser.username = fieldUsername.text!
            newUser.password = fieldPassword.text!
            newUser.name = fieldName.text!
            newUser.email = fieldEmail.text!
            mAppManager.doSignUp(newUser, completion: { (success, error) -> Void in
                self.stopIndicator()
                if success{
                    self.toMainApp()
                } else {
                    self.alertError((error.message))
                }
            })
        } else {
            self.stopIndicator()
        }
    }
    
    func canDoSignUp() -> Bool{
        if fieldUsername.text!.isEmpty{
            self.alertError(Constants.ErrorMessage.userNameisRequired)
            return false
        }
        if fieldPassword.text!.isEmpty{
            self.alertError(Constants.ErrorMessage.passwordisRequired)
            return false
        }
        if fieldName.text!.isEmpty{
            self.alertError(Constants.ErrorMessage.nameisRequired)
            return false
        }
        return true
    }
    
    func toMainApp(){
        mAppManager.autoLoggedIn = false
        self.performSegueWithIdentifier(Constants.Segues.fromSignUpToMain, sender: nil)    }
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
  
}
