//
//  AddPlace.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class AddPlace: UITableViewControllerOwn {
    
    let mPlaceManager = PlaceManager()
    var location: PlaceLocation!
    
    @IBOutlet weak var fieldName: UITextFieldOwn!
    @IBOutlet weak var fieldDescription: UITextView!
    @IBOutlet weak var fieldLongitude: UITextField!
    @IBOutlet weak var fieldLatitude: UITextField!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = btnSave
        self.navigationItem.title = Constants.TitlesViews.addPlace
        
        
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        // Save place
        savePlace()
    }
    
    func savePlace(){
        let namePlace = fieldName.text
        let descPlace = fieldDescription.text
        let longPlace = fieldLongitude.text
        let latPlace  = fieldLatitude.text
        
        var errors = [String]()
        
        let colorOK = UIColor.whiteColor()
        let colorError = UIColor.redColor().colorWithAlphaComponent(0.15)

        if namePlace == "" {
            fieldName.backgroundColor = colorError
            errors.append(Constants.ErrorMessage.namePlaceRequired)
        } else {
            fieldName.backgroundColor = colorOK
        }
        
        if descPlace == "" {
            fieldDescription.backgroundColor = colorError
            errors.append(Constants.ErrorMessage.descPlaceRequired)
        } else {
            fieldDescription.backgroundColor = colorOK
        }
        
        if longPlace == "" {
            fieldLongitude.backgroundColor = colorError
            errors.append(Constants.ErrorMessage.longPlaceRequired)
        } else {
            fieldLongitude.backgroundColor = colorOK
        }
        
        if latPlace == "" {
            fieldLatitude.backgroundColor = colorError
            errors.append(Constants.ErrorMessage.latPlaceRequired)
        } else {
            fieldLatitude.backgroundColor = colorOK
        }
        
        let numErrors = errors.count
        if numErrors > 0 {
            // Show Alert
            let errorMessage = errors.joinWithSeparator(".\n")
            let alertController = UIAlertController(title: "Review the registration form", message: errorMessage, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            let place = Place()
            place.name = namePlace!
            place.desc = descPlace!
            place.longitude = longPlace!
            place.latitude = latPlace!
            
            startIndicator()
            mPlaceManager.save(
                place,
                response: { (result) in
                    self.stopIndicator()
                    self.performSegueWithIdentifier(Constants.Segues.returnMyPlacesFromAddPlace, sender: self)
                },
                _error: { (error) in
                    self.stopIndicator()
                    self.alertError(error.message)
            })
 
        }
    }
    
    
    func setPlaceLocation(location: PlaceLocation){
        self.location = location
    }
    
    
    @IBAction func returnFromAddLocation(segue: UIStoryboardSegue) {
        
    }
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
 
}