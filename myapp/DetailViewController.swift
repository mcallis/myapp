//
//  DetailViewController.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 23/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fieldName: UILabel!
    @IBOutlet weak var fieldDescription: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    var currentPlace: Place!
    var mPlaceManager: PlaceManager = PlaceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fixedWidth = fieldDescription.frame.size.width
        fieldDescription.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = fieldDescription.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = fieldDescription.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        fieldDescription.frame = newFrame;

        
        // get data
        mPlaceManager.findOne(
            currentPlace.objectId,
            response: { (result) in
                self.currentPlace = result
                self.fillFields()
            }) { (error) in
                self.alertError(error.description)
        }
    
    }
    
    func fillFields(){
        downloadImage(NSURL(string: currentPlace.urlImage)!, imageView: imageView)
        fieldName.text = currentPlace.name
        fieldDescription.text = currentPlace.desc
        loadMap()
    }
    
    func loadMap() {
        let longitude = currentPlace.location.longitude
        let latitude = currentPlace.location.latitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        centerMapOnLocation(location)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        self.mapView.showsUserLocation = true
        self.mapView.removeAnnotations(mapView.annotations)
        
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

    
    
    
    // LOAD IMAGES
    func downloadImage(url: NSURL, imageView: UIImageView!){
        print("Download Started")
        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print(response?.suggestedFilename ?? "")
                print("Download Finished")
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    

    
    
    // DELETE PLACE
    
    @IBAction func deletePlace(sender: AnyObject) {
        if currentPlace != nil {
            let alertController = UIAlertController(title: "Are you sure?", message: "Do you want remove this place?", preferredStyle: .Alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                NSLog("OK Pressed")
                self.delete()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
                alertController.dismissViewControllerAnimated(true, completion: nil)
            }
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func delete(){
        mPlaceManager.delete(currentPlace, response: { (result) in
            let alertController = UIAlertOwn(title: "Info", message: "Place deleted!", preferredStyle: .Alert)
            // Create the actions
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                NSLog("OK Pressed")
                self.navigationController?.popViewControllerAnimated(true)
            }

            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
           
            }) { (error) in
                let alertController = UIAlertOwn(title: "Error", message: error.description, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
        }

    }
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
