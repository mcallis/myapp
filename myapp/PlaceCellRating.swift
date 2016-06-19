//
//  PlaceCellRating.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 20/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class PlaceCellRating: UITableViewCell {

    @IBOutlet weak var customImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var rateView: FloatRatingView!
    @IBOutlet weak var fieldTotalReviews: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set rateview
        self.rateView.fullImage = UIImage(named: "fullstar")
        self.rateView.emptyImage = UIImage(named: "emptystar")
        self.rateView.editable = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
    }
    
    func setRating(value: Double) -> Void {
        let myIntValue = Int(value)
        self.rateView.rating = Float(myIntValue)
    }
    
    
}
