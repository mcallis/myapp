//
//  DetailViewController.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 23/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit
import SDWebImage

class DetailViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var fieldName: UILabel!
    @IBOutlet weak var fieldDescription: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imagesCollection: UICollectionView!
    
    var currentPlace: Place!
    
    
    // Imagenes del sitio utilizando el tipo que PlaceImageWithData, que permite almacenar las UIImage
    var placeImages: [PlaceImageWithData] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuramos el delegado y el data source de la colección de imágenes
        imagesCollection.delegate = self
        imagesCollection.dataSource = self
        
        // Y finalmente inicializamos las imágenes que utilizaremos para alimentar la colección de imágenes del sitio
        for image in currentPlace!.images {
            let newPlaceImageWithData = PlaceImageWithData(image: image)
            placeImages.append(newPlaceImageWithData)
        }

        fieldName.text = currentPlace.name
        fieldDescription.text = currentPlace.desc

        setupMapView()
        /*
        let fixedWidth = fieldDescription.frame.size.width
        fieldDescription.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = fieldDescription.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = fieldDescription.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        fieldDescription.frame = newFrame;
         */

    }
    
    /**
     Lanzada por la colección de imágenes cuando necesita saber cuántas debe mostar
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeImages.count
    }
    
    /**
     Lanzada por la colección de imágenes para que le configuremos cada una de las celdas.
     En nuestro caso cada objeto PlaceImageWithData contiene la imagen completa y una versión thumbnail (reducida).
     En la celda configuraremos la versión thumbnail
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! PlaceImageCell
        
        let placeImage = placeImages[indexPath.row]
        
        if let image = placeImage.uiImageThumbnail {
            // Si ya tenemos el fichero de imagen lo configuramos en la celda
            cell.imageView.image = image
        } else {
            // No lo tenemos, tenemos que consultarlo al servidor.
            let imageUrl = placeImage.image?.thumbUrl
            let url = NSURL(string: imageUrl!)
            
            // Configuramos un indicador de actividad para que se muestre mientras se carga la imagen
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.center = cell.imageView.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.color = UIColor.blackColor()
            cell.imageView.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            // Utilizamos SDWebImage para descargar la imagen en segundo plano directamente sobre el UIImageView de la celda
            cell.imageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"), completed: { (image: UIImage!, error: NSError!, cache: SDImageCacheType, url: NSURL!) in
                // Al terminar la carga también actualizaremos el thumbnail del objecto PlaceImageWithData
                placeImage.uiImageThumbnail = image
                activityIndicator.removeFromSuperview()
            })
        }
        
        return cell
    }

    
    
    /**
     Si tenemos una posición para el sitio se configura un mapa con un pin centrado en su posición.
     Pero si no tenemos posición ocultaremos el mapa y mostraremos un botón para escoger la ubicación en una pantalla dedicada a ello.
     */
    func setupMapView() {
        if let place = currentPlace, placeLocation = place.location {
            mapView.hidden = false
            
            // Mostraremos un pin con la posición del sitio
            let coordinate = CLLocationCoordinate2D(latitude: placeLocation.latitude as CLLocationDegrees, longitude: placeLocation.longitude as CLLocationDegrees)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
            
            // Y centraremos el mapa
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
        } else {
            mapView.hidden = true
        }
    }

   
    
    
    
    
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
