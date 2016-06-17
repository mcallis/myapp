//
//  Place.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 21/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class Place: NSObject {
    
    var name: String = ""
    var desc: String = ""
    var owner: BackendlessUser?
    var location: PlaceLocation?
    var urlImage: String!
    var images: [PlaceImage] = []
    
    
    
    
    
    
}