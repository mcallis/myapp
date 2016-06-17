//
//  AddPlace.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 22/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit
import SDWebImage

/**
 Protocolo para gestionar los sitios
 */
protocol PlaceManagerDelegate {
    func createPlace(place: Place, placeImages: [PlaceImageWithData]) -> Bool
    func updatePlace(place: Place, placeImages: [PlaceImageWithData], deletedImages: [PlaceImageWithData]) -> Bool
}

enum Mode {
    case Create
    case Edit
}

class AddPlace: UITableViewControllerOwn, UITextFieldDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, ImageManagerDelegate, EditLocationDelegate {
    
    var delegate: PlaceManagerDelegate?
    
    var currentPlace: Place!
    
    // Imagenes del sitio utilizando el tipo que PlaceImageWithData, que permite almacenar las UIImage
    var placeImages: [PlaceImageWithData] = []
    
    // Array que contiene las imagenes que se han borrado durante la edición del sitio
    var deletedImages: [PlaceImageWithData] = []
    
    var mode: Mode = .Create
    
    // Controlador para la selección de la imagen
    var imagePicker = UIImagePickerController()
    
    // Reconocedor de pulsaciones para que el mapa actue como un botón
    var tapRecognizerMap = UITapGestureRecognizer()
    
    // Reconocedor de pulsaciones para que ocultar el teclado
    var tapRecognizerKeyboard = UITapGestureRecognizer()
    
    // Indicador de actividad
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let mPlaceManager = PlaceManager()
    var mLocation: CLLocation!
    
    

    
    @IBOutlet weak var fieldName: UITextFieldOwn!
    @IBOutlet weak var fieldDescription: UITextView!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var imagesCollection: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnMap: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        self.navigationItem.rightBarButtonItem = btnSave
        self.navigationItem.title = Constants.TitlesViews.addPlace
        
        // Inicializamos el TapGestureRecognizer para detectar la pulsación sobre el MapView
        tapRecognizerMap.addTarget(self, action: #selector(AddPlace.mapViewTapped))
        mapView.addGestureRecognizer(tapRecognizerMap)
        
        // Inicializamos el TapGestureRecognizer para detectar la pulsación sobre la vista principal
        tapRecognizerKeyboard.addTarget(self, action: #selector(AddPlace.viewTapped))
        tapRecognizerKeyboard.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizerKeyboard)
        
        // Add border to textview
        // Configuramos el aspecto del textview de descripción
        fieldDescription.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        fieldDescription!.layer.borderWidth = 1.0
        fieldDescription!.layer.cornerRadius = 5
        
        // Si tenemos configurado un sitio para editar inicializamos los controles de la pantalla
        if let currentPlace = currentPlace {
            fieldName.text = currentPlace.name
            fieldDescription.text = currentPlace.desc
            mode = .Edit
        } else {
            currentPlace = Place()
            mode = .Create
        }
        
        // Configuramos el delegado y el data source de la colección de imágenes
        imagesCollection.delegate = self
        imagesCollection.dataSource = self

        // Y finalmente inicializamos las imágenes que utilizaremos para alimentar la colección de imágenes del sitio
        for image in currentPlace!.images {
            let newPlaceImageWithData = PlaceImageWithData(image: image)
            placeImages.append(newPlaceImageWithData)
        }

    
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        // Save place
        savePlace()
    }
    
