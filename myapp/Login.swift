//
//  Login.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 12/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class Login: UIViewControllerOwn, UITextFieldDelegate {

    @IBOutlet weak var fieldUserName: UITextFieldOwn!
    @IBOutlet weak var fieldPassword: UITextFieldOwn!
    @IBOutlet weak var btnLogin: UIButtonOwn!
    @IBOutlet weak var btnSignup: UIButtonOwn!
    
    let mAppManager = AppManager.sharedInstance
    var fromLogOut = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fieldUserName.text = "admin"
        self.fieldPassword.text = "admin"
        
        btnLogin.addTarget(self, action: #selector(Login.tapLogin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btnSignup.addTarget(self, action: #selector(Login.tapSignUp(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
        textField.resignFirstResponder()
        return true
    }
    
    func tapLogin(sender: UIButton!){
        if canDoLogin(){
            let username = fieldUserName.text
            let password = fieldPassword.text
            self.startIndicator()
            mAppManager.doLogin(username!, password: password!, completion: { (success, error) -> Void in
                self.stopIndicator()
                if success{
                    self.toMainApp()
                } else {
                    self.alertError((error.message))
                }
            })
        } 
    }
    
    func toMainApp(){
        performSegueWithIdentifier(Constants.Segues.fromLoginToMain, sender: self)
        self.resetFields()
    }
    
    func tapSignUp(sender: UIButton!){
        performSegueWithIdentifier(Constants.Segues.fromLoginToSignUp, sender: self)
        self.resetFields()
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
        if segue.identifier == Constants.Segues.fromLoginToMain{
            mAppManager.doLogOut()
        }
    }
    


}

