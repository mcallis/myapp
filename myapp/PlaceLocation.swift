//
//  PlaceLocation.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class PlaceLocation: NSObject {
    
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    
    init(longitude: Double, latitude: Double){
        self.longitude = longitude
        self.latitude = longitude
    }
}