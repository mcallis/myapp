//
//  VCMapView.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import AddressBook


extension MapViewController {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PlaceAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { 
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.init(type: .DetailDisclosure)
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        var selectedPlace: Place!
        for place in listPlaces {
            if place.name == ((view.annotation?.title)!)! {
                selectedPlace = place
            }
        }
        self.performSegueWithIdentifier("segueToDetailPlace", sender: selectedPlace)
    }
}
