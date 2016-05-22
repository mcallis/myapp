//
//  MapManager.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation


class Map: UIViewControllerOwn, CLLocationManagerDelegate, MKMapViewDelegate {
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let locationManager = CLLocationManager()
    var isUpdatingLocation = false
    var lastLocationError: NSError?
    var location: CLLocation?
    let regionRadius: CLLocationDistance = 1000
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
        mapView.delegate = self
    }
    
    
    @IBAction func saveLocation(sender: AnyObject) {
        self.performSegueWithIdentifier(Constants.Segues.returnFromAddLocation, sender: self)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let addPlaceVC: AddPlace = segue.destinationViewController as! AddPlace
        addPlaceVC.setPlaceLocation(location as! PlaceLocation)
    }
    
    
    func centerMapOnLocation(location: CLLocation) {        
        
        setRegion(location.coordinate)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
    }
    
    
    func setRegion(coordinate: CLLocationCoordinate2D){
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView?.draggable = true
            pinView!.pinTintColor = UIColor.purpleColor()
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if (newState == MKAnnotationViewDragState.Ending)
        {
            let droppedAt = annotationView.annotation!.coordinate;
            setRegion(droppedAt)
        }
    }
    
    
    
    // LOCATION METHODS
    
    func getLocation(){
        checkIfAuthStatusLocation()
    }
    
    func checkIfAuthStatusLocation(){
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .Denied || authStatus == .Restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.",
                                          preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        startLocationManager()
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
            startIndicator()
        }
    }
    
    
    func stopLocationManager() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            isUpdatingLocation = false
            stopIndicator()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
        }
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            print("Got the desired accuracy")
            NSLog("Location: \(location?.coordinate.longitude), \(location?.coordinate.latitude)")
            // TODO: show centered map
            let initialLocation = location
            centerMapOnLocation(initialLocation!)
            stopLocationManager()
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) { print("didFailWithError \(error)")
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        lastLocationError = error
        alertError(lastLocationError.debugDescription)
        stopLocationManager()
    }
    
    
    
    
    // UTILS
    
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
}