//
//  AppManager.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 13/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import UIKit



class AppManager {
    
    static let sharedInstance = AppManager()
    var currentUser: User!
    var autoLoggedIn: Bool!

    init(){}
    
    func doLogin(username: String, password: String, completion:(success: Bool, error: Fault!) -> Void){
        UserSession.login(username, password: password, response: { (registeredUser) in
            self.currentUser = registeredUser
            completion(success: true, error: nil)
        }, _error: { (error) in
            self.clearUserData()
            completion(success: false, error: error)
        })
    }
    
    func doSignUp(newUser: User, completion:(success: Bool, error: Fault!) -> Void){
        UserSession.signup(newUser, response: { (registeredUser) in
            self.currentUser = registeredUser
            completion(success: true, error: nil)
            }, _error: { (error) in
                self.clearUserData()
                completion(success: false, error: error)
        })
    }
    
    func doLogOut(){
        self.clearUserData()
    }
    
    func saveUserSession(){
        currentUser.logged = true
        UserSession.set(currentUser.username, password: currentUser.password)
    }

    func clearUserData(){
        currentUser = nil
        UserSession.clear()
    }
    
    func existUserSession() -> Bool{
        if UserSession.exist() {
            autoLoggedIn(true)
        }
        return UserSession.exist()
    }

    func autoLoggedIn(enabled: Bool){
        self.autoLoggedIn = enabled
    }
    
    
    
}
