//
//  Place.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 21/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class Place: NSObject {
    
    var objectId: String!
    var name: String = ""
    var desc: String = ""
    var owner: BackendlessUser?
    var location: GeoPoint?
    var urlImage: String!
    var images: [PlaceImage] = []
    var reviews: [Rating] = []
    var rating: Double = 0.0
    
    
    
    
    
    
}