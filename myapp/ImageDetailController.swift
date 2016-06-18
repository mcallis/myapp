//
//  ImageDetailViewController.swift
//  MyPlaces
//
//  Created by Xavier Pereta on 02/06/16.
//  Copyright © 2016 Xavier Pereta. All rights reserved.
//

import UIKit


protocol ImageManagerDelegate {
    func deleteImage(index: Int)
}

class ImageDetailViewController: UIViewController {
    var delegate: ImageManagerDelegate?
    
    // Este es el modelo de datos que editaremos en este controller
    var image: PlaceImageWithData?
    var imageIndex: Int?
    
    // Outlet para acceder a la imagen que mostraremos
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let uiImage = image?.uiImage {
            // Si ya tenemos la imagen completa descargada la configuramos directamente en el UIImageView
            imageView.image = uiImage
        } else {
            // Si no la tenemos la descargamos usando SDWebImage
            if let imageUrl = image!.image?.url {
                let url = NSURL(string: imageUrl)
                
                // Configuramos un indicador de actividad para que se muestre mientras se carga la imagen
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = .WhiteLarge
                activityIndicator.color = UIColor.blackColor()
                self.view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                
                imageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"), completed: { (image: UIImage!, error: NSError!, cache: SDImageCacheType, url: NSURL!) in
                    // Al terminar la descarga de la imagen quitamos el indicador de actividad
                    activityIndicator.removeFromSuperview()
                })
            }
        }
    }

    /**
        Acción del botón eliminar imagen
        Utiliza el delegado para actualizar los datos, en este caso eliminar la imagen
    */
    @IBAction func actionDeleteImage(sender: AnyObject) {
        let alertController = UIAlertController(title: "Delete this image", message: "Deleted images will be gone forever", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.delegate?.deleteImage(self.imageIndex!)
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(okAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
