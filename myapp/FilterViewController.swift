//
//  FilterViewController.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 20/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

protocol FilterManagerDelegate {
    func calculateWithNewDistance(distance: Int)
}

class FilterViewController: UIViewController {
    
    var delegate: FilterManagerDelegate?

    @IBOutlet weak var fieldDistance: UILabel!
    @IBOutlet weak var slideBar: UISlider!
    
    var distance: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (distance != nil) {
            self.slideBar.value = Float(distance)
        } else {
            self.slideBar.value = 0
        }
        self.fieldDistance.text = String(format: "%i Km", Int(self.slideBar.value))
     
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        self.fieldDistance.text = String(format: "%i Km", Int(sender.value))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.delegate?.calculateWithNewDistance(Int(self.slideBar.value))
        print("viewWillDesappear")
    }
}
