//
//  Signup.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 13/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit



class Signup: UITableViewControllerOwn, UITextFieldDelegate {
    
    @IBOutlet weak var fieldUsername: UITextFieldOwn!
    @IBOutlet weak var fieldPassword: UITextFieldOwn!
    @IBOutlet weak var fieldConfirmPassword: UITextFieldOwn!
    @IBOutlet weak var fieldName: UITextFieldOwn!
    @IBOutlet weak var fieldEmail: UITextFieldOwn!
    @IBOutlet weak var btnRegister: UIBarButtonItem!
    @IBOutlet weak var fieldAcceptTerms: UISwitch!
    @IBOutlet weak var btnTerms: UIButton!
  
    let mAppManager: AppManager = AppManager.sharedInstance
    var fromLogOut: Bool = false
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = btnRegister
        self.navigationItem.title = Constants.TitlesViews.signup
        fieldAcceptTerms.on = false
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
        var errors = [String]()
        let acceptTerms = fieldAcceptTerms.on
        
        if fieldUsername.text!.isEmpty{
            errors.append(Constants.ErrorMessage.userNameisRequired)
        }
        if fieldPassword.text!.isEmpty{
            errors.append(Constants.ErrorMessage.passwordisRequired)
        }
        if fieldPassword.text != fieldConfirmPassword.text {
            errors.append(Constants.ErrorMessage.passwordsDontMatch)
        }
        if fieldName.text!.isEmpty{
            errors.append(Constants.ErrorMessage.nameisRequired)
        }
        
        if fieldEmail.text!.isEmpty {
            errors.append(Constants.ErrorMessage.emailisRequired)
        }
        
        if (acceptTerms == false) {
            errors.append(Constants.ErrorMessage.mustAcceptTerms)
        }
        
        let numErrors = errors.count
        if numErrors > 0 {
            // Informamos al usuario
            let errorMessage = errors.joinWithSeparator(".\n")
            let alertController = UIAlertController(title: "Review the registration form", message: errorMessage, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        } else {
            return true
        }
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case fieldUsername:
            fieldPassword.becomeFirstResponder()
            
        case fieldPassword:
            fieldConfirmPassword.becomeFirstResponder()
            
        case fieldConfirmPassword:
            fieldName.becomeFirstResponder()
            
        case fieldName:
            fieldEmail.becomeFirstResponder()

        case fieldEmail:
            btnTerms.becomeFirstResponder()
            
        case btnTerms:
            fieldAcceptTerms.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
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
