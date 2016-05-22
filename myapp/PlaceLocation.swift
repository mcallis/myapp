//
//  PlaceLocation.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class PlaceLocation: NSObject {
    
    var objectId: String?
    var created: NSDate?
    var updated: NSDate?
    var counter: Int = 0
    var isPublished: Bool = true
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    
    override init(){}
    
    init(latitude: Double, longitude: Double){
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
}