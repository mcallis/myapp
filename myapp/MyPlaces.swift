//
//  MyPlaces.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 21/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import ImageIO
import SDWebImage

class MyPlaces: UITableViewControllerOwn, PlaceManagerDelegate {
    
    let mAppManager = AppManager.sharedInstance
    let mPlaceManager = PlaceManager()

    // Datos que va a gestionar este controlador
    var listPlaces: [Place] = []

    // Instancia de backendless
    var backendless = Backendless.sharedInstance()
    // Tamaño de página para la consulta a Backendless
    let PAGESIZE = 5
    
    // Numero de consulta a Backendless, se utiliza para cancelar las peticiones asíncronas que estuvieran
    // pendientes cuando consulta de sitios
    var currentQueryNumber = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuramos el controll "Pull to refresh"
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(MyPlaces.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        // Configuramos el delegado y el dataSource de la table view
        tableView.delegate = self
        tableView.dataSource = self
    
        // Get All Places
        loadPlaces()
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.endRefreshing()
        
    }
    
    // MARK: - Refresh control
    func refresh(sender: AnyObject) {
        loadPlaces()
    }

    
    
    func loadPlaces(){
        // Durante todo el proceso de carga mostraremos el indicador de actividad de red en la aplicación
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        currentQueryNumber += 1
        let queryNumber = currentQueryNumber
        
        let startTime = NSDate()
        let offset = 0
        
        // Consultaremos los stios junto con sus relaciones images y location
        let query = BackendlessDataQuery()
        query.queryOptions.pageSize = PAGESIZE
        //query.whereClause = "owner.objectId = '\(currentUser.objectId)'"
        query.queryOptions.related = ["images", "location"]
        
        backendless.data.of(Place.ofClass()).find(
            query,
            response: { ( places : BackendlessCollection!) -> () in
                if queryNumber == self.currentQueryNumber {
                    print("Total places in the server: \(places.totalObjects)")
                    self.listPlaces = []
                    self.listPlaces.appendContentsOf(places.getCurrentPage() as! [Place])
                    self.tableView.reloadData()
                    self.getPageAsync(places, offset: offset, queryNumber: queryNumber, startTime:startTime)
                }
            },
            error: { (fault : Fault!) -> () in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if queryNumber == self.currentQueryNumber && self.listPlaces.count > 0 {
                    if self.listPlaces.count > 0{
                        let alertController = UIAlertController(title: "Error", message: "An error has ocurred while fetching your places", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
    
                }
            }
        )

    }
    
    
    
    
    /**
     Obtiene las siguientes páginas.
     Si el número de petición no se corresponde con el actual se cancela la operación.
     */
    func getPageAsync(places: BackendlessCollection, offset: Int, queryNumber: Int, startTime: NSDate) {
        if queryNumber != self.currentQueryNumber {
            return
        }
        
        let size = places.getCurrentPage().count
        if size == 0 {
            print("Total time (ms) - \(1000*NSDate().timeIntervalSinceDate(startTime))")
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
            
            refreshControl?.endRefreshing()
            
            // Una vez finalizado el proceso de carga ocultamos el indicador de actividad de red en la aplicación
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            return
        }
        
        print("Query: \(queryNumber), loaded \(size) places in the current page")
        
        let newOffset = offset + size
        places.getPage(
            newOffset,
            pageSize: PAGESIZE,
            response: { ( places : BackendlessCollection!) -> () in
                if queryNumber == self.currentQueryNumber {
                    self.listPlaces.appendContentsOf(places.getCurrentPage() as! [Place])
                    self.getPageAsync(places, offset:newOffset, queryNumber: queryNumber, startTime:startTime)
                    self.tableView.reloadData()
                }
            },
            error: { ( fault : Fault!) -> () in
                if queryNumber == self.currentQueryNumber {
                    let alertController = UIAlertController(title: "Error", message: "An error has ocurred while fetching your places", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        )
    }
    

    
    
    // TABLEVIEW METHODS

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listPlaces.count
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("segueToEditPlace", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToCreatePlace" {
            let destinationVC = segue.destinationViewController as! AddPlace
            
            destinationVC.delegate = self
        } else if (segue.identifier == "segueToEditPlace") {
            let controller = segue.destinationViewController as! AddPlace
            controller.delegate = self
            let indexPath = sender as! NSIndexPath
            controller.currentPlace = listPlaces[indexPath.row]
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as! PlaceCell
        let place = listPlaces[indexPath.row]
        
        // Configuramos los textos de las celdas
        if !place.name.isEmpty {
            cell.name.text = place.name
        }
      
        if !place.desc.isEmpty {
            // De la descripción solamente mostraremos los 100 primero caracteres
            let reducedDescripcion = place.desc.substringToIndex(place.desc.startIndex.advancedBy(100, limit: place.desc.endIndex))
            cell.desc.text = reducedDescripcion
        }
        
        // Configuramos la imagen inicial de la celda, que se mostrará mientras no se carga la imagen final, o si el sitio no tiene imagen
        cell.customImage.image = UIImage(named: "placeholder")
        
        // Si tenemos una imagen para el sitio iniciamos us descarga asíncrona mediende SDWebImage
        if let firstImage = place.images.first, thumbUrl = firstImage.thumbUrl {
            // Configuramos un indicador de actividad para que se muestre mientras se carga la imagen
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.center = CGPointMake(CGRectGetMidX(cell.customImage.bounds), CGRectGetMidY(cell.customImage.bounds))
            activityIndicator.hidesWhenStopped = true
            activityIndicator.color = UIColor.blackColor()
            cell.customImage.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            // En la imagen de la celda mostraremos la imagen reducida (thumbnail)
            // SDWebImage amplia la funcionalidad del UIImageView, entre otras cosas permite:
            //   - Configurar la descarga de imagenes en segundo plano a partir de una URL
            //   - Cache de las imágenes descargadas
            //   - Controlar la visibilidad del UIImageView para cancelar la descarga cuando ya no es visible. Esto evita el problema que
            //     algunas celdas muestren imágenes que no les corresponden porque cuando el proceso en segundo plano termina de descargar la
            //     imagen puede ser que la celda se hubiera reutilizado para mostrar otro de los sitios.
            let url = NSURL(string: thumbUrl)
            // Utilizamos SDWebImage para descargar la imagen en segundo plano directamente sobre el UIImageView de la celda
            cell.customImage.sd_setImageWithURL(url, placeholderImage: UIImage(named: "placeholder"), completed: { (image: UIImage!, error: NSError!, cache: SDImageCacheType, url: NSURL!) in
                // Al terminar la descarga de la imagen quitamos el indicador de actividad
                activityIndicator.removeFromSuperview()
            })
        }
        

        return cell
    }
    
    /**
     Lanzado por el table view para que le indiquemos si una celda es editables.
     En nuestro caso todas las celdas serán editables (para eliminar)
     */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    /**
     Lanzado por el table view para iniciar la operación de edición, en nuestro caso para eliminar sitios.
     */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deletePlace(listPlaces[indexPath.row])
            listPlaces.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    
    /**
     Elimina un sitio en Backendless
     */
    func deletePlace(place: Place) {
        // Eliminamos primero las imágenes y sus ficheros
        let dataStoreImages = backendless.data.of(PlaceImage.ofClass())
        
        Types.tryblock({
            for placeImage in place.images {
                if let fileUrl = placeImage.url {
                    self.deleteImageFile(fileUrl)
                }
                if let fileThumbUrl = placeImage.thumbUrl {
                    self.deleteImageFile(fileThumbUrl)
                }
                dataStoreImages.removeID(placeImage.objectId)
            }
            
            // Y finalmente el propio sitio
            let dataStore = self.backendless.data.of(Place.ofClass())
            
            dataStore.remove(place, response: { (i: NSNumber!) in
                print("Place deleted")
                }, error: { (fault: Fault!) in
                    print("Error: \(fault.description)")
            })
            }, catchblock: { (exception)->Void in
                let alertController = UIAlertController(title: "Error", message: "There was an error deleting your place", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
        })
    }

    
    /**
     Elimina una fichero de imagen de Backendless
     */
    func deleteImageFile(fileUrl: String) {
        let filePath = Util.getImagePathFromFileURL(fileUrl)
        self.backendless.fileService.remove(filePath)
    }


    /*
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
    */

    
    @IBAction func returnFromAddPlace(segue: UIStoryboardSegue) {
        loadPlaces();
    }
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    /**
     Función del protocolo PlaceManagerDelegate para crear un sitio
     */
    func createPlace(place: Place, placeImages: [PlaceImageWithData]) -> Bool {
        return createPlaceBackend(place, placeImages: placeImages)
    }
    
    /**
     Crea un sitio en backendless
     */
    func createPlaceBackend(place: Place, placeImages: [PlaceImageWithData]) -> Bool {
        var result = false
        
        let backendless = Backendless.sharedInstance()
        
        place.owner = backendless.userService.currentUser
        
        Types.tryblock({
            // Al tratarse de un sitio nuevo subiremos todas las imágenes
            for image in placeImages {
                let url = self.uploadImage(image.uiImage!)
                let thumbUrl = self.uploadImageThumbnail(image.uiImage!)
                
                let newImage = PlaceImage()
                newImage.url = url
                newImage.thumbUrl = thumbUrl
                
                place.images.append(newImage)
            }
            
            let dataStore = backendless.data.of(Place.ofClass())
            
            dataStore.save(place)
            
            result = true
            }, catchblock: { (exception)->Void in
                result = false
        })
        
        return result
    }
    
    /**
     Sube una imagen a Backendless y devuelve la url donde está publicada
     */
    func uploadImage(image: UIImage) -> String {
        let uId = NSUUID().UUIDString
        
        let path = "places/\(uId).jpg"
        return uploadImageFile(path, image: image)
    }
    
    /**
     Sube una imagen thumbnail a Backendless y devuelve la url donde está publicada
     */
    func uploadImageThumbnail(image: UIImage) -> String {
        let uId = NSUUID().UUIDString
        
        let path = "places/\(uId).thumb.jpg"
        let thumbImage = Util.createThumbnail(image)
        
        return uploadImageFile(path, image: thumbImage)
    }
    
    /**
     Sube un fichero de imagen a Backendless y devuelve la url donde está publicado
     */
    func uploadImageFile(path: String, image: UIImage) -> String {
        let data = UIImageJPEGRepresentation(image, 0.5)
        let file = self.backendless.fileService.upload(path, content: data)
        print("Uploaded image: \(file.fileURL)")
        return file.fileURL
    }
    
    /**
     Función del protocolo PlaceManagerDelegate para actualizar un sitio
     */
    func updatePlace(place: Place, placeImages: [PlaceImageWithData], deletedImages: [PlaceImageWithData]) -> Bool {
        return updatePlaceBackend(place, placeImages: placeImages, deletedImages: deletedImages)
    }
    
    /**
     Actualiza un sitio en el backend
     */
    func updatePlaceBackend(place: Place, placeImages: [PlaceImageWithData], deletedImages: [PlaceImageWithData]) -> Bool {
        var result = false
        
        let backendless = Backendless.sharedInstance()
        
        let dataStore = backendless.data.of(Place.ofClass())
        Types.tryblock({
            var remainingImages: [PlaceImage] = []
            
            for image in place.images {
                let r = deletedImages.filter({$0.image!.url == image.url})
                if r.count == 0 {
                    remainingImages.append(image)
                }
            }
            
            place.images = remainingImages
            
            // En un sitio actualizado las imágenes nuevas no tendran inicializado el objeto image
            for image in placeImages {
                if image.image == nil {
                    
                    // Subimos la imagen completa y el thumbnail
                    let url = self.uploadImage(image.uiImage!)
                    let thumbUrl = self.uploadImageThumbnail(image.uiImage!)
                    
                    let newImage = PlaceImage()
                    newImage.url = url
                    newImage.thumbUrl = thumbUrl
                    place.images.append(newImage)
                }
            }
            
            dataStore.save(place)
            
            result = true
            }, catchblock: { (exception)->Void in
                result = false
        })
        
        return result
    }



}