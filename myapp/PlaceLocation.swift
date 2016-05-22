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
    var longitude: String = ""
    var latitude: String = ""
}