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
        self.backendless.initApp(ConnectionApi.APP_ID, secret:ConnectionApi.SECRET_KEY, version:ConnectionApi.VERSION_NUM)
    }
    
    // USER REGISTRATION

    
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
    
    
    
    // OBJECT MANAGE

    func getMyPlacesDataStore(_entity: AnyClass) -> AnyObject!{
        return backendless.data.of(_entity)
    }
    
    func save(_entity: AnyClass, object: AnyObject, response:(result: AnyObject) -> Void, _error:(fault: Fault!) -> Void){
        let dataStore = getMyPlacesDataStore(_entity)
        
        // save object asynchronously
        dataStore.save(
            object,
            response: { (result: AnyObject!) -> Void in
                response(result: result)
            },
            error: { (fault: Fault!) -> Void in
                _error(fault: fault)
                print("Server reported an error: \(fault) on Save method")
        })
    }
    
    func update(_entity: AnyClass, object: AnyObject, response:(result: AnyObject) -> Void, _error:(fault: Fault!) -> Void){
        let dataStore = getMyPlacesDataStore(_entity)
        
        // update object asynchronously
        dataStore.save(
            object,
            response: { (result: AnyObject!) -> Void in
                response(result: result)
            },
            error: { (fault: Fault!) -> Void in
                _error(fault: fault)
                print("Server reported an error: \(fault) on Update method")
        })
    }
    
    func delete(_entity: AnyClass, object: AnyObject, response:(result: AnyObject) -> Void, _error:(fault: Fault!) -> Void){
        let dataStore = getMyPlacesDataStore(_entity)
        
        // now delete the saved object
        dataStore.remove(
            object,
            response: { (result: AnyObject!) -> Void in
                response(result: result)
            },
            error: { (fault: Fault!) -> Void in
                _error(fault: fault)
                print("Server reported an error: \(fault) on Delete method")
        })
    }
    
    func describeSchema(_entity: AnyClass, object: AnyObject, _entityString: String){
        let dataStore = getMyPlacesDataStore(_entity)

        // save object asynchronously
        dataStore.save(
            object,
            response: { (result: AnyObject!) -> Void in
                //et savedPerson = result as! Person
                print("Entity has been saved: \(result)")
                
                // now delete the saved object
                self.backendless.data.describe(
                    _entityString,
                    response: { (props: [ObjectProperty]!) -> Void in
                        for prop in props {
                            print("Property: \(prop)")
                        }
                    },
                    error: { (fault: Fault!) -> Void in
                        print("Server reported an error (2): \(fault) on describeSchema method")
                })
                
            },
            error: { (fault: Fault!) -> Void in
                print("Server reported an error (1): \(fault) on describeSchema method")
        })
    }
    
    func findAllElements(_entity: AnyClass, response:(result: BackendlessCollection!) -> Void, _error:(error: Fault!) -> Void){
        let dataStore = getMyPlacesDataStore(_entity)
        
        dataStore.find(
            { (result: BackendlessCollection!) -> Void in
                response(result: result)
            },
            error: { (fault: Fault!) -> Void in
                _error(error: fault)
                print("Server reported an error: \(fault) on findAllElements method")
        })
    }
    
    func findObjectById(_entity: AnyClass, objectID: String!, response:(result: AnyObject!) -> Void, _error:(error: Fault!) -> Void){
        let dataStore = getMyPlacesDataStore(_entity)
        
        dataStore.findID(
            objectID,
            response: { (result: AnyObject!) -> Void in
                response(result: result)
                //
            },
            error: { (fault: Fault!) -> Void in
                print("Server reported an error: \(fault) on findObjectById method")
        })
    }
    
}
