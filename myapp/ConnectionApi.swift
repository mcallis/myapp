//
//  ConnectionApi.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 13/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import UIKit

class ConnectionApi {
    
    static let APP_ID = "CA8016EE-C4B3-45B7-FFDF-9022E3862400"
    static let SECRET_KEY = "E52794F2-A2AD-007D-FF71-5038D836F400"
    static let VERSION_NUM = "v1"
    
    static let sharedInstance = ConnectionApi()
    let backendless: Backendless
    
    init(){
        self.backendless = Backendless.sharedInstance()
    }
    
    func login(username: String, password: String, response:(logedInUser: BackendlessUser) -> Void, _error:(error: Fault!) -> Void){
        self.backendless.userService.login(username, password: password,
            response: { (logedInUser) -> Void in
                response(logedInUser: logedInUser)
            },
            error: { (error) -> Void in
                _error(error: error)
        })
    }
    
    func signup(username: String, password: String, name: String, email: String, response:(registeredUser: BackendlessUser) -> Void, _error:(error: Fault!) -> Void){
        let user: BackendlessUser = BackendlessUser()
        user.setProperty("username", object: username)
        user.password = password
        user.name = name
        user.email = email
        self.backendless.userService.registering(user,
            response: { (registeredUser) -> Void in
                response(registeredUser: registeredUser)
            },
            error: { (error) -> Void in
                // Codi en cas d’error al registre
                let message = error.message
                print("Error registrant l’usuari: \(message)")
                _error(error: error)
        })
    }
    
    func setComment(email: String, message: String){
        let comment = Comment()
        comment.message = message
        comment.authorEmail = email
        backendless.persistenceService.of(Comment.ofClass()).save(comment)
    }
    
    func describeUserAsync() {
        backendless.userService.describeUserClass(
            { ( description : [UserProperty]!) -> () in
                print("Properties: \(description)")
            },
            error: { ( fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
        })
    }
    
}
