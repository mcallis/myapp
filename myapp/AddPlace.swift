//
//  AddPlace.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class AddPlace: UITableViewControllerOwn, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let mPlaceManager = PlaceManager()
    var mLocation: CLLocation!
    var mImage: UIImage!
    
    @IBOutlet weak var fieldName: UITextFieldOwn!
    @IBOutlet weak var fieldDescription: UITextView!
    @IBOutlet weak var fieldLongitude: UITextField!
    @IBOutlet weak var fieldLatitude: UITextField!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        self.navigationItem.rightBarButtonItem = btnSave
        self.navigationItem.title = Constants.TitlesViews.addPlace
        
        // Add border to textview
        fieldDescription!.layer.borderWidth = 0.5
        fieldDescription!.layer.cornerRadius = 5
        fieldDescription!.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.3).CGColor
    
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        // Save place
        savePlace()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case fieldName:
            fieldDescription.becomeFirstResponder()
            
        case fieldDescription:
            fieldLongitude.becomeFirstResponder()
            
        case fieldLongitude:
            fieldLatitude.becomeFirstResponder()
            
        default:
            textField.resignFirstResponder()
        }
        return true
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
        
        if mImage == nil {
           errors.append(Constants.ErrorMessage.imageRequired)
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
            place.location.longitude = Double(longPlace!)!
            place.location.latitude = Double(latPlace!)!
            
            startIndicator()
            // Get url image
            let imageName = "image_" + place.name
            mPlaceManager.uploadImage(mImage, imageName: imageName, response: { (file) in
                place.urlImage = file.fileURL
                // Save place
                self.uploadPlace(place)
                
                }, _error: { (error) in
                    self.stopIndicator()
                    self.alertError(error.message)
            })
        }
    }
    
    func uploadPlace(place: Place){
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
    
    @IBAction func takePhoto(sender: AnyObject) {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func selectPhoto(sender: AnyObject) {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        self.imageView.image = chosenImage
        self.mImage = chosenImage
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func returnFromAddLocation(segue: UIStoryboardSegue) {
        mLocation = AppManager.sharedInstance.getPlaceLocation()
        if mLocation != nil {
            fieldLatitude.text = "\(mLocation.coordinate.latitude)"
            fieldLongitude.text = "\(mLocation.coordinate.longitude)"
        }

    }
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
 
}