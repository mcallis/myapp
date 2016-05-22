//
//  PlaceManager.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class PlaceManager {
    
    let mConnectionApi = ConnectionApi.sharedInstance
    
    init(){}
    
    func save(newPlace: Place, response:(result: Place) -> Void, _error:(error: Fault!) -> Void){
        mConnectionApi.save(
            Place.ofClass(),
            object: newPlace,
            response: { (result) in
                let obj = result as! Place
                print("Place has been saved: \(obj.objectId)")
                response(result: obj)
            }) { (fault) in
                print("Server reported an error: \(fault)")
                _error(error: fault)
        }
    }
    
    
    func update(place: Place, response:(result: Place) -> Void, _error:(error: Fault!) -> Void) {
        mConnectionApi.update(
            Place.ofClass(),
            object: place,
            response: { (result) in
                let updatedPlace = result as! Place
                print("Place has been updated: \(updatedPlace.objectId)")
                response(result: updatedPlace)
            }) { (fault) in
                _error(error: fault)
                print("Server reported an error: \(fault)")
        }
    }
    
    
    func delete(place: Place, response:(result: AnyObject) -> Void, _error:(error: Fault!) -> Void)  {
        mConnectionApi.delete(
            Place.ofClass(),
            object: place,
            response: { (result) in
                print("Place has been deleted: \(result)")
                response(result: result)
            }) { (fault) in
                _error(error: fault)
                print("Server reported an error: \(fault)")
        }
    }
    
    
    func findAllElements(response:(result: NSArray!) -> Void, _error:(error: Fault!) -> Void){
        mConnectionApi.findAllElements(
            Place.ofClass(),
            response: { (result) in
                let places = result.getCurrentPage()
                response(result: places)
                for obj in places {
                    print("\(obj)")
                }
            }) { (fault) in
                _error(error: fault)
                print("Server reported an error: \(fault)")
        }
    }
    
    func findOne(objectID: String!, response:(result: Place) -> Void, _error:(error: Fault!) -> Void){
        mConnectionApi.findObjectById(
            Place.ofClass(),
            objectID: objectID,
            response: { (result) in
                let obj = result as! Place
                print("Contact has been found: \(obj.objectId)")
                response(result: obj)
            }) { (fault) in
                _error(error: fault)
                print("Server reported an error: \(fault)")
        }
    }
    
}