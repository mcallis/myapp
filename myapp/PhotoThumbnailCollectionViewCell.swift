//
//  PhotoThumbnailCollectionViewCell.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 23/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class PhotoThumbnailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    func setThumbnailImage(thumbnailImage: UIImage){
        self.imgView.image = thumbnailImage
    }
}
