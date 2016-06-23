//
//  TabBar.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 15/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class TabBar: UITabBarController{
    
    override func viewDidLoad() {
        //checkSession()
    }
    
    /*
    func checkSession(){
        let mAppManager = AppManager.sharedInstance
        if (mAppManager.autoLoggedIn != nil && mAppManager.autoLoggedIn) {
            UserSession.get()
            let name = UserSession.userName
            let pass = UserSession.password
            
            
            mAppManager.doLogin(name, password: pass) { (success, error) in
                if !success{
                    // Show alert
                    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! Login
                    self.presentViewController(loginVC, animated: true, completion: nil)
                }
            }
        }
    }
    */
    
}