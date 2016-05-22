//
//  MapManager.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation


class Map: UIViewControllerOwn, CLLocationManagerDelegate {
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let locationManager = CLLocationManager()
    var isUpdatingLocation = false
    var lastLocationError: NSError?
    var location: CLLocation?
    var mLongitude: Double?
    var mLatitude: Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfAuthStatusLocation()
    }
    
    
    @IBAction func saveLocation(sender: AnyObject) {
        if mLongitude != nil && mLatitude != nil {
            self.performSegueWithIdentifier(Constants.Segues.returnFromAddLocation, sender: self)

        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let location: PlaceLocation = PlaceLocation(longitude: self.mLongitude!, latitude: self.mLatitude!)
    
        let addPlaceVC: AddPlace = segue.destinationViewController as! AddPlace
        addPlaceVC.setPlaceLocation(location)
    }

    
    
    
    // LOCATION METHODS
    
    func checkIfAuthStatusLocation(){
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return }
        if authStatus == .Denied || authStatus == .Restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this appin Settings.",
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
    
    
    func stopLocationManager() { if isUpdatingLocation {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        isUpdatingLocation = false
        stopIndicator()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){ let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation }
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            print("Got the desired accuracy")
            // TODO: set location
            mLongitude = newLocation.coordinate.longitude
            mLatitude = newLocation.coordinate.latitude
            // TODO: show centered map
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
    
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
}