//
//  PlaceLocationHelper.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class PlaceLocationHelper {
    
    let mConnectionApi = ConnectionApi.sharedInstance
    
    init(){}
    
    func save(newPlaceLocation: PlaceLocation, response:(result: PlaceLocation) -> Void, _error:(error: Fault!) -> Void){
        mConnectionApi.save(
            PlaceLocation.ofClass(),
            object: newPlaceLocation,
            response: { (result) in
                let obj = result as! PlaceLocation
                print("Place has been saved: \(obj.objectId)")
                response(result: obj)
        }) { (fault) in
            print("Server reported an error: \(fault)")
            _error(error: fault)
        }
    }
    
    
    func update(placeLocation: PlaceLocation, response:(result: PlaceLocation) -> Void, _error:(error: Fault!) -> Void) {
        mConnectionApi.update(
            PlaceLocation.ofClass(),
            object: placeLocation,
            response: { (result) in
                let updatedPlaceLocation = result as! PlaceLocation
                print("PlaceLocation has been updated: \(updatedPlaceLocation.objectId)")
                response(result: updatedPlaceLocation)
        }) { (fault) in
            _error(error: fault)
            print("Server reported an error: \(fault)")
        }
    }
    
    
    func delete(placeLocation: PlaceLocation, response:(result: AnyObject) -> Void, _error:(error: Fault!) -> Void)  {
        mConnectionApi.delete(
            PlaceLocation.ofClass(),
            object: placeLocation,
            response: { (result) in
                print("PlaceLocation has been deleted: \(result)")
                response(result: result)
        }) { (fault) in
            _error(error: fault)
            print("Server reported an error: \(fault)")
        }
    }
    
    
    func findAllElements(response:(result: NSArray!) -> Void, _error:(error: Fault!) -> Void){
        mConnectionApi.findAllElements(
            PlaceLocation.ofClass(),
            response: { (result) in
                let placeLocations = result.getCurrentPage()
                response(result: placeLocations)
                for obj in placeLocations {
                    print("\(obj)")
                }
        }) { (fault) in
            _error(error: fault)
            print("Server reported an error: \(fault)")
        }
    }
    
    func findOne(objectID: String!, response:(result: PlaceLocation) -> Void, _error:(error: Fault!) -> Void){
        mConnectionApi.findObjectById(
            PlaceLocation.ofClass(),
            objectID: objectID,
            response: { (result) in
                let obj = result as! PlaceLocation
                print("Contact has been found: \(obj.objectId)")
                response(result: obj)
        }) { (fault) in
            _error(error: fault)
            print("Server reported an error: \(fault)")
        }
    }

}