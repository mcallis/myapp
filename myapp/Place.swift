//
//  Place.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 21/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class Place: NSObject {
    
    var objectId: String?
    var created: NSDate?
    var updated: NSDate?
    var counter: Int = 0
    var isPublished: Bool = true
    var name: String = ""
    var desc: String = ""
    var images: NSArray!
    var location = PlaceLocation()
    
    
    
    
    
    
}