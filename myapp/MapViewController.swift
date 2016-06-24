//
//  MapViewController.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 20/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import SDWebImage

class MapViewController: UIViewControllerOwn, FilterManagerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var mapView: MKMapView!
  
    @IBOutlet weak var tableView: UITableView!
    
    var distance: Int = 40
    
    var listPlaces: [Place] = []
    
    // Instancia de backendless
    var backendless = Backendless.sharedInstance()
    // Tamaño de página para la consulta a Backendless
    let PAGESIZE = 5
    
    // Numero de consulta a Backendless, se utiliza para cancelar las peticiones asíncronas que estuvieran
    // pendientes cuando consulta de sitios
    var currentQueryNumber = 0
    
    var refreshControl: UIRefreshControl?
    
    // Este es el modelo de datos que editaremos en este controller
    var userLocation: CLLocation?

    
    let locationManager = CLLocationManager()
    var isUpdatingLocation: Bool = false
    var lastLocationError: NSError?
    var location: CLLocation?
    let regionRadius: CLLocationDistance = 5000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuramos el controll "Pull to refresh"
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(MapViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)

        
        self.mapView.hidden = false
        self.tableView.hidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.mapView.delegate = self
        
        self.userLocation = mapView.userLocation.location
        
        loadPlaces()
        
        setupMap()
        
        searchCurrentLocation()
        
        /*
        
        if userLocation != nil {
            // Si tenemos una ubicación configuramos el mapa
            setupMap()
        } else {
            searchCurrentLocation()
        }
 */
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Refresh control
    func refresh(sender: AnyObject) {
        loadPlaces()
    }

    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        switch (self.segmentedControl.selectedSegmentIndex)
        {
        case 0:
            self.mapView.hidden = false
            self.tableView.hidden = true
            break;
        case 1:
            self.mapView.hidden = false
            self.tableView.hidden = false
            break;
        default: 
            break; 
        }
    }
    
    func loadPlaces(){
        // Durante todo el proceso de carga mostraremos el indicador de actividad de red en la aplicación
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        startIndicator()
        
        currentQueryNumber += 1
        let queryNumber = currentQueryNumber
        
        let startTime = NSDate()
        let offset = 0
        /*
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // Consultaremos los stios junto con sus relaciones images y location
            let query = BackendlessDataQuery()
            query.queryOptions.pageSize = self.PAGESIZE
            query.queryOptions.related = ["images", "location", "owner", "reviews"]
            query.queryOptions.relationsDepth = 1
            //query.whereClause = "distance( \(latitude), \(longitude), location.latitude, location.longitude) <= km(10)"
            query.whereClause = "distance( \(self.userLocation!.coordinate.latitude), \(self.userLocation!.coordinate.longitude), location.latitude, location.longitude ) <= km(\(self.distance))"
            
            
            let places: BackendlessCollection = self.backendless.persistenceService.find(Place.ofClass(), dataQuery: query) as BackendlessCollection
            self.listPlaces = []
            self.listPlaces.appendContentsOf(places.getCurrentPage() as! [Place])
            self.tableView.reloadData()
            self.getPageAsync(places, offset: offset, queryNumber: queryNumber, startTime:startTime)
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.stopIndicator()
                if queryNumber == self.currentQueryNumber && self.listPlaces.count > 0 {
                    if self.listPlaces.count > 0{
                        let alertController = UIAlertController(title: "Error", message: "An error has ocurred while fetching your places", preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                        alertController.addAction(OKAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }

            }
        
        
        }*/
        
        Types.tryblock({ () -> Void in
            // Consultaremos los stios junto con sus relaciones images y location
            let query = BackendlessDataQuery()
            query.queryOptions.pageSize = self.PAGESIZE
            query.queryOptions.related = ["images", "location", "owner", "reviews"]
            query.queryOptions.relationsDepth = 1
            //query.whereClause = "distance( \(latitude), \(longitude), location.latitude, location.longitude) <= km(10)"
            if (self.userLocation != nil) {
                query.whereClause = "distance( \(self.userLocation!.coordinate.latitude), \(self.userLocation!.coordinate.longitude), location.latitude, location.longitude ) <= km(\(self.distance))"
            }
            
            
            
            let places: BackendlessCollection = self.backendless.persistenceService.find(Place.ofClass(), dataQuery: query) as BackendlessCollection
            self.listPlaces = []
            self.listPlaces.appendContentsOf(places.getCurrentPage() as! [Place])
            self.tableView.reloadData()
            self.getPageAsync(places, offset: offset, queryNumber: queryNumber, startTime:startTime)
            
        },
        catchblock: { (exception) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.stopIndicator()
            if queryNumber == self.currentQueryNumber && self.listPlaces.count > 0 {
                if self.listPlaces.count > 0{
                    let alertController = UIAlertController(title: "Error", message: "An error has ocurred while fetching your places", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
            }

        })
        
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
            self.stopIndicator()
            
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
                    self.setupMap()
                    self.addAnotationPlaces()
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
    

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToFilter" {
            let destinationVC = segue.destinationViewController as! FilterViewController
            destinationVC.delegate = self
            destinationVC.distance = self.distance
        } else if (segue.identifier == "segueToDetailPlace"){
            let controller = segue.destinationViewController as! DetailViewController
            if (sender?.ofClass() == Place.ofClass()) {
                controller.currentPlace = sender as! Place
            } else {
                let indexPath = sender as! NSIndexPath
                controller.currentPlace = listPlaces[indexPath.row]
            }
        }
    }
    
    func calculateWithNewDistance(dist: Int) {
        print("distance: \(self.distance)")
        if self.distance != dist {
            self.distance = dist
            loadPlaces()
        }
    }
    
    
    // Methods to TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listPlaces.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("segueToDetailPlace", sender: indexPath)
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as! PlaceCellRating
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
        
        if place.reviews.count > 0 {
            cell.fieldTotalReviews.text = "(\(place.reviews.count) reviews)"
        }
        
        if place.rating > 0 {
            cell.rateView.rating = Float(place.rating)
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
    
    
    // LOCATION METHODS
    
    /**
     Inicia la búsqueda de la posición del usuario.
     Si es necesario solicitará el permiso
     */
    func searchCurrentLocation() {
        // Pedimos autorización para usar la geolocalización si es necesario (a partir de iOS 7)
        if self.locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)) {
            let authStatus = CLLocationManager.authorizationStatus()
            if authStatus == .NotDetermined {
                locationManager.requestWhenInUseAuthorization()
                
                return
            }
            if authStatus == .Denied || authStatus == .Restricted {
                let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(okAction)
                presentViewController(alert, animated: true, completion: nil)
                
                return
            }
            
        }
        location = nil
        startLocationManager()
    }
    
    
    
    /**
     Inicia el proceso de obtención de la posición del usuario
     */
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
        }
        startIndicator()
    }
    
    /**
     Para el proceso de obtención de la posición del usuario
     */
    func stopLocationManager() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            isUpdatingLocation = false
        }
        stopIndicator()
    }
    
    
    
    /**
     Se llama cada vez que se obtiene la posición del usuario.
     Si todo va bien cada vez nos dará posiciones con más precisión, y cuando obtengamos la
     precisión deseada pararemos el proceso y configuraremos el mapa
     */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let newLocation = locations.last!
        
        print("didUpdateLocations \(newLocation)")
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
        }
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            print("Got the desired accuracy")
            stopLocationManager()
            if let location = location {
                userLocation = location
                
                loadPlaces()
                
                setupMap()
            }
            /*
             // TODO: show centered map
             let initialLocation = location
             centerMapOnLocation(initialLocation!)
             stopLocationManager()
             */
        }
    }
    
    
    /**
     Se llama si se produce un error al obtener la posición del usuario
     */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        if error.code == CLError.LocationUnknown.rawValue {
            // Este error se produce si el sistema no ha sido capaz de dar con la ubicación del usuario.
            // Pero va a seguir intentándolo, de momento no pararemos el proceso
            return
        }
        // Si se ha producido algún otro error entonces sí que paramos el proceso e informamos al
        lastLocationError = error
        alertError(lastLocationError.debugDescription)
        stopLocationManager()
    }
    
    

    // UTILS
    
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Map management, MKMapViewDelegate
    /**
     Configura el MapView centrándolo añadiendo un pin en la posición actual del sitio
     */
    func setupMap() {
        if let userLocation = userLocation {
            let myRegionRadius: CLLocationDistance = Double(self.distance)
            var region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, myRegionRadius * 2.0, myRegionRadius * 2.0)
            let latDelta:CLLocationDegrees = Double(self.distance) / 100
            let lonDelta:CLLocationDegrees = Double(self.distance) / 100
            region.span = MKCoordinateSpanMake(latDelta, lonDelta)
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
            mapView.delegate = self
            
            //let annotation = MKPointAnnotation()
            //annotation.coordinate = userLocation.coordinate
            //annotation.title = "you"
            
            //mapView.addAnnotation(annotation)
            
            
        }
    }
    
    func addAnotationPlaces(){
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        
        for place in listPlaces {
            let coordinate = CLLocationCoordinate2D(latitude: place.location!.latitude as CLLocationDegrees, longitude: place.location!.longitude as CLLocationDegrees)
            
            let annotation = PlaceAnnotation(idPlace: place.objectId, title: place.name, locationName: place.desc, coordinate: coordinate)
            
            mapView.addAnnotation(annotation)
        }
        
    }

    

    
    
}
