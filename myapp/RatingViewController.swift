//
//  RatingViewController.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 19/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class RatingViewController: UIViewControllerOwn, FloatRatingViewDelegate {

    @IBOutlet weak var rateView: FloatRatingView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var currentPlace: Place!
    var backendless = Backendless.sharedInstance()
    var currentUser: BackendlessUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentUser = backendless.userService.currentUser
        
        self.rateView.fullImage = UIImage(named: "fullstar")
        self.rateView.emptyImage = UIImage(named: "emptystar")
        initRating()
        
        self.rateView.editable = true
        self.rateView.maxRating = 5;
        self.rateView.delegate = self;
       
    }
    
    func initRating(){
        self.rateView.rating = 0
        for i in 0 ..< self.currentPlace.reviews.count {
            let review = self.currentPlace.reviews[i]
            if review.idUser == currentUser.objectId {
                self.rateView.rating = review.value
            }
        }
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating: Float) {
        self.statusLabel.text = String(format: "Rating: %f", rating)
    }
    
    
    @IBAction func actionSave(sender: AnyObject) {
        
        currentUser = backendless.userService.currentUser
        let rating = Rating()
        rating.value = self.rateView.rating
        rating.idUser = currentUser.objectId
        
        updatePlaceBackend(rating)
    }
    
    /**
     Actualiza un sitio en el backend
     */
    func updatePlaceBackend(rating: Rating) {
        
        let backendless = Backendless.sharedInstance()
        
        let dataStore = backendless.data.of(Place.ofClass())
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        startIndicator()
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            var found: Bool = false
            
            for i in 0 ..< self.currentPlace.reviews.count {
                let item = self.currentPlace.reviews[i]
                if item.idUser == rating.idUser {
                    found = true
                    item.value = rating.value
                }
            }
            
            if !found {
                self.currentPlace.reviews.append(rating)
            }
            
            var sum: Float = 0.0
            for review in self.currentPlace.reviews{
                sum = sum + review.value
            }
            let myIntValue = Int(sum)
            self.currentPlace.rating = Double(myIntValue) / Double(self.currentPlace.reviews.count)
            
            
            
            Types.tryblock({
                
                dataStore.save(self.currentPlace)
                
                
                }, catchblock: { (exception)->Void in
                    
            })

            
            dispatch_async(dispatch_get_main_queue()) {
                found = false
                self.stopIndicator()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.performSegueWithIdentifier("returnFromRatingView", sender: self)
                
            }
        }

    }

}
