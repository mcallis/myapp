//
//  UserSession.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 15/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class UserSession {
    
    static var userName: String!
    static var password: String!
    static let key = Constants.UserDefaults.self
    
    static func get(){
        self.userName = UserDefaults.get(key.usernameKeyConstant) as! String
        self.password = UserDefaults.get(key.passwordKeyConstant) as! String
    }
    
    static func set(username: String, password: String){
        UserDefaults.add(username, key: key.usernameKeyConstant)
        UserDefaults.add(password, key: key.passwordKeyConstant)
    }
    
    static func clear(){
        UserDefaults.remove(key.usernameKeyConstant)
        UserDefaults.remove(key.passwordKeyConstant)
    }
    
    static func exist() -> Bool{
        return (UserDefaults.get(key.usernameKeyConstant) != nil) && (UserDefaults.get(key.passwordKeyConstant) != nil)
    }
    
    static func login(userName: String, password: String, response:(registeredUser: User) -> Void, _error:(error: Fault!) -> Void){
        let connection = ConnectionApi.sharedInstance
        connection.login(userName, password: password,
            response: { (logedInUser) -> Void in
                
                // Set user session
                self.set(userName, password: password)
                
                // Create user
                let user = User()
                user.username = userName
                user.password = password
                user.name = logedInUser.name!
                user.email = logedInUser.email
                user.logged = true
                response(registeredUser: user)
            },
            _error: { (error) -> Void in
                NSLog("Error login: ", error.message)
                _error(error: error)
        })
    }
    
    static func signup(newUser: User, response:(registeredUser: User) -> Void, _error:(error: Fault!) -> Void){
        let connection = ConnectionApi.sharedInstance
        connection.signup(newUser.username, password: newUser.password, name: newUser.name, email: newUser.email,
                          response: { (registeredUser) -> Void in
                            newUser.name = registeredUser.name
                            newUser.email = registeredUser.email
                            print("Usuari \(newUser.email) registrat correctament")
                            connection.setComment(newUser.email, message: "I'm in")
                            // do login
                            self.login(newUser.username, password: newUser.password, response: { (registeredUser) in
                                // login ok
                                response(registeredUser: registeredUser)
                                }, _error: { (error) in
                                    _error(error: error)
                            })

            },
                          _error: { (error) -> Void in
                            NSLog("Error signup: ", error.message)
                            _error(error: error)
        })

}
        

}
