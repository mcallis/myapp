//
//  PlaceAnnotation.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    let idPlace: String
    let title: String?
    let locationName: String
 //   let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(idPlace: String, title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.idPlace = idPlace
        self.title = title
        self.locationName = locationName
        //self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}