    /**
     Gestiona el siguiente campo que debe activarse al pulsar el botón Next en el campo de texto
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == fieldName {
            fieldDescription.becomeFirstResponder()
        }
        
        return true
    }

    
    func savePlace(){
        let namePlace = fieldName.text
        let descPlace = fieldDescription.text
        
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
        
        
        let numErrors = errors.count
        if numErrors > 0 {
            // Show Alert
            let errorMessage = errors.joinWithSeparator(".\n")
            let alertController = UIAlertController(title: "Review the registration form", message: errorMessage, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.currentPlace!.name = namePlace!
            self.currentPlace!.desc = descPlace!
           
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            startIndicator()
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                if self.mode == .Create {
                    self.currentPlace!.name = namePlace!
                    self.currentPlace!.desc = descPlace!
                    
                    let result = self.delegate?.createPlace(self.currentPlace!, placeImages: self.placeImages)
                    
                    if result == false {
                        let alertController = UIAlertController(title: "Error", message: "There was an error creating your place", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                } else {
                    self.currentPlace!.name = namePlace!
                    self.currentPlace!.desc = descPlace!
                    
                    let result = self.delegate?.updatePlace(self.currentPlace!, placeImages: self.placeImages, deletedImages: self.deletedImages)
                    
                    if result == false {
                        let alertController = UIAlertController(title: "Error", message: "There was an error updating your place", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopIndicator()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.performSegueWithIdentifier(Constants.Segues.returnMyPlacesFromAddPlace, sender: self)
                    //self.performSegueWithIdentifier("returnMyPlacesFromAddPlace", sender: self)
                }
            }
            
        }
    }

    
    
    
    /**
     Se lanzará cuando el usuario pulse fuera de los campos de texto o botones de la vista.
     Finaliza la edición en curso y oculta el teclado
     */
    func viewTapped() {
        self.view.endEditing(true)
    }
    
    
    

   
    @IBAction func takePhoto(sender: AnyObject) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func selectPhoto(sender: AnyObject) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
    
    /**
     Se lanza cuando se ha obtenido una imagen, ya sea desde la galeria o capturada con la cámara
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Añadimos la nueva imagen a la colección de imagenes, este inicializador también nos creará el thumbnail
            let newPlaceImageWithData = PlaceImageWithData(uiImage: image)
            placeImages.append(newPlaceImageWithData)
            imagesCollection.reloadData()
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
     Lanzada por la colección de imágenes cuando se selecciona una de las celdas
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        self.performSegueWithIdentifier("segueToImageDetail", sender: cell)
    }
    
    
    // MARK: - Mapview
    
    /**
     Se lanzará cuando el usuario pulse en el mapa de localización del sitio.
     */
    func mapViewTapped() {
        performSegueWithIdentifier("segueToEditLocation", sender: self)
    }

    
    
    /**
     Si tenemos una posición para el sitio se configura un mapa con un pin centrado en su posición.
     Pero si no tenemos posición ocultaremos el mapa y mostraremos un botón para escoger la ubicación en una pantalla dedicada a ello.
     */
    func setupMapView() {
        if let place = currentPlace, placeLocation = place.location {
            mapView.hidden = false
            btnMap.hidden = true
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
            btnMap.hidden = false
        }
    }

    
    
    
    // MARK: - Navigation
    
    /**
     Prepara los datos y los delegados para los controladores a los que enlaza éste
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToImageDetail" {
            if let cell = sender as? UICollectionViewCell, indexPath = imagesCollection.indexPathForCell(cell), imageDetailController  = segue.destinationViewController as? ImageDetailViewController {
                imageDetailController.delegate = self
                let selectedImage = placeImages[indexPath.row]
                imageDetailController.image = selectedImage
                imageDetailController.imageIndex = indexPath.row
            }
        } else if segue.identifier == "segueToEditLocation" {
            if let editLocationController = segue.destinationViewController as? Map {
                editLocationController.delegate = self
                if let placeLocation = currentPlace!.location {
                    let location = CLLocation(latitude: placeLocation.latitude as CLLocationDegrees, longitude: placeLocation.longitude as CLLocationDegrees)
                    editLocationController.placeLocation = location
                }
            }

        }
    }

    // MARK: - ImageManagerDelegate
    
    /**
     Única función del protocolo ImageManagerDelegate.
     Permite eliminar una imagen, para simplificar eliminaremos la imagen por índice, por lo que
     en el controlador que llame a esta función debemos pasarle el índice de la imagen que está editando
     */
    func deleteImage(index: Int) {
        let deletedImage = placeImages[index]
        deletedImages.append(deletedImage)
        
        placeImages.removeAtIndex(index)
        
        imagesCollection.reloadData()
    }
    
    
    // MARK: - EditLocationDelegate
    
    /**
     Única función del protocolo ImageManagerDelegate.
     Permite establecer una nueva ubicación para el sitio
     */
    func newLocation(location: CLLocation) {
        currentPlace!.location = GeoPoint.geoPoint(GEO_POINT(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)) as? GeoPoint
        setupMapView()
    }


    

 
}