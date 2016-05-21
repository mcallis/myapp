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

    func getMyPlacesDataStore(_entity: AnyObject) -> AnyObject!{
        return backendless.data.of(_entity.ofClass())
    }
    
    func save(_entity: AnyObject, object: AnyObject, response:(result: AnyObject) -> Void, _error:(error: Fault!) -> Void){
        let dataStore = getMyPlacesDataStore(_entity)
        
        // save object asynchronously
        dataStore.save(
            object,
            response: { (result: AnyObject!) -> Void in
                //let obj = result
                response(result: result)
                //print("Place has been saved: \(obj.objectId)")
            },
            error: { (fault: Fault!) -> Void in
                _error(error: fault)
                //print("fServer reported an error: \(fault)")
        })
    }
    
    func update(_entity: AnyObject, object: AnyObject, response:(result: AnyObject) -> Void, _error:(error: Fault!) -> Void){
        let dataStore = getMyPlacesDataStore(_entity)
        
        // update object asynchronously
        dataStore.save(
            object,
            response: { (result: AnyObject!) -> Void in
               // let updatedPlace = result as! Place
                response(result: result)
                //print("Place has been updated: \(updatedPlace.objectId)")
            },
            error: { (fault: Fault!) -> Void in
                _error(error: fault)
                //print("Server reported an error (2): \(fault)")
        })
    }
    
    func delete(_entity: AnyObject, object: AnyObject, response:(result: AnyObject) -> Void, _error:(error: Fault!) -> Void){
        let dataStore = getMyPlacesDataStore(_entity)
        
        // now delete the saved object
        dataStore.remove(
            object,
            response: { (result: AnyObject!) -> Void in
                response(result: result)
                print("Place has been deleted: \(result)")
            },
            error: { (fault: Fault!) -> Void in
                _error(error: fault)
                print("Server reported an error: \(fault)")
        })
    }
    
    func describeSchema(_entity: AnyObject, object: AnyObject, _entityString: String){
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
                        print("Server reported an error (2): \(fault)")
                })
                
            },
            error: { (fault: Fault!) -> Void in
                print("Server reported an error (1): \(fault)")
        })
    }
    
    func findAllElements(_entity: AnyObject, response:(result: BackendlessCollection!) -> Void, _error:(error: Fault!) -> Void){
        let dataStore = getMyPlacesDataStore(_entity)
        
        dataStore.find(
            { (result: BackendlessCollection!) -> Void in
                response(result: result)
                /*let contacts = result.getCurrentPage()
                for obj in contacts {
                    print("\(obj)")
                }*/
            },
            error: { (fault: Fault!) -> Void in
                _error(error: fault)
                print("Server reported an error: \(fault)")
        })
    }
    
    func findObjectById(_entity: AnyObject, objectID: String!, response:(result: AnyObject!) -> Void, _error:(error: Fault!) -> Void){
        let dataStore = getMyPlacesDataStore(_entity)
        
        dataStore.findID(
            objectID,
            response: { (result: AnyObject!) -> Void in
                response(result: result)
                //print("Contact has been found: \(foundContact.objectId)")
            },
            error: { (fault: Fault!) -> Void in
                print("Server reported an error: \(fault)")
        })
    }
    
}
