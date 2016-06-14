//
//  MyPlaces.swift
//  myapp
//
//  Created by Marc Callís Vilalta on 21/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation

class MyPlaces: UITableViewControllerOwn {
    
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
        
        configureTableView()
        // Get All Places
        getData()
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        
    }
    
    func configureTableView(){
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 250.0;
    }
    
    func getData(){
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
                if queryNumber == self.currentQueryNumber {
                    let alertController = UIAlertController(title: "Error", message: "An error has ocurred while fetching your places", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alertController.addAction(OKAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listPlaces.count
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        let currentPlace: Place = listPlaces[indexPath.row] 
        detailVC.currentPlace = currentPlace
                
        self.navigationController?.pushViewController(detailVC, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as! PlaceCell

        // Configure cell...
        setImageForCell(cell, indexPath: indexPath)
        setTitleForCell(cell, indexPath: indexPath)
        setDescForCell(cell, indexPath: indexPath)
        return cell
    }
    
    
    func setImageForCell(cell: PlaceCell, indexPath: NSIndexPath){
        let place = listPlaces[indexPath.row] 
        let image = UIImage(named: "no_image")
        
        if place.urlImage == nil {
            cell.customImage.image = image
        } else {
            downloadImage(NSURL(string: place.urlImage)!, imageView: cell.customImage)
        }
    }
    
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
    
    func setTitleForCell(cell: PlaceCell, indexPath: NSIndexPath){
        let place = listPlaces[indexPath.row] 
        cell.name.text = place.name
    }
    
    func setDescForCell(cell: PlaceCell, indexPath: NSIndexPath){
        let place = listPlaces[indexPath.row] 
        cell.desc.text = place.desc

    }
    
    @IBAction func returnFromAddPlace(segue: UIStoryboardSegue) {
       
    }
    
    func alertError(message: String){
        let alertController = UIAlertOwn(title: "Error", message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}