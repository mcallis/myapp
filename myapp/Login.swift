//
//  Login.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 12/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class Login: UITableViewControllerOwn, UITextFieldDelegate {

    @IBOutlet weak var fieldUserName: UITextFieldOwn!
    @IBOutlet weak var fieldPassword: UITextFieldOwn!
    @IBOutlet weak var btnLogin: UIButtonOwn!
    @IBOutlet weak var btnSignup: UIButtonOwn!

    let backendless = Backendless.sharedInstance()
    let mAppManager = AppManager.sharedInstance
    var fromLogOut = false

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startIndicator()
        backendless.userService.isValidUserToken(
            { ( result : AnyObject!) -> () in
                print("isValidUserToken (ASYNC): \(result.boolValue)")
                self.stopIndicator()
                // toMainApp
                if (result.boolValue == true) {
                    self.mAppManager.autoLoggedIn = true
                    self.toMainApp()
                }
            },
            error: { ( fault : Fault!) -> () in
                print("Server reported an error (ASYNC): \(fault)")
                self.stopIndicator()
            }
        )

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //let loggedIn = mAppManager.existUserSession()
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetFields(){
        self.fieldUserName.text = ""
        self.fieldPassword.text = ""
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case fieldUserName:
            fieldPassword.becomeFirstResponder()
        default:
            tapLogin()
        }
        return true
    }
    
    @IBAction func tapLogin() {
        if canDoLogin(){
            let username = fieldUserName.text
            let password = fieldPassword.text
            self.startIndicator()
            mAppManager.doLogin(username!, password: password!, completion: { (success, error) -> Void in
                self.stopIndicator()
                if success{
                    self.mAppManager.autoLoggedIn = false
                    self.toMainApp()
                } else {
                    self.alertError((error.message))
                }
            })
        }

    }
    
    
    func toMainApp(){
        performSegueWithIdentifier(Constants.Segues.fromLoginToMain, sender: self)
    }

    
    func canDoLogin() -> Bool{
        if fieldUserName.text!.isEmpty{
            self.alertError(Constants.ErrorMessage.userNameisRequired)
            return false
        }
        if fieldPassword.text!.isEmpty{
            self.alertError(Constants.ErrorMessage.passwordisRequired)
            return false
        }
        return true
    }
    
    
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func returnActionForSegue(segue: UIStoryboardSegue) {
        mAppManager.doLogOut()
        self.resetFields()
    }
 }

