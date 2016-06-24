//
//  MapManager.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import UIKit

protocol EditLocationDelegate {
    func newLocation(location: CLLocation)
}


class Map: UIViewControllerOwn, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var delegate: EditLocationDelegate?
    
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // Este es el modelo de datos que editaremos en este controller
    var placeLocation: CLLocation?
    
    let locationManager = CLLocationManager()
    var isUpdatingLocation: Bool = false
    var lastLocationError: NSError?
    var location: CLLocation?
    let regionRadius: CLLocationDistance = 500
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = btnSave
        self.navigationItem.title = Constants.TitlesViews.addLocation
        
        if placeLocation != nil {
            // Si tenemos una ubicación configuramos el mapa
            setupMap()
        } else {
            searchCurrentLocation()
        }
        
        
        
    }
    
    
    @IBAction func saveLocation(sender: AnyObject) {
        if let placeLocation = placeLocation {
            delegate?.newLocation(placeLocation)
        }
        self.navigationController?.popViewControllerAnimated(true)
        
        /*
        let appManager = AppManager.sharedInstance
        appManager.setPlaceLocation(location!)
        self.performSegueWithIdentifier(Constants.Segues.returnFromAddLocation, sender: self)
        */
        //self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
    // MARK: - Map management, MKMapViewDelegate
    /**
     Configura el MapView centrándolo añadiendo un pin en la posición actual del sitio
     */
    func setupMap() {
        if let placeLocation = placeLocation {
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: placeLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            mapView.delegate = self
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = placeLocation.coordinate
            annotation.title = "Place"
            
            mapView.addAnnotation(annotation)
        }
    }
    
    /**
     Configura el aspecto y la funcionalidad de cada annotation.
     En este caso solamente tendremo una y la configuramos como un pin rojo
     que puede ser reposicionado por el usuario
     */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            let reuseId = "pin"
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.canShowCallout = true
            pinView.animatesDrop = true
            pinView.draggable = true
            pinView.pinTintColor = UIColor.purpleColor()
            
            return pinView
        }
        
        return nil
    }

    
    /**
     Se llama cada vez que cambia el estado de reposicionamiento de una annotation
     La usamos para detectar cuando el usuario ha soltado el pin que marca la posición del sitio
     */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
    
        
        if oldState == .Dragging && newState == .Ending {
            if let coordinate = view.annotation?.coordinate {
                self.placeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        }

        if (newState == MKAnnotationViewDragState.Ending)
        {
            let droppedAt = view.annotation!.coordinate;
            setRegion(droppedAt)
        }

    }


    
    func setRegion(coordinate: CLLocationCoordinate2D){
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    @IBAction func addPinToTouch(sender: UILongPressGestureRecognizer) {
        
        let loc = sender.locationInView(self.mapView)
        
        let locCoord = self.mapView.convertPoint(loc, toCoordinateFromView: self.mapView)
        self.location = CLLocation(latitude: locCoord.latitude, longitude: locCoord.longitude)
        self.placeLocation = self.location
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)
    
    }
    
    
    
    
    
    
    
    // LOCATION METHODS
    
    /**
     Inicia la búsqueda de la posición del usuario.
     Si es necesario solicitará el permiso
     */
    func searchCurrentLocation() {
        // Pedimos autorización para usar la geolocalización si es necesario (a partir de iOS 7)
        if self.locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)) {
            let authStatus = CLLocationManager.authorizationStatus()
            if authStatus == .NotDetermined {
                locationManager.requestWhenInUseAuthorization()
                
                return
            }
            if authStatus == .Denied || authStatus == .Restricted {
                let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(okAction)
                presentViewController(alert, animated: true, completion: nil)
                
                return
            }
            
        }
        location = nil
        startLocationManager()
    }

    
    
    /**
     Inicia el proceso de obtención de la posición del usuario
     */
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
        }
        startIndicator()
    }
    
    /**
     Para el proceso de obtención de la posición del usuario
     */
    func stopLocationManager() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            isUpdatingLocation = false
        }
        stopIndicator()
    }


    
    /**
     Se llama cada vez que se obtiene la posición del usuario.
     Si todo va bien cada vez nos dará posiciones con más precisión, y cuando obtengamos la
     precisión deseada pararemos el proceso y configuraremos el mapa
     */
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
            stopLocationManager()
            if let location = location {
                placeLocation = location
                setupMap()
            }
/*
            // TODO: show centered map
            let initialLocation = location
            centerMapOnLocation(initialLocation!)
            stopLocationManager()
 */
        }
    }
    
    
    /**
     Se llama si se produce un error al obtener la posición del usuario
     */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        if error.code == CLError.LocationUnknown.rawValue {
            // Este error se produce si el sistema no ha sido capaz de dar con la ubicación del usuario.
            // Pero va a seguir intentándolo, de momento no pararemos el proceso
            return
        }
        // Si se ha producido algún otro error entonces sí que paramos el proceso e informamos al
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